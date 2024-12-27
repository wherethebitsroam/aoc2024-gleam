import day24
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day24.txt")
  let value = day24.part2(input)
  io.debug(value)
}
