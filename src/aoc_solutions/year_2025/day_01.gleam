import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn day() {
  advent.Day(
    day: 01,
    parse:,
    part_a:,
    expected_a: option.Some(1034),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(6166),
    wrong_answers_b: [7200],
  )
}

pub type Rotation {
  Left(Int)
  Right(Int)
}

fn part_a(rotations: List(Rotation)) {
  list.scan(over: rotations, from: 50, with: fn(current_position, rotation) {
    let #(new_position, _zeros) =
      rotate(from: current_position, by: rotation, count: 0)
    new_position
  })
  |> list.count(fn(position) { position == 0 })
}

fn part_b(rotations: List(Rotation)) -> Int {
  let #(_final_position, zeros) =
    list.fold(over: rotations, from: #(50, 0), with: fn(acc, rotation) {
      let #(current_position, zeros_so_far) = acc
      rotate(from: current_position, by: rotation, count: zeros_so_far)
    })

  zeros
}

fn rotate(
  from current: Int,
  by rotation: Rotation,
  count zeros: Int,
) -> #(Int, Int) {
  case rotation {
    Left(0) -> #(current, zeros)
    Left(turns) if current == 0 -> rotate(99, Left(turns - 1), zeros)
    Left(turns) if current == 1 ->
      rotate(current - 1, Left(turns - 1), zeros + 1)
    Left(turns) -> rotate(current - 1, Left(turns - 1), zeros)

    Right(0) -> #(current, zeros)
    Right(turns) if current == 99 -> rotate(0, Right(turns - 1), zeros + 1)
    Right(turns) -> rotate(current + 1, Right(turns - 1), zeros)
  }
}

fn parse(input: String) -> List(Rotation) {
  let assert Ok(rotations) =
    input
    |> string.trim
    |> string.split(on: "\n")
    |> list.try_map(parse_rotation)

  rotations
}

fn parse_rotation(line: String) -> Result(Rotation, Nil) {
  case line {
    "L" <> number -> int.parse(number) |> result.map(Left)
    "R" <> number -> int.parse(number) |> result.map(Right)
    _ -> Error(Nil)
  }
}
