import day12
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day12.txt")
  let value = day12.part2(input)
  io.debug(value)
}
