import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import point.{type Point, Point}
import util

fn next(unvisited: Dict(Point, Int)) -> #(Point, Int) {
  // sort by the score
  let sorted =
    unvisited
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare({ a.1 }, { b.1 }) })
  // take the first sorted node
  case sorted {
    [] -> panic as "no nodes left"
    [a, ..] -> a
  }
}

fn neighbours(p: Point, size: Int, corrupted: Set(Point)) -> List(Point) {
  point.neighbours(p)
  |> list.filter(fn(n) { n.x >= 0 && n.x <= size && n.y >= 0 && n.y <= size })
  |> list.filter(fn(n) { !{ corrupted |> set.contains(n) } })
}

fn walk(
  unvisited: Dict(Point, Int),
  visited: Dict(Point, Int),
  neighbours: fn(Point) -> List(Point),
  end: Point,
) -> Result(Int, Nil) {
  case unvisited |> dict.is_empty {
    True -> Error(Nil)
    False -> {
      // find the unvisited with the lowest score
      let #(p, best) = next(unvisited)

      case p == end {
        True -> Ok(best)
        False -> {
          let visited = visited |> dict.insert(p, best)

          let unvisited =
            neighbours(p)
            |> list.fold(unvisited, fn(acc, n) {
              let score = best + 1
              acc
              |> dict.upsert(n, fn(v) {
                case v {
                  Some(v) -> int.min(v, score)
                  None -> score
                }
              })
            })
            // drop any visited nodes
            |> dict.drop(visited |> dict.keys)

          walk(unvisited, visited, neighbours, end)
        }
      }
    }
  }
}

fn parse(input: String) -> List(Point) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let #(x, y) = case line |> string.split_once(",") {
      Ok(v) -> v
      Error(_) -> panic as { "failed to split: " <> line }
    }
    Point(util.parse_int(x), util.parse_int(y))
  })
}

pub fn part1(input: String, size: Int, fallen: Int) -> Int {
  let unvisited = [#(Point(0, 0), 0)] |> dict.from_list
  let end = Point(size, size)
  let corrupted = input |> parse |> list.take(fallen) |> set.from_list

  walk(unvisited, dict.new(), neighbours(_, size, corrupted), end)
  |> util.unwrap_or_panic
}

fn blocker(
  bytes: List(Point),
  end: Point,
  from: Int,
  to: Int,
  size: Int,
) -> Point {
  case from == to {
    True -> {
      bytes
      |> list.drop(from - 1)
      |> list.first
      |> util.unwrap_or_panic
    }
    False -> {
      // bisect
      let mid = from + { to - from } / 2
      let corrupted = bytes |> list.take(mid) |> set.from_list
      let unvisited = [#(Point(0, 0), 0)] |> dict.from_list

      case walk(unvisited, dict.new(), neighbours(_, size, corrupted), end) {
        Error(_) -> blocker(bytes, end, from, mid, size)
        Ok(_) -> blocker(bytes, end, mid + 1, to, size)
      }
    }
  }
}

pub fn part2(input: String, size: Int, fallen: Int) -> String {
  let end = Point(size, size)
  let bytes = input |> parse
  let p = blocker(bytes, end, fallen, bytes |> list.length, size)
  int.to_string(p.x) <> "," <> int.to_string(p.y)
}
