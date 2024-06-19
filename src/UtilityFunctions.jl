using HerbGrammar: RuleNode, depth

export
  length_as_utility_larger_better,
  length_as_utility_smaller_better,
  frequency_as_utility,
  depth_as_utility_deeper_better,
  depth_as_utility_shallower_better,
  number_of_holes_as_utility

frequency_as_utility(::RuleNode, frequency::Int64, ::Int64) = frequency

# TODO: maybe use a better function for reverse methods
length_as_utility_larger_better(node::RuleNode, ::Int64, ::Int64) = find_size_except_holes(node)
length_as_utility_smaller_better(node::RuleNode, ::Int64, ::Int64) = max(1, div(1000, find_size_except_holes(node)))

depth_as_utility_deeper_better(node::RuleNode, ::Int64, ::Int64) = depth(node)
depth_as_utility_shallower_better(node::RuleNode, ::Int64, ::Int64) = max(1, div(1000, depth(node)))

number_of_holes_as_utility(node::RuleNode, ::Int64, ::Int64) = number_of_holes(node)