import gleam/dict.{type Dict}
import gleam/int
import gleam/list
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
  |> blink(25)
  |> list.length
}

// a cache item of initial value and number of rounds
type Item {
  Item(value: Int, rounds: Int)
}

// cache of the final number of stones for each item
type Cache =
  Dict(Item, Int)

// a monad to maintain the cache
type CacheValue {
  CacheValue(cache: Cache, value: Int)
}

fn value(cv: CacheValue) -> Int {
  cv.value
}

fn blink2(cache: Cache, l: List(Int), times: Int) -> CacheValue {
  case times {
    0 -> CacheValue(cache, l |> list.length)
    _ -> {
      let initial = CacheValue(cache, 0)
      l
      |> list.fold(initial, fn(acc, x) {
        let cv = resolve(CacheValue(acc.cache, x), times)
        CacheValue(cv.cache, acc.value + cv.value)
      })
    }
  }
}

fn resolve(cv: CacheValue, times: Int) -> CacheValue {
  let item = Item(cv.value, times)
  case cv.cache |> dict.get(item) {
    Ok(x) -> CacheValue(cv.cache, x)
    Error(_) -> {
      let v = blink2(cv.cache, apply_rule(cv.value), times - 1)
      CacheValue(v.cache |> dict.insert(item, v.value), v.value)
    }
  }
}

pub fn part2(input: String) -> Int {
  input
  |> string.trim
  |> string.split(" ")
  |> list.map(util.parse_int)
  |> blink2(dict.new(), _, 75)
  |> value
}
