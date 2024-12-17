import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import point.{type Point, Point}
import util

type Dir {
  Up
  Down
  Left
  Right
}

type PointDir {
  PointDir(point: Point, dir: Dir)
}

fn move(p: Point, dir: Dir) -> Point {
  case dir {
    Up -> Point(0, -1)
    Down -> Point(0, 1)
    Left -> Point(-1, 0)
    Right -> Point(1, 0)
  }
  |> point.add(p)
}

fn find(m: Dict(Point, String), s: String) -> Result(Point, Nil) {
  m
  |> dict.to_list
  |> list.find(fn(x) { x.1 == s })
  |> result.map(pair.first)
}

fn parse(m: Dict(Point, String)) -> #(Point, Point, Dict(Point, List(Point))) {
  let s = m |> find("S") |> util.unwrap_or_panic
  let e = m |> find("E") |> util.unwrap_or_panic

  // filter out the walls
  let m = m |> dict.filter(fn(_, s) { s == "S" || s == "E" || s == "." })

  // map each point to it's neighbours
  let m =
    m
    |> dict.map_values(fn(p, _) {
      p
      |> point.neighbours
      |> list.filter(fn(n) { m |> dict.has_key(n) })
    })

  #(s, e, m)
}

fn dir(p: Point, n: Point) -> Dir {
  case point.sub(n, p) {
    Point(0, -1) -> Up
    Point(0, 1) -> Down
    Point(-1, 0) -> Left
    Point(1, 0) -> Right
    _ ->
      panic as {
        "not neightbours? " <> point.to_string(p) <> ", " <> point.to_string(n)
      }
  }
}

fn points(p: Point, d: Dir, n: Point) -> Int {
  case move(p, d) == n {
    True -> 1
    // turn plus move
    False -> 1001
  }
}

type State {
  State(best: Int, from: Set(PointDir))
}

fn next(unvisited: Dict(PointDir, State)) -> #(PointDir, State) {
  // sort by the score
  let sorted =
    unvisited
    |> dict.to_list
    |> list.sort(fn(a, b) { int.compare({ a.1 }.best, { b.1 }.best) })
  // take the first sorted node
  case sorted {
    [] -> panic as "no nodes left"
    [a, ..] -> a
  }
}

fn walk(
  ps: Dict(Point, List(Point)),
  unvisited: Dict(PointDir, State),
  visited: Dict(PointDir, State),
) -> Dict(PointDir, State) {
  // find the unvisited with the lowest score
  let #(pd, state) = next(unvisited)

  let visited = visited |> dict.insert(pd, state)

  let unvisited =
    ps
    |> dict.get(pd.point)
    |> util.unwrap_or_panic
    |> list.fold(unvisited, fn(acc, n) {
      let npd = PointDir(n, dir(pd.point, n))
      let next_points = state.best + points(pd.point, pd.dir, n)
      acc
      |> dict.upsert(npd, fn(v) {
        case v {
          Some(v) -> {
            case int.compare(next_points, v.best) {
              order.Eq -> State(v.best, v.from |> set.insert(pd))
              order.Gt -> v
              order.Lt -> State(next_points, [pd] |> set.from_list)
            }
          }
          None -> State(next_points, [pd] |> set.from_list)
        }
      })
    })
    // drop any visited nodes
    |> dict.drop(visited |> dict.keys)

  case unvisited |> dict.is_empty {
    True -> visited
    False -> walk(ps, unvisited, visited)
  }
}

pub fn part1(input: String) -> Int {
  let #(s, e, ps) = util.map_to_dict(input) |> parse

  let unvisited = [#(PointDir(s, Right), State(0, set.new()))] |> dict.from_list

  walk(ps, unvisited, dict.new())
  |> dict.to_list
  |> list.filter_map(fn(x) {
    case { x.0 }.point == e {
      True -> Ok({ x.1 }.best)
      False -> Error(Nil)
    }
  })
  |> list.reduce(int.min)
  |> util.unwrap_or_panic
}

fn walk_back(
  visited: Dict(PointDir, State),
  remaining: Set(PointDir),
  acc: Set(PointDir),
) -> Set(Point) {
  case remaining |> set.to_list {
    [] -> acc |> set.map(fn(pd) { pd.point })
    [pd, ..rest] -> {
      let acc = acc |> set.insert(pd)
      case visited |> dict.get(pd) {
        Error(_) -> panic as "blah"
        Ok(s) -> {
          let remaining =
            rest
            |> set.from_list
            |> set.union(s.from)
          walk_back(visited, remaining, acc)
        }
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let #(s, e, ps) = util.map_to_dict(input) |> parse

  let unvisited = [#(PointDir(s, Right), State(0, set.new()))] |> dict.from_list

  let visited = walk(ps, unvisited, dict.new())

  // get the best end points
  let end =
    [PointDir(e, Right), PointDir(e, Up)]
    |> list.filter_map(fn(pd) {
      visited |> dict.get(pd) |> result.map(fn(s) { #(pd, s) })
    })
    |> list.fold(#(set.new(), 1_000_000), fn(acc, x) {
      let #(pd, s) = x
      case int.compare(s.best, acc.1) {
        order.Gt -> acc
        order.Lt -> #([pd] |> set.from_list, s.best)
        order.Eq -> #(acc.0 |> set.insert(pd), s.best)
      }
    })
    |> pair.first

  walk_back(visited, end, set.new()) |> set.size
}
