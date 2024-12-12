#!/bin/sh

day="$1"
if [ -z "$day" ]; then
    day=`date "+%d"`
    echo "No day given, using today: $day"
    read -p "Continue [Yn]? " yn
    if [ "$yn" != "y" -a "$yn" != "" ]; then
        exit
    fi
fi

cat > "src/day$day.gleam" <<__END__
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import point.{type Point, Point}
import util

pub fn part1(input: String) -> Int {
  0
}

pub fn part2(input: String) -> Int {
  0
}
__END__

cat > "test/day${day}_test.gleam" <<__END__
import day$day
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const example = ""

pub fn part1_test() {
  day${day}.part1(example)
  |> should.equal(0)
}

pub fn part2_test() {
  day${day}.part2(example)
  |> should.equal(0)
}
__END__

echo "Generated day${day}!"
