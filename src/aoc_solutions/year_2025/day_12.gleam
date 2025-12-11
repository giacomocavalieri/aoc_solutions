import advent
import gleam/bit_array
import gleam/list
import gleam/option

pub fn day() {
  advent.Day(
    day: 12,
    parse: fn(input) { input },
    part_a:,
    expected_a: option.Some(451),
    wrong_answers_a: [549],
    part_b:,
    expected_b: option.Some("merry christmas"),
    wrong_answers_b: [],
  )
}

fn part_a(input: String) -> Int {
  let input = bit_array.from_string(input)
  solve_loop(input, [])
}

fn part_b(_input) {
  "merry christmas"
}

/// Very cursed way to solve it but I wanted to be silly and try and make this
/// as fast as I possibly could.
/// This loop goes over the entire input just once, never allocating anything
/// except for a list with the shapes' areas.
///
fn solve_loop(input: BitArray, shapes: List(Int)) -> Int {
  case input {
    <<_shape_number, ":\n", rest:bits>> -> shape_loop(rest, shapes, 0)
    _ -> areas_loop(input, list.reverse(shapes), 0)
  }
}

/// With this loop we count the area of the shape, that's the only thing we
/// really care about!
///
fn shape_loop(input: BitArray, shapes: List(Int), area: Int) -> Int {
  case input {
    <<".", rest:bits>> -> shape_loop(rest, shapes, area)
    <<"#", rest:bits>> -> shape_loop(rest, shapes, area + 1)
    <<"\n\n", rest:bits>> -> solve_loop(rest, [area, ..shapes])
    <<"\n", rest:bits>> -> shape_loop(rest, shapes, area)
    _ -> panic as "invalid aoc input"
  }
}

/// This loop goes over the regions rows, one by one and checks if the region
/// can fit the given shapes.
///
fn areas_loop(input: BitArray, shapes: List(Int), answer: Int) -> Int {
  case input {
    <<>> | <<"\n">> -> answer
    <<a, b, "x", c, d, ":", rest:bits>> -> {
      let w = { a - 48 } * 10 + b - 48
      let h = { c - 48 } * 10 + d - 48
      let area = w * h
      count_loop(rest, shapes, shapes, area, 0, 0, answer)
    }
    _ -> panic as "invalid aoc input"
  }
}

/// This loop goes over the quantities in a region's row and checks if the given
/// shapes can fit.
///
fn count_loop(
  input: BitArray,
  all_shapes: List(Int),
  shapes: List(Int),
  area: Int,
  min_area: Int,
  shapes_count: Int,
  answer: Int,
) -> Int {
  case input, shapes {
    // A new number in the list, we parse it and keep going.
    <<" ", a, b, rest:bits>>, [shape, ..shapes] -> {
      let quantity = { a - 48 } * 10 + { b - 48 }
      let min_area = shape * quantity + min_area
      let shapes_count = shapes_count + quantity
      count_loop(rest, all_shapes, shapes, area, min_area, shapes_count, answer)
    }
    // The row is over, now we just have to check.
    // The shapes can easily fit side by side.
    <<"\n", rest:bits>>, [] if area >= 9 * shapes_count ->
      areas_loop(rest, all_shapes, answer + 1)
    // The shapes will never fit: the minimum required area is not enough even
    // assuming a perfect packing.
    <<"\n", rest:bits>>, [] if area < min_area ->
      areas_loop(rest, all_shapes, answer)
    // We can't easily tell if the region is ok or not, guess Christmas is
    // ruined!
    <<"\n", _rest:bits>>, [] -> panic as "this will ruin Christmas"

    _, _ -> panic as "invalid aoc input"
  }
}
