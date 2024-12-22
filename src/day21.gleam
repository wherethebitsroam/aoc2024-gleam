import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import point.{type Point, Point}
import util

// +---+---+---+
// | 7 | 8 | 9 |
// +---+---+---+
// | 4 | 5 | 6 |
// +---+---+---+
// | 1 | 2 | 3 |
// +---+---+---+
//     | 0 | A |
//     +---+---+
const numeric_keypad = [
  #(Point(0, 0), "7"), #(Point(1, 0), "8"), #(Point(2, 0), "9"),
  #(Point(0, 1), "4"), #(Point(1, 1), "5"), #(Point(2, 1), "6"),
  #(Point(0, 2), "1"), #(Point(1, 2), "2"), #(Point(2, 2), "3"),
  #(Point(1, 3), "0"), #(Point(2, 3), "A"),
]

//     +---+---+
//     | ^ | A |
// +---+---+---+
// | < | v | > |
// +---+---+---+
const dir_keypad = [
  #(Point(1, 0), "^"), #(Point(2, 0), "A"), #(Point(0, 1), "<"),
  #(Point(1, 1), "v"), #(Point(2, 1), ">"),
]

fn move(p: Point, dir: String) -> Point {
  case dir {
    "^" -> p |> point.add(Point(0, -1))
    "v" -> p |> point.add(Point(0, 1))
    ">" -> p |> point.add(Point(1, 0))
    "<" -> p |> point.add(Point(-1, 0))
    _ -> panic as "bad dir"
  }
}

fn goes_through_point(start: Point, dirs: List(String), exclude: Point) -> Bool {
  case start == exclude {
    True -> True
    False ->
      case dirs {
        [] -> False
        [d, ..rest] -> goes_through_point(move(start, d), rest, exclude)
      }
  }
}

fn paths(
  pad: Dict(Point, String),
  exclude: Point,
) -> Dict(#(String, String), List(String)) {
  let pad_list = pad |> dict.to_list

  pad_list
  |> list.flat_map(fn(x) {
    let #(p1, s1) = x

    pad_list
    |> list.filter(fn(x) { x.0 != p1 })
    |> list.map(fn(x) {
      let #(p2, s2) = x
      let move = point.sub(p2, p1)
      let xdir = case move.x > 0 {
        True -> ">"
        False -> "<"
      }
      let ydir = case move.y > 0 {
        True -> "v"
        False -> "^"
      }

      let dirs =
        list.repeat(xdir, int.absolute_value(move.x))
        |> list.append(list.repeat(ydir, int.absolute_value(move.y)))
        |> list.permutations
        |> list.unique
        |> list.filter(fn(dirs) { !goes_through_point(p1, dirs, exclude) })
        |> list.map(fn(path) { path |> string.join("") |> string.append("A") })

      #(#(s1, s2), dirs)
    })
  })
  |> dict.from_list
}

fn to_dirs(
  s: String,
  num_paths: Dict(#(String, String), List(String)),
) -> List(List(String)) {
  ["A", ..s |> string.to_graphemes]
  |> list.window_by_2
  |> list.map(fn(x) {
    num_paths |> dict.get(#(x.0, x.1)) |> result.unwrap(["A"])
  })
}

fn path_length(path: List(List(String))) -> Int {
  path |> list.map(options_length) |> list.fold(0, int.add)
}

fn options_length(os: List(String)) -> Int {
  case os {
    [] -> panic as "empty options"
    l ->
      l
      |> list.map(string.length)
      |> list.reduce(int.min)
      |> util.unwrap_or_panic
  }
}

fn complexity(code: String, l: Int) -> Int {
  let v = code |> string.drop_end(1) |> util.parse_int
  v * l
}

type CacheItem {
  CacheItem(value: String, times: Int)
}

fn find_shortest_path(
  path: List(List(String)),
  times: Int,
  pad: Dict(#(String, String), List(String)),
  cache: Dict(CacheItem, Int),
) -> #(Int, Dict(CacheItem, Int)) {
  case times {
    0 -> #(path_length(path), cache)
    _ ->
      path
      |> list.fold(#(0, cache), fn(acc, j) {
        let #(acc, cache) = acc
        let #(l, cache) = find_shortest_option(j, times, pad, cache)
        #(acc + l, cache)
      })
  }
}

fn find_shortest_option(
  options: List(String),
  times: Int,
  pad: Dict(#(String, String), List(String)),
  cache: Dict(CacheItem, Int),
) -> #(Int, Dict(CacheItem, Int)) {
  let #(lengths, cache) =
    options
    |> list.fold(#([], cache), fn(acc, s) {
      let #(acc, cache) = acc
      let #(l, cache) = find_shortest_string(s, times, pad, cache)
      #([l, ..acc], cache)
    })
  let min = lengths |> list.reduce(int.min) |> util.unwrap_or_panic
  #(min, cache)
}

fn find_shortest_string(
  s: String,
  times: Int,
  pad: Dict(#(String, String), List(String)),
  cache: Dict(CacheItem, Int),
) -> #(Int, Dict(CacheItem, Int)) {
  let item = CacheItem(s, times)
  case cache |> dict.get(item) {
    Ok(v) -> #(v, cache)
    Error(_) -> {
      let #(l, cache) =
        to_dirs(s, pad) |> find_shortest_path(times - 1, pad, cache)
      let cache = cache |> dict.insert(item, l)
      #(l, cache)
    }
  }
}

fn run(input: String, times: Int) -> Int {
  let nums = numeric_keypad |> dict.from_list |> paths(Point(0, 3))
  let dirs = dir_keypad |> dict.from_list |> paths(Point(0, 0))

  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(code) {
    let l =
      code
      |> to_dirs(nums)
      |> find_shortest_path(times, dirs, dict.new())
      |> pair.first

    #(code, l)
  })
  |> list.map(fn(x) { complexity(x.0, x.1) })
  |> list.fold(0, int.add)
}

pub fn part1(input: String) -> Int {
  run(input, 2)
}

pub fn part2(input: String) -> Int {
  run(input, 25)
}
