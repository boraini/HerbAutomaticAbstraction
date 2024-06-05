using BenchmarkTools
using HerbBenchmarks.PBE_SLIA_Track_2019
using HerbConstraints
using HerbSpecification
using HerbSearch
using HerbInterpret

function solve(g, start_symbol, problems::Vector{Problem})
    iterator = BFSIterator(g, :ntString, max_depth=5)
    
    programs = synth_multiple(problems, iterator, allow_evaluation_errors=true, mod=PBE_SLIA_Track_2019)

    return programs
end

function stringBenchmark()
    g = @csgrammar begin
        Start = ntString
        ntString = _arg_1
        # ntString = ""
        ntStringDelim = " "
        ntStringDelim = "."
        ntStringDelim = "-"
        ntStringDelim = "/"
        ntStringDelim = "= "
        ntString = substr_cvc(ntString, ntInt, ntInt)
        # ntString = concat_cvc(ntString, ntString)
        # ntString = replace_cvc(ntString, ntString, ntString)
        # ntString = at_cvc(ntString, ntInt)
        # ntString = int_to_str_cvc(ntInt)
        ntInt = -1
        ntInt = 0
        ntInt = 1
        ntInt = 2
        # ntInt = 1
        ntInt = ntInt + ntInt
        # ntInt = ntInt - ntInt
        ntInt = len_cvc(ntString)
        # ntInt = str_to_int_cvc(ntString)
        # ntInt = ntBool ? ntInt : ntInt
        ntInt = indexof_cvc(ntString, ntStringDelim, ntInt)
        ntString = ntBool ? ntString : ntString
        ntBool = true
        ntBool = false
        ntBool = ntInt == ntInt
        # ntBool = prefixof_cvc(ntString, ntString)
        # ntBool = suffixof_cvc(ntString, ntString)
        ntBool = contains_cvc(ntString, ntStringDelim)
        # ntInt = val2
        # ntInt = val3
        ntStringDelim = ntString # this is just short circuited somehow
    end

    ruleid_substr = 8
    ruleid_plus = 13

    # do not chain substr_cvc
    # addconstraint!(g, Forbidden(
    #     RuleNode(5, [
    #         RuleNode(5, [RuleNode(5, [
    #             RuleNode(5, [RuleNode(5, [
    #                 RuleNode(5, [VarNode(:a), VarNode(:b), VarNode(:c)])
    #                 VarNode(:d)
    #                 VarNode(:e)
    #             ]), VarNode(:f), VarNode(:g)])
    #             VarNode(:h)
    #             VarNode(:i)
    #         ]), VarNode(:j), VarNode(:k)])
    #         VarNode(:l)
    #         VarNode(:m)
    #     ])
    # ))

    # do not chain substr_cvc
    addconstraint!(g, Forbidden(
        RuleNode(ruleid_substr, [
            RuleNode(ruleid_substr, [VarNode(:a), VarNode(:b), VarNode(:c)])
            VarNode(:d)
            VarNode(:e)
        ])
    ))

    # addconstraint!(g, ForbiddenSequence([ruleid_substr, ruleid_substr])) # do not nest substr_cvc
    addconstraint!(g, ForbiddenSequence([ruleid_plus, ruleid_plus])) # do not chain (+)

    iterator_to_use = BFSIterator(g, :ntString, max_depth=5)
    iterator_init_state = deepcopy(iterator_to_use.solver.state)

    problems = [
        # PBE_SLIA_Track_2019.problem_36462127,
        PBE_SLIA_Track_2019.problem_exceljet3,
        PBE_SLIA_Track_2019.problem_11604909, # substr_cvc(_arg_1, -1 + indexof_cvc(_arg_1, ".", 2), indexof_cvc(_arg_1, ".", 1) + 1)
        PBE_SLIA_Track_2019.problem_exceljet4 # substr_cvc(_arg_1, indexof_cvc(_arg_1, "/", -1) + 2, len_cvc(_arg_1))
    ]

    (examples, splitting_strategy) = make_spans_strategy(problems)

    printstyled("Extending grammar...\n"; color = :orange)

    new_g = extend_grammar(examples, g, :ntString;
        iterator_provider=_ -> iterator_to_use,
        splitting_strategy,
        min_utility=0.3,
        min_size=4,
        mod=PBE_SLIA_Track_2019,
        in_place=false
    )

    iterator_to_use.solver.state = deepcopy(iterator_init_state)

    printstyled("Trying with the new grammar...\n"; color = :lime)

    solve(new_g, :ntString, convert(Vector{Problem}, problems))

    iterator_to_use.solver.state = deepcopy(iterator_init_state)

    # TODO: delete this

    # val = substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1))

    # val2 = substr_cvc(val, indexof_cvc(val, " ", 0) + 1, length_cvc(val))

    # val3 = substr_cvc(val2, 0, indexof_cvc(val2, " ", 0))

    # result = substr_cvc(substr_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1)), indexof_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1)), " ", 0) + 1, length_cvc(val)), 0, indexof_cvc(substr_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1)), indexof_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1)), " ", 0) + 1, length_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 0) + 1, length_cvc(_arg_1)))), " ", 0))


    # val = indexof_cvc(_arg_1, " ", 0)
    
    # val2 = indexof_cvc(_arg_1, " ", val + 1)

    # val3 = indexof_cvc(_arg_1, " ", val2 + 1)

    # result = substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", indexof_cvc(_arg_1, " ", 0) + 1), indexof_cvc(_arg_1, " ", indexof_cvc(_arg_1, " ", 0) + 1) - 1)

    # program3 = @time solve(g, :ntString, PBE_SLIA_Track_2019.problem_36462127)

    # program4 = @time solve(g, :ntString, PBE_SLIA_Track_2019.problem_exceljet4)

    # program1 = @time solve(g, :ntString, PBE_SLIA_Track_2019.problem_11604909)

    # program2 = @time solve(g, :ntString, PBE_SLIA_Track_2019.problem_31753108)

    # # hand-written solution for problem_11604909
    # program = :(substr_cvc(_arg_1, -1 + indexof_cvc(_arg_1, ".", 0), 1 + indexof_cvc(_arg_1, ".", 0)))
    # # depth = 3

    # solutions = solve(
    #     g,
    #     :ntString,
    #     convert(Vector{Problem}, [
    #         # PBE_SLIA_Track_2019.problem_36462127,
    #         PBE_SLIA_Track_2019.problem_exceljet3,
    #         PBE_SLIA_Track_2019.problem_11604909, # substr_cvc(_arg_1, -1 + indexof_cvc(_arg_1, ".", 2), indexof_cvc(_arg_1, ".", 1) + 1)
    #         PBE_SLIA_Track_2019.problem_exceljet4 # substr_cvc(_arg_1, indexof_cvc(_arg_1, "/", -1) + 2, len_cvc(_arg_1))
    #     ])
    # )
    
    # problem_44789427 = Problem("problem_44789427", [
	# IOExample(Dict{Symbol, Any}(:_arg_1 => "1/17/16-1/18/17"), "1/17/16"), 
	# IOExample(Dict{Symbol, Any}(:_arg_1 => "01/17/2016-01/18/2017"), "01/17/2016")])

    # program4 = @time solve(g, :ntString, problem_44789427)

    # problem_44789427_2 = Problem("problem_44789427", [
	# IOExample(Dict{Symbol, Any}(:_arg_1 => "256.4401"), "256"), 
	# IOExample(Dict{Symbol, Any}(:_arg_1 => "519.63"), "519")])

    # program5 = @time solve(g, :ntString, problem_44789427_2)

    # program = :(substr_cvc(_arg_1, 1, indexof_cvc(_arg_1, "-", 1) + -1))
    # println(HerbInterpret.execute_on_input(SymbolTable(g), program, Dict(:_arg_1 => "01/17/2016-01/18/2017")))

    # program = :(substr_cvc(substr_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)), indexof_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)), " ", 0) + 1, len_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)))), 1, indexof_cvc(substr_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)), indexof_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)), " ", 0) + 1, len_cvc(substr_cvc(_arg_1, indexof_cvc(_arg_1, " ", 1 + 1) + 1, len_cvc(_arg_1)))), " ", 0)))
    # println(HerbInterpret.execute_on_input(SymbolTable(g), program, Dict(:_arg_1 => " Air conditioner GHF211 maintenance")))
    # println(HerbSearch.evaluate(PBE_SLIA_Track_2019.problem_31753108, program, SymbolTable(g)))

    # subprogram for finding the third word
    # requires 9319 iterations
    # problem3 = Problem([
    #     IOExample(Dict(:val2 => 11, :val3 => 16, :_arg_1 => "ice pikmin rock solid"), "rock"),
    #     IOExample(Dict(:val2 => 12, :val3 => 15, :_arg_1 => "hello world no yes"), "no"),
    #     IOExample(Dict(:val2 => 4, :val3 => 6, :_arg_1 => "a b c d"), "c")
    # ])
    # program3 = @time solve(g, problem3)

    # subprogram for finding the next space character

    # problem4 = Problem([
    #     IOExample(Dict(:val2 => 4, :val3 => 999, :_arg_1 => "ice pikmin rock solid"), 12),
    #     IOExample(Dict(:val2 => 6, :val3 => 999, :_arg_1 => "hello world no yes"), 11),
    #     IOExample(Dict(:val2 => 2, :val3 => 999, :_arg_1 => "a b c d"), 3)
    # ])
    # program4 = @time solve(g, :ntInt, problem4)


    # println(HerbSearch.evaluate(problem4, :(indexof_cvc(_arg_1, " ", val2 + 1)), SymbolTable(g)))
end