import day19
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day19.txt")
  let value = day19.part1(input)
  io.debug(value)
}
