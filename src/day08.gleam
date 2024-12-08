import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import point.{type Point, Point}
import util

type OnMapPairFn =
  fn(fn(Point) -> Bool, #(Point, Point)) -> List(Point)

type PairFn =
  fn(#(Point, Point)) -> List(Point)

fn antinodes(m: dict.Dict(point.Point, String), pair_fn: OnMapPairFn) -> Int {
  let max =
    m
    |> dict.fold(Point(0, 0), fn(acc, k, _) {
      Point(int.max(k.x, acc.x), int.max(k.y, acc.y))
    })

  let on_map = fn(p: Point) {
    p.x >= 0 && p.x <= max.x && p.y >= 0 && p.y <= max.y
  }

  let pair_fn = pair_fn(on_map, _)

  m
  |> dict.to_list
  // filter out the "."
  |> list.filter(fn(x) { x.1 != "." })
  // group by letter
  |> list.fold(dict.new(), fn(d, x) {
    d
    |> dict.upsert(x.1, fn(v) {
      case v {
        Some(v) -> [x.0, ..v]
        None -> [x.0]
      }
    })
  })
  |> dict.fold(set.new(), fn(acc, _, ps) {
    // compare pairwise to get antinodes.
    antinodes_by_letter(ps, acc, pair_fn)
  })
  |> set.filter(on_map)
  |> set.size
}

pub fn antinodes_by_letter(
  ps: List(Point),
  acc: Set(Point),
  pair_fn: PairFn,
) -> Set(Point) {
  ps
  |> list.combination_pairs
  |> list.fold(acc, fn(acc, pair) {
    pair_fn(pair) |> set.from_list |> set.union(acc)
  })
}

pub fn antinodes_by_pair(pair: #(Point, Point)) -> List(Point) {
  let a = pair.0
  let b = pair.1
  let d = point.sub(b, a)
  [point.sub(a, d), point.add(b, d)]
}

pub fn part1(input: String) -> Int {
  util.map_to_dict(input) |> antinodes(fn(_, pair) { antinodes_by_pair(pair) })
}

fn antinodes_by_pair2(
  on_map: fn(Point) -> Bool,
  pair: #(Point, Point),
) -> List(Point) {
  let a = pair.0
  let b = pair.1
  let d = point.sub(b, a)

  let backwards = points_while(on_map, point.sub(_, d), [], a)
  let forwards = points_while(on_map, point.add(_, d), [], b)

  backwards |> list.append(forwards)
}

fn points_while(
  check: fn(Point) -> Bool,
  next: fn(Point) -> Point,
  acc: List(Point),
  p: Point,
) -> List(Point) {
  case check(p) {
    False -> acc
    True -> points_while(check, next, [p, ..acc], next(p))
  }
}

pub fn part2(input: String) -> Int {
  util.map_to_dict(input) |> antinodes(antinodes_by_pair2)
}
