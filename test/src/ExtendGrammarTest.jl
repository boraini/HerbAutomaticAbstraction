using HerbGrammar

@testset "min utility is handled properly" begin
    usages = Dict(
        RuleNode(1) => 10,
        RuleNode(2) => 20,
        RuleNode(3) => 40,
        RuleNode(4) => 80
    )

    count = 150

    extensions = HerbAutomaticAbstraction.choose_extensions(count, usages;
        min_utility=0.5
        )

    @test length(extensions) == 1
end

@testset "max rules is evaluated correctly" begin
    usages = Dict(
        RuleNode(1) => 10,
        RuleNode(2) => 20,
        RuleNode(3) => 40,
        RuleNode(4) => 80
    )

    count = 150

    extensions = HerbAutomaticAbstraction.choose_extensions(count, usages;
        min_utility=0,
        max_new_rules=3
        )

    @test length(extensions) == 3

    extensions = HerbAutomaticAbstraction.choose_extensions(count, usages;
        min_utility=0
        )

    @test length(extensions) == 4
end