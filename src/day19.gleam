import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import util

fn parse(input: String) -> #(List(String), List(String)) {
  let #(start, end) =
    input
    |> string.trim
    |> string.split_once("\n\n")
    |> util.unwrap_or_panic

  #(start |> string.split(", "), end |> string.split("\n"))
}

fn solve(patterns: List(String), designs: List(String)) -> List(Int) {
  designs
  |> list.fold(#(dict.new(), []), fn(acc, design) {
    let #(cache, acc) = acc
    let #(cache, ways) = solveable(cache, design, patterns)
    #(cache, [ways, ..acc])
  })
  |> pair.second
}

fn solveable(
  cache: Dict(String, Int),
  design: String,
  patterns: List(String),
) -> #(Dict(String, Int), Int) {
  // io.debug(#(design, patterns))
  case cache |> dict.get(design) {
    Ok(count) -> #(cache, count)
    Error(_) -> {
      case design |> string.is_empty {
        True -> #(cache, 1)
        False -> {
          let #(cache, ways) =
            patterns
            |> list.filter(fn(p) { design |> string.starts_with(p) })
            |> list.fold(#(cache, 0), fn(acc, p) {
              let #(cache, acc) = acc
              let design = design |> string.drop_start(p |> string.length)
              let #(cache, ways) = solveable(cache, design, patterns)
              #(cache, acc + ways)
            })

          let cache = cache |> dict.insert(design, ways)
          #(cache, ways)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(patterns, designs) = input |> parse
  solve(patterns, designs) |> list.filter(fn(c) { c != 0 }) |> list.length
}

pub fn part2(input: String) -> Int {
  let #(patterns, designs) = input |> parse
  solve(patterns, designs) |> list.fold(0, int.add)
}
