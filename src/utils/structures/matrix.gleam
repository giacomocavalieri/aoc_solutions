import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result

pub type Matrix {
  Matrix(data: BitArray, rows: Int, columns: Int)
}

pub fn gauss(matrix: Matrix) -> Matrix {
  gauss_loop(matrix, 0, 0)
}

/// All the values a_ii.
///
pub fn diagonal(matrix: Matrix) -> List(Int) {
  diagonal_loop(matrix, 0, [])
}

fn diagonal_loop(matrix: Matrix, i: Int, acc: List(Int)) -> List(Int) {
  case i >= matrix.rows || i >= matrix.columns {
    True -> list.reverse(acc)
    False -> diagonal_loop(matrix, i + 1, [unsafe_get(matrix, i, i), ..acc])
  }
}

fn gauss_loop(matrix: Matrix, pivot_row: Int, pivot_col: Int) -> Matrix {
  case pivot_row >= matrix.rows || pivot_col >= matrix.columns {
    True -> matrix
    False ->
      case unsafe_get(matrix, pivot_row, pivot_col) {
        0 ->
          case index_of_next_pivot_row(matrix, pivot_row + 1, pivot_col) {
            // No pivot is found in this column, so we keep going with the
            // next one.
            Error(_) -> gauss_loop(matrix, pivot_row, pivot_col + 1)
            Ok(new_pivot_row) ->
              unsafe_swap_rows(matrix, pivot_row, new_pivot_row)
              |> gauss_loop(pivot_row, pivot_col)
          }

        _pivot -> {
          // We get the row where the pivot is in and divide it by its gcd
          // to keep the coefficients as small as possible.
          let row = unsafe_row(matrix, pivot_row)
          let row = divide_row(row, row_gcd(row, 0))
          // We then subtract a multiple of the pivot row from all subsequent
          // rows to zero out the pivot column; after that we keep going with
          // the loop, moving to the next pivot.
          unsafe_subtract_pivot_row(matrix, row, pivot_row, pivot_col)
          |> gauss_loop(pivot_row + 1, pivot_col + 1)
        }
      }
  }
}

fn row_gcd(row: BitArray, acc: Int) -> Int {
  case row {
    <<n:size(32)-signed, row:bytes>> -> row_gcd(row, gcd(acc, n))
    <<>> -> acc
    _ -> panic as "invalid row"
  }
}

fn unsafe_subtract_pivot_row(
  matrix: Matrix,
  pivot: BitArray,
  pivot_row: Int,
  pivot_col: Int,
) -> Matrix {
  let Matrix(data:, rows: _, columns:) = matrix

  // We first need to skip all rows (including the pivot one), those won't
  // change.
  let row_bytes = columns * 4
  let prefix_bytes = row_bytes * pivot_row
  let assert <<
    prefix:size(prefix_bytes)-bytes,
    _old_pivot:size(row_bytes)-bytes,
    rest:bytes,
  >> = data

  let prefix = <<prefix:bits, pivot:bits>>

  // Then we'll go in the loop subtracting everything from all remaining rows.
  let data =
    unsafe_subtract_pivot_row_loop(rest, pivot_col, row_bytes, pivot, prefix)
  Matrix(..matrix, data:)
}

fn unsafe_subtract_pivot_row_loop(
  data: BitArray,
  pivot_col: Int,
  row_bytes: Int,
  row_to_subtract: BitArray,
  acc: BitArray,
) -> BitArray {
  case data {
    <<>> -> acc
    <<next_row:size(row_bytes)-bytes, data:bytes>> -> {
      // We need to find both the pivot and the value exactly under the pivot so
      // we can tell by what factors to multiply the pivot row when subtracting
      // it from the new one when zeroing the value under the pivot.
      let prefix_bytes = pivot_col * 4
      let assert <<_:size(prefix_bytes)-bytes, pivot:size(32)-signed, _:bytes>> =
        row_to_subtract
      let assert <<
        _:size(prefix_bytes)-bytes,
        below_pivot:size(32)-signed,
        _:bytes,
      >> = next_row

      let reduced =
        unsafe_subtract_multiply(next_row, row_to_subtract, pivot, below_pivot)

      unsafe_subtract_pivot_row_loop(
        data,
        pivot_col,
        row_bytes,
        row_to_subtract,
        <<acc:bits, reduced:bits>>,
      )
    }

    _ -> panic as "invalid matrix"
  }
}

