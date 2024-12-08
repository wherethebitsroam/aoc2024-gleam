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
