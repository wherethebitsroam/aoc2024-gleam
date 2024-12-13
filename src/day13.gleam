import gleam/int
import gleam/list
import gleam/result
import gleam/string
import point.{type Point, Point}
import util

fn solve(a: Point, b: Point, dest: Point) -> Result(#(Int, Int), Nil) {
  let bp = { a.x * dest.y - a.y * dest.x } / { b.y * a.x - b.x * a.y }
  let ap = { dest.y - bp * b.y } / a.y

  case ap * a.x + bp * b.x == dest.x && ap * a.y + bp * b.y == dest.y {
    True -> Ok(#(ap, bp))
    False -> Error(Nil)
  }
}

type Machine {
  Machine(a: Point, b: Point, prize: Point)
}

fn parse_line(s: String, splitter: String) -> Result(Point, Nil) {
  case s |> string.split(splitter) {
    [_, a, b] -> {
      case a |> string.split(",") {
        [a, _] -> Ok(Point(util.parse_int(a), util.parse_int(b)))
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_machine(s: String) -> Result(Machine, Nil) {
  case s |> string.split("\n") {
    [a, b, prize] -> {
      [parse_line(a, "+"), parse_line(b, "+"), parse_line(prize, "=")]
      |> result.all
      |> result.then(fn(l) {
        case l {
          [a, b, prize] -> Ok(Machine(a, b, prize))
          _ -> Error(Nil)
        }
      })
    }
    _ -> Error(Nil)
  }
}

fn parse(input: String) -> Result(List(Machine), Nil) {
  input
  |> string.trim
  |> string.split("\n\n")
  |> list.map(parse_machine)
  |> result.all
}

fn cost(soln: #(Int, Int)) -> Int {
  // a costs 3, b costs 1
  3 * soln.0 + soln.1
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> result.unwrap([])
  |> list.filter_map(fn(m) { solve(m.a, m.b, m.prize) })
  |> list.map(cost)
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  let extra = Point(10_000_000_000_000, 10_000_000_000_000)
  input
  |> parse
  |> result.unwrap([])
  |> list.map(fn(m) { Machine(m.a, m.b, point.add(m.prize, extra)) })
  |> list.filter_map(fn(m) { solve(m.a, m.b, m.prize) })
  |> list.map(cost)
  |> list.fold(0, int.add)
}
