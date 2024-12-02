import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const example = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

fn parse_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s)
  i
}

fn parse_line(s: String) -> List(Int) {
  s
  |> string.split(" ")
  |> list.map(parse_int)
}

fn diffs(l: List(Int)) -> List(Int) {
  l
  |> list.window_by_2
  |> list.map(fn(x) { x.0 - x.1 })
}

fn combos(l: List(Int)) -> List(List(Int)) {
  [l, ..list.combinations(l, list.length(l) - 1)]
}

fn safe(l: List(Int)) -> Bool {
  let d = l |> diffs
  let inc = d |> list.all(fn(x) { x >= 1 && x <= 3 })
  let dec = d |> list.all(fn(x) { x >= -3 && x <= -1 })
  inc || dec
}

pub fn part1() -> Nil {
  let assert Ok(input) = simplifile.read(from: "../day02.txt")
  // let input = example

  let safe =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(parse_line)
    |> list.filter(safe)
    |> list.length

  io.debug(safe)

  Nil
}

pub fn part2() -> Nil {
  let assert Ok(input) = simplifile.read(from: "../day02.txt")
  // let input = example

  let safe =
    input
    |> string.trim()
    |> string.split("\n")
    |> list.map(parse_line)
    |> list.map(combos)
    |> list.filter(fn(l) { l |> list.any(safe) })
    |> list.length

  io.debug(safe)

  Nil
}
