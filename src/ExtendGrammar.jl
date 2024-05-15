using HerbGrammar: AbstractGrammar, rulenode2expr
using HerbSpecification
using HerbSearch: synth, ProgramIterator, BFSIterator
using StatsBase: sample

abstract type ProblemSplittingStrategy end

"""Draw random subsets of problems."""
struct RandomPick <: ProblemSplittingStrategy
    length::Int64
    max::Union{Int64, Nothing}
end

"""Handle each example as a separate problem. Probably will always lead to overfitting the way it is implemented currently."""
struct Each <: ProblemSplittingStrategy end

"""If the counts list is [2, 3], take the first two items as one subproblem, and the next three as another. Works similar for other counts lists."""
struct Spans <: ProblemSplittingStrategy
    counts::Vector{Int64}
end

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
        print("Task: ")
        println(task)
        push!(result, task)
        current_start = current_end
    end
    return result
end

function extend_grammar(examples::Vector{IOExample}, g::AbstractGrammar, sym::Symbol;
    iterator_provider::Function,
    min_utility=0.0,
    max_new_rules=nothing,
    splitting_strategy=RandomPick(length(examples) ÷ 3, nothing)
    )
    problems = split_examples(examples, splitting_strategy)
    len_problems = length(problems)
    println("$len_problems problems to be solved.")
    programs = map(function(p) 
      println("Solving problem...")
      iterator = iterator_provider(p)
      solution, _ = synth(Problem(p), iterator, allow_evaluation_errors=true)
      println(rulenode2expr(solution, g))
      return solution
    end, problems)
    (my_count, usages) = hash_common_subcomponents(programs; min_utility=min_utility)
    for prog in keys(usages)
        print(usages[prog])
        print(" times ")
        println(rulenode2expr(prog, g))
    end
end
