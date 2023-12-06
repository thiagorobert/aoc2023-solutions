import sys

input = """Time:      7  15   30
Distance:  9  40  200"""


if __name__ == "__main__":

    input_lines = input.split("\n")

    times = [int(t) for t in input_lines[0].split(":")[1].split(" ") if t != ""]
    print(times)

    distances = [int(d) for d in input_lines[1].split(":")[1].split(" ") if d != ""]
    print(distances)

    ways_to_win = [0 for d in distances]
    for i, t in enumerate(times):
        for acc in range(1, t - 1):
            distance_travelled = acc * (t - acc)
            if distance_travelled > distances[i]:
                ways_to_win[i] += 1
    print(ways_to_win)

    total = 1
    for w in ways_to_win:
        total *= w

    print("\n\n********** Part 1: the grand total: ", total)


    time = int("".join([t for t in input_lines[0].split(":")[1].split(" ") if t != ""]))
    print(time)

    distance = int("".join([d for d in input_lines[1].split(":")[1].split(" ") if d != ""]))
    print(distance)

    ways_to_win = 0
    for acc in range(1, time - 1):
        distance_travelled = acc * (time - acc)
        if distance_travelled > distance:
            ways_to_win += 1
    print(ways_to_win)

    print("\n\n********** Part 2: the grand total: ", ways_to_win)
