using Herb: RuleNode, Hole

@testset "find common subcomponents" begin
    g = @csgrammar begin
        Start = String #1
        String = "a" #2
        String = "$(Number)" #3
        String = String * String #4
        Number = length(String) #5
        Number = 5 #6
    end

    # length of a as string
    p1 = RuleNode(3, [
        RuleNode(5, [
            RuleNode(2),
        ]),
    ])

    # length of aa as string
    p2 = RuleNode(3, [
        RuleNode(5, [
            RuleNode(4, [
                RuleNode(2),
                RuleNode(2)
            ]),
        ]),
    ])

    # a1
    p3 = RuleNode(4, [
        RuleNode(2),
        RuleNode(5, [
            RuleNode(2)
        ])
    ])

    # length of aaa
    p4 = RuleNode(3, [
        RuleNode(5, [
            RuleNode(4, [
                RuleNode(2),
                RuleNode(4, [
                    RuleNode(2),
                    RuleNode(2)
                ])
            ]),
        ]),
    ])

    nodes = [p1, p2, p3, p4]

    @test HerbAutomaticAbstraction.hash_common_subcomponents_pairwise(g, nodes;
        min_size = 2,
        with_holes = true,
    ) == (9, Dict(
          RuleNode(4, [RuleNode(2), RuleNode(2)]) => 1,
          RuleNode(3, [RuleNode(5, [Hole(Bool[0, 1, 1, 1, 0, 0])])]) => 3,
          RuleNode(4, [RuleNode(2), Hole(Bool[0, 1, 1, 1, 0, 0])]) => 2,
          RuleNode(5, [RuleNode(4, [RuleNode(2), Hole(Bool[0, 1, 1, 1, 0, 0])])]) => 1,
          RuleNode(3, [RuleNode(5, [RuleNode(4, [RuleNode(2), Hole(Bool[0, 1, 1, 1, 0, 0])])])]) => 1,
          RuleNode(5, [RuleNode(2)]) => 1,
        ))
end
