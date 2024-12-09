import gleam/int
import gleam/list
import gleam/order
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

type Disk {
  Disk(files: List(Node), free_list: List(Node))
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
fn reorder(disk: Disk) -> Disk {
  reorder_loop(disk.files, disk.free_list |> sort_nodes, [])
}

fn reorder_loop(
  remaining: List(Node),
  free_list: List(Node),
  processed: List(Node),
) -> Disk {
  case remaining {
    [] -> Disk(processed, free_list)
    [n, ..rest] -> {
      let #(free_list, n) = find_free(free_list, n)
      reorder_loop(rest, free_list, [n, ..processed])
    }
  }
}

fn find_free(free_list: List(Node), node: Node) -> #(List(Node), Node) {
  case find_free_loop(free_list, [], node) {
    Ok(update) -> update
    // we didn't find a spot. return unchanged
    Error(_) -> #(free_list, node)
  }
}

fn find_free_loop(
  free_list: List(Node),
  checked: List(Node),
  node: Node,
) -> Result(#(List(Node), Node), Nil) {
  case free_list {
    [free, ..rest] ->
      // we don't want to move a node right
      case free.start > node.start {
        True -> Error(Nil)
        False ->
          case int.compare(size(free), size(node)) {
            order.Lt -> find_free_loop(rest, [free, ..checked], node)
            order.Eq -> {
              let node = Node(node.id, free.start, free.end)
              Ok(#(checked |> list.reverse |> list.append(rest), node))
            }
            order.Gt -> {
              let node = Node(node.id, free.start, free.start + size(node))
              let free = Node(-1, node.end, free.end)
              Ok(#(checked |> list.reverse |> list.append([free, ..rest]), node))
            }
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

fn parse_disk(disk: List(Int), id: Int, idx: Int, acc: Disk) -> Disk {
  case disk {
    [] -> acc
    // A single last node can only be a file
    [file] -> Disk([node(id, idx, file), ..acc.files], acc.free_list)
    [file, free, ..rest] -> {
      let files = [node(id, idx, file), ..acc.files]
      let frees = [node(-1, idx + file, free), ..acc.free_list]
      let idx = idx + file + free
      parse_disk(rest, id + 1, idx, Disk(files, frees))
    }
  }
}

pub fn part2(input: String) -> Int {
  let disk =
    input
    |> string.trim
    |> string.to_graphemes
    |> list.map(util.parse_int)
    |> parse_disk(0, 0, Disk([], []))
    |> reorder

  disk.files
  |> sort_nodes
  |> checksum2(0)
}
