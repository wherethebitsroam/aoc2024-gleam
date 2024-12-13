import day13
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day13.txt")
  let value = day13.part2(input)
  io.debug(value)
}
