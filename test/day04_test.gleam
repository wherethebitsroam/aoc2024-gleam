import day04
import gleeunit
import gleeunit/should

const example = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  day04.part1(example)
  |> should.equal(18)
}

pub fn to_diag_test() {
  let input = [
    ["A", "B", "C", "D"],
    ["E", "F", "G", "H"],
    ["I", "J", "K", "L"],
    ["M", "N", "O", "P"],
  ]

  let expected = [
    ["A"],
    ["B", "E"],
    ["C", "F", "I"],
    ["D", "G", "J", "M"],
    ["H", "K", "N"],
    ["L", "O"],
    ["P"],
  ]

  day04.to_diag(input)
  |> should.equal(expected)
}

pub fn part2_test() {
  day04.part2(example)
  |> should.equal(9)
}

pub fn part1_2_test() {
  day04.part1_2(example)
  |> should.equal(18)
}
