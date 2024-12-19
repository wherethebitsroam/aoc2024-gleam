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
  ps: Dict(Point, List(Point)),
  unvisited: Dict(Point, Int),
  visited: Dict(Point, Int),
  corrupted: Set(Point),
  // neighbours: fn(Point) -> List(Point),
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
            ps
            |> dict.get(p)
            |> util.unwrap_or_panic
            |> list.filter(fn(n) { !{ corrupted |> set.contains(n) } })
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

          walk(ps, unvisited, visited, corrupted, end)
        }
      }
    }
  }
}

fn parse(input: String, size: Int) -> #(Dict(Point, List(Point)), List(Point)) {
  let bytes =
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

  #(map_loop(0, 0, size, dict.new()), bytes)
}

fn map_loop(
  x: Int,
  y: Int,
  size: Int,
  acc: Dict(Point, List(Point)),
) -> Dict(Point, List(Point)) {
  case y > size {
    True -> acc
    False ->
      case x > size {
        True -> map_loop(0, y + 1, size, acc)
        False -> {
          let p = Point(x, y)
          let ns =
            point.neighbours(p)
            |> list.filter(fn(n) {
              n.x >= 0 && n.x <= size && n.y >= 0 && n.y <= size
            })

          map_loop(x + 1, y, size, acc |> dict.insert(p, ns))
        }
      }
  }
}

pub fn part1(input: String, size: Int, fallen: Int) -> Int {
  let unvisited = [#(Point(0, 0), 0)] |> dict.from_list
  let end = Point(size, size)
  let #(m, bytes) = input |> parse(size)

  let corrupted = bytes |> list.take(fallen) |> set.from_list

  walk(m, unvisited, dict.new(), corrupted, end) |> util.unwrap_or_panic
}

fn blocker(
  ps: Dict(Point, List(Point)),
  bytes: List(Point),
  end: Point,
  from: Int,
  to: Int,
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

      case walk(ps, unvisited, dict.new(), corrupted, end) {
        Error(_) -> blocker(ps, bytes, end, from, mid)
        Ok(_) -> blocker(ps, bytes, end, mid + 1, to)
      }
    }
  }
}

pub fn part2(input: String, size: Int, fallen: Int) -> String {
  let end = Point(size, size)
  let #(m, bytes) = input |> parse(size)
  let p = blocker(m, bytes, end, fallen, bytes |> list.length)
  int.to_string(p.x) <> "," <> int.to_string(p.y)
}
