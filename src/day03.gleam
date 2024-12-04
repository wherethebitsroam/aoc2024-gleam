import gleam/int
import gleam/list
import gleam/string

type State =
  List(String)

pub fn create_state(s: String) -> State {
  string.to_graphemes(s)
}

// list of graphemes

pub type ParseResult(result) {
  Success(result, State)
  Fail(State)
}

// move to the next char in state
fn bump(s: State) -> State {
  case s {
    [_, ..rest] -> rest
    [] -> []
  }
}

fn is_digit(s: String) -> Bool {
  case s {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

pub fn match_str(s: State, str: String) -> ParseResult(String) {
  let state = s
  let chars = string.to_graphemes(str)
  case match_str_loop(s, chars) {
    Success(_, state) -> Success(str, state)
    Fail(_) -> Fail(state)
  }
}

fn match_str_loop(s: State, chars: List(String)) -> ParseResult(Nil) {
  case chars {
    [c, ..rest] ->
      case match_char(s, c) {
        Success(_, state) -> match_str_loop(state, rest)
        Fail(state) -> Fail(state)
      }
    [] -> Success(Nil, s)
  }
}

fn match_char(s: State, char: String) -> ParseResult(Nil) {
  case parse_char(s) {
    Success(c, state) ->
      case c == char {
        True -> Success(Nil, state)
        False -> Fail(s)
      }
    Fail(state) -> Fail(state)
  }
}

pub fn parse_char(s: State) -> ParseResult(String) {
  case s {
    [c, ..rest] -> Success(c, rest)
    [] -> Fail(s)
  }
}

pub fn parse_int(s: State) -> ParseResult(Int) {
  case read(is_digit, s) {
    Success(digits, state) -> {
      let str = string.join(digits, "")
      case int.parse(str) {
        Ok(i) -> Success(i, state)
        Error(_) -> Fail(state)
      }
    }
    Fail(s) -> Fail(s)
  }
}

fn read(predicate: fn(String) -> Bool, s: State) -> ParseResult(List(String)) {
  read_loop(predicate, s, [])
}

fn read_loop(
  predicate: fn(String) -> Bool,
  s: State,
  acc: List(String),
) -> ParseResult(List(String)) {
  case s {
    [c, ..rest] ->
      case predicate(c) {
        True -> read_loop(predicate, rest, [c, ..acc])
        False -> Success(list.reverse(acc), [c, ..rest])
      }
    [] -> Success([], list.reverse(acc))
  }
}

fn parse_mul(s: State) -> ParseResult(#(Int, Int)) {
  let initial = s
  case match_str(s, "mul(") {
    Success(_, s) ->
      case parse_int(s) {
        Success(i1, s) ->
          case match_char(s, ",") {
            Success(_, s) ->
              case parse_int(s) {
                Success(i2, s) ->
                  case match_char(s, ")") {
                    Success(_, s) -> Success(#(i1, i2), s)
                    Fail(_) -> Fail(initial)
                  }
                Fail(_) -> Fail(initial)
              }
            Fail(_) -> Fail(initial)
          }
        Fail(_) -> Fail(initial)
      }
    Fail(_) -> Fail(initial)
  }
}

fn parse_loop(state: State, acc: Int) -> Int {
  case parse_mul(state) {
    Success(#(a, b), state) -> parse_loop(state, acc + a * b)
    Fail(state) ->
      case state {
        [] -> acc
        _ -> parse_loop(bump(state), acc)
      }
  }
}

pub fn part1(input: String) -> Int {
  let state = create_state(input)
  parse_loop(state, 0)
}

fn parse_loop2(state: State, acc: Int, enabled: Bool) -> Int {
  case match_str(state, "do()") {
    Success(_, state) -> parse_loop2(state, acc, True)
    Fail(state) ->
      case state {
        // if state is empty we're done
        [] -> acc
        _ ->
          case match_str(state, "don't()") {
            Success(_, state) -> parse_loop2(state, acc, False)
            Fail(state) ->
              case state {
                // if state is empty we're done
                [] -> acc
                _ ->
                  case enabled {
                    True ->
                      case parse_mul(state) {
                        Success(#(a, b), state) ->
                          parse_loop2(state, acc + a * b, enabled)
                        Fail(state) ->
                          case state {
                            [] -> acc
                            _ -> parse_loop2(bump(state), acc, enabled)
                          }
                      }
                    False -> parse_loop2(bump(state), acc, enabled)
                  }
              }
          }
      }
  }
}

pub fn part2(input: String) -> Int {
  let state = create_state(input)
  parse_loop2(state, 0, True)
}
