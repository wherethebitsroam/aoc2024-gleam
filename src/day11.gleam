import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import util

fn apply_rule(i: Int) -> List(Int) {
  case i {
    0 -> [1]
    _ -> {
      let d = int.digits(i, 10) |> result.unwrap([])
      let l = list.length(d)
      case l % 2 == 0 {
        True -> {
          // split
          let #(a, b) = list.split(d, l / 2)
          let a = int.undigits(a, 10) |> result.unwrap(0)
          let b = int.undigits(b, 10) |> result.unwrap(0)
          [a, b]
        }
        False -> [i * 2024]
      }
    }
  }
}

fn blink(l: List(Int), times: Int) -> List(Int) {
  case times {
    0 -> l
    _ -> {
      let l = l |> list.flat_map(apply_rule)
      blink(l, times - 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(util.parse_int)
  |> list.fold(0, fn(acc, i) { acc + stones(i, 25) })
}

// a cache item of initial value and number of rounds
type Item {
  Item(value: Int, rounds: Int)
}

// cache of the final number of stones for each item
type Cache =
  Dict(Item, Int)

fn blink2(cache: Cache, l: List(Int), times: Int) -> #(Cache, Int) {
  case times {
    0 -> #(cache, l |> list.length)
    _ -> {
      l
      |> list.fold(#(cache, 0), fn(acc, x) {
        let #(cache, acc) = acc
        let #(cache, value) = resolve(cache, x, times)
        #(cache, acc + value)
      })
    }
  }
}

fn resolve(cache: Cache, value: Int, times: Int) -> #(Cache, Int) {
  let item = Item(value, times)
  case cache |> dict.get(item) {
    Ok(x) -> #(cache, x)
    Error(_) -> {
      let #(cache, v) = blink2(cache, apply_rule(value), times - 1)
      #(cache |> dict.insert(item, v), v)
    }
  }
}

fn stones(value: Int, times: Int) -> Int {
  case times {
    0 -> 1
    _ -> {
      case value {
        0 -> stones(1, times - 1)
        _ -> {
          let d = int.digits(value, 10) |> result.unwrap([])
          let l = list.length(d)
          case l % 2 == 0 {
            True -> {
              // split
              let #(a, b) = list.split(d, l / 2)
              let a = int.undigits(a, 10) |> result.unwrap(0)
              let b = int.undigits(b, 10) |> result.unwrap(0)

              stones(a, times - 1) + stones(b, times - 1)
            }
            False -> stones(value * 2024, times - 1)
          }
        }
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(util.parse_int)
  |> blink2(dict.new(), _, 75)
  |> pair.second
}
