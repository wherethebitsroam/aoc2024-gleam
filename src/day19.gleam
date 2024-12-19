import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import gleam/string
import point.{type Point, Point}
import util

fn parse(input: String) -> #(List(String), List(String)) {
  let #(start, end) =
    input
    |> string.trim
    |> string.split_once("\n\n")
    |> util.unwrap_or_panic

  #(start |> string.split(", "), end |> string.split("\n"))
}

fn solve(patterns: List(String), designs: List(String)) -> Int {
  designs
  |> list.fold(#(dict.new(), 0), fn(acc, design) {
    let #(cache, count) = acc
    let #(cache, success) = solveable(cache, design, patterns)
    let count = case success {
      True -> count + 1
      False -> count
    }
    #(cache, count)
  })
  |> pair.second
}

fn solveable(
  cache: Dict(String, Bool),
  design: String,
  patterns: List(String),
) -> #(Dict(String, Bool), Bool) {
  // io.debug(#(design, patterns))
  case cache |> dict.get(design) {
    Ok(b) -> #(cache, b)
    Error(_) -> {
      case design |> string.is_empty {
        True -> #(cache, True)
        False -> {
          let #(cache, success) =
            patterns
            |> list.filter(fn(p) { design |> string.starts_with(p) })
            |> list.fold(#(cache, False), fn(acc, p) {
              let #(cache, success) = acc
              let design = design |> string.drop_start(p |> string.length)
              let #(cache, solved) = solveable(cache, design, patterns)
              #(cache, success || solved)
            })

          let cache = cache |> dict.insert(design, success)
          #(cache, success)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(patterns, designs) = input |> parse
  solve(patterns, designs)
}

pub fn part2(input: String) -> Int {
  0
}
