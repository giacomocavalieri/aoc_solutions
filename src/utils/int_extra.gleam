import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam_community/maths

pub fn count_digits(number: Int) -> Int {
  int.absolute_value(number)
  |> int.to_float
  |> maths.logarithm_10
  |> result.unwrap(0.0)
  |> float.floor
  |> float.truncate
  |> int.add(1)
}

pub fn power(base: Int, exponent: Int) -> Int {
  let assert Ok(power) = int.power(base, int.to_float(exponent))
  float.truncate(power)
}

/// Generates all numbers with the given number of digits.
///
/// ```gleam
/// assert numbers(sized: 1) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
/// assert numbers(sized: 2) == list.range(10, 99)
/// ```
///
pub fn numbers(sized digits: Int) -> List(Int) {
  case digits {
    1 -> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    digits if digits <= 0 -> []
    digits -> {
      let start = power(10, digits - 1)
      let end = power(10, digits) - 1
      list.range(start, end)
    }
  }
}

/// Shifts the given number to the left by the given number of digits.
///
/// ```gleam
/// assert shift_left(2, by: 3) == 2000
/// assert shift_left(12, by: 2) == 1200
/// ```
///
pub fn shift_left(number: Int, by digits: Int) -> Int {
  number * power(10, digits)
}

/// Given a number, this repeats it the given number of times.
///
/// ```
/// assert repeat(1, times: 2) == 11
/// assert repeat(12, times: 3) == 121212
/// assert repeat(123, times: 1) == 123
/// ```
///
pub fn repeat(number: Int, times times: Int) -> Int {
  case times <= 1 {
    True -> number
    False -> {
      let digits = count_digits(number)
      repeat_loop(number, digits, 0, times)
    }
  }
}

fn repeat_loop(number: Int, digits: Int, acc: Int, times: Int) -> Int {
  case times {
    0 -> acc
    _ -> {
      let acc = shift_left(acc, by: digits) + number
      repeat_loop(number, digits, acc, times - 1)
    }
  }
}

/// Turns a list of digits into the corresponding number
///
/// ```gleam
/// assert from_digits([1, 2, 3]) == 123
/// assert from_digits([]) == 0
/// ```
///
pub fn from_digits(digits: List(Int)) -> Int {
  list.fold(over: digits, from: 0, with: fn(n, digit) { n * 10 + digit })
}
