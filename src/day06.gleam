import gleam/dict
import gleam/list
import gleam/set.{type Set}
import point.{type Point, Point}
import util

type Block {
  Free
  // Obstruction
  Obs
}

type Dir {
  Up
  Down
  Left
  Right
}

type Map =
  dict.Dict(Point, Block)

fn turn(dir: Dir) -> Dir {
  case dir {
    Up -> Right
    Down -> Left
    Left -> Up
    Right -> Down
  }
}

fn move(dir: Dir) -> Point {
  case dir {
    Up -> Point(0, -1)
    Down -> Point(0, 1)
    Left -> Point(-1, 0)
    Right -> Point(1, 0)
  }
}

fn char_to_block(c: String) -> Block {
  case c {
    "." -> Free
    "#" -> Obs
    _ -> {
      let msg = "unexpected block: " <> c
      panic as msg
    }
  }
}

fn extract_guard(
  m: dict.Dict(Point, String),
) -> #(dict.Dict(Point, String), Point) {
  // get the guard position
  let guard = m |> dict.filter(fn(_, v) { v == "^" }) |> dict.to_list
  case guard {
    [g] -> {
      // mark the gaurd square as free
      #(m |> dict.insert(g.0, "."), g.0)
    }
    _ -> panic as "guards != 1"
  }
}

fn walk(m: Map, start: PointDir) -> Int {
  walk_loop(m, set.new(), start)
}

fn walk_loop(m: Map, seen: Set(Point), pd: PointDir) -> Int {
  let seen = set.insert(seen, pd.point)
  let next = point.add(pd.point, move(pd.dir))
  case dict.get(m, next) {
    Error(_) -> {
      // next point is not on the map, return the set size
      set.size(seen)
    }
    Ok(block) -> {
      case block {
        Free -> walk_loop(m, seen, PointDir(next, pd.dir))
        Obs -> walk_loop(m, seen, PointDir(pd.point, turn(pd.dir)))
      }
    }
  }
}

fn parse(input: String) -> #(dict.Dict(Point, Block), PointDir) {
  let m = util.map_to_dict(input)
  let #(m, start) = extract_guard(m)

  let m =
    m
    |> dict.to_list
    |> list.map(fn(i) { #(i.0, char_to_block(i.1)) })
    |> dict.from_list

  #(m, PointDir(start, Up))
}

pub fn part1(input: String) -> Int {
  let #(m, start) = parse(input)
  walk(m, start)
}

type PointDir {
  PointDir(point: Point, dir: Dir)
}

fn path(m: Map, start: PointDir) -> List(PointDir) {
  path_loop(m, [], start)
}

fn path_loop(m: Map, acc: List(PointDir), pd: PointDir) -> List(PointDir) {
  let acc = [pd, ..acc]
  let next = point.add(pd.point, move(pd.dir))
  case dict.get(m, next) {
    Error(_) -> acc
    Ok(block) -> {
      case block {
        Free -> path_loop(m, acc, PointDir(next, pd.dir))
        Obs -> path_loop(m, acc, PointDir(pd.point, turn(pd.dir)))
      }
    }
  }
}

// anywhere on the path where we continue straight
// or the last point on the path
fn get_possible_obs(path: List(PointDir)) -> Set(Point) {
  case path {
    [] -> set.new()
    [h, ..] -> {
      path
      |> list.window_by_2
      |> list.filter_map(fn(pair) {
        case { pair.0 }.dir == { pair.1 }.dir {
          True -> Ok({ pair.1 }.point)
          False -> Error(Nil)
        }
      })
      |> set.from_list
      |> set.insert(h.point)
    }
  }
}

fn test_obs(m: Map, start: PointDir, o: Point) -> Bool {
  let m = m |> dict.insert(o, Obs)
  is_loop(m, set.new(), start)
}

fn is_loop(m: Map, seen: Set(PointDir), pd: PointDir) -> Bool {
  case seen |> set.contains(pd) {
    True -> True
    False -> {
      let seen = seen |> set.insert(pd)
      let next = point.add(pd.point, move(pd.dir))
      case dict.get(m, next) {
        Error(_) -> {
          // next point is not on the map
          False
        }
        Ok(block) -> {
          case block {
            Free -> is_loop(m, seen, PointDir(next, pd.dir))
            Obs -> is_loop(m, seen, PointDir(pd.point, turn(pd.dir)))
          }
        }
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let #(m, start) = parse(input)

  path(m, start)
  |> get_possible_obs
  |> set.filter(test_obs(m, start, _))
  |> set.size
}
