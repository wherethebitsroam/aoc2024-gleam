import day01
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn part1_test() {
  day01.part1(example)
  |> should.equal(11)
}

pub fn part2_test() {
  day01.part2(example)
  |> should.equal(31)
}
