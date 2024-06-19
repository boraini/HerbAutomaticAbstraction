using HerbSearch: ProgramIterator

id_generator = 0
map_of_solver_states = convert(Dict{Int64, Any}, Dict())

"""
Call this once in each example that uses iterators, for each different iterator, to produce ids.
"""
function generate_iterator_id()::Int64
    global id_generator

    id_generator += 1
    return id_generator
end

"""
Reset the state of the provided iterator to the previously saved initial state
"""
function reset_iterator(id::Int64, iterator::ProgramIterator)
    global map_of_solver_states

    if haskey(map_of_solver_states, id)
        iterator.solver.state = deepcopy(map_of_solver_states[id])
    else
        map_of_solver_states[id] = deepcopy(iterator.solver.state)
    end

    return iterator
end