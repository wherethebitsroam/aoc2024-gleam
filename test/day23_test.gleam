import day23
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = "kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"

pub fn part1_test() {
  day23.part1(example)
  |> should.equal(7)
}

pub fn part2_test() {
  day23.part2(example)
  |> should.equal("co,de,ka,ta")
}
