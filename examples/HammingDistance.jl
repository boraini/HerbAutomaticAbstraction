# preallocated memoization table to possibly improve performance
max_supported_string_length = 256
row() = [0 for _ in 1:(max_supported_string_length + 1)]
mem = [row() for _ in 1:(max_supported_string_length + 1)]

counter = 0

"""
Find the Hamming distance between two strings given as a tuple.

Written by Mert Bora İnevi (https://boraini.com)
"""
function hamming_distance(point::Tuple{String, String})
    global counter
    global mem

    spec = point[1]
    actual = point[2]

    penalty = 1
    score(a, b) = if (a == b) 0 else 1 end

    for i in eachindex(spec)
        mem[i + 1][1] = i
    end

    # print("0\t") # top left

    for j in eachindex(actual)
        mem[1][j + 1] = j
        # print("$(mem[1][j + 1])\t") # top row rest of the items
    end

    # println() # top row end

    for i in eachindex(spec)
        # print("$(mem[i + 1][1])\t") # rest of the rows first column
        for j in eachindex(actual)
            skip_i = penalty + mem[i][j + 1]
            skip_j = penalty + mem[i + 1][j]
            match_letters = score(spec[i], actual[j]) + mem[i][j]
            # println("options: \t$(mem[i][j + 1])\t$(mem[i + 1][j])\t$(skip_i)\t$(skip_j)\t$(match_letters)")
            mem[i + 1][j + 1] = min(skip_i, skip_j, match_letters)

            # print("$(mem[i + 1][j + 1])\t") # rest of the cells
        end
        # println() # rest of the rows end
    end

    # print alignment

    # i = length(spec)
    # j = length(actual)
    # while (i > 0 && j > 0)
    #     if (mem[i + 1][j + 1] == mem[i][j + 1] + penalty)
    #         println("$(spec[i])\t")
    #         i -= 1
    #     elseif (mem[i + 1][j + 1] == mem[i + 1][j] + penalty)
    #         println("\t$(actual[j])")
    #         j -= 1
    #     else
    #         println("$(spec[i])\t$(actual[j])")
    #         i -= 1
    #         j -= 1
    #     end
    # end
    # while (i > 0)
    #     println("$(spec[i])\t")
    #     i -= 1
    # end
    # while (j > 0)
    #     println("\t$(actual[j])")
    #     j -= 1
    # end

    # counter += 1
    # if (counter % 100 == 0)
    #     println("$(counter) strings tested")
    # end

    return mem[length(spec) + 1][length(actual) + 1]
end

"""
Fitness function for GeneticSearchIterator

Normally, the genetic search iterator doesn't support custom fitness functions (as if 01/06/2024) but I have made
some modifications to it. See library_modifications/genetic_search_iterator.jl
"""
function hamming_fitness(iter, program, results::Vector{<:Tuple{String, Any}})
    global max_supported_string_length
    distances = map(val -> if (val[2] isa String && val[2] != "" && length(val[2]) <= max_supported_string_length)
        hamming_distance(val)
    else
        1000000
    end, results)

    return length(distances) / sum(x->x.^2, distances)
end