// Node v12.22.9
const INPUT = `...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....`;

function expand(input) {
    const lines = input.split(/\r?\n|\r|\n/g);

    let matrix = [];
    for (const [_, l] of lines.entries()) {
        if (l.match(/#/g)) {
            matrix.push(l.split(''));
        } else {
            for (let i = 0; i < 2; i++) {
                matrix.push(l.split(''));
            }
        }
    }
    console.log("dimensions: " + matrix.length + " X " + matrix[0].length);
    let transposed = matrix[0].map((_, colIndex) => matrix.map(row => row[colIndex]));

    matrix = [];
    for (let i = 0; i < transposed.length; i++) {
        const l = transposed[i].join('');
        if (l.match(/#/g)) {
            matrix.push(l.split(''));
        } else {
            for (let i = 0; i < 2; i++) {
                matrix.push(l.split(''));
            }
        }
    }

    transposed =  matrix[0].map((_, colIndex) => matrix.map(row => row[colIndex]));
    console.log("dimensions: " + transposed.length + " X " + transposed[0].length);
    return transposed;
}

console.log(INPUT);
expanded = expand(INPUT)
for (const [_, e] of expanded.entries()) {
    console.log(e.join(''));
}

galaxies = [];
for (const [x, _] of expanded.entries()) {
    for (const [y, e] of expanded[x].entries()) {
        if (e == "#") {
            console.log(e + " found at " + x + " x " + y);
            galaxies.push([x, y]);
        }
    }
}
console.log("N galaxies: " + galaxies.length);

let sum = 0;
let nPairs = 0;
for (const [i, g1] of galaxies.entries()) {
    for (let j = i + 1; j < galaxies.length; j++) {
        const g2 = galaxies[j];
        const xd = Math.max(g2[0], g1[0]) - Math.min(g2[0], g1[0]);
        const yd = Math.max(g2[1], g1[1]) - Math.min(g2[1], g1[1]);
        const shortestD = xd + yd;
        sum += shortestD;
        nPairs += 1;
    }
}
console.log("\n\nN pairs of galaxies: " + nPairs);
console.log("Part 1 grand total: " + sum);