import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import util

fn parse(input: String) -> Dict(String, Set(String)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc, line) {
    let assert Ok(#(a, b)) = line |> string.split_once("-")
    acc
    |> dict.upsert(a, fn(existing) {
      case existing {
        option.Some(s) -> s |> set.insert(b)
        option.None -> [b] |> set.from_list
      }
    })
    |> dict.upsert(b, fn(existing) {
      case existing {
        option.Some(s) -> s |> set.insert(a)
        option.None -> [a] |> set.from_list
      }
    })
  })
}

fn groups_of_three(
  check: List(#(String, Set(String))),
  machines: Dict(String, Set(String)),
  acc: List(List(String)),
) {
  case check {
    [] -> acc
    [#(id, conns), ..rest] -> {
      let neighbours =
        conns
        |> set.to_list
        |> list.filter_map(fn(n) {
          machines |> dict.get(n) |> result.map(fn(nconns) { #(n, nconns) })
        })

      let group =
        neighbours
        |> list.combination_pairs
        |> list.filter(fn(pair) { pair.0.1 |> set.contains(pair.1.0) })
        |> list.map(fn(pair) { [id, pair.0.0, pair.1.0] })

      let acc = acc |> list.append(group)
      let machines = machines |> dict.delete(id)

      groups_of_three(rest, machines, acc)
    }
  }
}

pub fn part1(input: String) -> Int {
  let ms = input |> parse
  groups_of_three(ms |> dict.to_list, ms, [])
  |> list.filter(fn(group) {
    group |> list.filter(fn(m) { m |> string.starts_with("t") }) |> list.length
    > 0
  })
  |> list.length
}

fn groups(check: List(#(String, Set(String))), acc: List(Set(String))) {
  case check {
    [] -> acc
    [m, ..rest] -> {
      // find a set where we connect to all of the nodes
      let #(conn_to_all, others) =
        acc
        |> list.partition(fn(s) { s |> set.is_subset(m.1) })

      let conn_to_all = case conn_to_all {
        [] -> [[m.0] |> set.from_list]
        l -> l |> list.map(fn(s) { s |> set.insert(m.0) })
      }

      let acc = conn_to_all |> list.append(others)

      groups(rest, acc)
    }
  }
}

pub fn part2(input: String) -> String {
  input
  |> parse
  |> dict.to_list
  |> groups([])
  |> list.sort(fn(a, b) { int.compare(b |> set.size, a |> set.size) })
  |> list.first
  |> util.unwrap_or_panic
  |> set.to_list
  |> list.sort(string.compare)
  |> string.join(",")
}
