using HerbGrammar, HerbSpecification, HerbSearch, HerbInterpret

using HerbAutomaticAbstraction

function extendGrammarExample()
    g = @cfgrammar begin
        Number = |(1:3)
        Number = x
        Number = Number + Number
        Number = Number * Number
    end

    examples = [IOExample(Dict(:x => x), 2x+1) for x in 1:20]

    iterator_provider = problem -> BFSIterator(g, :Number, max_depth = 5)

    extend_grammar(examples, g, :Number;
        iterator_provider=iterator_provider,
        splitting_strategy=RandomPick(3, nothing),
        min_utility=0.1,
        min_size=2
    )
end