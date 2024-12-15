import gleam/dict.{type Dict}
import gleam/erlang
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import point.{type Point, Point}
import util

fn red(s: String) -> String {
  "\u{001b}[31m" <> s <> "\u{001b}[0m"
}

fn green(s: String) -> String {
  "\u{001b}[38;5;2m" <> s <> "\u{001b}[0m"
}

fn clear() -> String {
  "\u{001b}[2J\u{001b}[H"
}

type Cell {
  Wall
  Empty
  Box
  BoxL
  BoxR
  Robot
}

fn cell_to_string(cell: Cell) -> String {
  case cell {
    Wall -> "#"
    Empty -> "."
    Box -> "O"
    BoxL -> "["
    BoxR -> "]"
    Robot -> green("@")
  }
}

type Dir {
  Up
  Down
  Left
  Right
}

fn dir_to_string(d: Dir) -> String {
  case d {
    Up -> "^"
    Down -> "v"
    Left -> "<"
    Right -> ">"
  }
}

fn move(p: Point, d: Dir) -> Point {
  case d {
    Up -> point.add(p, Point(0, -1))
    Down -> point.add(p, Point(0, 1))
    Left -> point.add(p, Point(-1, 0))
    Right -> point.add(p, Point(1, 0))
  }
}

fn find_robot(map: Dict(Point, Cell)) -> Point {
  case map |> dict.to_list |> list.find(fn(x) { x.1 == Robot }) {
    Ok(x) -> x.0
    Error(_) -> panic as "failed to find robot"
  }
}

fn parse_map(s: String) -> Dict(Point, Cell) {
  util.map_to_dict(s)
  |> dict.map_values(fn(_, v) {
    case v {
      "#" -> Wall
      "." -> Empty
      "@" -> Robot
      "O" -> Box
      _ -> panic as { "unknown cell: " <> v }
    }
  })
}

fn parse_moves(s: String) -> List(Dir) {
  s
  |> string.to_graphemes
  |> list.filter(fn(c) { c != "\n" })
  |> list.map(fn(c) {
    case c {
      "^" -> Up
      "v" -> Down
      "<" -> Left
      ">" -> Right
      _ -> {
        panic as { "Unknown dir: " <> c }
      }
    }
  })
}

fn parse(input: String) -> #(Dict(Point, Cell), List(Dir)) {
  case input |> string.trim |> string.split("\n\n") {
    [map, moves] -> {
      let map = parse_map(map)
      #(map, parse_moves(moves))
    }
    _ -> panic as "wtf"
  }
}

