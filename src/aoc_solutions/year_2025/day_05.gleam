import advent
import gleam/int
import gleam/list
import gleam/option
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
  let #(ranges, ingredients) = input

  list.count(ingredients, fn(ingredient) {
    list.any(ranges, contains(_, ingredient))
  })
}

fn contains(range: Range, number: Int) {
  range.from <= number && number <= range.to
}

pub fn part_b(input: #(List(Range), _)) -> Int {
  let #(ranges, _) = input
  sum_ranges(ranges)
}

fn sum_ranges(ranges: List(Range)) {
  ranges
  |> list.sort(fn(left, right) { int.compare(left.from, right.from) })
  |> sum_ranges_loop(0, 0)
}

fn sum_ranges_loop(ranges: List(Range), previous_end: Int, acc: Int) {
  case ranges {
    [] -> acc

    // ..... ] previous range
    // .. ]    new range
    [Range(from: _, to:), ..rest] if to <= previous_end ->
      sum_ranges_loop(rest, previous_end, acc)

    // .... ]      previous range
    //   ....... ] new range
    [Range(from:, to:), ..rest] if from <= previous_end ->
      sum_ranges_loop(rest, to, acc + to - previous_end)

    // .... ]           previous range
    //         [ .... ] new range
    [Range(from:, to:), ..rest] ->
      sum_ranges_loop(rest, to, acc + to - from + 1)
  }
}

fn parse(input: String) -> #(List(Range), List(Int)) {
  let assert [ranges, ingredients] = string.split(string.trim(input), "\n\n")

  let ranges =
    list.map(string.split(ranges, "\n"), fn(str) {
      let assert [from, to] = string.split(str, "-")
      Range(from: int_extra.expect(from), to: int_extra.expect(to))
    })

  let ingredients =
    string.split(ingredients, on: "\n")
    |> list.map(int_extra.expect)

  #(ranges, ingredients)
}
