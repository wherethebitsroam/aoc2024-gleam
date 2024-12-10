import day10
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day10.txt")
  let value = day10.part2(input)
  io.debug(value)
}
