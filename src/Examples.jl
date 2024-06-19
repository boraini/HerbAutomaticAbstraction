export Examples

module Examples
  include("../examples/util/Util.jl")
  include("../examples/ExtendGrammarExample.jl")
  include("../examples/ListExample.jl")
  include("../examples/stringBenchmark.jl")
  include("../examples/BitVectorBenchmark.jl")
  
  export
    Lisp,
    extendGrammarExample,
    listExample,
    string2020,
    stringBenchmark,
    splitExample,
    UFPhase1,
    UFPhase1
end