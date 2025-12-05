pub type Point {
  Point(x: Int, y: Int)
}

pub fn neighbours(of point: Point) -> List(Point) {
  let Point(x:, y:) = point
  [
    Point(x - 1, y - 1),
    Point(x, y - 1),
    Point(x + 1, y - 1),
    Point(x - 1, y),
    Point(x + 1, y),
    Point(x - 1, y + 1),
    Point(x, y + 1),
    Point(x + 1, y + 1),
  ]
}
