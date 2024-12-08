import gleam/dict
import gleam/list
import gleam/option.{None, Some}
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

type PointDir {
  PointDir(point: Point, dir: Dir)
}

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
  path(m, start) |> list.map(fn(pd) { pd.point }) |> set.from_list |> set.size
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
          True -> Ok({ pair.0 }.point)
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
  is_loop(m, dict.new(), start)
}

fn is_loop(m: Map, seen: PointDirDict, pd: PointDir) -> Bool {
  case seen |> pd_contains(pd) {
    True -> True
    False -> {
      let seen = seen |> pd_insert(pd)
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

type PointDirDict =
  dict.Dict(Point, Set(Dir))

fn pd_insert(d: PointDirDict, pd: PointDir) -> PointDirDict {
  d
  |> dict.upsert(pd.point, fn(o) {
    case o {
      Some(v) -> v |> set.insert(pd.dir)
      None -> [pd.dir] |> set.from_list
    }
  })
}

fn pd_contains(d: PointDirDict, pd: PointDir) -> Bool {
  case d |> dict.get(pd.point) {
    Error(_) -> False
    Ok(v) -> v |> set.contains(pd.dir)
  }
}

fn pd_delete(d: PointDirDict, pd: PointDir) -> PointDirDict {
  case d |> dict.get(pd.point) {
    Error(_) -> d
    Ok(v) -> {
      let v = v |> set.delete(pd.dir)
      case v |> set.size {
        0 -> d |> dict.delete(pd.point)
        _ -> d |> dict.insert(pd.point, v)
      }
    }
  }
}

// NOTE: we are going backwards through the path
fn get_obstacles(
  m: Map,
  path: List(PointDir),
  seen: PointDirDict,
  acc: Set(Point),
) -> Set(Point) {
  case path {
    [] -> acc
    // can't put an obstruction at the starting point
    [_] -> acc
    [a, b, ..rest] -> {
      // we've going backwards, so remove points from the seen set
      let seen = seen |> pd_delete(a) |> pd_delete(b)
      // add `a` to acc if `a` can be an obstacle
      let acc = case
        // can't have been a turn
        a.dir == b.dir
        // we can't have already crossed the point
        && !dict.has_key(seen, a.point)
        // and it creates a loop
        && is_loop(m |> dict.insert(a.point, Obs), seen, b)
      {
        True -> acc |> set.insert(a.point)
        False -> acc
      }
      get_obstacles(m, [b, ..rest], seen, acc)
    }
  }
}

pub fn part2_2(input: String) -> Int {
  let #(m, start) = parse(input)

  let path = path(m, start)

  let seen = path |> list.fold(dict.new(), fn(acc, pd) { acc |> pd_insert(pd) })

  get_obstacles(m, path, seen, set.new()) |> set.size
}
