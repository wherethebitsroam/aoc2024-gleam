import day22
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "1
10
100
2024"

pub fn part1_test() {
  day22.part1(example)
  |> should.equal(37_327_623)
}

const example2 = "1
2
3
2024"

pub fn part2_test() {
  day22.part2(example2)
  |> should.equal(23)
}
