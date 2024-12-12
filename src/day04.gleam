import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import point.{type Point, Point}
import util

// part1

type Row =
  List(String)

fn check_row(row: Row, acc: Int) -> Int {
  case row {
    ["X", "M", "A", "S", ..rest] -> check_row(["S", ..rest], acc + 1)
    ["S", "A", "M", "X", ..rest] -> check_row(["X", ..rest], acc + 1)
    [_, ..rest] -> check_row(rest, acc)
    [] -> acc
  }
}

fn check_horizontal(letters: List(Row)) -> Int {
  letters
  |> list.map(check_row(_, 0))
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn to_diag(letters: List(Row)) -> List(Row) {
  case letters {
    [] -> []
    [a, ..rest] -> to_diag_loop([a], rest, [])
  }
}

fn read_row(process: List(Row)) -> #(Row, List(Row)) {
  process
  |> list.filter_map(fn(row) {
    case row {
      [a, ..rest] -> Ok(#(a, rest))
      [] -> Error(Nil)
    }
  })
  |> list.unzip
}

fn to_diag_loop(
  process: List(Row),
  remaining: List(Row),
  acc: List(Row),
) -> List(Row) {
  let #(row, process) = read_row(process)
  let acc = case row {
    [] -> acc
    row -> [row, ..acc]
  }
  case process, remaining {
    [], [] -> list.reverse(acc)
    p, [] -> to_diag_loop(p, [], acc)
    p, [a, ..rest] -> to_diag_loop(list.append(p, [a]), rest, acc)
  }
}

pub fn part1(input: String) -> Int {
  let letters =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(fn(row) { row |> string.to_graphemes })

  let permutations = [
    letters,
    list.transpose(letters),
    to_diag(letters),
    to_diag(list.reverse(letters)),
  ]

  permutations
  |> list.map(check_horizontal)
  |> list.fold(0, fn(a, b) { a + b })
}

// part2

type Grid =
  dict.Dict(Point, String)

// 0.2
// .X.
// 3.1
const offsets = [Point(-1, -1), Point(1, 1), Point(1, -1), Point(-1, 1)]

fn get_by_offsets(
  g: Grid,
  offsets: List(Point),
  index: Point,
) -> Result(List(String), Nil) {
  offsets
  |> list.map(fn(o) { point.add(index, o) })
  |> list.try_map(fn(idx) { dict.get(g, idx) })
}

fn check2(g: Grid, index: Point) -> Bool {
  case dict.get(g, index) {
    Ok("A") -> {
      case get_by_offsets(g, offsets, index) {
        Ok(l) ->
          case l {
            ["M", "S", "M", "S"] -> True
            ["M", "S", "S", "M"] -> True
            ["S", "M", "M", "S"] -> True
            ["S", "M", "S", "M"] -> True
            _ -> False
          }
        Error(_) -> False
      }
    }
    _ -> False
  }
}

pub fn part2(input: String) -> Int {
  let letters = util.map_to_dict(input)

  letters
  |> dict.keys
  |> list.filter(check2(letters, _))
  |> list.length
}

// part1 take #2

fn is_mas(g: Grid, offsets: List(Point), index: Point) -> Bool {
  case get_by_offsets(g, offsets, index) {
    Ok(["M", "A", "S"]) -> True
    _ -> False
  }
}

fn check1(g: Grid, dir_offsets: List(List(Point)), index: Point) -> Int {
  case dict.get(g, index) {
    Ok("X") -> {
      dir_offsets
      |> list.filter(is_mas(g, _, index))
      |> list.length
    }
    _ -> 0
  }
}

pub fn part1_2(input: String) -> Int {
  let dirs =
    [-1, 0, 1]
    |> list.flat_map(fn(x) {
      [-1, 0, 1]
      |> list.map(fn(y) { Point(x, y) })
    })
    |> list.filter(fn(d) { d != Point(0, 0) })

  let dir_offsets =
    dirs
    |> list.map(fn(p) { [p, point.scale(p, 2), point.scale(p, 3)] })

  let letters = util.map_to_dict(input)
  letters
  |> dict.keys
  |> list.map(fn(i) { check1(letters, dir_offsets, i) })
  |> list.fold(0, int.add)
}
