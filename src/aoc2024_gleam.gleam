import day21
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day21.txt")
  let value = day21.part2(input)
  io.debug(value)
}
