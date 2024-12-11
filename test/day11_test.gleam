import day11
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "125 17"

pub fn part1_test() {
  day11.part1(example)
  |> should.equal(55_312)
}

pub fn part2_test() {
  day11.part2(example)
  |> should.equal(0)
}
