using Herb: RuleNode, AbstractGrammar, Hole
export
  Each,
  RandomPick,
  Spans

Base.:(==)(A::Hole, B::Hole) = A.domain == B.domain

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

find_size_except_holes(node::Hole) = 0
find_size_except_holes(node::RuleNode) = 1 + sum(map(find_size_except_holes, node.children))

"""Get the most useful subcomponents and how often they are used according to a min utility value between 0 and 1"""
function hash_common_subcomponents_pairwise(g::AbstractGrammar, nodes::Vector{RuleNode};
    min_utility = 0.0,
    min_size::Union{Int64, Nothing} = nothing,
)
    utilities = convert(Dict{RuleNode, Int64}, Dict())
    total_utility = 0
    for i in eachindex(nodes)
        for j in (i + 1):lastindex(nodes)
            node1 = nodes[i]
            node2 = nodes[j]
            handle_pair(n1, n2) = begin
                common = find_common_subtree_with_holes(g, n1, n2)

                if (!isnothing(common) && (isnothing(min_size) || min_size <= find_size_except_holes(common)))
                    c = get(utilities, common, 0)

                    utilities[common] = c + 1
                    total_utility += 1
                end
            end

            visit_rulenode(node1, (v1) -> visit_rulenode(node2, (v2) -> handle_pair(v1, v2)))
        end
    end

    return (total_utility, utilities)
end

"""Find the deepest subtree with holes that is common."""
function find_common_subtree_with_holes(g::AbstractGrammar, node1::RuleNode, node2::RuleNode)::Union{RuleNode, Nothing}
    if (node1.ind != node2.ind) return nothing end

    # shallow copy is intended
    common_tree = RuleNode(node1.ind, copy(node1.children))

    for (i, (n1c, n2c)) in enumerate(zip(node1.children, node2.children))
        if (g.types[n1c.ind] == g.types[n2c.ind])
            common_subtree = find_common_subtree_with_holes(g, n1c, n2c)
            if (isnothing(common_subtree))
                # this will make it become the type when rulenode2expr is used
                common_tree.children[i] = Hole([type == g.types[n1c.ind] for type in g.types])
            else
                # already cloned
                common_tree.children[i] = common_subtree
            end
        else
            return nothing
        end
    end

    return common_tree
end