import day21
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "029A
980A
179A
456A
379A"

pub fn part1_test() {
  day21.part1(example)
  |> should.equal(126_384)
}

pub fn part2_test() {
  day21.part2(example)
  |> should.equal(154_115_708_116_294)
}
