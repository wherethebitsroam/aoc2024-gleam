import day11
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day11.txt")
  let value = day11.part2(input)
  io.debug(value)
}
