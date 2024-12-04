import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

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

fn parse_input(s: String) -> #(List(Int), List(Int)) {
  s
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_pair)
  |> list.unzip
}

pub fn part1(input: String) -> Int {
  let #(left, right) = input |> parse_input
  let a = left |> list.sort(int.compare)
  let b = right |> list.sort(int.compare)

  list.map2(a, b, fn(x, y) { x - y |> int.absolute_value })
  |> list.fold(0, fn(a, b) { a + b })
}

fn get_freq(d: dict.Dict(Int, List(Int)), i: Int) -> Int {
  dict.get(d, i)
  |> result.map(list.length)
  |> result.unwrap(0)
}

pub fn part2(input: String) -> Int {
  let #(left, right) = input |> parse_input

  let freq = right |> list.group(fn(i) { i })

  left
  |> list.map(fn(x) { get_freq(freq, x) * x })
  |> list.fold(0, fn(a, b) { a + b })
}
