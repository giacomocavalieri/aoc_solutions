import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/int_extra

pub fn day() {
  advent.Day(
    day: 06,
    parse: fn(input) { input },
    part_a:,
    expected_a: option.Some(6_503_327_062_445),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(9_640_641_878_593),
    wrong_answers_b: [],
  )
}

pub type Operation {
  Times
  Plus
}

fn part_a(input: String) -> Int {
  let rows = string.split(input, on: "\n")
  let assert #(rows, [operations, ""]) = list.split(rows, list.length(rows) - 2)
  let columns = list.transpose(list.map(rows, parse_line_loop(_, [])))
  apply_operations_loop(operations, to: columns, sum: 0)
}

fn apply_operations_loop(
  operations: String,
  to columns: List(List(Int)),
  sum sum: Int,
) -> Int {
  case operations, columns {
    " " <> rest, columns -> apply_operations_loop(rest, columns, sum)
    "*" <> rest, [column, ..columns] ->
      apply_operations_loop(rest, columns, sum + int.product(column))
    "+" <> rest, [column, ..columns] ->
      apply_operations_loop(rest, columns, sum + int.sum(column))
    "", _ -> sum
    _, _ -> panic as "unexpected operation"
  }
}

fn parse_line_loop(line: String, acc: List(Int)) {
  case string.trim_start(line) {
    "" -> list.reverse(acc)
    line ->
      case string.split_once(line, on: " ") {
        Ok(#(number, rest)) ->
          parse_line_loop(rest, [int_extra.expect(number), ..acc])
        Error(_) -> list.reverse([int_extra.expect(line), ..acc])
      }
  }
}

fn part_b(input) {
  let assert [first, ..rest] =
    string.split(input, on: "\n")
    |> list.map(string.to_graphemes)
    |> list.transpose
    |> list.map(fn(chars) { string.trim(string.concat(chars)) })

  solve_loop(first, rest, 0)
}

fn solve_loop(first: String, rest: List(String), sum: Int) -> Int {
  let parsed = string.drop_end(first, 1) |> string.trim_end |> int_extra.expect
  case string.ends_with(first, "+") {
    True -> solve_group_loop(rest, Plus, parsed, sum)
    False -> solve_group_loop(rest, Times, parsed, sum)
  }
}

fn solve_group_loop(
  numbers: List(String),
  operation: Operation,
  group: Int,
  sum: Int,
) -> Int {
  case numbers {
    ["", number, ..numbers] -> solve_loop(number, numbers, sum + group)
    [number, ..numbers] -> {
      let group = case operation {
        Plus -> group + int_extra.expect(number)
        Times -> group * int_extra.expect(number)
      }
      solve_group_loop(numbers, operation, group, sum)
    }
    [] -> sum + group
  }
}
