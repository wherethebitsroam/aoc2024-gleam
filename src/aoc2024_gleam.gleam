import day05
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day05.txt")
  let value = day05.part2(input)
  io.debug(value)
}
