import day03
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_int_test() {
  let state = day03.create_state("123x")

  day03.parse_int(state)
  |> should.equal(day03.Success(123, ["x"]))
}

pub fn parse_int_empty_test() {
  let state = day03.create_state("")

  day03.parse_int(state)
  |> should.equal(day03.Fail([]))
}

pub fn parse_int_fail_test() {
  let state = day03.create_state("xxx")

  day03.parse_int(state)
  |> should.equal(day03.Fail(["x", "x", "x"]))
}

pub fn match_str_test() {
  let state = day03.create_state("123x")

  day03.match_str(state, "123")
  |> should.equal(day03.Success("123", ["x"]))
}

pub fn match_str_empty_test() {
  let state = day03.create_state("")

  day03.match_str(state, "abc")
  |> should.equal(day03.Fail([]))
}

pub fn match_str_fail_test() {
  let state = day03.create_state("123x")

  day03.match_str(state, "abc")
  |> should.equal(day03.Fail(["1", "2", "3", "x"]))
}

pub fn match_str_fail_halfway_test() {
  let state = day03.create_state("123x")

  day03.match_str(state, "12c")
  |> should.equal(day03.Fail(["1", "2", "3", "x"]))
}

const example = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

pub fn part1_test() {
  day03.part1(example)
  |> should.equal(161)
}

const example2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn part2_test() {
  day03.part2(example2)
  |> should.equal(48)
}
