using HerbGrammar: AbstractGrammar, rulenode2expr, add_rule!
using HerbSpecification
using HerbSearch: synth, ProgramIterator, BFSIterator
using StatsBase: sample

export
    extend_grammar,
    find_extensions,
    choose_extensions,
    make_spans_strategy

abstract type ProblemSplittingStrategy end

"""Draw random subsets of problems."""
struct RandomPick <: ProblemSplittingStrategy
    length::Int64
    max::Union{Int64, Nothing}
end

"""Handle each example as a separate problem. Probably will always lead to overfitting the way it is implemented currently."""
struct Each <: ProblemSplittingStrategy end

"""
The recommended way of obtaining this, if possible, is to use the `make_spans_strategy(problems)` method.

If the counts list is [2, 3], take the first two items as one subproblem, and the next three as another. Works similar for other counts lists.
"""
struct Spans <: ProblemSplittingStrategy
    counts::Vector{Int64}
end

"""
Returns the concatenated array of IOExamples and the Spans splitting strategy description.
"""
make_spans_strategy(problems::Vector{Problem{Vector{IOExample}}})::Tuple{Vector{IOExample}, Spans} =
    (reduce(vcat, map(p -> p.spec, problems)), Spans(reduce(vcat, map(p -> length(p.spec), problems))))

function split_examples(examples::Vector{IOExample}, _::Each)
    return map(examples, e -> [e])
end

function split_examples(examples::Vector{IOExample}, random_pick::RandomPick)
    return [sample(examples, random_pick.length; replace=false) for _ in range(length=if (random_pick.max == nothing) length(examples) else random_pick.max end)]
end

function split_examples(examples::Vector{IOExample}, spans::Spans)
    result = []
    current_start = 1
    current_end = 1
    for count in spans.counts
        current_end = current_start + count
        task = examples[current_start:(current_end - 1)]
        push!(result, task)
        current_start = current_end
    end
    return result
end

"""Run a divide-and-conquer algorithm on the examples to find common parts produced for them.

  - `iterator_provider`: a function which takes a vector of examples and returns a program iterator for solving the subproblems.
  - `min_utility`: min number of occurrences of a subprogram out of all in order to not filter it out during the merge phase
  - `min_size`: minimum size of subprograms to include (using the length(rule_node) function)
  - `splitting_strategy`: an instance of `ProblemSplittingStrategy` which will be used to split the provided examples
"""
function find_extensions(examples::Vector{IOExample}, g::AbstractGrammar, sym::Symbol;
    iterator_provider::Function,
    min_utility=0.0,
    min_size::Int64=nothing,
    max_enumerations::Int64=nothing,
    splitting_strategy=RandomPick(length(examples) ÷ 3, nothing),
    mod=Main
    )::Tuple{Int64, Dict{RuleNode, Int64}}
    problems = convert(Vector{Problem}, map(Problem, split_examples(examples, splitting_strategy)))
    # len_problems = length(problems)
    # println("$len_problems problems to be solved.")
    """programs = map(function(p) 
      # println("Solving problem...")
      iterator = iterator_provider(p)
      solution, _ = synth(Problem(p), iterator, allow_evaluation_errors=true, mod=mod)
      # println(rulenode2expr(solution, g))
      return solution
    end, problems)"""

    solutions = synth_multiple(problems, iterator_provider(problems[1].spec); allow_evaluation_errors=true, max_enumerations, mod)

    programs = map(p -> p[1], filter(p -> !isnothing(p), solutions))

    # return hash_common_subcomponents(programs; min_utility=min_utility, min_size=min_size)
    return hash_common_subcomponents_pairwise(g, programs; min_utility=min_utility, min_size=min_size)
end

"""
Choose extensions to actually add to the grammar.
"""
function choose_extensions(count::Int64, usages::Dict{RuleNode, Int64};
    min_utility=0.0,
    max_new_rules=length(usages)
    )::Vector{RuleNode}

    threshold = min_utility * count

    println("threshold is $(threshold)")

    filtered = filter(((n, c),) ->
          if (c < threshold)
            count = count - c
            false
          else
            true
          end
        , usages)

    rules_to_use = collect(keys(filtered))

    println(rules_to_use)

    sort!(rules_to_use; by=(k -> usages[k]), rev=true)

    if length(rules_to_use) > max_new_rules
        return rules_to_use[1:max_new_rules]
    else
        return rules_to_use
    end
end

"""Produce a new grammar which can be used to synthesize new programs with a lesser search depth than before.

 - `iterator_provider`: a function which takes a vector of examples and returns a program iterator for solving the subproblems.
 - `min_utility`: min number of occurrences of a subprogram out of all in order to not filter it out during the merge phase
 - `min_size`: minimum size of subprograms to include (using the length(rule_node) function)
 - `splitting_strategy`: an instance of `ProblemSplittingStrategy` which will be used to split the provided examples
 - `max_new_rules`: if you want to limit the new rules being added. More often used and larger rules are prioritized.
 - `in_place`: whether you want the original grammar object to be modified instead of a copy of it."""
function extend_grammar(examples::Vector{IOExample}, g::AbstractGrammar, sym::Symbol;
    iterator_provider::Function,
    min_utility=0.0,
    min_size::Int64=nothing,
    max_enumerations::Int64=nothing,
    splitting_strategy=RandomPick(length(examples) ÷ 3, nothing),
    max_new_rules::Union{Int64, Nothing}=nothing,
    in_place=false,
    mod=Main
    )::AbstractGrammar

    (total_usages, usages) = find_extensions(examples, g, sym;
        iterator_provider,
        min_utility,
        min_size,
        splitting_strategy,
        max_enumerations,
        mod,
    )

    new_g = if (in_place) g else deepcopy(g) end

    rules_added = 0

    rules_to_use = choose_extensions(total_usages, usages; min_utility, max_new_rules)

    for ruleNode in rules_to_use
        rules_added = rules_added + 1
        if (!isnothing(max_new_rules) && rules_added == max_new_rules) break end
        new_rule_type = g.types[ruleNode.ind]
        new_rule_expr = rulenode2expr(ruleNode, g)
        new_rule = Expr(:(=), new_rule_type, new_rule_expr)
        add_rule!(new_g, new_rule)
    end

    return new_g
end