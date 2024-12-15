import day14
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3"

pub fn part1_test() {
  day14.part1(example, 11, 7)
  |> should.equal(12)
}