fn unsafe_subtract_multiply(
  from row: BitArray,
  subtract other: BitArray,
  pivot pivot: Int,
  below_pivot below_pivot: Int,
) -> BitArray {
  unsafe_subtract_multiply_loop(0, row, other, pivot, below_pivot, <<>>)
}

fn unsafe_subtract_multiply_loop(
  i: Int,
  row: BitArray,
  pivot_row: BitArray,
  pivot: Int,
  below_pivot: Int,
  acc: BitArray,
) -> BitArray {
  let prefix_bits = i * 32
  case row, pivot_row {
    <<_:size(prefix_bits), n:size(32)-signed, _:bytes>>,
      <<_:size(prefix_bits), m:size(32)-signed, _:bytes>>
    ->
      unsafe_subtract_multiply_loop(i + 1, row, pivot_row, pivot, below_pivot, <<
        acc:bits,
        { { n * pivot } - { m * below_pivot } }:size(32),
      >>)

    _, _ -> acc
  }
}

fn divide_row(row: BitArray, by n: Int) -> BitArray {
  divide_row_loop(row, n, <<>>)
}

fn divide_row_loop(row: BitArray, n: Int, acc: BitArray) -> BitArray {
  case row {
    <<>> -> acc
    <<m:size(32)-signed, row:bytes>> ->
      divide_row_loop(row, n, <<acc:bits, { m / n }:size(32)>>)
    _ -> panic as "invalid row"
  }
}

fn gcd(a: Int, b: Int) -> Int {
  gcd_loop(int.absolute_value(a), int.absolute_value(b))
}

fn gcd_loop(a: Int, b: Int) -> Int {
  case b {
    0 -> a
    _ -> gcd_loop(b, a % b)
  }
}

fn index_of_next_pivot_row(
  matrix: Matrix,
  row: Int,
  pivot_column: Int,
) -> Result(Int, Nil) {
  case row >= matrix.rows || pivot_column >= matrix.columns {
    True -> Error(Nil)
    False ->
      case unsafe_get(matrix, row, pivot_column) {
        0 -> index_of_next_pivot_row(matrix, row + 1, pivot_column)
        _ -> Ok(row)
      }
  }
}

pub fn swap_rows(matrix: Matrix, i: Int, j: Int) -> Matrix {
  case i == j || i > matrix.rows || j > matrix.rows || i <= 0 || j <= 0 {
    True -> matrix
    False ->
      case i < j {
        True -> unsafe_swap_rows(matrix, i - 1, j - 1)
        False -> unsafe_swap_rows(matrix, j - 1, i - 1)
      }
  }
}

fn unsafe_swap_rows(matrix: Matrix, i: Int, j: Int) -> Matrix {
  let Matrix(data:, rows: _, columns:) = matrix

  let row_bytes = 4 * columns
  let prefix_bytes = i * row_bytes
  let middle_bytes = { j - i - 1 } * row_bytes
  let assert <<
    prefix:size(prefix_bytes)-bytes,
    row_i:size(row_bytes)-bytes,
    middle:size(middle_bytes)-bytes,
    row_j:size(row_bytes)-bytes,
    suffix:bytes,
  >> = data
  let data = <<prefix:bits, row_j:bits, middle:bits, row_i:bits, suffix:bits>>
  Matrix(..matrix, data:)
}

pub fn row(matrix: Matrix, row: Int) -> Result(List(Int), Nil) {
  case row <= 0 || row > matrix.rows {
    True -> Error(Nil)
    False ->
      unsafe_row(matrix, row - 1)
      |> row_to_list
      |> Ok
  }
}

fn unsafe_row(matrix: Matrix, row: Int) {
  let Matrix(data:, rows: _, columns:) = matrix
  part(data, row * columns * 4, columns * 4)
}

pub fn get(matrix: Matrix, row: Int, column: Int) -> Result(Int, Nil) {
  let Matrix(data: _, rows:, columns:) = matrix
  case { 0 < row && row <= rows } && { 0 < column && column <= columns } {
    False -> Error(Nil)
    True -> Ok(unsafe_get(matrix, row - 1, column - 1))
  }
}

fn unsafe_get(matrix: Matrix, row: Int, column: Int) -> Int {
  let Matrix(data:, rows: _, columns:) = matrix
  let assert <<n:size(32)-signed>> =
    part(data, { row * columns * 4 } + { column * 4 }, 4)

  n
}

