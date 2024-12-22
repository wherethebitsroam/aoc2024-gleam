import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/set
import gleam/string
import util

fn mix_prune(v: Int, secret: Int) -> Int {
  v
  |> int.bitwise_exclusive_or(secret)
  |> int.modulo(16_777_216)
  |> util.unwrap_or_panic
}

fn step(secret: Int, action: fn(Int) -> Int) -> Int {
  secret |> action |> mix_prune(secret)
}

pub fn next(secret: Int) -> Int {
  secret
  |> step(fn(i) { i * 64 })
  |> step(fn(i) { i / 32 })
  |> step(fn(i) { i * 2048 })
}

fn apply(initial: Int, times: Int) -> Int {
  case times {
    0 -> initial
    _ -> {
      let v = next(initial)
      apply(v, times - 1)
    }
  }
}

fn prices(initial: Int, times: Int) -> List(Int) {
  prices_loop(initial, times, [initial % 10])
}

fn prices_loop(initial: Int, times: Int, acc: List(Int)) -> List(Int) {
  case times {
    0 -> acc |> list.reverse
    _ -> {
      let v = next(initial)
      prices_loop(v, times - 1, [v % 10, ..acc])
    }
  }
}

// only count the first time a seq is seen
fn prices_to_seqs(prices: List(Int)) -> List(#(List(Int), Int)) {
  prices
  |> list.window(5)
  |> list.fold(#([], set.new()), fn(acc, ps) {
    let #(acc, seen) = acc
    let diffs = ps |> list.window_by_2 |> list.map(fn(x) { x.1 - x.0 })
    case seen |> set.contains(diffs) {
      True -> #(acc, seen)
      False -> {
        let price = ps |> list.last |> util.unwrap_or_panic
        #([#(diffs, price), ..acc], seen |> set.insert(diffs))
      }
    }
  })
  |> pair.first
}

pub fn part1(input: String) -> Int {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(s) {
    let i = util.parse_int(s)
    i |> apply(2000)
  })
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  let seq_prices =
    input
    |> string.trim
    |> string.split("\n")
    |> list.flat_map(fn(s) {
      let i = util.parse_int(s)
      i
      |> prices(2000)
      |> prices_to_seqs
    })
    |> list.filter(fn(x) { x.1 != 0 })

  let combined =
    seq_prices
    |> list.fold(dict.new(), fn(acc, sp) {
      let #(seq, bananas) = sp
      acc
      |> dict.upsert(seq, fn(existing) {
        { existing |> option.unwrap(0) } + bananas
      })
    })

  combined |> dict.values |> list.fold(0, int.max)
}
