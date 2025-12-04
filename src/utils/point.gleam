pub type Point {
  Point(x: Int, y: Int)
}

pub fn neighbours(of point: Point) -> List(Point) {
  let Point(x:, y:) = point
  [
    Point(x: x - 1, y: y - 1),
    Point(x:, y: y - 1),
    Point(x: x + 1, y: y - 1),
    Point(x: x - 1, y:),
    Point(x: x + 1, y:),
    Point(x: x - 1, y: y + 1),
    Point(x:, y: y + 1),
    Point(x: x + 1, y: y + 1),
  ]
}
