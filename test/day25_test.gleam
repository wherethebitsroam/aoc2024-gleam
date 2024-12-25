import day25
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"

pub fn part1_test() {
  day25.part1(example)
  |> should.equal(3)
}
