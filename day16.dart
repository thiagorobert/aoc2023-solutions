// Dart SDK version: 3.2.4

import 'dart:async';
import 'dart:convert';
import "dart:io";
import "dart:math";

final inputFile = File("day16.input");

enum Direction { right, left, up, down }

class Beam {
    Direction d;
    (int, int) pos;

    Beam(this.d, this.pos);

    bool valid() {
        return this.pos != (-1, -1);
    }

    @override
    bool operator ==(Object other) =>
        other is Beam &&
            other.d == this.d &&
            other.pos == this.pos;
}

class Matrix {
    List<List<String>> data;
    Matrix(this.data);

    (int, int) testBounds((int, int) current) {
        if (
            (current.$1 < this.data.length) &&
            (current.$1 >= 0) &&
            (current.$2 < this.data.length) &&
            (current.$2 >= 0)) {
            return current;
        }
        return (-1, -1);
    }

    String tile(Beam beam) {
        return this.data[beam.pos.$1][beam.pos.$2];
    }

    List<Beam> nextRight(Beam beam) {
        final out = <Beam>[];
        switch(this.tile(beam)) {
            case ".":
            case "-": {
                final b = new Beam(Direction.right, this.testBounds((beam.pos.$1, beam.pos.$2 + 1)));
                out.add(b);
            }
            case "|": {
                var b = new Beam(Direction.up, this.testBounds((beam.pos.$1 - 1, beam.pos.$2)));
                out.add(b);
                b = new Beam(Direction.down, this.testBounds((beam.pos.$1 + 1, beam.pos.$2)));
                out.add(b);
            }
            case "/": {
                final b = new Beam(Direction.up, this.testBounds((beam.pos.$1 - 1, beam.pos.$2)));
                out.add(b);
            }
            case "\\": {
                final b = new Beam(Direction.down, this.testBounds((beam.pos.$1 + 1, beam.pos.$2)));
                out.add(b);
            }
            default: throw FormatException('Invalid');
        }
        return out;
    }

    List<Beam> nextLeft(Beam beam) {
        final out = <Beam>[];
        switch(this.tile(beam)) {
            case ".":
            case "-": {
                final b = new Beam(Direction.left, this.testBounds((beam.pos.$1, beam.pos.$2 - 1)));
                out.add(b);
            }
            case "|": {
                var b = new Beam(Direction.up, this.testBounds((beam.pos.$1 - 1, beam.pos.$2)));
                out.add(b);
                b = new Beam(Direction.down, this.testBounds((beam.pos.$1 + 1, beam.pos.$2)));
                out.add(b);
            }
            case "/": {
                final b = new Beam(Direction.down, this.testBounds((beam.pos.$1 + 1, beam.pos.$2)));
                out.add(b);
            }
            case "\\": {
                final b = new Beam(Direction.up, this.testBounds((beam.pos.$1 - 1, beam.pos.$2)));
                out.add(b);
            }
            default: throw FormatException('Invalid');
        }
        return out;
    }

    List<Beam> nextUp(Beam beam) {
        final out = <Beam>[];
        switch(this.tile(beam)) {
            case ".":
            case "|": {
                final b = new Beam(Direction.up, this.testBounds((beam.pos.$1 - 1, beam.pos.$2)));
                out.add(b);
            }
            case "-": {
                var b = new Beam(Direction.right, this.testBounds((beam.pos.$1, beam.pos.$2 + 1)));
                out.add(b);
                b = new Beam(Direction.left, this.testBounds((beam.pos.$1, beam.pos.$2 - 1)));
                out.add(b);
            }
            case "/": {
                final b = new Beam(Direction.right, this.testBounds((beam.pos.$1, beam.pos.$2 + 1)));
                out.add(b);
            }
            case "\\": {
                final b = new Beam(Direction.left, this.testBounds((beam.pos.$1, beam.pos.$2 - 1)));
                out.add(b);
            }
            default: throw FormatException('Invalid');
        }
        return out;
    }

