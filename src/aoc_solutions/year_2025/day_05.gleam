import advent
import gleam/int
import gleam/list
import gleam/option
import gleam/order.{type Order}
import gleam/string
import utils/int_extra

pub fn day() {
  advent.Day(
    day: 05,
    parse:,
    part_a:,
    expected_a: option.Some(744),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(347_468_726_696_961),
    wrong_answers_b: [347_814_981_078_864],
  )
}

pub type Range {
  Range(from: Int, to: Int)
}

pub fn part_a(input: #(List(Range), List(Int))) -> Int {
  let #(ranges, ids) = input
  list.count(ids, in_ranges(_, ranges))
}

fn in_ranges(id: Int, ranges: List(Range)) {
  case ranges {
    [Range(from:, to: _), ..] if id < from -> False
    [Range(from: _, to:), ..] if id <= to -> True
    [_, ..ranges] -> in_ranges(id, ranges)
    [] -> False
  }
}

pub fn part_b(input: #(List(Range), _)) -> Int {
  let #(ranges, _) = input
  list.fold(over: ranges, from: 0, with: fn(sum, range) {
    sum + range.to - range.from + 1
  })
}

fn parse(input: String) -> #(List(Range), List(Int)) {
  let assert [ranges, ingredients] = string.split(string.trim(input), "\n\n")

  let ranges =
    reduce_ranges(
      list.map(string.split(ranges, "\n"), fn(str) {
        let assert [from, to] = string.split(str, "-")
        Range(from: int_extra.expect(from), to: int_extra.expect(to))
      }),
    )

  let ingredients =
    string.split(ingredients, on: "\n")
    |> list.map(int_extra.expect)

  #(ranges, ingredients)
}

fn ranges_compare(one: Range, other: Range) -> Order {
  int.compare(one.from, other.from)
}

fn reduce_ranges(ranges: List(Range)) -> List(Range) {
  case list.sort(ranges, ranges_compare) {
    [Range(from:, to:), ..ranges] -> reduce_ranges_loop(ranges, from, to, [])
    [] -> []
  }
}

fn reduce_ranges_loop(
  ranges: List(Range),
  previous_start: Int,
  previous_end: Int,
  acc: List(Range),
) -> List(Range) {
  case ranges {
    [] -> list.reverse([Range(from: previous_start, to: previous_end), ..acc])

    // ..... ] previous range
    // .. ]    new range
    [Range(from: _, to:), ..rest] if to <= previous_end ->
      reduce_ranges_loop(rest, previous_start, previous_end, acc)

    // ..... ]     previous range
    //   ....... ] new range
    [Range(from:, to:), ..rest] if from <= previous_end ->
      reduce_ranges_loop(rest, previous_start, to, acc)

    // ..... ]          previous range
    //         [ .... ] new range
    [Range(from:, to:), ..rest] ->
      reduce_ranges_loop(rest, from, to, [
        Range(from: previous_start, to: previous_end),
        ..acc
      ])
  }
}
