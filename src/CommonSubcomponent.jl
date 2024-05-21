using Herb: RuleNode

"""Call a function on each subprogram."""
function visit_rulenode(n::RuleNode, f::Function)
    f(n)
    for c in n.children visit_rulenode(c, f) end
end

""""Return a vector of rulenodes recursively, in depth-first order. Rejecting nodes less than a size is possible."""
function find_all_subcomponents(n::RuleNode; min_size::Int64=nothing)::Vector{RuleNode}
    found = []
    if (isnothing(min_size))
        visit_rulenode(n, v -> push!(found, v))
    else
        visit_rulenode(n, v::RuleNode -> if (length(v) > min_size) push!(found, v) end)
    end
    return found
end

"""Run a O(n^2) algorithm to find the common subparts of two programs. It won't produce results with holes in them."""
function find_common_subcomponents_of_pair(n1::RuleNode, n2::RuleNode)
    found = []
    visit_rulenode(n1, (v1) -> visit_rulenode(n2, (v2) -> if (v1 == v2) push!(found, v1) end))
end

"""Run a divide-and-conquer algorithm in order to find common subprograms in a list. No filtering is performed."""
function find_common_subcomponents_of_list(nodes::Vector{RuleNode}, low = 1, high = length(nodes))
    if high - low <= 0
        return find_all_subcomponents(nodes[low])
    elseif high - low == 1
        return find_common_subcomponents_of_pair(nodes[low], nodes[high])
    else
        mid = (low + high) ÷ 2
        s1 = find_common_subcomponents_of_list(nodes, low, mid)
        s2 = find_common_subcomponents_of_list(nodes, mid + 1, high)
        return intersect!(s1, s2)
    end
end

"""Get the most useful subcomponents and how often they are used according to a min utility value between 0 and 1"""
function hash_common_subcomponents(nodes::Vector{RuleNode}, low = 1, high = length(nodes);
    min_utility = 0.0,
    min_size::Int64 = nothing,
)
    if high - low <= 0
        # each subcomponent will exist once
        subcomponents = find_all_subcomponents(nodes[low], min_size=min_size)
        return (length(subcomponents), Dict(map(sc -> (sc, 1), subcomponents)))
    else
        mid = (low + high) ÷ 2
        c1, h1 = hash_common_subcomponents(nodes, low, mid, min_utility=min_utility, min_size=min_size)
        c2, h2 = hash_common_subcomponents(nodes, mid + 1, high, min_utility=min_utility, min_size=min_size)
        count = c1 + c2
        h = mergewith(+, h1, h2)
        threshold = min_utility * count
        # modify count while filtering so min_utility works
        filtered = filter(((n, c),) ->
          if (c < threshold)
            count = count - c
            false
          else
            true
          end
        , h)
        return (count, Dict(filtered))
    end
end
