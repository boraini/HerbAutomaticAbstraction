using HerbGrammar, HerbSpecification, HerbSearch, HerbInterpret

using HerbAutomaticAbstraction

function listExample()
    g = @cfgrammar begin
        Number = |(2:3)
        Number = Number * Head
        Head = List[0] # head
        List = x
        List = ((x, y) -> [x, y...])(Number, List) # cons
        List = ((x) -> x[1:(lastindex(x))])(List) # tail
        List = [] # nil
    end

    examples = [
        IOExample(Dict(:x => [2, 4, 10]), 12),
        IOExample(Dict(:x => [3, 5, 8]), 15),
        IOExample(Dict(:x => [2, 3, 4]), 9),

        IOExample(Dict(:x => [2, 4, 10]), 8),
        IOExample(Dict(:x => [3, 5, 8]), 10),
        IOExample(Dict(:x => [2, 3, 4]), 6)
    ]

    iterator_provider = problem -> DFSIterator(g, :Number, max_depth = 5)

    """for prog in iterator_provider(nothing)
        println(rulenode2expr(prog, g))
    end"""

    extend_grammar(examples, g, :Number, iterator_provider=iterator_provider, splitting_strategy=Spans([3, 3]), min_utility=0.1)
end