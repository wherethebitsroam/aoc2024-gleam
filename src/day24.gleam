import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import point.{type Point, Point}
import util

fn parse(input: String) -> Dict(String, Int) {
  let assert Ok(#(wires, gates)) =
    input |> string.trim |> string.split_once("\n\n")

  let wires =
    wires
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(name, value)) = line |> string.split_once(": ")
      let assert Ok(value) = int.parse(value)
      #(name, value)
    })
    |> dict.from_list

  // x00 AND y00 -> z00
  let gates =
    gates
    |> string.split("\n")
    |> list.map(fn(line) {
      case line |> string.split(" ") {
        [w1, g, w2, _, w] -> #(w, g, w1, w2)
        _ -> panic
      }
    })

  solve(gates, wires)
}

fn solve(
  gates: List(#(String, String, String, String)),
  wires: Dict(String, Int),
) -> Dict(String, Int) {
  case gates {
    [] -> wires
    l -> {
      let #(to_map, rest) =
        l
        |> list.partition(fn(g) {
          let #(_, _, w1, w2) = g
          wires |> dict.has_key(w1) && wires |> dict.has_key(w2)
        })

      let wires =
        to_map
        |> list.map(fn(g) {
          let #(w, g, w1, w2) = g
          let assert Ok(w1) = wires |> dict.get(w1)
          let assert Ok(w2) = wires |> dict.get(w2)
          case g {
            "AND" -> #(w, int.bitwise_and(w1, w2))
            "OR" -> #(w, int.bitwise_or(w1, w2))
            "XOR" -> #(w, int.bitwise_exclusive_or(w1, w2))
            _ -> panic
          }
        })
        |> list.fold(wires, fn(wires, w) { wires |> dict.insert(w.0, w.1) })

      solve(rest, wires)
    }
  }
}

pub fn part1(input: String) -> Int {
  input
  |> parse
  |> dict.to_list
  |> list.filter_map(fn(x) {
    case x.0 |> string.starts_with("z") {
      False -> Error(Nil)
      True -> {
        let assert Ok(shift) = x.0 |> string.drop_start(1) |> int.parse
        Ok(#(shift, x.1))
      }
    }
  })
  |> list.fold(0, fn(acc, x) { acc + int.bitwise_shift_left(x.1, x.0) })
}

type Wire {
  And(String, String)
  Or(String, String)
  Xor(String, String)
}

fn parse2(input: String) -> #(Dict(String, Int), Dict(String, Wire)) {
  let assert Ok(#(inputs, gates)) =
    input |> string.trim |> string.split_once("\n\n")

  let inputs =
    inputs
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert Ok(#(name, value)) = line |> string.split_once(": ")
      let assert Ok(value) = int.parse(value)
      #(name, value)
    })
    |> dict.from_list

  // x00 AND y00 -> z00
  let gates =
    gates
    |> string.split("\n")
    |> list.fold(dict.new(), fn(wires, line) {
      case line |> string.split(" ") {
        [w1, g, w2, _, w] -> {
          let wire = case g {
            "AND" -> And(w1, w2)
            "OR" -> Or(w1, w2)
            "XOR" -> Xor(w1, w2)
            _ -> panic
          }
          wires |> dict.insert(w, wire)
        }
        _ -> panic
      }
    })

  #(inputs, gates)
}

// fn run(inputs: Dict(String, Int), gates: Dict(String, Wire)) -> 

pub fn part2(input: String) -> Int {
  input
  |> parse2
  // |> io.debug

  // x: 44 bit
  // y: 44 bit
  // z: 45 bit
  // go through each bit and see what happens?
  0
}
