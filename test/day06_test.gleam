import day06
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn part1_test() {
  day06.part1(example)
  |> should.equal(41)
}

pub fn part2_test() {
  day06.part2(example)
  |> should.equal(6)
}
