// scalac day17.scala && scala Day17

// WIP: this is my best attempt so far but still not quite there.
// One of the problems: the code requires a turn into the lava factory, it doesn't take into account possibilities
// where it can be reached before the turn.

import scala.io.Source._
import scala.collection.mutable.HashMap

object Consts {
  val INPUT_FILE = "day17.input"
}

class Coord(var x: Int, var y: Int) {
  override def hashCode(): Int = this.x + this.y

  override def equals(other: Any): Boolean = other match {
    case point: Coord =>
      this.x == point.x && this.y == point.y
    case _ => false
  }

  override def toString(): String = f"(${this.x}%d, ${this.y}%d)"
}

class Point(var x: Int, var y: Int, var heat: Int, var path: Array[Coord], var turns: HashMap[Coord, String], var lastTurn: String) {
  def this() = this(0, 0, 0, Array(), HashMap(), "")

  def this(x: Int, y: Int, heat: Int, path: Array[Coord], lastTurn: String) = this(x, y, heat, path, HashMap(), lastTurn)

  override def hashCode(): Int = this.x + this.y

  override def equals(other: Any): Boolean = other match {
    case point: Point =>
      this.x == point.x && this.y == point.y
    case _ => false
  }

  def dirToInt(): Int = {
    var out: Int = 0
    if (this.lastTurn == "") out = 0
    if (this.lastTurn == "U") out = 1
    if (this.lastTurn == "D") out = 2
    if (this.lastTurn == "L") out = 3
    if (this.lastTurn == "R") out = 4
    out
  }

  override def toString(): String = f"(${this.x}%d, ${this.y}%d) == ${this.heat}%d"

  def update(): Int = {
    val nc = new Coord(this.x, this.y)
    this.path :+= nc
    this.turns += (nc -> lastTurn)
    0
  }
}

class Matrix() {
  // Constructor start.
  var lines: Array[String] = Array()
  fromFile(Consts.INPUT_FILE).getLines.foreach((s: String) => {
    lines :+= s
  })
  var matrix: Array[Array[Int]] = Array()
  lines.foreach((s: String) => {
    var ints: Array[Int] = Array()
    s.toCharArray().foreach((c: Char) => {
      ints :+= c.asDigit
    })
    matrix :+= ints
  })
  val limit = matrix.length
  var seen: HashMap[Point, Int] = HashMap()
  // Constructor end.

  override def toString(): String = {
    var out = f"Matrix size: ${this.limit}%d X ${this.limit}%d\n\n"
    this.matrix.foreach((l: Array[Int]) => {
      l.foreach((e: Int) => {
        out += f"$e%d"
      })
      out += s"\n"
    })
    out += s"====================\n"
    out
  }

  def onGoal(point: Point): Boolean = {
    point.x >= this.limit - 1 && point.y >= this.limit - 1
  }

  private def valid(x: Int, y: Int): Boolean = {
    x >= 0 && y >= 0 && x < this.limit && y < this.limit
  }

  def next(start: Point): Array[Point] = {
    var all: Array[Point] = Array()
    var heat: Int = start.heat
    var path: Array[Coord] = Array()

    if (start.lastTurn != "L") {
      for (y <- Range(start.y + 1, start.y + 4)) {
        heat = start.heat
        path = start.path
        for (offset <- Range(start.y + 1, y + 1)) {
          heat += heatLoss(start.x, offset)
          path :+= new Coord(start.x, offset)
        }
        all :+= new Point(start.x + 1, y, heat + heatLoss(start.x + 1, y), path, "D")
        all :+= new Point(start.x - 1, y, heat + heatLoss(start.x - 1, y), path, "U")
      }
    }

    if (start.lastTurn != "U") {
      for (x <- Range(start.x + 1, start.x + 4)) {
        heat = start.heat
        path = start.path
        for (offset <- Range(start.x + 1, x + 1)) {
          heat += heatLoss(offset, start.y)
          path :+= new Coord(offset, start.y)
        }
        all :+= new Point(x, start.y + 1, heat + heatLoss(x, start.y + 1), path, "R")
        all :+= new Point(x, start.y - 1, heat + heatLoss(x, start.y - 1), path, "L")
      }
    }

    var valid: Array[Point] = Array()
    for (p <- all) {
      if (this.valid(p.x, p.y)) {
        if (seen.contains(p)) {
          if (seen(p) > p.heat) {
            p.update()
            valid :+= p
            seen(p) = p.heat
          }
        } else {
          p.update()
          valid :+= p
          seen += (p -> p.heat)
        }
      }
    }
    valid
  }

  private def heatLoss(x: Int, y: Int): Int = {
    var out: Int = 0
    if (x >= 0 && y >= 0 && x < this.limit && y < this.limit) {
      out = this.matrix(x)(y)
    }
    out
  }
}


object Day17 {
  val matrix = new Matrix()

  def main(args: Array[String]) {

    var candidates: Array[Point] = Array()
    var current: Array[Point] = Array()
    current :+= new Point()
    while (current.length > 0) {
      println(f"-- current length: ${current.length}%d")
      var next: Array[Point] = Array()
      for (point <- current) {
        val possible = matrix.next(point)
        for (p <- possible) {
          next :+= p
        }
      }
      current = next
      for (p <- current) {
        if (matrix.onGoal(p)) {
          candidates :+= p
        }
      }
    }
    var lowestHeatLoss: Int = Int.MaxValue;
    var lowestPoint: Point = new Point()
    for (p <- candidates) {
      println(f"p: $p%s")
      var out = f"\n\n"
      var x: Int = 0
      while (x < matrix.limit) {
        var y: Int = 0
        while (y < matrix.limit) {
          val c = new Coord(x, y)
          if (!(lowestPoint.path contains c)) {
            out += f"."
          } else {
            out += f"${matrix.matrix(x)(y)}%d"
          }
          y += 1
        }
        out += f"\n"
        x += 1
      }
      print(out)

      if (p.heat < lowestHeatLoss) {
        lowestHeatLoss = p.heat
        lowestPoint = p
      }
    }
    print(f"Part 1 grand total: $lowestHeatLoss%d");

    print("\n\n")
    for (p <- lowestPoint.path) {
      print(p)
    }
  }
}