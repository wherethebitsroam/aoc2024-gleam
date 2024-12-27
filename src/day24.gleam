import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

type GateKind {
  And
  Or
  Xor
}

type Gate {
  Gate(out: String, kind: GateKind, in1: String, in2: String)
}

fn parse(input: String) -> #(Dict(String, Int), List(Gate)) {
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
    |> list.map(fn(line) {
      case line |> string.split(" ") {
        [w1, g, w2, _, w] -> {
          case g {
            "AND" -> Gate(w, And, w1, w2)
            "OR" -> Gate(w, Or, w1, w2)
            "XOR" -> Gate(w, Xor, w1, w2)
            _ -> panic
          }
        }
        _ -> panic
      }
    })

  #(inputs, gates)
}

fn solve(gates: List(Gate), wires: Dict(String, Int)) -> Dict(String, Int) {
  case gates {
    [] -> wires
    l -> {
      let #(to_map, rest) =
        l
        |> list.partition(fn(g) {
          wires |> dict.has_key(g.in1) && wires |> dict.has_key(g.in2)
        })

      let wires =
        to_map
        |> list.map(fn(g) {
          let assert Ok(w1) = wires |> dict.get(g.in1)
          let assert Ok(w2) = wires |> dict.get(g.in2)
          let value = case g.kind {
            And -> int.bitwise_and(w1, w2)
            Or -> int.bitwise_or(w1, w2)
            Xor -> int.bitwise_exclusive_or(w1, w2)
          }
          #(g.out, value)
        })
        |> list.fold(wires, fn(wires, w) { wires |> dict.insert(w.0, w.1) })

      solve(rest, wires)
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(inputs, gates) = input |> parse

  solve(gates, inputs)
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

fn wire_name(prefix: String, bit: Int) -> String {
  case bit < 10 {
    True -> prefix <> "0" <> int.to_string(bit)
    False -> prefix <> int.to_string(bit)
  }
}

fn gate_match(g: Gate, kind: GateKind, w1: String, w2: String) -> Bool {
  g.kind == kind
  && { { g.in1 == w1 && g.in2 == w2 } || { g.in1 == w2 && g.in2 == w1 } }
}

// only swap output wires
fn wire_swap(gates: List(Gate), w1: String, w2: String) -> List(Gate) {
  gates
  |> list.map(fn(g) {
    case g.out == w1, g.out == w2 {
      True, _ -> Gate(w2, g.kind, g.in1, g.in2)
      _, True -> Gate(w1, g.kind, g.in1, g.in2)
      _, _ -> g
    }
  })
}

fn check_full(bit: Int, carry: String, gates: List(Gate), max: Int) {
  case bit >= max {
    True -> Nil
    False -> {
      let x = wire_name("x", bit)
      let y = wire_name("y", bit)
      let z = wire_name("z", bit)

      // io.debug(#(bit, carry))

      // we expect to find an XOR and AND that take both x and y
      let assert Ok(xor) = gates |> list.find(gate_match(_, Xor, x, y))
      let assert Ok(and) = gates |> list.find(gate_match(_, And, x, y))

      // we expect to find an XOR and AND that take xor above and carry
      let assert Ok(cxor) =
        gates |> list.find(gate_match(_, Xor, xor.out, carry))
      let assert Ok(cand) =
        gates |> list.find(gate_match(_, And, xor.out, carry))

      // we expect to find an OR that takes `and` and `cand`
      let assert Ok(or) =
        gates |> list.find(gate_match(_, Or, and.out, cand.out))

      // we expect cxor to output to z
      case cxor.out == z {
        True -> Nil
        False -> panic as "cxor.out != z"
      }

      check_full(bit + 1, or.out, gates, max)
    }
  }
}

pub fn part2(input: String) -> String {
  let #(_, gates) = input |> parse

  let gates =
    gates
    |> wire_swap("vss", "z14")
    |> wire_swap("kdh", "hjf")
    |> wire_swap("kpp", "z31")
    |> wire_swap("z35", "sgj")

  // we know that `qtf` is the carry from bit 0
  check_full(1, "qtf", gates, 45)

  ["vss", "z14", "kdh", "hjf", "kpp", "z31", "z35", "sgj"]
  |> list.sort(string.compare)
  |> string.join(",")
}
