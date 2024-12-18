import day17
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn combo_test() {
  let m = day17.new(4, 5, 6, [])
  day17.combo(m, 0) |> should.equal(0)
  day17.combo(m, 1) |> should.equal(1)
  day17.combo(m, 2) |> should.equal(2)
  day17.combo(m, 3) |> should.equal(3)
  day17.combo(m, 4) |> should.equal(4)
  day17.combo(m, 5) |> should.equal(5)
  day17.combo(m, 6) |> should.equal(6)
}

pub fn adv_test() {
  let m = day17.new(4, 0, 0, [])
  // divides a by 2^0 and stores in a
  let op = day17.adv(0)
  let x = op.f(m)
  x.a |> should.equal(4)
  // divides a by 2^1 and stores in a
  let op = day17.adv(1)
  let x = op.f(m)
  x.a |> should.equal(2)
}

pub fn part1_test() {
  day17.part1(729, 0, 0, [0, 1, 5, 4, 3, 0])
  |> should.equal("4,6,3,5,6,3,5,2,1,0")
}

pub fn part2_test() {
  day17.part2(2024, 0, 0, [0, 3, 5, 4, 3, 0])
  |> should.equal(117_440)
}

pub fn eval_test() {
  let program = [2, 4, 1, 7, 7, 5, 0, 3, 4, 4, 1, 7, 5, 5, 3, 0]
  let m = day17.Machine2(day17.A, day17.Lit(0), day17.Lit(0), [], program)
  let m = day17.calc(program, m)

  let a = 52_042_868
  let expected = [2, 1, 0, 1, 7, 2, 5, 0, 3]
  m.output
  |> list.reverse
  |> list.take(expected |> list.length)
  |> list.map(day17.eval(_, a))
  |> should.equal(expected)
}

pub fn eval_test2() {
  let program = [2, 4, 1, 7, 7, 5, 0, 3, 4, 4, 1, 7, 5, 5, 3, 0]
  let m = day17.Machine2(day17.A, day17.Lit(0), day17.Lit(0), [], program)
  let m = day17.calc(program, m)

  let a = 267_265_166_222_237
  m.output
  |> list.reverse
  |> list.map(day17.eval(_, a))
  |> should.equal(program)
}
