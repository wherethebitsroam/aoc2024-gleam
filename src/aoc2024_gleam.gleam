import day08
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day08.txt")
  let value = day08.part2(input)
  io.debug(value)
}