    List<Beam> nextDown(Beam beam) {
        final out = <Beam>[];
        switch(this.tile(beam)) {
            case ".":
            case "|": {
                final b = new Beam(Direction.down, this.testBounds((beam.pos.$1 + 1, beam.pos.$2)));
                out.add(b);
            }
            case "-": {
                var b = new Beam(Direction.right, this.testBounds((beam.pos.$1, beam.pos.$2 + 1)));
                out.add(b);
                b = new Beam(Direction.left, this.testBounds((beam.pos.$1, beam.pos.$2 - 1)));
                out.add(b);
            }
            case "/": {
                final b = new Beam(Direction.left, this.testBounds((beam.pos.$1, beam.pos.$2 - 1)));
                out.add(b);
            }
            case "\\": {
                final b = new Beam(Direction.right, this.testBounds((beam.pos.$1, beam.pos.$2 + 1)));
                out.add(b);
            }
            default: throw FormatException('Invalid');
        }
        return out;
    }

    List<Beam> next(Beam beam) {
        switch(beam.d) {
            case Direction.right: {
                return this.nextRight(beam);
            }
            case Direction.left: {
                return this.nextLeft(beam);
            }
            case Direction.down: {
                return this.nextDown(beam);
            }
            case Direction.up: {
                return this.nextUp(beam);
            }
            default: throw FormatException('Invalid');
        }
    }
}

Future<Matrix> getInput() async {
    final data = <List<String>>[];
    Stream<String> lines = inputFile.openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    try {
        await for (var line in lines) {
            List<String> lineList = <String>[];
            for (var j = 0; j < line.length; j++) {
                lineList.add(line[j]);
            }
            data.add(lineList);
        }
    } catch (e) {
        print('Error: $e');
    }
    return new Matrix(data);
}

List<List<String>> getOutput(int dimSize) {
    // There should be a better way to do this with generators.
    List<List<String>> output = <List<String>>[];
    for (var i = 0; i < dimSize; i++) {
        List<String> lineList = <String>[];
        for (var j = 0; j < dimSize; j++) {
            lineList.add(".");
        }
        output.add(lineList);
    }
    return output;
}

int logic(Matrix matrix, Beam startBeam) {
    final output = getOutput(matrix.data.length);
    List<Beam> current = <Beam>[startBeam];
    List<Beam> seen = <Beam>[];

    while (current.length != 0) {
        seen.addAll(current);
        bool addedToOut = false;

        List<Beam> next = <Beam>[];
        for (final e in current) {
            if (output[e.pos.$1][e.pos.$2] == ".") {
                addedToOut = true;
            }
            output[e.pos.$1][e.pos.$2] = '#';
            final out = matrix.next(e);
            for (final ne in out) {
                if (ne.valid() && !seen.contains(ne)) {
                    next.add(ne);
                };
            }

        }
        current = next;
    }
    print("\n\n");
    int result = 0;
    for (var i = 0; i < output.length; i++) {
        final line = output[i];
        String toPrint = "";
        for (var j = 0; j < line.length; j++) {
            toPrint += "${line[j]}";
            if (output[i][j] == "#") {
                result++;
            }
        }
        print(toPrint);
    }
    return result;
}

void part1(Matrix matrix) {
    final result = logic(matrix, new Beam(Direction.right, (0, 0)));
    print("Part 1 grand total: $result");
}

void part2(Matrix matrix) {
    var maxActivated = 0;

    for (var i = 0; i < matrix.data.length; i++) {
        var result = logic(matrix, new Beam(Direction.right, (i, 0)));
        if (result > maxActivated) {
            maxActivated = result;
        }
        result = logic(matrix, new Beam(Direction.left, (i, matrix.data.length - 1)));
        if (result > maxActivated) {
            maxActivated = result;
        }
        result = logic(matrix, new Beam(Direction.down, (0, i)));
        if (result > maxActivated) {
            maxActivated = result;
        }
        result = logic(matrix, new Beam(Direction.up, (matrix.data.length - 1, i)));
        if (result > maxActivated) {
            maxActivated = result;
        }
    }
    print("Part 2 grand total: $maxActivated");
}

void main() async {
    final matrix = await getInput();
    part1(matrix);
    part2(matrix);
}