import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string

fn parse_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s)
  i
}

fn parse_head_row(row: String) -> #(Int, Int) {
  let assert Ok(#(l, r)) = string.split_once(row, "|")
  #(parse_int(l), parse_int(r))
}

fn parse_head(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_head_row)
  |> list.fold(dict.new(), fn(acc, x) {
    dict.upsert(acc, x.0, fn(existing) {
      case existing {
        Some(s) -> set.insert(s, x.1)
        None -> [x.1] |> set.from_list
      }
    })
  })
}

fn parse_tail_row(s) {
  s
  |> string.split(",")
  |> list.map(parse_int)
}

fn parse_tail(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_tail_row)
}

fn parse_input(input: String) {
  let assert Ok(#(head, tail)) =
    input
    |> string.trim
    |> string.split_once("\n\n")

  let head = parse_head(head)
  let tail = parse_tail(tail)

  #(head, tail)
}

fn check_update(d: dict.Dict(Int, Set(Int)), update: List(Int)) -> Bool {
  case update {
    [] -> True
    [h, ..rest] -> check_update_loop(d, h, rest)
  }
}

fn get_after(d: dict.Dict(Int, Set(Int)), i: Int) -> Set(Int) {
  case dict.get(d, i) {
    Ok(x) -> x
    Error(_) -> set.new()
  }
}

fn check_update_loop(d, h, rest) -> Bool {
  case rest {
    // nothing after this page, so we're fine
    [] -> True
    [n, ..rest] -> {
      let after = get_after(d, h)
      case set.contains(after, n) {
        True -> check_update_loop(d, n, rest)
        False -> False
      }
    }
  }
}

fn get_middle(l: List(Int)) -> Int {
  let mid = list.length(l) / 2
  let #(_, x) = list.split(l, mid)
  list.first(x)
  |> result.unwrap(0)
}

fn reorder(d: dict.Dict(Int, Set(Int)), l: List(Int)) -> List(Int) {
  reorder_loop(d, l, [])
}

fn reorder_loop(
  d: dict.Dict(Int, Set(Int)),
  l: List(Int),
  acc: List(Int),
) -> List(Int) {
  case l {
    [] -> acc
    _ -> {
      // the last page will be the one that has none of the other
      // pages in their after list
      let last =
        l
        |> list.filter(fn(i) {
          let after = get_after(d, i)
          !overlap(after, l)
        })
      // move the last page from l to acc and continue
      case last {
        [n] -> reorder_loop(d, list.filter(l, fn(i) { i != n }), [n, ..acc])
        _ -> panic as "Multiple candidates"
      }
    }
  }
}

fn overlap(s: Set(Int), l: List(Int)) -> Bool {
  l |> list.any(fn(i) { set.contains(s, i) })
}

pub fn part1(input: String) -> Int {
  let #(d, updates) = parse_input(input)

  updates
  |> list.filter(check_update(d, _))
  |> list.map(get_middle)
  |> list.fold(0, int.add)
}

pub fn part2(input: String) -> Int {
  let #(d, updates) = parse_input(input)

  updates
  |> list.filter(fn(l) { !check_update(d, l) })
  |> list.map(reorder(d, _))
  |> list.map(get_middle)
  |> list.fold(0, int.add)
}
