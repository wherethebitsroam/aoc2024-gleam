import day18
import gleam/io

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day18.txt")
  let value = day18.part2(input, 70, 1024)
  io.debug(value)
}
