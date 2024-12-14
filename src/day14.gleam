import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import point.{type Point, Point}
import util

type Robot {
  Robot(p: Point, v: Point)
}

fn parse_pair(s: String) -> Result(Point, Nil) {
  case s |> string.split(",") {
    [x, y] -> Ok(Point(util.parse_int(x), util.parse_int(y)))
    _ -> Error(Nil)
  }
}

// p=0,4 v=3,-3
fn parse_robot(s: String) -> Result(Robot, Nil) {
  case s |> string.split("=") {
    [_, p, v] ->
      case p |> string.split(" ") {
        [p, _] ->
          parse_pair(p)
          |> result.then(fn(p) {
            v |> parse_pair |> result.map(fn(v) { Robot(p, v) })
          })
        _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn inc(start: Int, velocity: Int, time: Int, l: Int) -> Int {
  let p = { start + time * velocity } % l
  case p < 0 {
    True -> p + l
    False -> p
  }
}

fn move(r: Robot, s: Int, room: Point) -> Robot {
  let p = Point(inc(r.p.x, r.v.x, s, room.x), inc(r.p.y, r.v.y, s, room.y))
  Robot(p, r.v)
}

fn parse(input: String) -> List(Robot) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_robot)
  |> result.all
  |> result.unwrap([])
}

fn safety_factor(ps: List(Point), room: Point) -> Int {
  let x_mid = room.x / 2
  let y_mid = room.y / 2
  let #(a, b, c, d) =
    ps
    |> list.fold(#(0, 0, 0, 0), fn(acc, p) {
      case int.compare(p.y, y_mid), int.compare(p.x, x_mid) {
        order.Gt, order.Gt -> #(acc.0 + 1, acc.1, acc.2, acc.3)
        order.Gt, order.Lt -> #(acc.0, acc.1 + 1, acc.2, acc.3)
        order.Lt, order.Gt -> #(acc.0, acc.1, acc.2 + 1, acc.3)
        order.Lt, order.Lt -> #(acc.0, acc.1, acc.2, acc.3 + 1)
        _, _ -> acc
      }
    })
  a * b * c * d
}

pub fn part1(input: String, x: Int, y: Int) -> Int {
  let room = Point(x, y)
  parse(input)
  |> list.map(fn(r) {
    let r = move(r, 100, room)
    r.p
  })
  |> safety_factor(room)
}

fn unique_p(rs: List(Robot)) -> Bool {
  let l = rs |> list.length
  let ul =
    rs
    |> list.map(fn(r) { r.p })
    |> list.unique
    |> list.length
  l == ul
}

// assume that we have a tree when all robots are in
// unique positions
fn find_tree(rs: List(Robot), room: Point, acc: Int) -> Int {
  case rs |> unique_p {
    True -> acc
    False -> find_tree(rs |> list.map(move(_, 1, room)), room, acc + 1)
  }
}

pub fn part2(input: String) -> Int {
  let room = Point(101, 103)
  parse(input)
  |> find_tree(room, 0)
}
