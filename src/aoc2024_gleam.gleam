import day03
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read(from: "../day03.txt")
  day03.part2(input)
}
