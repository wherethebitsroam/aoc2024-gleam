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
      [
        point.add(p, Point(1, 0)),
        point.add(p, Point(-1, 0)),
        point.add(p, Point(0, 1)),
        point.add(p, Point(0, -1)),
      ]
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

fn walk(
  edges: Dict(Point, List(Point)),
  starts: List(Point),
  end: Set(Point),
) -> Int {
  walk_loop(edges, starts, end, 0)
}

fn walk_loop(
  edges: Dict(Point, List(Point)),
  starts: List(Point),
  end: Set(Point),
  acc: Int,
) -> Int {
  case starts {
    [] -> acc
    [s, ..rest] -> {
      let score = score_walk(s, edges, end) |> set.size
      walk_loop(edges, rest, end, acc + score)
    }
  }
}

fn score_walk(
  p: Point,
  edges: Dict(Point, List(Point)),
  end: Set(Point),
) -> Set(Point) {
  // see if we've reached the end of the trail
  case end |> set.contains(p) {
    True -> [p] |> set.from_list
    False -> {
      case edges |> dict.get(p) {
        // if we've got no edges out from this point, we're done
        Error(_) -> set.new()
        Ok(l) -> {
          l
          |> list.map(score_walk(_, edges, end))
          |> list.fold(set.new(), set.union)
        }
      }
    }
  }
}

fn walk2(
  edges: Dict(Point, List(Point)),
  starts: List(Point),
  end: Set(Point),
) -> Int {
  walk_loop2(edges, starts, end, 0)
}

fn walk_loop2(
  edges: Dict(Point, List(Point)),
  starts: List(Point),
  end: Set(Point),
  acc: Int,
) -> Int {
  case starts {
    [] -> acc
    [s, ..rest] -> {
      let score = score_walk2(s, edges, end)
      walk_loop2(edges, rest, end, acc + score)
    }
  }
}

fn score_walk2(
  p: Point,
  edges: Dict(Point, List(Point)),
  end: Set(Point),
) -> Int {
  // see if we've reached the end of the trail
  case end |> set.contains(p) {
    True -> {
      // io.debug(#(p, "at end"))
      1
    }
    False -> {
      // io.debug(#(p, "not at end"))
      case edges |> dict.get(p) {
        // if we've got no edges out from this point, we're done
        Error(_) -> 0
        Ok(l) -> {
          // io.debug(l)
          l
          |> list.map(score_walk2(_, edges, end))
          |> list.fold(0, fn(a, b) { a + b })
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let m =
    util.map_to_dict(input)
    |> dict.to_list
    |> list.map(fn(x) { #(x.0, util.parse_int(x.1)) })

  let zeros =
    m
    |> list.filter_map(fn(x) {
      case x.1 {
        0 -> Ok(x.0)
        _ -> Error(Nil)
      }
    })

  let nines =
    m
    |> list.filter_map(fn(x) {
      case x.1 {
        9 -> Ok(x.0)
        _ -> Error(Nil)
      }
    })
    |> set.from_list

  let m = m |> dict.from_list

  let e = edges(m)

  walk(e, zeros, nines)
}

pub fn part2(input: String) -> Int {
  let m =
    util.map_to_dict(input)
    |> dict.to_list
    |> list.map(fn(x) { #(x.0, util.parse_int(x.1)) })

  let zeros =
    m
    |> list.filter_map(fn(x) {
      case x.1 {
        0 -> Ok(x.0)
        _ -> Error(Nil)
      }
    })

  let nines =
    m
    |> list.filter_map(fn(x) {
      case x.1 {
        9 -> Ok(x.0)
        _ -> Error(Nil)
      }
    })
    |> set.from_list

  let m = m |> dict.from_list

  let e = edges(m)

  walk2(e, zeros, nines)
}
