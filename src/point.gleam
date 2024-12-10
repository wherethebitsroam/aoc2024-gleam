import gleam/int
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
