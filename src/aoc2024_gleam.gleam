import day17
import gleam/io

// import simplifile

pub fn main() {
  // let assert Ok(input) = simplifile.read(from: "../day17.txt")
  let value =
    day17.part2(52_042_868, 0, 0, [
      // bst(a) = a % 8 -> b
      2, 4,
      // bxl(7) = b xor 7 -> b
      1, 7,
      // cdv(a) = a / 2^b -> c
      7, 5,
      // adv(3) = a / 2^3 -> a
      0, 3,
      // bxc() = b xor c -> b
      4, 4,
      // bxl(7) = b xor 7 -> b
      1, 7,
      // out(a) = a % 8 -> out
      5, 5,
      // jnz(0) = a != 0, restart
      3, 0,
    ])
  io.debug(value)
}
