import day16
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day16.txt")
  let value = day16.part2(input)
  io.debug(value)
}
