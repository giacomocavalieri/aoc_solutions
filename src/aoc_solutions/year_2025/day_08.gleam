import advent
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/extra/dict_extra
import utils/extra/int_extra

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
  let assert Ok(group_size) =
    list.combination_pairs(boxes)
    |> list.map(fn(pair) { #(pair.0, pair.1, distance(pair.0, pair.1)) })
    |> list.sort(fn(one, other) { int.compare(one.2, other.2) })
    |> list.take(1000)
    |> connect_boxes(boxes)

  let assert [a, b, c, ..] =
    dict.values(group_size)
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

pub fn connect_boxes(
  pairs: List(#(Box, Box, Int)),
  boxes: List(Box),
) -> Result(Dict(Int, Int), Int) {
  let point_group =
    list.index_fold(over: boxes, from: dict.new(), with: dict.insert)
  let group_size =
    list.index_fold(over: boxes, from: dict.new(), with: fn(acc, _, i) {
      dict.insert(acc, i, 1)
    })

  connect_boxes_loop(pairs, point_group, group_size)
}

fn distance(one: Box, other: Box) {
  let dx = one.x - other.x
  let dy = one.y - other.y
  let dz = one.z - other.z
  dx * dx + dy * dy + dz * dz
}

fn connect_boxes_loop(
  pairs: List(#(Box, Box, Int)),
  point_group: Dict(Box, Int),
  group_size: Dict(Int, Int),
) -> Result(Dict(Int, Int), Int) {
  case pairs {
    [] -> Ok(group_size)
    [#(one, other, _), ..rest] -> {
      let assert Ok(group_one) = dict.get(point_group, one)
      let assert Ok(group_other) = dict.get(point_group, other)

      case group_one == group_other {
        True -> connect_boxes_loop(rest, point_group, group_size)
        False -> {
          let assert Ok(group_one_size) = dict.get(group_size, group_one)
          let assert Ok(group_other_size) = dict.get(group_size, group_other)

          case group_one_size + group_other_size {
            1000 -> Error(one.x * other.x)
            new_size -> {
              let new_group = int.min(group_one, group_other)
              let old_group = int.max(group_one, group_other)
              let point_group =
                dict_extra.replace_value(point_group, old_group, new_group)
              let group_size =
                dict.insert(group_size, new_group, new_size)
                |> dict.delete(old_group)
              connect_boxes_loop(rest, point_group, group_size)
            }
          }
        }
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