fn find_tings_to_move(
  ps: List(Point),
  dir: Dir,
  map: Dict(Point, Cell),
  acc: List(Point),
) -> List(Point) {
  case ps {
    // everything on this line was empty, so lets move
    [] -> acc
    ps -> {
      let cells = ps |> list.map(fn(p) { map |> dict.get(p) }) |> result.all
      case cells {
        Ok(cells) -> {
          case cells |> list.any(fn(c) { c == Wall }) {
            // we hit a wall. abort!
            True -> []
            False -> {
              // get all of the next squares in `dir` that are not empty
              let next_ps =
                ps
                |> list.filter_map(fn(p) {
                  let np = move(p, dir)
                  map |> dict.get(np) |> result.map(fn(c) { #(np, c) })
                })
                |> list.filter(fn(x) { x.1 != Empty })
                |> list.map(pair.first)

              // expand those squares if required (only for up/down)
              let next_ps = case dir {
                Up | Down -> {
                  // if we have the left or right side of a box, make sure
                  // the other side is included
                  next_ps
                  |> list.flat_map(fn(p) {
                    case map |> dict.get(p) {
                      Ok(BoxL) -> [p, move(p, Right)]
                      Ok(BoxR) -> [move(p, Left), p]
                      Error(_) -> panic as "aaaarrrggghhh"
                      _ -> [p]
                    }
                  })
                  // remove duplicates
                  |> set.from_list
                  |> set.to_list
                }
                Left | Right -> next_ps
              }
              find_tings_to_move(next_ps, dir, map, ps |> list.append(acc))
            }
          }
        }
        Error(_) -> panic as "went off the map"
      }
    }
  }
}

// we have a reverse list of things to move, ending with the robot
fn move_things(
  l: List(Point),
  d: Dir,
  map: Dict(Point, Cell),
) -> Dict(Point, Cell) {
  case l {
    [] -> map
    [p, ..rest] -> {
      let next = move(p, d)
      case map |> dict.get(p), map |> dict.get(next) {
        Ok(c), Ok(Empty) -> {
          let map = map |> dict.insert(next, c) |> dict.insert(p, Empty)
          move_things(rest, d, map)
        }
        _, _ -> panic as "something went wrong"
      }
    }
  }
}

fn run(
  robot: Point,
  map: Dict(Point, Cell),
  moves: List(Dir),
) -> Dict(Point, Cell) {
  case moves {
    [] -> map
    [d, ..rest] -> {
      case find_tings_to_move([robot], d, map, []) {
        [] -> run(robot, map, rest)
        ttm -> {
          let map = move_things(ttm, d, map)
          let robot = find_robot(map)
          run(robot, map, rest)
        }
      }
    }
  }
}

fn gps(p: Point) -> Int {
  p.x + 100 * p.y
}

fn score(map: Dict(Point, Cell)) -> Int {
  map
  |> dict.to_list
  |> list.map(fn(x) {
    case x.1 {
      Box | BoxL -> gps(x.0)
      _ -> 0
    }
  })
  |> list.fold(0, int.add)
}

pub fn part1(input: String) -> Int {
  let #(map, moves) = parse(input)
  let robot = find_robot(map)
  run(robot, map, moves) |> score
}

fn double_map(map: Dict(Point, Cell)) -> Dict(Point, Cell) {
  map
  |> dict.to_list
  |> list.flat_map(fn(x) {
    let #(p, c) = x
    let l = Point(p.x * 2, p.y)
    let r = Point(p.x * 2 + 1, p.y)
    case c {
      Box -> [#(l, BoxL), #(r, BoxR)]
      Empty -> [#(l, Empty), #(r, Empty)]
      Wall -> [#(l, Wall), #(r, Wall)]
      Robot -> [#(l, Robot), #(r, Empty)]
      _ -> panic as "blah"
    }
  })
  |> dict.from_list
}

pub fn part2(input: String) -> Int {
  let #(map, moves) = parse(input)
  let map = double_map(map)
  let robot = find_robot(map)
  run(robot, map, moves) |> score
}

fn print_moves(moves: List(Dir), move_index: Int) {
  moves
  |> list.index_map(fn(x, i) { #(i, x) })
  |> list.each(fn(x) {
    case x.0 == move_index {
      True -> io.print(red(dir_to_string(x.1)))
      False -> io.print(dir_to_string(x.1))
    }
    case x.0 % 70 == 69 {
      True -> io.print("\n")
      False -> Nil
    }
  })
}

fn debug_run(
  robot: Point,
  map: Dict(Point, Cell),
  moves: List(Dir),
  move_index: Int,
  all_moves: List(Dir),
) -> Dict(Point, Cell) {
  case moves {
    [] -> map
    [d, ..rest] -> {
      io.print(clear())
      util.print_map(map, cell_to_string)
      io.print("\n")
      print_moves(all_moves, move_index)
      let _ = erlang.get_line("\nPress enter...")

      case find_tings_to_move([robot], d, map, []) {
        [] -> debug_run(robot, map, rest, move_index + 1, all_moves)
        ttm -> {
          let map = move_things(ttm, d, map)
          let robot = move(robot, d)
          debug_run(robot, map, rest, move_index + 1, all_moves)
        }
      }
    }
  }
}

pub fn debug() -> Nil {
  // Thankyou this person:
  // https://www.reddit.com/r/adventofcode/comments/1hetkud/year_2024day_15_extra_test_case_to_help_with_part/
  let input =
    "#######
#.....#
#.....#
#.@O..#
#..#O.#
#...O.#
#..O..#
#.....#
#######

>><vvv>v>^^^"

  let #(map, moves) = parse(input)
  let map = double_map(map)
  let robot = find_robot(map)
  debug_run(robot, map, moves, 0, moves)

  Nil
}
