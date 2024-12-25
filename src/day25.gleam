import gleam/dict
import gleam/list
import gleam/set
import gleam/string
import point.{type Point, Point}
import util

fn parse(input: String) {
  input
  |> string.trim
  |> string.split("\n\n")
  |> list.fold(#([], []), fn(acc, schema) {
    let #(keys, locks) = acc

    let m =
      util.map_to_dict(schema)
      |> dict.to_list
      |> list.filter(fn(pv) { pv.1 == "#" })
      |> list.map(fn(pv) { pv.0 })
      |> set.from_list

    case m |> set.contains(Point(0, 0)) {
      True -> #(keys, [m, ..locks])
      False -> #([m, ..keys], locks)
    }
  })
}

pub fn part1(input: String) -> Int {
  let #(keys, locks) = input |> parse

  keys
  |> list.fold(0, fn(acc, key) {
    locks
    |> list.fold(acc, fn(acc, lock) {
      case key |> set.is_disjoint(lock) {
        True -> acc + 1
        False -> acc
      }
    })
  })
}
