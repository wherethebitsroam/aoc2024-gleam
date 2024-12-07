import gleam/int
import gleam/list
import gleam/string

fn parse_int(s: String) -> Int {
  let assert Ok(i) = int.parse(s)
  i
}

fn parse_line(line: String) -> #(Int, List(Int)) {
  case line |> string.split_once(": ") {
    Ok(x) -> #(parse_int(x.0), x.1 |> string.split(" ") |> list.map(parse_int))
    Error(_) -> panic as "aaaaaaahhhhhhh!"
  }
}

fn parse(input: String) -> List(#(Int, List(Int))) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_line)
}

fn solvable(eq: #(Int, List(Int))) -> Bool {
  case eq.1 {
    [] -> False
    [h, ..rest] -> solvable_loop(eq.0, h, rest)
  }
}

fn solvable_loop(ans: Int, cur: Int, rem: List(Int)) -> Bool {
  case cur > ans {
    // if we're over the answer we're done
    True -> False
    False -> {
      case rem {
        [] -> cur == ans
        [h, ..rest] -> {
          solvable_loop(ans, cur + h, rest) || solvable_loop(ans, cur * h, rest)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> list.filter(solvable)
  |> list.map(fn(x) { x.0 })
  |> list.fold(0, fn(a, b) { a + b })
}

fn combine(a: Int, b: Int) -> Int {
  let a = a |> int.to_string
  let b = b |> int.to_string
  parse_int(a <> b)
}

fn solvable2(eq: #(Int, List(Int))) -> Bool {
  case eq.1 {
    [] -> False
    [a, ..rest] -> solvable2_loop(eq.0, a, rest)
  }
}

fn solvable2_loop(ans: Int, cur: Int, rem: List(Int)) -> Bool {
  case cur > ans {
    // if we're over the answer we're done
    True -> False
    False -> {
      case rem {
        [] -> cur == ans
        [a, ..rest] ->
          solvable2_loop(ans, cur + a, rest)
          || solvable2_loop(ans, cur * a, rest)
          || solvable2_loop(ans, combine(cur, a), rest)
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> list.filter(solvable2)
  |> list.map(fn(x) { x.0 })
  |> list.fold(0, fn(a, b) { a + b })
}
