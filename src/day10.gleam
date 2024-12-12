import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import point.{type Point, Point}
import util

fn edges(m: Dict(Point, Int)) -> Dict(Point, List(Point)) {
  m
  |> dict.to_list
  |> list.map(fn(x) {
    let #(p, h) = x
    let next =
      point.neighbours(p)
      // get heights
      |> list.filter_map(fn(n) {
        m
        |> dict.get(n)
        |> result.map(fn(nh) { #(n, nh) })
      })
      // filter jumps
      |> list.filter(fn(n) { n.1 - h == 1 })
      // map to just the point
      |> list.map(fn(n) { n.0 })
    #(p, next)
  })
  |> dict.from_list
}

fn walk(starts: List(Point), score: fn(Point) -> Int) -> Int {
  starts |> list.fold(0, fn(acc, p) { acc + score(p) })
}

fn score(p: Point, edges: Dict(Point, List(Point)), end: Set(Point)) -> Int {
  score_loop(p, edges, end) |> set.from_list |> set.size
}

fn score2(p: Point, edges: Dict(Point, List(Point)), end: Set(Point)) -> Int {
  score_loop(p, edges, end) |> list.length
}

fn score_loop(
  p: Point,
  edges: Dict(Point, List(Point)),
  end: Set(Point),
) -> List(Point) {
  case end |> set.contains(p) {
    True -> [p]
    False ->
      edges
      |> dict.get(p)
      |> result.unwrap([])
      |> list.flat_map(score_loop(_, edges, end))
  }
}

fn height_is(v: #(Point, Int), height: Int) -> Result(Point, Nil) {
  case v.1 == height {
    True -> Ok(v.0)
    False -> Error(Nil)
  }
}

fn parse(input: String) {
  let m =
    util.map_to_dict(input)
    |> dict.to_list
    |> list.map(fn(x) { #(x.0, util.parse_int(x.1)) })

  let zeros = m |> list.filter_map(height_is(_, 0))
  let nines = m |> list.filter_map(height_is(_, 9)) |> set.from_list

  let m = m |> dict.from_list

  let e = edges(m)

  #(e, zeros, nines)
}

pub fn part1(input: String) -> Int {
  let #(edges, zeros, nines) = parse(input)
  walk(zeros, score(_, edges, nines))
}

pub fn part2(input: String) -> Int {
  let #(edges, zeros, nines) = parse(input)
  walk(zeros, score2(_, edges, nines))
}
