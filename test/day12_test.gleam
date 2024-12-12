import day12
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "AAAA
BBCD
BBCC
EEEC"

const example2 = "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO"

const example3 = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"

pub fn part1_test() {
  day12.part1(example)
  |> should.equal(140)
}

pub fn part1_eg2_test() {
  day12.part1(example2)
  |> should.equal(772)
}

pub fn part1_eg3_test() {
  day12.part1(example3)
  |> should.equal(1930)
}

pub fn part2_test() {
  day12.part2(example)
  |> should.equal(80)
}

pub fn part2_eg2_test() {
  day12.part2(example2)
  |> should.equal(436)
}

pub fn part2__eg3_test() {
  day12.part2(example3)
  |> should.equal(1206)
}

const example4 = "EEEEE
EXXXX
EEEEE
EXXXX
EEEEE"

pub fn part2__eg4_test() {
  day12.part2(example4)
  |> should.equal(236)
}

const example5 = "AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
"

pub fn part2__eg5_test() {
  day12.part2(example5)
  |> should.equal(368)
}
