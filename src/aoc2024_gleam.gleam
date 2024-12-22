import day22
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day22.txt")
  let value = day22.part2(input)
  io.debug(value)
}
