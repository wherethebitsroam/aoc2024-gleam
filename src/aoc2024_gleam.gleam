import day04
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day04.txt")
  let value = day04.part1(input)
  io.debug(value)
}
