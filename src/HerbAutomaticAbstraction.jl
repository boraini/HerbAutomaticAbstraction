module HerbAutomaticAbstraction

include("CommonSubcomponent.jl")
include("ExtendGrammar.jl")
include("Examples.jl")

export
  extend_grammar,
  Each,
  RandomPick,
  Spans,
  Examples
end