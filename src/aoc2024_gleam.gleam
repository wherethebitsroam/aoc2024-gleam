import day15
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day15.txt")
  let value = day15.part2(input)
  io.debug(value)
}
