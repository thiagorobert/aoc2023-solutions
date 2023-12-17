using static System.Console;
using System.Text;

namespace Day14 {
    class Solver {
        const string INPUT_FILE = "day14.input";

        static StringBuilder[] readInput() {
            string text = File.ReadAllText(INPUT_FILE);
            string[] lines = text.Split('\n');
            StringBuilder[] w = new StringBuilder[lines.Length];
            for (int i = 0; i < lines.Length; i++) {
                w[i] = new StringBuilder(lines[i]);
            }
            return w;
        }

        static int[] spinCycles(int nCycles, bool northOnly, StringBuilder[] w) {
            int nDone = 0;
            int[] results = new int[nCycles];
            do {
                bool moved = false;
                // North
                do {
                    moved = false;
                    for (int i = 0; i < w.Length - 1; i++) {
                        for (int j = 0; j < w[i].Length; j++) {
                            if (w[i][j] == '.' && w[i + 1][j] == 'O') {
                                w[i].Remove(j, 1).Insert(j, "O");
                                w[i + 1].Remove(j, 1).Insert(j, ".");
                                moved = true;
                            }
                        }
                    }
                } while (moved);

                if (!northOnly) {
                    // West
                    do {
                        moved = false;
                        for (int i = 0; i < w.Length; i++) {
                            for (int j = 0; j < w[i].Length - 1; j++) {
                                if (w[i][j] == '.' && w[i][j + 1] == 'O') {
                                    w[i].Remove(j, 1).Insert(j, "O");
                                    w[i].Remove(j + 1, 1).Insert(j + 1, ".");
                                    moved = true;
                                }
                            }
                        }
                    } while (moved);

                    // South
                    do {
                        moved = false;
                        for (int i = 0; i < w.Length - 1; i++) {
                            for (int j = 0; j < w[i].Length; j++) {
                                if (w[i][j] == 'O' && w[i + 1][j] == '.') {
                                    w[i].Remove(j, 1).Insert(j, ".");
                                    w[i + 1].Remove(j, 1).Insert(j, "O");
                                    moved = true;
                                }
                            }
                        }
                    } while (moved);

                    // East
                    do {
                        moved = false;
                        for (int i = 0; i < w.Length; i++) {
                            for (int j = w[i].Length - 1; j > 0; j--) {
                                if (w[i][j] == '.' && w[i][j - 1] == 'O') {
                                    w[i].Remove(j, 1).Insert(j, "O");
                                    w[i].Remove(j - 1, 1).Insert(j - 1, ".");
                                    moved = true;
                                }
                            }
                        }
                    } while (moved);
                }

                int newResult = 0;
                for (int i = 0; i < w.Length; i++) {
                    int load = w.Length - i;
                    for (int j = 0; j < w[i].Length; j++) {
                        if (w[i][j] == 'O') {
                            newResult += load;
                        }
                    }
                }
                results[nDone] = newResult;
                nDone += 1;

            } while (nDone != results.Length);
            return results;
        }

        static int part1() {
            StringBuilder[] w = readInput();
            int[] results = spinCycles(1, /* northOnly */ true, w);
            return results[0];
        }

        static int part2() {
            StringBuilder[] w = readInput();
            int[] results = spinCycles(100, /* northOnly */ false, w);
            int lastResult = results[results.Length - 1];
            int lastCycleEnd = 0;
            int cycleLength = 0;
            for (int i = 0; i < results.Length; i++) {
                if (results[i] == lastResult) {
                    int newCycleLength = i - lastCycleEnd;
                    if (newCycleLength == cycleLength) {
                        break;
                    } else {
                        cycleLength = i - lastCycleEnd;
                        lastCycleEnd = i;
                    }
                }
            }
            int nCyclesRequired = (1000000000 - results.Length) / cycleLength;
            int missing = 1000000000 - results.Length - (nCyclesRequired * cycleLength);
            return results[results.Length - missing];
        }

        static void Main(string[] args) {
            Console.WriteLine(String.Format("Part 1 grand total: {0}", part1()));
            Console.WriteLine(String.Format("Part 2 grand total: {0}", part2()));
        }
    }
}