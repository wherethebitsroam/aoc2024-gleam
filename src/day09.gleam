import gleam/int
import gleam/list
import gleam/string
import util

type Mode {
  Files
  Free
}

type File {
  File(id: Int, size: Int)
}

fn add_index(size: Int, id: Int, acc: Int, idx: Int) -> #(Int, Int) {
  case size {
    0 -> #(acc, idx)
    x -> add_index(x - 1, id, acc + id * idx, idx + 1)
  }
}

fn fill_free(
  size: Int,
  files: List(File),
  acc: Int,
  idx: Int,
) -> #(List(File), Int, Int) {
  let files = files |> list.reverse
  fill_free_loop(size, files, acc, idx)
}

fn fill_free_loop(
  size: Int,
  files_rev: List(File),
  acc: Int,
  idx: Int,
) -> #(List(File), Int, Int) {
  case size {
    0 -> #(files_rev |> list.reverse, acc, idx)
    _ -> {
      case files_rev {
        [] -> #(files_rev |> list.reverse, acc, idx)
        [f, ..rest] -> {
          let file_size = f.size - 1
          let files = case file_size {
            0 -> rest
            _ -> [File(id: f.id, size: file_size), ..rest]
          }
          fill_free_loop(size - 1, files, acc + f.id * idx, idx + 1)
        }
      }
    }
  }
}

fn checksum(
  files: List(File),
  free: List(Int),
  mode: Mode,
  idx: Int,
  acc: Int,
) -> Int {
  case mode {
    Files ->
      case files {
        [] -> acc
        [f, ..rest] -> {
          let #(acc, idx) = add_index(f.size, f.id, acc, idx)
          checksum(rest, free, Free, idx, acc)
        }
      }
    Free -> {
      case free {
        [] -> checksum(files, [], Files, idx, acc)
        [f, ..rest] -> {
          let #(files, acc, idx) = fill_free(f, files, acc, idx)
          checksum(files, rest, Files, idx, acc)
        }
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let disk =
    input |> string.trim |> string.to_graphemes |> list.map(util.parse_int)

  let #(files, free) =
    disk
    |> list.index_fold(#([], []), fn(acc, item, index) {
      case index % 2 == 0 {
        True -> #([item, ..acc.0], acc.1)
        False -> #(acc.0, [item, ..acc.1])
      }
    })

  let files =
    files |> list.reverse |> list.index_map(fn(x, i) { File(id: i, size: x) })

  checksum(files, free |> list.reverse, Files, 0, 0)
}

type Node {
  Node(id: Int, start: Int, end: Int)
}

fn node(id: Int, start: Int, size: Int) -> Node {
  Node(id, start, start + size)
}

fn size(node: Node) -> Int {
  node.end - node.start
}

fn sort_nodes(nodes: List(Node)) -> List(Node) {
  nodes |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
}

// remaining should be in reverse of id
fn reorder(remaining: List(Node), processed: List(Node)) -> List(Node) {
  case remaining {
    [] -> processed
    [n, ..rest] -> {
      let sorted = remaining |> list.append(processed) |> sort_nodes
      let size = size(n)
      let n = case find_spot(sorted, n.start, size) {
        Error(_) -> n
        Ok(start) -> node(n.id, start, size)
      }
      reorder(rest, [n, ..processed])
    }
  }
}

fn find_spot(nodes: List(Node), start: Int, size: Int) -> Result(Int, Nil) {
  case nodes {
    [a, b, ..rest] ->
      // we don't want to move a node right
      case a.end > start {
        True -> Error(Nil)
        False ->
          case b.start - a.end >= size {
            True -> Ok(a.end)
            False -> find_spot([b, ..rest], start, size)
          }
      }
    _ -> Error(Nil)
  }
}

fn checksum2(nodes: List(Node), acc: Int) -> Int {
  case nodes {
    [] -> acc
    [n, ..rest] -> {
      let #(acc, _) = add_index(size(n), n.id, acc, n.start)
      checksum2(rest, acc)
    }
  }
}

fn parse_disk(disk: List(Int), id: Int, idx: Int, acc: List(Node)) -> List(Node) {
  case disk {
    [] -> acc
    // A single last node can only be a file
    [file] -> [node(id, idx, file), ..acc]
    [file, free, ..rest] -> {
      let acc = [node(id, idx, file), ..acc]
      let idx = idx + file + free
      parse_disk(rest, id + 1, idx, acc)
    }
  }
}

pub fn part2(input: String) -> Int {
  let disk =
    input |> string.trim |> string.to_graphemes |> list.map(util.parse_int)

  disk
  |> parse_disk(0, 0, [])
  |> reorder([])
  |> sort_nodes
  |> checksum2(0)
}
