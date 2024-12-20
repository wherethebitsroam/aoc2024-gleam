import day20
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"

pub fn part1_test() {
  day20.part1(example, 10)
  |> should.equal(10)
}

pub fn part2_test() {
  day20.part2(example)
  |> should.equal(0)
}
