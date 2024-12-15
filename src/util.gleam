import gleam/dict
import gleam/int
import gleam/io
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

fn print_line(p: Point, m: dict.Dict(Point, a), f: fn(a) -> String) {
  case m |> dict.get(p) {
    Ok(c) -> {
      io.print(f(c))
      print_line(point.add(p, Point(1, 0)), m, f)
    }
    Error(_) -> {
      io.print("\n")
      let next = Point(0, p.y + 1)
      case m |> dict.get(next) {
        Ok(_) -> print_line(next, m, f)
        Error(_) -> Nil
      }
    }
  }
}

pub fn print_map(m: dict.Dict(Point, a), f: fn(a) -> String) {
  print_line(Point(0, 0), m, f)
}
