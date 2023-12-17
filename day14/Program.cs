using System.Text;

const string INPUT_FILE = "day14.input";
string text = File.ReadAllText(INPUT_FILE);
Console.WriteLine(text);
string[] lines = text.Split('\n');
StringBuilder[] w = new StringBuilder[lines.Length];
for (int i = 0; i < lines.Length; i++) {
    w[i] = new StringBuilder(lines[i]);
}
Console.WriteLine(lines);

bool moved = false;
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
Console.WriteLine("=============================\r\n");
foreach (var line in w) {
    Console.WriteLine(line);
}

int result = 0;
for (int i = 0; i < w.Length; i++) {
    int load = w.Length - i;
    for (int j = 0; j < w[i].Length; j++) {
        if (w[i][j] == 'O') {
            result += load;
        }
    }
}
Console.WriteLine(String.Format("Part 1 grand total: {0}", result));