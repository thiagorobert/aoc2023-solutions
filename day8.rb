# ruby 3.0.2p107

INPUT = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"

# Debug print.
DEBUG = true
def debug(any)
    if DEBUG
        puts
        pp any
    end
end


# Input.
inputLines = INPUT.split("\n")


# Get nav instructions.
instructions = inputLines.shift
debug(instructions)


# Get map directions.
TURN_RE = /([A-Z1-2]{3}) = \(([A-Z1-2]{3}), ([A-Z1-2]{3})\)/

directions = {}
for line in inputLines
    next if line.empty?
    m = line.match TURN_RE
    debug(m[1] + ": " + m[2] + "," + m[3])
    directions[m[1]] = [m[2], m[3]]
end


# Part 1 solution.
current = "22A"
nSteps = 0
while current != "22Z"
    for ic in instructions.chars
        i = - 1
        if ic == "R" then i = 1 else i = 0 end
        current = directions[current][i]
        nSteps += 1
    end
end

print "\n\n********** Part 1: steps to get there: ", nSteps
puts


# Part 2 solution.
startNodes = directions.keys.select {|node| node[-1] == "A"}
debug(startNodes)
solutions = {}

# Find solution for individual nodes.
for node in startNodes
    nSteps = 0
    current = node
    while current[-1] != "Z"
        for ic in instructions.chars
            i = - 1
            if ic == "R" then i = 1 else i = 0 end
            current = directions[current][i]
            nSteps += 1
        end
    end
    solutions[node] = nSteps
end

debug("solutions:")
debug(solutions)

# Solution with longest number of steps.
solutionsLengths = solutions.values.sort
longest = solutionsLengths.sort[-1]
shortest = solutionsLengths.sort[0]
debug("longest:")
debug(longest)

# Loop over that solution until we find the iteration where
# all available solutions 'align'; ie, the number of steps divisible
# divisible by the number of steps of all solutions.
def divisible(dividend, divisors)
    for divisor in divisors
        if dividend % divisor != 0
            return false
        end
    end
    return true
end

nSteps = longest
loop do
    break if divisible(nSteps, solutionsLengths)
    nSteps += longest
end

print "\n\n********** Part 2: steps to get there: ", nSteps
puts