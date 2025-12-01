import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import utils/int_extra

pub fn day() {
  advent.Day(
    day: 02,
    parse:,
    part_a:,
    expected_a: option.Some(19_574_776_074),
    wrong_answers_a: [519_095],
    part_b:,
    expected_b: option.Some(25_912_654_282),
    wrong_answers_b: [25_894_454_288, 25_894_454_330, 25_912_654_324],
  )
}

fn part_a(ranges: List(#(Int, Int))) -> Int {
  sum_invalid_ids(for: ranges, with: invalid_ids_part_a)
}

fn part_b(ranges: List(#(Int, Int))) -> Int {
  sum_invalid_ids(for: ranges, with: invalid_ids_part_b)
}

fn sum_invalid_ids(
  for ranges: List(#(Int, Int)),
  with invalid_ids_sized: fn(Int) -> List(Int),
) -> Int {
  list.flat_map(ranges, fn(range) {
    let #(start, end) = range
    all_invalid_ids(from: start, to: end, with: invalid_ids_sized)
  })
  |> list.unique
  |> int.sum
}

fn all_invalid_ids(
  from min: Int,
  to max: Int,
  with invalid_ids_sized: fn(Int) -> List(Int),
) -> List(Int) {
  list.range(int_extra.count_digits(min), int_extra.count_digits(max))
  |> list.filter(keeping: fn(chunk_digits) { chunk_digits >= 2 })
  |> list.flat_map(invalid_ids_sized)
  |> list.filter(fn(id) { min <= id && id <= max })
}

fn invalid_ids_part_a(sized digits: Int) -> List(Int) {
  case int.is_even(digits) {
    False -> []
    True ->
      int_extra.numbers(sized: digits / 2)
      |> list.map(int_extra.repeat(_, times: 2))
  }
}

fn invalid_ids_part_b(sized digits: Int) -> List(Int) {
  list.range(1, digits / 2)
  |> list.filter(fn(chunk_digits) { digits % chunk_digits == 0 })
  |> list.flat_map(fn(chunk_digits) {
    int_extra.numbers(sized: chunk_digits)
    |> list.map(with: int_extra.repeat(_, times: digits / chunk_digits))
  })
}

fn parse(input: String) -> List(#(Int, Int)) {
  string.trim(input)
  |> string.split(on: ",")
  |> list.map(fn(range) {
    let assert [min, max] = string.split(range, on: "-")
    let assert Ok(min) = int.parse(min)
    let assert Ok(max) = int.parse(max)
    #(min, max)
  })
}
