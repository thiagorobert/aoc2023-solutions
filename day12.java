import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

// Represents a state in the search.
class State {
    int brokenClusterIndex;
    int brokenClusterCount;
    boolean expectWorking;

    public State() {
        this.brokenClusterIndex = 0;
        this.brokenClusterCount = 0;
        this.expectWorking = false;
    }
    public State(State s) {
        this.brokenClusterIndex = s.brokenClusterIndex;
        this.brokenClusterCount = s.brokenClusterCount;
        this.expectWorking = s.expectWorking;
    }

    @Override
    public int hashCode() {
        int ew = (expectWorking) ? 1 : 0;
        return brokenClusterIndex + brokenClusterCount + ew;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        if (this.getClass() != o.getClass()) return false;
        State s = (State) o;
        return this.brokenClusterIndex == s.brokenClusterIndex
                && this.brokenClusterCount == s.brokenClusterCount
                && this.expectWorking == s.expectWorking;
    }
}

// Represents an line in the spring map.
class SpringMap {
    String map;
    List<Integer> brokenClustersSizes;

    public SpringMap(String map, List<Integer> brokenClustersSizes) {
        this.map = map;
        this.brokenClustersSizes = brokenClustersSizes;
    }

    public long countArrangements() {
        Map<State, Long> states = new HashMap<State, Long>();
        states.put(new State(), 1L);

        // For each character in the map.
        for (int i = 0; i < this.map.length(); i++) {
            char current = this.map.charAt(i);

            // States at current character.
            Map<State, Long> newStates = new HashMap<State, Long>();

            // For each known state so far.
            for (Map.Entry<State, Long> entry : states.entrySet()) {
                State s = entry.getKey();
                long stateCount = entry.getValue();

                // If at a (potential or known) broken spring cluster.
                if ((current == '#' || current == '?')
                        && s.brokenClusterIndex < this.brokenClustersSizes.size()
                        && !s.expectWorking) {
                    if (current == '?' && s.brokenClusterCount == 0) {
                        // Not in a cluster of broken springs.
                        newStates.put(entry.getKey(), newStates.getOrDefault(entry.getKey(), 0L) + stateCount);
                    }
                    // In a cluster of broken springs.
                    int newCount = s.brokenClusterCount + 1;
                    State newState = new State(entry.getKey());
                    newState.brokenClusterCount = newCount;
                    if (newCount == this.brokenClustersSizes.get(s.brokenClusterIndex)) {
                        // Found a cluster of broken springs with the expected size...
                        newState.brokenClusterIndex++;
                        newState.brokenClusterCount = 0;
                        newState.expectWorking = true;  // ... so the next character should be a working spring.
                    }
                    newStates.put(newState, newStates.getOrDefault(newState, 0L) + stateCount);
                // If at a (potential or konwn) working spring.
                } else if ((current == '.' || current == '?')
                            && s.brokenClusterCount == 0) {
                    State newState = new State(entry.getKey());
                    newState.expectWorking = false;
                    newStates.put(newState, newStates.getOrDefault(newState, 0L) + stateCount);
                }
            }
            states = newStates;
        }

        // Account the states with expected number of clusters of broken springs.
        long out = 0;
        for (Map.Entry<State, Long> entry : states.entrySet()) {
            if (entry.getKey().brokenClusterIndex == this.brokenClustersSizes.size()) {
                out += entry.getValue();
            }
        }
        return out;
    }
}

class Day12 {
    private static String INPUT_FILE = "day12.input";

    private static List<String> readInput() throws IOException {
        return Files.readAllLines(Paths.get(INPUT_FILE), StandardCharsets.UTF_8);
    }

    private static long logic(List<SpringMap> springsMaps, int nRepetitions) {
        long result = 0;
        for (SpringMap m : springsMaps) {
            StringBuilder newMap = new StringBuilder();
            List<Integer> newBrokenClustersSizes = new ArrayList<Integer>();
            for (int i = 0; i < nRepetitions; i++) {
                newMap.append(m.map);
                if (i != nRepetitions - 1) {
                    newMap.append('?');
                }
                newBrokenClustersSizes.addAll(m.brokenClustersSizes);
            }
            SpringMap n = new SpringMap(newMap.toString(), newBrokenClustersSizes);
            result += n.countArrangements();
        }
        return result;
    }

    public static void main(String[] args) throws IOException {
        List<SpringMap> springsMaps = new ArrayList<SpringMap>();
        for(String line : readInput()) {
            String[] parts = line.split(" ", 0);
            assert parts.length == 2 : "invalid input";
            List<Integer> brokenClustersSizes = new ArrayList<Integer>();
            for(String d : parts[1].split(",", 0)) {
                brokenClustersSizes.add(Integer.valueOf(d));
            }
            springsMaps.add(new SpringMap(parts[0], brokenClustersSizes));
        }

        System.out.printf("Part 1 grand total: %d\n", logic(springsMaps, 1));
        System.out.printf("Part 2 grand total: %d\n", logic(springsMaps, 5));
    }
}