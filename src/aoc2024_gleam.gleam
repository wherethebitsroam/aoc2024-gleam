import day09
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day09.txt")
  let value = day09.part2(input)
  io.debug(value)
}
