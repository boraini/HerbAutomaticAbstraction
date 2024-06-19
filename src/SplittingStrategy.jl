using HerbSpecification

export
    Each,
    RandomPick,
    Spans,
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