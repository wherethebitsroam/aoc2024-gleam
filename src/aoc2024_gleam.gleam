import day07
import gleam/io
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day07.txt")
  let value = day07.part2(input)
  io.debug(value)
}
