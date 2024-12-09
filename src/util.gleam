import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import point.{type Point, Point}

pub fn map_to_dict(input: String) -> dict.Dict(Point, String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.index_map(fn(row, y) {
    row
    |> string.to_graphemes
    |> list.index_map(fn(c, x) { #(Point(x, y), c) })
  })
  |> list.flatten
  |> dict.from_list
}

pub fn parse_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s)
  i
}
