import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/extra/int_extra
import utils/extra/list_extra
import utils/point.{type Point, Point}

pub fn day() {
  advent.Day(
    day: 09,
    parse:,
    part_a:,
    expected_a: option.Some(4_738_108_384),
    wrong_answers_a: [4_737_970_575],
    part_b:,
    expected_b: option.Some(1_513_792_010),
    wrong_answers_b: [4_582_310_446, 4_730_474_923],
  )
}

fn part_a(points: List(Point)) {
  let assert Ok(rectangle) =
    list.combination_pairs(points)
    |> list.map(fn(pair) { rectangle_from_vertices(pair.0, pair.1) })
    |> list_extra.max(by: fn(one, other) { int.compare(area(one), area(other)) })

  area(rectangle)
}

fn area(rectangle: Rectangle) {
  { rectangle.right - rectangle.left + 1 }
  * { rectangle.top - rectangle.bottom + 1 }
}

fn part_b(points: List(Point)) {
  let polygon = polygon_from_points(points)

  let assert Ok(rectangle) =
    list.combination_pairs(points)
    |> list.map(fn(pair) { rectangle_from_vertices(pair.0, pair.1) })
    |> list.sort(fn(one, other) { int.compare(area(other), area(one)) })
    |> list.find(fn(rectangle) { !list.any(polygon, intersects(_, rectangle)) })

  area(rectangle)
}

fn polygon_from_points(points: List(Point)) -> List(Rectangle) {
  let assert Ok(last) = list.last(points)
  let assert Ok(first) = list.first(points)

  [#(last, first), ..list.zip(points, list.drop(points, 1))]
  |> list.map(fn(pair) { rectangle_from_vertices(pair.0, pair.1) })
}

fn intersects(rectangle: Rectangle, with other: Rectangle) -> Bool {
  //                   ┌──────┐
  //           r.left  └──────┘ r.right
  //       s.left ├───────────────┤ s.right
  //
  //                            ┬  s.top
  //      r.top    ┌──────┐    │
  //      r.bottom └──────┘    │
  //                            ┴  s.bottom
  //

  // Great explanation someone linked on Reddit!
  // https://kishimotostudios.com/articles/aabb_collision/

  // Rectangle isn't to the right of the other
  rectangle.left < other.right
  // Rectangle isn't to the left of the other
  && rectangle.right > other.left
  // Rectangle isn't above the other
  && rectangle.bottom < other.top
  // Rectangle isn't below the other
  && rectangle.top > other.bottom
}

pub type Rectangle {
  Rectangle(top: Int, bottom: Int, left: Int, right: Int)
}

fn rectangle_from_vertices(p: Point, q: Point) -> Rectangle {
  let Point(x: qx, y: qy) = q
  let Point(x: px, y: py) = p

  let #(left, right) = case qx > px {
    True -> #(px, qx)
    False -> #(qx, px)
  }
  let #(bottom, top) = case qy > py {
    True -> #(py, qy)
    False -> #(qy, py)
  }

  Rectangle(top:, bottom:, left:, right:)
}

fn parse(input: String) -> List(Point) {
  string.trim_end(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert [x, y] = string.split(line, on: ",")
    Point(x: int_extra.expect(x), y: int_extra.expect(y))
  })
}
