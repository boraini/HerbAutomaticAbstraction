using HerbGrammar: rulenode2expr, add_rule!
using HerbSpecification
using HerbSearch: synth, ProgramIterator, BFSIterator

export
    extend_grammar,
    find_extensions,
    choose_extensions,
    compute_utilities

"""Replace nothing values of an union with some default value."""
default(val, def) = isnothing(val) ? def : val

"""Run a divide-and-conquer algorithm on the examples to find common parts produced for them.

  - `iterator_provider`: a function which takes a vector of examples and returns a program iterator for solving the subproblems.
  - `min_utility`: min number of occurrences of a subprogram out of all in order to not filter it out during the merge phase
  - `min_size`: minimum size of subprograms to include (using the length(rule_node) function)
  - `with_holes`: if the found subprograms are able to include holes
  - `splitting_strategy`: an instance of `ProblemSplittingStrategy` which will be used to split the provided examples
"""
function find_extensions(problems::Vector{Problem}, g::AbstractGrammar, sym::Symbol;
    iterator_provider::Function,
    min_size::Int64=nothing,
    max_enumerations::Union{Int64, Nothing}=nothing,
    with_holes=false,
    concurrent=true,
    mod=Main
    )::Tuple{Int64, Dict{RuleNode, Int64}}
    
    solutions = if concurrent
        println("concurrent")
        synth_multiple(problems, iterator_provider(problems[1].spec); allow_evaluation_errors=true, max_enumerations=default(max_enumerations, typemax(Int)), print_iteration=false, mod)
    else
        println("one by one")
        temp = []
        for (problemid, p) in enumerate(problems)
            println("solving $(problemid)")
            push!(temp, synth(p, iterator_provider(p.spec); allow_evaluation_errors=true, max_enumerations=default(max_enumerations, typemax(Int)), mod))
        end
        temp
    end

    programs = map(p -> p[1], filter(p -> !isnothing(p), solutions))

    return hash_common_subcomponents_pairwise(g, programs; min_size, with_holes)
end

function compute_utilities(total_frequency, utilities, utility_function::Function)
    total_utility = 0

    for program in keys(utilities)
        new_utility = utility_function(program, utilities[program], total_frequency)
        total_utility += new_utility
        utilities[program] = new_utility
    end

    return (total_utility, utilities)
end

last_common_parts::Union{Dict{RuleNode, Int64}, Nothing} = nothing
"""
Choose extensions to actually add to the grammar.
"""
function choose_extensions(count::Int64, usages::Dict{RuleNode, Int64};
    min_utility=0.0,
    max_new_rules::Int64=length(usages)
    )::Vector{RuleNode}

    global last_common_parts

    last_common_parts = usages

    threshold = min_utility * count

    println("threshold is $(threshold)")

    rules_to_use = RuleNode[]

    for (rn, c) in pairs(usages)
        c = usages[rn]
        if usages[rn] >= threshold
            push!(rules_to_use, rn)
        else
            count = count - c
        end
    end

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
 - `with_holes`: if the found subprograms are able to include holes
 - `splitting_strategy`: an instance of `ProblemSplittingStrategy` which will be used to split the provided examples
 - `max_new_rules`: if you want to limit the new rules being added. More often used and larger rules are prioritized.
 - `in_place`: whether you want the original grammar object to be modified instead of a copy of it."""
function extend_grammar(problems::Vector{Problem}, g::AbstractGrammar, sym::Symbol;
    iterator_provider::Function,
    utility_function::Function=frequency_as_utility,
    min_utility=0.0,
    min_size::Int64=nothing,
    max_enumerations::Union{Int64, Nothing}=nothing,
    with_holes=false,
    max_new_rules::Union{Int64, Nothing}=nothing,
    in_place=false,
    concurrent=true,
    mod=Main
    )::AbstractGrammar

    (total_frequency, usages) = find_extensions(problems, g, sym;
        iterator_provider,
        min_size,
        with_holes,
        max_enumerations,
        concurrent,
        mod,
    )

    (total_usages, usages) = compute_utilities(total_frequency, usages, utility_function)

    new_g = if (in_place) g else deepcopy(g) end

    rules_added = 0

    rules_to_use = choose_extensions(total_usages, usages; min_utility, max_new_rules=default(max_new_rules, length(usages)))

    for ruleNode in rules_to_use
        rules_added = rules_added + 1
        if (!isnothing(max_new_rules) && rules_added == max_new_rules) break end
        new_rule_type = g.types[ruleNode.ind]
        new_rule_expr = rulenode2expr(ruleNode, g)
        new_rule = Expr(:(=), new_rule_type, new_rule_expr)
        print(usages[ruleNode])
        print("\t")
        println(new_rule)
        add_rule!(new_g, new_rule)
    end

    return new_g
end

function extend_grammar(examples::Vector{IOExample}, g::AbstractGrammar, sym::Symbol;
    splitting_strategy=RandomPick(length(examples) ÷ 3, nothing),
    kwargs...
    )
    problems = convert(Vector{Problem}, map(Problem, split_examples(examples, splitting_strategy)))

    return extend_grammar(problems, g, sym; kwargs...)
end