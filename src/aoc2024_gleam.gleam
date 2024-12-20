import day20
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day20.txt")
  let value = day20.part2(input, 100)
  io.debug(value)
}
