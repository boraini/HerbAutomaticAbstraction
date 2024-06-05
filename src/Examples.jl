export Examples

module Examples
  include("../examples/Lisp.jl")
  include("../examples/HammingDistance.jl")
  include("../examples/ExtendGrammarExample.jl")
  include("../examples/ListExample.jl")
  include("../examples/stringBenchmark.jl")
  
  export
    Lisp,
    extendGrammarExample,
    listExample,
    stringBenchmark
end