@external(erlang, "binary", "part")
fn part(bit_array: BitArray, position: Int, length: Int) -> BitArray

pub fn solve_system(
  matrix: Matrix,
  variables: Dict(Int, Int),
) -> Result(Dict(Int, Int), Nil) {
  solve_system_loop(matrix, variables, matrix.rows - 1)
}

fn solve_system_loop(
  matrix: Matrix,
  variables: Dict(Int, Int),
  row: Int,
) -> Result(Dict(Int, Int), Nil) {
  use <- bool.guard(when: row < 0, return: Ok(variables))
  let row_values = unsafe_row(matrix, row)
  case first_non_zero_index_and_value(row_values) {
    Error(_) -> solve_system_loop(matrix, variables, row - 1)
    Ok(#(i, k_i)) -> {
      let prefix_bytes = { i + 1 } * 4
      let assert <<_:size(prefix_bytes)-bytes, rest:bits>> = row_values
      use k_i_x_i <- result.try(value_loop(rest, i + 1, variables, 0))
      case k_i_x_i % k_i {
        0 ->
          case k_i_x_i / k_i {
            x_i if x_i < 0 -> Error(Nil)
            x_i ->
              dict.insert(variables, i, x_i)
              |> solve_system_loop(matrix, _, row - 1)
          }

        _ -> Error(Nil)
      }
    }
  }
}

fn value_loop(row, i: Int, variables: Dict(Int, Int), sum) {
  case row {
    <<result:size(32)-signed>> -> Ok(result - sum)
    <<0:size(32)-signed, row:bits>> -> value_loop(row, i + 1, variables, sum)
    <<n:size(32)-signed, row:bits>> ->
      case dict.get(variables, i) {
        Error(_) -> Error(Nil)
        Ok(x) -> value_loop(row, i + 1, variables, sum + n * x)
      }

    _ -> panic as "invalid row"
  }
}

fn first_non_zero_index_and_value(row: BitArray) -> Result(#(Int, Int), Nil) {
  first_non_zero_index_and_value_loop(row, 0)
}

fn first_non_zero_index_and_value_loop(
  row: BitArray,
  i: Int,
) -> Result(#(Int, Int), Nil) {
  case row {
    <<>> | <<_:size(32)>> -> Error(Nil)
    <<0:size(32)-signed, row:bytes>> ->
      first_non_zero_index_and_value_loop(row, i + 1)
    <<n:size(32)-signed, _:bytes>> -> Ok(#(i, n))
    _ -> panic as "invalid row"
  }
}

/// Turns a list of ints into a matrix.
///
/// > Beware, if one of the lists has a different length from the others
/// > this will result in some faulty matrix!!
///
pub fn new(rows: List(List(Int))) -> Matrix {
  case rows {
    [] -> Matrix(data: <<>>, rows: 0, columns: 0)
    [first, ..rest] -> matrix_loop(first, rest, <<>>, 1, 0)
  }
}

fn matrix_loop(
  row: List(Int),
  rest: List(List(Int)),
  data: BitArray,
  rows: Int,
  columns: Int,
) -> Matrix {
  case row {
    [n, ..row] ->
      matrix_loop(row, rest, <<data:bits, n:size(32)>>, rows, columns + 1)
    [] ->
      case rest {
        [row, ..rest] -> matrix_loop(row, rest, data, rows + 1, 0)
        [] -> Matrix(data:, rows:, columns:)
      }
  }
}

/// Turns a matrix into a list of rows.
///
pub fn to_list(matrix: Matrix) -> List(List(Int)) {
  to_list_loop(matrix.data, [])
  |> list.sized_chunk(matrix.columns)
}

fn to_list_loop(data: BitArray, acc: List(Int)) -> List(Int) {
  case data {
    <<>> -> list.reverse(acc)
    <<n:size(32)-signed, data:bytes>> -> to_list_loop(data, [n, ..acc])
    _ -> panic as "invalid matrix"
  }
}

fn row_to_list(data: BitArray) -> List(Int) {
  row_to_list_loop(data, [])
}

fn row_to_list_loop(data: BitArray, acc: List(Int)) -> List(Int) {
  case data {
    <<>> -> list.reverse(acc)
    <<n:size(32)-signed, data:bytes>> -> row_to_list_loop(data, [n, ..acc])
    _ -> panic as "invalid row"
  }
}
