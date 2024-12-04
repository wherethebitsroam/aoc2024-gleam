import gleam/dict
import gleam/list
import gleam/string

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
  dict.Dict(#(Int, Int), String)

fn make_dict(input: String) -> Grid {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(c, x) { #(#(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

// 0.2
// .X.
// 3.1
const offsets = [#(-1, -1), #(1, 1), #(1, -1), #(-1, 1)]

fn get_by_offsets(
  g: Grid,
  offsets: List(#(Int, Int)),
  index: #(Int, Int),
) -> Result(List(String), Nil) {
  offsets
  |> list.map(fn(o) { #(index.0 + o.0, index.1 + o.1) })
  |> list.try_map(fn(idx) { dict.get(g, idx) })
}

fn check2(g: Grid, index: #(Int, Int)) -> Bool {
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
  let letters = make_dict(input)

  letters
  |> dict.keys
  |> list.filter(check2(letters, _))
  |> list.length
}

// part1 take #2

fn is_mas(g: Grid, offsets: List(#(Int, Int)), index: #(Int, Int)) -> Bool {
  case get_by_offsets(g, offsets, index) {
    Ok(["M", "A", "S"]) -> True
    _ -> False
  }
}

fn check1(
  g: Grid,
  dir_offsets: List(List(#(Int, Int))),
  index: #(Int, Int),
) -> Int {
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
      |> list.map(fn(y) { #(x, y) })
    })
    |> list.filter(fn(d) { d != #(0, 0) })

  let dir_offsets =
    dirs
    |> list.map(fn(d) { [d, #(d.0 * 2, d.1 * 2), #(d.0 * 3, d.1 * 3)] })

  let letters = make_dict(input)
  letters
  |> dict.keys
  |> list.map(fn(i) { check1(letters, dir_offsets, i) })
  |> list.fold(0, fn(a, b) { a + b })
}
