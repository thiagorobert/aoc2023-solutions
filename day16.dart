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
        return (pos.$1 >= 0 && pos.$2 >= 0);
    }

    @override
    bool operator ==(Object other) =>
        other is Beam &&
            other.d == this.d &&
            other.pos == this.pos;
            // other.pos.$1 == this.pos.$1 &&
            // other.pos.$2 == this.pos.$2;
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

void main() async {
    final matrix = await getInput();
    final output = getOutput(matrix.data.length);
    List<Beam> current = <Beam>[new Beam(Direction.right, (0, 0))];
    List<Beam> seen = <Beam>[];

    while (current.length != 0) {
        seen.addAll(current);

        List<Beam> next = <Beam>[];
        for (final e in current) {
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

    int result = 0;
    for (var i = 0; i < output.length; i++) {
        final line = output[i];
        for (var j = 0; j < line.length; j++) {
            if (output[i][j] == "#") {
                result++;
            }
        }
    }
    print("Part 1 grand total: $result");
}