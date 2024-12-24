import day23
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day23.txt")
  let value = day23.part2(input)
  io.debug(value)
}
