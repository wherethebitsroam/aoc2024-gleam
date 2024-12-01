import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

const example = "3   4
4   3
2   5
1   3
3   9
3   3"

fn parse_pair(pair: String) -> #(Int, Int) {
  let assert Ok(x) = pair |> string.split_once("   ")
  let assert Ok(f) = x.0 |> int.parse
  let assert Ok(s) = x.1 |> int.parse
  #(f, s)
}

fn split_lists(
  list: List(#(Int, Int)),
  a: List(Int),
  b: List(Int),
) -> #(List(Int), List(Int)) {
  case list {
    [first, ..rest] -> split_lists(rest, [first.0, ..a], [first.1, ..b])
    [] -> #(a, b)
  }
}

fn sum_list(list: List(Int), total: Int) -> Int {
  case list {
    [first, ..rest] -> sum_list(rest, total + first)
    [] -> total
  }
}

pub fn part1() -> Nil {
  let assert Ok(input) = simplifile.read(from: "../day01.txt")

  let pairs =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(parse_pair)
    |> split_lists([], [])

  let a = pairs.0 |> list.sort(int.compare)
  let b = pairs.1 |> list.sort(int.compare)

  let x =
    list.map2(a, b, fn(x, y) { x - y |> int.absolute_value })
    |> sum_list(0)

  io.debug(x)

  Nil
}

fn get_freq(d: dict.Dict(Int, List(Int)), i: Int) -> Int {
  case dict.get(d, i) {
    Ok(l) -> list.length(l)
    Error(_) -> 0
  }
}

pub fn part2() -> Nil {
  let assert Ok(input) = simplifile.read(from: "../day01.txt")
  // let input = example

  let pairs =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(parse_pair)
    |> split_lists([], [])

  let freq = pairs.1 |> list.group(fn(i) { i })

  let score =
    pairs.0
    |> list.map(fn(x) { get_freq(freq, x) * x })
    |> sum_list(0)

  io.debug(score)

  Nil
}
