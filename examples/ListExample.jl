using HerbGrammar, HerbSpecification, HerbSearch, HerbInterpret

using HerbAutomaticAbstraction

function listExample()
    g = @cfgrammar begin
        Number = |(2:3) # 0 1
        Number = times(Number, Head) # 2
        Head = head(List) # 3
        List = x # 4 # input is expected to be a list for this example
        List = cons(Number, List) # 5
        List = tail(List) # 6
        List = nil() # 7
        List = cons(Head, List) # 8
    end

    println(rulenode2expr(Hole([false, false, false, true, true, true, true, true]), g))
    
    examples = [
        IOExample(Dict(:x => [2, 4, 10]), 12), # triple the second element
        IOExample(Dict(:x => [3, 5, 8]), 15),
        IOExample(Dict(:x => [2, 3, 4]), 9),

        IOExample(Dict(:x => [2, 4, 10]), 8), # double the second element
        IOExample(Dict(:x => [3, 5, 8]), 10),
        IOExample(Dict(:x => [2, 3, 4]), 6)
    ]

    iterator_to_use = DFSIterator(g, :Number, max_depth = 5)
    iterator_init_state = deepcopy(iterator_to_use.solver.state)

    new_g = extend_grammar(examples, g, :Number; # expect to find head(tail(x)) as an extension
        iterator_provider=_ -> iterator_to_use,
        splitting_strategy=Spans([3, 3]),
        min_utility=0.3,
        min_size=2,
        mod=Lisp,
    )

    iterator_to_use.solver.state = deepcopy(iterator_init_state)

    examples = [
        IOExample(Dict(:x => [2, 4, 10]), [2, 4]), # double the second element
        IOExample(Dict(:x => [3, 5, 8]), [3, 5]),
        IOExample(Dict(:x => [2, 3, 4]), [2, 3])
    ]

    iterator = BFSIterator(new_g, :List, max_depth = 3)
    
    final_program, result = synth(Problem(examples), iterator, allow_evaluation_errors=true, mod=Lisp)

    iterator_to_use.solver.state = deepcopy(iterator_init_state)

    println(rulenode2expr(final_program, new_g))
end