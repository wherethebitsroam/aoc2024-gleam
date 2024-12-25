import day25
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day25.txt")
  let value = day25.part1(input)
  io.debug(value)
}
