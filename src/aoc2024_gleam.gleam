import day06
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day06.txt")
  let value = day06.part2_2(input)
  io.debug(value)
}
