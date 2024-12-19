import day19
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"

pub fn part1_test() {
  day19.part1(example)
  |> should.equal(6)
}

pub fn part2_test() {
  day19.part2(example)
  |> should.equal(0)
}
