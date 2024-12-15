import gleam/int
import gleam/list
import gleam/order

pub type Point {
  Point(x: Int, y: Int)
}

pub fn add(p1: Point, p2: Point) -> Point {
  Point(x: p1.x + p2.x, y: p1.y + p2.y)
}

pub fn sub(p1: Point, p2: Point) -> Point {
  Point(x: p1.x - p2.x, y: p1.y - p2.y)
}

pub fn scale(p: Point, factor: Int) -> Point {
  Point(p.x * factor, p.y * factor)
}

pub fn compare(p1: Point, p2: Point) -> order.Order {
  case int.compare(p1.x, p2.x) {
    order.Eq -> int.compare(p1.y, p2.y)
    order.Lt -> order.Lt
    order.Gt -> order.Gt
  }
}

const adjacent = [Point(0, 1), Point(0, -1), Point(1, 0), Point(-1, 0)]

pub fn neighbours(p: Point) -> List(Point) {
  adjacent |> list.map(add(_, p))
}

pub fn is_neighbour(p1: Point, p2: Point) -> Bool {
  let p = sub(p1, p2)
  int.absolute_value(p.x) + int.absolute_value(p.y) == 1
}

pub fn to_string(p: Point) -> String {
  "(" <> int.to_string(p.x) <> "," <> int.to_string(p.y) <> ")"
}
