import gleam/int
import gleam/list
import gleam/string

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

pub fn part1(input: String) -> Int {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_line)
  |> list.filter(safe)
  |> list.length
}

pub fn part2(input: String) -> Int {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.map(parse_line)
  |> list.map(combos)
  |> list.filter(fn(l) { l |> list.any(safe) })
  |> list.length
}
