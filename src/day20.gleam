import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import point.{type Point, Point}
import util

fn find(m: Dict(Point, String), s: String) -> Result(Point, Nil) {
  m
  |> dict.to_list
  |> list.find_map(fn(x) {
    case x.1 == s {
      True -> Ok(x.0)
      False -> Error(Nil)
    }
  })
}

type Shortcut {
  Shortcut(to: Point, saves: Int)
}

type Details {
  Details(dist: Int, shortcuts: List(Shortcut))
}

fn next(
  p: Point,
  m: Dict(Point, String),
  from: option.Option(Point),
) -> Result(Point, Nil) {
  let ns =
    p
    |> point.neighbours
    |> list.filter(fn(n) {
      case m |> dict.get(n) {
        Ok(s) ->
          s != "#"
          && case from {
            Some(f) -> n != f
            None -> True
          }
        Error(_) -> False
      }
    })
  case ns {
    [p] -> Ok(p)
    _ -> Error(Nil)
  }
}

fn turn(p1: Point, p2: Point) -> Bool {
  p1.x != p2.x && p1.y != p2.y
}

fn walk(
  start: Point,
  end: Point,
  m: Dict(Point, String),
) -> Dict(Point, Details) {
  let next = next(end, m, None) |> util.unwrap_or_panic
  let acc = [#(end, Details(0, []))] |> dict.from_list
  walk_loop(next, end, 1, m, acc, start)
}

fn walk_loop(
  p: Point,
  from: Point,
  dist: Int,
  m: Dict(Point, String),
  acc: Dict(Point, Details),
  start: Point,
) -> Dict(Point, Details) {
  let shortcuts = find_shortcuts(p, from, dist, m, acc)
  let acc = acc |> dict.insert(p, Details(dist, shortcuts))
  case p == start {
    True -> acc
    False -> {
      let next = next(p, m, Some(from)) |> util.unwrap_or_panic
      walk_loop(next, p, dist + 1, m, acc, start)
    }
  }
}

fn find_shortcuts(
  p: Point,
  from: Point,
  dist: Int,
  m: Dict(Point, String),
  path: Dict(Point, Details),
) -> List(Shortcut) {
  p
  |> point.neighbours
  // we don't go back the way we came
  |> list.filter(fn(n) { n != from })
  // neighbour must be a wall
  |> list.filter(fn(n) {
    case m |> dict.get(n) {
      Error(_) -> False
      Ok(s) -> s == "#"
    }
  })
  |> list.filter_map(fn(n) {
    let dir = point.sub(n, p)
    let dest = point.add(n, dir)
    case path |> dict.get(dest) {
      Error(_) -> Error(Nil)
      // -2 because taking the shortcut takes 2 moves
      Ok(details) -> Ok(Shortcut(dest, dist - details.dist - 2))
    }
  })
}

pub fn part1(input: String, limit: Int) -> Int {
  let m = util.map_to_dict(input)
  let start = m |> find("S") |> util.unwrap_or_panic
  let end = m |> find("E") |> util.unwrap_or_panic

  let path = walk(start, end, m)

  path
  |> dict.values
  |> list.flat_map(fn(d) { d.shortcuts })
  |> list.group(fn(s) { s.saves })
  |> dict.to_list
  |> list.map(fn(x) { #(x.0, x.1 |> list.length) })
  |> list.filter(fn(x) { x.0 >= limit })
  |> list.fold(0, fn(acc, x) { acc + x.1 })
}

pub fn part2(input: String) -> Int {
  0
}
