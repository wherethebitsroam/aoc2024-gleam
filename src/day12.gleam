import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import point.{type Point, Point}
import util

pub type Area {
  Area(letter: String, points: Set(Point))
}

type Dir {
  Horizontal
  Vertical
}

type Edge {
  Edge(dir: Dir, on: Int, from: Int, to: Int)
}

fn to_edges(p: Point) -> List(Edge) {
  [
    Edge(Horizontal, p.y, p.x, p.x + 1),
    Edge(Horizontal, p.y + 1, p.x, p.x + 1),
    Edge(Vertical, p.x, p.y, p.y + 1),
    Edge(Vertical, p.x + 1, p.y, p.y + 1),
  ]
}

fn area(a: Area) -> Int {
  a.points |> set.size
}

// get all edges for all points, then remove all that appear more than
// once - those are internal edges
fn edges(a: Area) -> List(Edge) {
  a.points
  |> set.to_list
  |> list.flat_map(to_edges)
  |> list.group(fn(x) { x })
  |> dict.to_list
  |> list.filter(fn(ec) { ec.1 |> list.length == 1 })
  |> list.map(pair.first)
}

fn perimeter(a: Area) -> Int {
  a |> edges |> list.length
}

fn sides(a: Area) -> Int {
  a |> edges |> sides_loop([], a) |> list.length
}

// collect connected edges into sides
fn sides_loop(edges: List(Edge), sides: List(Edge), a: Area) -> List(Edge) {
  case edges {
    [] -> sides
    [e, ..rest] -> {
      let #(side, rest) = connect(e, rest, a)
      sides_loop(rest, [side, ..sides], a)
    }
  }
}

fn point_on_edge(e: Edge) -> Point {
  case e.dir {
    Horizontal -> Point(e.from, e.on)
    Vertical -> Point(e.on, e.from)
  }
}

fn connect(side: Edge, rest: List(Edge), a: Area) -> #(Edge, List(Edge)) {
  // we need to also make sure the the "area" remains on the side side
  let area_on_side = a.points |> set.contains(point_on_edge(side))
  let #(connected, rest) =
    rest
    |> list.partition(fn(e) {
      e.dir == side.dir
      && e.on == side.on
      && { e.from == side.to || e.to == side.from }
      && area_on_side == a.points |> set.contains(point_on_edge(e))
    })
  case connected {
    // no more edges to connection, we're done
    [] -> #(side, rest)
    // connect the edges in l to the side
    l -> {
      // from is the min of the froms
      let from = l |> list.fold(side.from, fn(acc, e) { int.min(e.from, acc) })
      // to is the max of the tos
      let to = l |> list.fold(side.to, fn(acc, e) { int.max(e.to, acc) })
      // increase the size of the side
      let side = Edge(side.dir, side.on, from, to)
      // check we have any more edges to connect
      connect(side, rest, a)
    }
  }
}

fn group(m: Dict(Point, String)) -> List(Area) {
  group_loop(m, [])
}

fn group_loop(m: Dict(Point, String), acc: List(Area)) -> List(Area) {
  case m |> dict.to_list {
    [] -> acc
    [f, ..] -> {
      let #(m, area) = group_area(m, [f.0], Area(f.1, set.new()))
      group_loop(m, [area, ..acc])
    }
  }
}

fn group_area(
  m: Dict(Point, String),
  process: List(Point),
  area: Area,
) -> #(Dict(Point, String), Area) {
  case process {
    [] -> #(m, area)
    [p, ..rest] -> {
      // add to the area
      let area = Area(area.letter, area.points |> set.insert(p))
      // remove from the dict
      let m = m |> dict.delete(p)
      // get the neighbours with the same letter
      let next =
        point.neighbours(p)
        // get 
        |> list.filter_map(fn(n) {
          m
          |> dict.get(n)
          |> result.map(fn(nletter) { #(n, nletter) })
        })
        // filter same letter
        |> list.filter(fn(n) { n.1 == area.letter })
        // map to just the point
        |> list.map(fn(n) { n.0 })

      // make sure the process list is unique
      let process = rest |> list.append(next) |> set.from_list |> set.to_list
      group_area(m, process, area)
    }
  }
}

pub fn part1(input: String) -> Int {
  util.map_to_dict(input)
  |> group
  |> list.map(fn(a) { area(a) * perimeter(a) })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  util.map_to_dict(input)
  |> group
  |> list.map(fn(a) { area(a) * sides(a) })
  |> list.fold(0, int.add)
}
