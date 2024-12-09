import day09
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "2333133121414131402"

// pub fn part1_test() {
//   day09.part1(example)
//   |> should.equal(1928)
// }

pub fn part2_test() {
  day09.part2(example)
  |> should.equal(2858)
}
