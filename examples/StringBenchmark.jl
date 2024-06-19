using HerbBenchmarks.String_transformations_2020
using HerbConstraints
using HerbSpecification
using HerbSearch
using HerbInterpret
using HerbBenchmarks

string_benchmark_before_iterator_id = generate_iterator_id()
string_benchmark_after_iterator_id = generate_iterator_id()

function stringBenchmark()
    g = sygus_2019_grammar

    problems = convert(Vector{Problem}, HerbBenchmarks.all_problems(PBE_SLIA_Track_2019))

    printstyled("Extending grammar...\n"; color = :orange)

    iterator_provider(::Any) = reset_iterator(string_benchmark_before_iterator_id, BFSIterator(g, :Start; max_depth=15))

    new_g = extend_grammar(problems, g, :ntString;
        iterator_provider,
        utility_function=number_of_holes_as_utility,
        min_utility=0,
        min_size=4,
        max_new_rules=4,
        max_enumerations=1_000_000,
        concurrent=true,
        in_place=false,
        with_holes=true,
        mod=PBE_SLIA_Track_2019,
    )

    printstyled("Trying with the new grammar...\n"; color = :lime)

    iterator = BFSIterator(new_g, :ntString; max_depth=8)
    
    programs = synth_multiple(problems, iterator, allow_evaluation_errors=true, max_enumerations=10_000_000, mod=PBE_SLIA_Track_2019)

    # TODO: delete this
    
    # problems = convert(Vector{Problem}, [
    #     PBE_SLIA_Track_2019.problem_34801680,
    #     PBE_SLIA_Track_2019.problem_exceljet3,
    #     PBE_SLIA_Track_2019.problem_stackoverflow6,
    #     PBE_SLIA_Track_2019.problem_phone_5_short,
    #     PBE_SLIA_Track_2019.problem_28627624_1,
    #     PBE_SLIA_Track_2019.problem_get_first_name_from_name,
    #     PBE_SLIA_Track_2019.problem_get_first_word,
    #     PBE_SLIA_Track_2019.problem_remove_file_extension_from_filename 
    # ])

    # problems = [
    #     # PBE_SLIA_Track_2019.problem_36462127,
    #     #PBE_SLIA_Track_2019.problem_extract_text_between_parentheses,
    #     PBE_SLIA_Track_2019.problem_extract_word_that_begins_with_specific_character,
    #     PBE_SLIA_Track_2019.problem_get_first_name_from_name_with_comma,
    #     PBE_SLIA_Track_2019.problem_stackoverflow11,
    #     PBE_SLIA_Track_2019.problem_replace_one_character_with_another,

    #     # original working problems
    #     PBE_SLIA_Track_2019.problem_exceljet3,
    #     PBE_SLIA_Track_2019.problem_11604909, # substr_cvc(_arg_1, -1 + indexof_cvc(_arg_1, ".", 2), indexof_cvc(_arg_1, ".", 1) + 1)
    #     PBE_SLIA_Track_2019.problem_exceljet4, # substr_cvc(_arg_1, indexof_cvc(_arg_1, "/", -1) + 2, len_cvc(_arg_1))
    #     PBE_SLIA_Track_2019.problem_get_last_name_from_name,
    #     PBE_SLIA_Track_2019.problem_get_first_name_from_name
    # ]

    # iterator_to_use.solver.state = deepcopy(iterator_init_state)

    # rule1expr = rulenode2expr(RuleNode(19, [RuleNode(2),RuleNode(10),RuleNode(13)]), g)
    # rule1 = Expr(:(=), :ntInt, rule1expr)
    # # rule2 = Expr(:(=), :ntString, rulenode2expr(RuleNode(12, [RuleNode(12, [RuleNode(2),RuleNode(16),RuleNode(19, [RuleNode(2),RuleNode(9),RuleNode(16)])]),RuleNode(19, [RuleNode(2),RuleNode(10),RuleNode(13)])RuleNode(15)]), g))
    # rule3 = Expr(:(=), :ntString, rulenode2expr(RuleNode(12, [RuleNode(2),RuleNode(16),RuleNode(19, [RuleNode(2),RuleNode(9),RuleNode(16)])]), g))
    # rule4 = Expr(:(=), :ntInt, rulenode2expr(RuleNode(19, [RuleNode(2),RuleNode(9),RuleNode(16)]), g))

    # add_rule!(g, rule1)
    # add_rule!(g, rule3)
    # add_rule!(g, rule4)

    # println(HerbInterpret.execute_on_input(
    #     SymbolTable(g),
    #     :(_arg_2 == 1 ? substr_cvc(_arg_1, indexof_cvc(_arg_1, ",", 0) + 1, len_cvc(_arg_1)) : substr_cvc(_arg_1, 1, indexof_cvc(_arg_1, ",", 0) + -1)),
    #     Dict(
    #         :_arg_1 => "chang,amy",
    #         :_arg_2 => 1
    #     )
    # ))

    # println("#$(HerbInterpret.execute_on_input(
    #     SymbolTable(g),
    #     :(
    #         contains_cvc(
    #             substr_cvc(
    #                 _arg_1,
    #                 indexof_cvc(_arg_1, "_", 0),
    #                 len_cvc(_arg_1)), " ")
    #         ? substr_cvc(
    #             substr_cvc(
    #                 _arg_1,
    #                 indexof_cvc(_arg_1, "_", 0),
    #                 len_cvc(_arg_1)
    #             ),
    #             1,
    #             indexof_cvc(
    #                 substr_cvc(
    #                     _arg_1,
    #                     indexof_cvc(
    #                         _arg_1,
    #                         "_",
    #                         0
    #                     ), len_cvc(_arg_1)
    #                 ),
    #                 " ",
    #                 0
    #             ) + -1
    #         )
    #         : substr_cvc(_arg_1, indexof_cvc(_arg_1, "_", 0), len_cvc(_arg_1))),
    #     Dict(
    #         :_arg_1 => "this is a _username in the middle",
    #     )
    # ))#")

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