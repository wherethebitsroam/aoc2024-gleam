import day14
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day14.txt")
  let value = day14.part2(input)
  io.debug(value)
}
