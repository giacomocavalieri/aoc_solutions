import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/extra/int_extra

pub fn day() {
  advent.Day(
    day: 03,
    parse:,
    part_a:,
    expected_a: option.Some(16_993),
    wrong_answers_a: [16_791],
    part_b:,
    expected_b: option.Some(168_617_068_915_447),
    wrong_answers_b: [],
  )
}

fn part_a(banks: List(List(Int))) -> Int {
  list.fold(over: banks, from: 0, with: fn(total_joltage, bank) {
    let #(b1, rest) = max_battery(from: bank, excluding_last: 1)
    let assert Ok(b2) = list.reduce(rest, with: int.max)
    total_joltage + int_extra.from_digits([b1, b2])
  })
}

fn part_b(banks: List(List(Int))) -> Int {
  list.fold(over: banks, from: 0, with: fn(total_joltage, bank) {
    let #(b1, rest) = max_battery(from: bank, excluding_last: 11)
    let #(b2, rest) = max_battery(from: rest, excluding_last: 10)
    let #(b3, rest) = max_battery(from: rest, excluding_last: 9)
    let #(b4, rest) = max_battery(from: rest, excluding_last: 8)
    let #(b5, rest) = max_battery(from: rest, excluding_last: 7)
    let #(b6, rest) = max_battery(from: rest, excluding_last: 6)
    let #(b7, rest) = max_battery(from: rest, excluding_last: 5)
    let #(b8, rest) = max_battery(from: rest, excluding_last: 4)
    let #(b9, rest) = max_battery(from: rest, excluding_last: 3)
    let #(b10, rest) = max_battery(from: rest, excluding_last: 2)
    let #(b11, rest) = max_battery(from: rest, excluding_last: 1)
    let assert Ok(b12) = list.reduce(rest, with: int.max)

    let joltage =
      int_extra.from_digits([b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12])
    total_joltage + joltage
  })
}

fn max_battery(
  from bank: List(Int),
  excluding_last excluded: Int,
) -> #(Int, List(Int)) {
  case bank {
    [first, ..rest] ->
      max_battery_loop(rest, first, rest, 2, list.length(bank) - excluded)
    [] -> panic as "no batteries"
  }
}

fn max_battery_loop(
  bank: List(Int),
  max_so_far: Int,
  bank_after_max: List(Int),
  index: Int,
  up_to_including end: Int,
) -> #(Int, List(Int)) {
  case bank, index > end {
    _, True | [], _ -> #(max_so_far, bank_after_max)
    [first, ..rest], False ->
      case first > max_so_far {
        True -> max_battery_loop(rest, first, rest, index + 1, end)
        False ->
          max_battery_loop(rest, max_so_far, bank_after_max, index + 1, end)
      }
  }
}

fn parse(input: String) -> List(List(Int)) {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.map(int_extra.expect)
  })
}
