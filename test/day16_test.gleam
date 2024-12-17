import day16
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"

const example2 = "#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################"

pub fn part1_test() {
  day16.part1(example)
  |> should.equal(7036)
}

pub fn part1_eg2_test() {
  day16.part1(example2)
  |> should.equal(11_048)
}

pub fn part2_test() {
  day16.part2(example)
  |> should.equal(45)
}

pub fn part2_eg2_test() {
  day16.part2(example2)
  |> should.equal(64)
}
