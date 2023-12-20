/*
    Wikipedia/Binomial coefficient
    Wikipedia/Pascal's triangle
    Wikipedia/Combination
 */
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
/*
    # to install:
    > sudo apt-get install        libcommons-math3-java

    # see where files where installed:
    > dpkg -L libcommons-math3-java

    # use when compiling / running:
    > javac -cp /usr/share/java/commons-math3-3.6.1.jar:. day12.java && java -cp /usr/share/java/commons-math3-3.6.1.jar:. Day12
*/
import org.apache.commons.math3.util.CombinatoricsUtils;

class SpringMap {
    String map;
    List<Integer> damaged;
    List<Integer> damagedIndices = new ArrayList<Integer>();
    List<Integer> unkownIndices = new ArrayList<Integer>();
    int totalDamaged;

    public SpringMap(String map, List<Integer> damaged) {
        this.map = map;
        for (int i = 0; i < this.map.length(); i++) {
            if (map.charAt(i) == '#') {
                this.damagedIndices.add(i);
            } else if (map.charAt(i) == '?') {
                this.unkownIndices.add(i);
            } else {
                assert false : "invalid input";
            }
        }

        this.damaged = damaged;
        for (int nDamaged : this.damaged) {
            this.totalDamaged += nDamaged;
        }
    }

    public List<String> bruteForce() {
        int nUnkown = this.unkownIndices.size();
        int nKnownDamaged = this.damagedIndices.size();
        int nToReplace = this.totalDamaged - nKnownDamaged;
        Iterator<int[]> it = CombinatoricsUtils.combinationsIterator(nUnkown, nToReplace);

        List<String> out = new ArrayList<String>();
        while (it.hasNext()) {
            StringBuffer alternativeMap = new StringBuffer(this.map);
            int[] currentSet = it.next();
            for (int i : currentSet) {
                int unkownIndex = this.unkownIndices.get(i);
                alternativeMap.setCharAt(unkownIndex, '#');
            }
            out.add(alternativeMap.toString().replaceAll("\\?", "."));
        }

        return out;
    }

    public List<String> filter(List<String> allPossible) {
        List<String> filtered = new ArrayList<String>();
        // For every possible map.
        for (String m : allPossible) {
            boolean valid = true;
            int startIndex = 0;
            // Iterate over the set of sizes for cluster of damaged springs.
            for(Integer expectedNDamaged : this.damaged) {
                // This map is known to be invalid, skip further processing.
                if (!valid) {
                    break;
                }
                int nWorkingCurrent = 0;
                int nDamagedCurrent = 0;
                for(int i = startIndex; i < m.length() - 1; i++) {
                    if (m.charAt(i) == '#') {
                        // If this is a new cluster of damaged springs, reset counter
                        // of working springs to ensure there are not working springs
                        // within the cluster.
                        if (nDamagedCurrent == 0) {
                            nWorkingCurrent = 0;
                        }
                        nDamagedCurrent++;
                    } else if (m.charAt(i) == '.') {
                        nWorkingCurrent++;
                    } else if (map.charAt(i) == '?') {
                        // Overkill.
                        assert false : "this should never happen";
                    }
                    // At the end of a cluster of damaged springs with expected size.
                    if (nDamagedCurrent == expectedNDamaged) {
                        // If the cluster continues, this is not a valid map.
                        if (m.charAt(i + 1) == '#') {
                            valid = false;
                        }
                        startIndex = i + 1;
                        nDamagedCurrent = 0;
                        nWorkingCurrent = 0;
                        break;
                    }
                    // Within a possible cluster, there shouldn't be any working springs.
                    if (nDamagedCurrent > 0 && nWorkingCurrent > 0) {
                        valid = false;
                        break;
                    }
                }
            }
            if (valid) {
                filtered.add(m);
            }
        }
        return filtered;
    }

    public int countArrangements() {
        return this.filter(this.bruteForce()).size();
    }
}

class Day12 {
    private static String INPUT_FILE = "day12.input";

    private static List<String> readInput() throws IOException {
        return Files.readAllLines(Paths.get(INPUT_FILE), StandardCharsets.UTF_8);
    }

    public static void main(String[] args) throws IOException {
        List<SpringMap> springsMaps = new ArrayList<SpringMap>();
        for(String line : readInput()) {
            String[] parts = line.split(" ", 0);
            assert parts.length == 2 : "invalid input";
            List<Integer> damaged = new ArrayList<Integer>();
            for(String d : parts[1].split(",", 0)) {
                damaged.add(Integer.valueOf(d));
            }
            springsMaps.add(new SpringMap(parts[0], damaged));
        }

        long result = 0;
        for (SpringMap m : springsMaps) {
            long nArrangements = m.countArrangements();
            result += nArrangements;
        }
        System.out.printf("Part 1 grand total: %d\n", result);
    }
}