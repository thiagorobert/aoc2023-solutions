function mirror_index(horizontal_pattern)
    mirror_indices = Dict()
    for (li, line) in enumerate(horizontal_pattern)
        line_indices = []
        min_index = length(line) - round(Int, ceil(length(line) / 2))

        # Julia uses byte indexing for arrays (starting at 1) ¯\_(ツ)_/¯
        for i in reverse(range(min_index, length(line) - 1))
            prefix = line[1:i]
            suffix = line[i + 1:end]
            reversedSuffix = reverse(suffix)
            @assert length(prefix) + length(reversedSuffix) == length(line)
            if endswith(prefix, reversedSuffix)
                push!(line_indices, i)
            end
        end
        mirror_indices[li] = line_indices
    end

    common_indices = intersect(values(mirror_indices)...)
    out = -1
    if length(common_indices) > 0
        out = min(common_indices...)
    end
    return out
end

function transpose(vertical_pattern_lines)
    matrix = reduce(vcat, permutedims.(collect.(vertical_pattern_lines)))
    out = []
     for col in reverse(eachcol(matrix))
        push!(out, join(col))
    end
    return out
end

function main(input)
    patterns = []
    for pattern in split(input, "\n\n")
        push!(patterns, pattern)
    end

    result = 0

    # Four possible positions for the mirror line:
    for pattern in patterns
        pattern_lines = split(pattern, "\n")

        # 1. second half, horizontal
        index = mirror_index(pattern_lines)
        if index != -1
            result += index
            continue
        end

        # 2. first half, horizontal
        reversed_pattern_lines = []
        for p in pattern_lines
            push!(reversed_pattern_lines, reverse(p))
        end
        index = mirror_index(reversed_pattern_lines)
        if index != -1
            result += length(pattern_lines[1]) - index
            continue
        end

        # transpose to look for a vertical pattern
        transposed_pattern = transpose(pattern_lines)

        # 3. second half, vertical
        index = mirror_index(transposed_pattern)
        if index != -1
            result += 100 * index
            continue
        end

        # 4. first half, vertical
        out = []
        for p in transposed_pattern
            push!(out, reverse(p))
        end
        index = mirror_index(out)

        # at this point we must have found a pattern
        @assert index != -1
        result += 100 * (length(pattern_lines) - index)
    end
    println("Part 1 grand total: ", result)
end

f = open("day13.input", "r")
input = read(f, String)
close(f)
main(input)