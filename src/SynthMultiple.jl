#
# You need to call synth_multiple with an iterator that doesn't take the problem in order to solve them at the same time.
#

using HerbSearch
using HerbGrammar
using HerbSpecification

export synth_multiple

"""
synth method but it takes a vector of problems and tries to solve them at the same time
"""
function synth_multiple(
    problems::Vector{Problem},
    iterator::ProgramIterator; 
    shortcircuit::Bool=true, 
    allow_evaluation_errors::Bool=false,
    max_time = typemax(Int),
    max_enumerations = typemax(Int),
    print_iteration = false,
    mod::Module=Main
)::Vector{Union{Tuple{RuleNode, SynthResult}, Nothing}}
    global last_iterator

    start_time = time()
    grammar = HerbSearch.get_grammar(iterator.solver)
    symboltable :: SymbolTable = SymbolTable(grammar, mod)

    best_scores = [0.0 for _ in problems]
    best_programs = convert(Vector{Union{Tuple{RuleNode, SynthResult}, Nothing}}, [nothing for _ in problems])
    found = 0
    
    for (i, candidate_program) ∈ enumerate(iterator)
        # Create expression from rulenode representation of AST
        expr = rulenode2expr(candidate_program, grammar)
        if (print_iteration) println(expr) end

        # Evaluate the expression
        for (problemid, problem) in enumerate(problems)
            if (!isnothing(best_programs[problemid]) && best_programs[problemid][2] == optimal_program) continue end
            score = HerbSearch.evaluate(problem, expr, symboltable, shortcircuit=shortcircuit, allow_evaluation_errors=allow_evaluation_errors)
            if score == 1
                found_program = HerbSearch.freeze_state(candidate_program)
                println("have done $(i) iterations")
                print("✅")
                println(expr)
                println("current time = $(time() - start_time)")
                best_programs[problemid] = (found_program, optimal_program)
                found += 1
                if (found >= length(problems)) return best_programs end
            elseif score >= best_scores[problemid]
                best_scores[problemid] = score
                found_program = HerbSearch.freeze_state(candidate_program)
                best_programs[problemid] = (found_program, suboptimal_program)
            end
        end

        # Check stopping criteria
        if i > max_enumerations || time() - start_time > max_time
            break;
        end
    end

    # The enumeration exhausted, but an optimal problem was not found
    return best_programs
end