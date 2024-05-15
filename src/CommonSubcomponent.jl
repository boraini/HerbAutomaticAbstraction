using Herb: RuleNode

function visit_rulenode(n::RuleNode, f)
    f(n)
    for c in n.children visit_rulenode(c, f) end
end

function find_all_subcomponents(n::RuleNode)
    found = []
    visit_rulenode(n, v -> push!(found, v))
    return found
end

function find_common_subcomponents_of_pair(n1::RuleNode, n2::RuleNode)
    found = []
    visit_rulenode(n1, (v1) -> visit_rulenode(n2, (v2) -> if (v1 == v2) push!(found, v1) end))
end

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

"""get the most useful subcomponents and how often they are used according to a min utility value between 0 and 1"""
function hash_common_subcomponents(nodes::Vector{RuleNode}, low = 1, high = length(nodes); min_utility = 0.0)
    if high - low <= 0
        # each subcomponent will exist once
        subcomponents = find_all_subcomponents(nodes[low])
        return (length(subcomponents), Dict(map(sc -> (sc, 1), subcomponents)))
    else
        mid = (low + high) ÷ 2
        c1, h1 = hash_common_subcomponents(nodes, low, mid)
        c2, h2 = hash_common_subcomponents(nodes, mid + 1, high)
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
