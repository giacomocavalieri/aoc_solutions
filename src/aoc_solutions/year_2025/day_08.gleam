import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/extra/int_extra
import utils/structures/disjoint_set.{type DisjointSet}

pub fn day() {
  advent.Day(
    day: 08,
    parse:,
    part_a:,
    expected_a: option.Some(75_582),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(59_039_696),
    wrong_answers_b: [],
  )
}

pub type Box {
  Box(x: Int, y: Int, z: Int)
}

fn part_a(boxes: List(Box)) {
  let assert Ok(groups) =
    list.combination_pairs(boxes)
    |> list.map(fn(pair) { #(pair.0, pair.1, distance(pair.0, pair.1)) })
    |> list.sort(fn(one, other) { int.compare(one.2, other.2) })
    |> list.take(1000)
    |> connect_boxes(boxes)

  let assert [a, b, c, ..] =
    disjoint_set.set_sizes(groups)
    |> list.sort(int.compare)
    |> list.reverse

  a * b * c
}

fn part_b(boxes: List(Box)) -> Int {
  let assert Error(result) =
    list.combination_pairs(boxes)
    |> list.map(fn(pair) { #(pair.0, pair.1, distance(pair.0, pair.1)) })
    |> list.sort(fn(one, other) { int.compare(one.2, other.2) })
    |> connect_boxes(boxes)

  result
}

fn distance(one: Box, other: Box) {
  let dx = one.x - other.x
  let dy = one.y - other.y
  let dz = one.z - other.z
  dx * dx + dy * dy + dz * dz
}

pub fn connect_boxes(
  pairs: List(#(Box, Box, Int)),
  boxes: List(Box),
) -> Result(DisjointSet(Box), Int) {
  list.fold(over: boxes, from: disjoint_set.new(), with: disjoint_set.insert)
  |> connect_boxes_loop(pairs, _)
}

fn connect_boxes_loop(
  pairs: List(#(Box, Box, Int)),
  groups: DisjointSet(Box),
) -> Result(DisjointSet(Box), Int) {
  case pairs {
    [] -> Ok(groups)
    [#(one, other, _), ..rest] -> {
      let groups = disjoint_set.merge(groups, one, other)
      case disjoint_set.set_size(groups, one) {
        Error(_) -> panic as "unreachable"
        Ok(#(1000, _)) -> Error(one.x * other.x)
        Ok(#(_, set)) -> connect_boxes_loop(rest, set)
      }
    }
  }
}

fn parse(string: String) -> List(Box) {
  string.trim_end(string)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert [x, y, z] = string.split(line, on: ",")
    let x = int_extra.expect(x)
    let y = int_extra.expect(y)
    let z = int_extra.expect(z)
    Box(x:, y:, z:)
  })
}
