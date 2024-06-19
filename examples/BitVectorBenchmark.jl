using HerbBenchmarks.PBE_BV_Track_2018
using Base.Iterators
using Random: randperm

bv_iterator_before_id = generate_iterator_id()

function bitVectorBenchmark()
    g = grammar_PRE_113_1000

    problems = HerbBenchmarks.all_problems(PBE_BV_Track_2018)

    problems = convert(Vector{Problem}, problems)

    halflength = ceil(Int64, length(problems) / 2)

    parts = collect(Iterators.partition(randperm(length(problems)), halflength))

    problems_train = problems[parts[1]]
    problems_test = problems[parts[2]]

    iterator_provider(examples) = reset_iterator(bv_iterator_before_id, BFSIterator(g, :Start; max_depth = 10))

    new_g = extend_grammar(problems_train, g, :Start;
        iterator_provider,
        min_utility = 0.0,
        min_size = 4,
        max_enumerations = 1_000_000,
        max_new_rules = 10,
        with_holes = true,
        concurrent = true,
        mod = PBE_BV_Track_2018,
    )

    after_iterator = BFSIterator(new_g, :Start; max_depth = 10)

    synth_multiple(problems_test, after_iterator, allow_evaluation_errors = true, max_enumerations = 1_000_000, mod=PBE_BV_Track_2018)
end