import gleam/int
import gleam/list
import gleam/string
import util

pub type Op {
  Op(name: String, f: fn(Machine) -> Machine)
}

pub type Machine {
  Machine(
    // registers
    a: Int,
    b: Int,
    c: Int,
    // the original list of ops
    ops: List(Op),
    // the current ops
    current: List(Op),
    // the collected output (in reverse order)
    output: List(Int),
  )
}

pub fn new(a: Int, b: Int, c: Int, opcodes: List(Int)) -> Machine {
  let ops = map_ops(opcodes)
  Machine(a, b, c, ops, ops, [])
}

pub fn combo(m: Machine, v: Int) -> Int {
  case v {
    0 | 1 | 2 | 3 -> v
    4 -> m.a
    5 -> m.b
    6 -> m.c
    _ -> panic as { "invalid combo arg: " <> int.to_string(v) }
  }
}

fn next_op(m: Machine) -> Machine {
  Machine(..m, current: m.current |> list.drop(1))
}

fn dv(m: Machine, v: Int) -> Int {
  int.bitwise_shift_right(m.a, combo(m, v))
}

pub fn adv(v: Int) -> Op {
  Op("adv", fn(m) { Machine(..m, a: dv(m, v)) |> next_op })
}

fn bxl(v: Int) -> Op {
  Op("bxl", fn(m) {
    let b = int.bitwise_exclusive_or(m.b, v)
    Machine(..m, b: b) |> next_op
  })
}

fn bst(v: Int) -> Op {
  Op("bst", fn(m) { Machine(..m, b: combo(m, v) % 8) |> next_op })
}

fn jnz(v: Int) -> Op {
  Op("jnz", fn(m) {
    case m.a == 0 {
      True -> m |> next_op
      False -> Machine(..m, current: m.ops |> list.drop(v / 2))
    }
  })
}

fn bxc(_: Int) -> Op {
  Op("bxc", fn(m) {
    Machine(..m, b: int.bitwise_exclusive_or(m.b, m.c)) |> next_op
  })
}

fn out(v: Int) -> Op {
  Op("out", fn(m) {
    Machine(..m, output: [combo(m, v) % 8, ..m.output]) |> next_op
  })
}

fn bdv(v: Int) -> Op {
  Op("bdv", fn(m) { Machine(..m, b: dv(m, v)) |> next_op })
}

fn cdv(v: Int) -> Op {
  Op("cdv", fn(m) { Machine(..m, c: dv(m, v)) |> next_op })
}

fn map_op(opcode: Int, v: Int) -> Op {
  let gen = case opcode {
    0 -> adv
    1 -> bxl
    2 -> bst
    3 -> jnz
    4 -> bxc
    5 -> out
    6 -> bdv
    7 -> cdv
    _ -> panic as { "bad opcode: " <> int.to_string(opcode) }
  }
  gen(v)
}

fn map_ops(program: List(Int)) -> List(Op) {
  program
  |> list.sized_chunk(2)
  |> list.map(fn(l) {
    case l {
      [opcode, v] -> map_op(opcode, v)
      _ -> panic as "bad pair"
    }
  })
}

fn run(m: Machine) -> Machine {
  case m.current {
    [] -> m
    [op, ..] -> run(op.f(m))
  }
}

pub fn part1(a: Int, b: Int, c: Int, program: List(Int)) -> String {
  let m = new(a, b, c, program) |> run
  m.output |> list.reverse |> list.map(int.to_string) |> string.join(",")
}

pub type AOp {
  A
  Lit(Int)
  Mod8(AOp)
  Div(AOp, AOp)
  Xor(AOp, AOp)
  ShiftR(AOp, AOp)
}

pub fn eval(op: AOp, a: Int) -> Int {
  case op {
    A -> a
    Lit(v) -> v
    Mod8(op) -> eval(op, a) % 8
    Div(n, d) -> eval(n, a) / eval(d, a)
    Xor(x, y) -> int.bitwise_exclusive_or(eval(x, a), eval(y, a))
    ShiftR(x, y) -> int.bitwise_shift_right(eval(x, a), eval(y, a))
  }
}

pub type Machine2 {
  Machine2(a: AOp, b: AOp, c: AOp, output: List(AOp), program: List(Int))
}

fn combo2(m: Machine2, v: Int) -> AOp {
  case v {
    0 | 1 | 2 | 3 -> Lit(v)
    4 -> m.a
    5 -> m.b
    6 -> m.c
    _ -> panic as { "invalid combo arg: " <> int.to_string(v) }
  }
}

fn dv2(m: Machine2, v: Int) -> AOp {
  let v = combo2(m, v)
  case m.a, v {
    ShiftR(a, Lit(x)), Lit(l) -> ShiftR(a, Lit(x + l))
    _, _ -> ShiftR(m.a, v)
  }
}

pub fn calc(program: List(Int), m: Machine2) {
  case program {
    [opcode, v, ..rest] -> {
      let m = case opcode {
        0 -> Machine2(..m, a: dv2(m, v))
        1 -> Machine2(..m, b: Xor(m.b, Lit(v)))
        2 -> Machine2(..m, b: Mod8(combo2(m, v)))
        3 -> {
          case m.output |> list.length == m.program |> list.length {
            True -> m
            False -> calc(m.program, m)
          }
        }
        4 -> Machine2(..m, b: Xor(m.b, m.c))
        5 -> Machine2(..m, output: [Mod8(combo2(m, v)), ..m.output])
        6 -> Machine2(..m, b: dv2(m, v))
        7 -> Machine2(..m, c: dv2(m, v))
        _ -> panic as "unknown opcode"
      }
      calc(rest, m)
    }
    _ -> m
  }
}

fn find_initial(o: Out, x: Int, acc: List(Int)) -> List(Int) {
  // max 10 bits can be used (I think)
  case x >= int.bitwise_shift_left(1, 10) {
    True -> acc
    False -> {
      let a = int.bitwise_shift_left(x, o.shift)
      let acc = case eval(o.op, a) == o.value {
        True -> [a, ..acc]
        False -> acc
      }
      find_initial(o, x + 1, acc)
    }
  }
}

fn find_rest(possible: List(Int), os: List(Out)) -> List(Int) {
  case os {
    [] -> possible
    [o, ..rest] -> {
      let possible = find_possible(o, possible)
      find_rest(possible, rest)
    }
  }
}

fn find_possible(o: Out, possible: List(Int)) -> List(Int) {
  possible
  |> list.flat_map(fn(a) {
    [0, 1, 2, 3, 4, 5, 6, 7]
    |> list.map(fn(v) { a + int.bitwise_shift_left(v, o.shift) })
  })
  |> list.filter(fn(a) { eval(o.op, a) == o.value })
}

type Out {
  Out(value: Int, op: AOp, shift: Int)
}

pub fn part2(_: Int, _: Int, _: Int, program: List(Int)) -> Int {
  let m = Machine2(a: A, b: Lit(0), c: Lit(0), output: [], program: program)
  let m = calc(program, m)

  let outs =
    program
    |> list.zip(m.output |> list.reverse)
    |> list.index_map(fn(x, i) { Out(x.0, x.1, i * 3) })
    |> list.reverse

  case outs {
    [o, ..rest] -> find_initial(o, 0, []) |> find_rest(rest)
    _ -> panic as "wtf"
  }
  |> list.reduce(int.min)
  |> util.unwrap_or_panic
}
