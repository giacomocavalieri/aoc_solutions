import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}

/// Adds an element to the end of a list until it has the wanted size.
///
/// ```
/// assert pad_end([1, 2], up_to: 5, with: 0) == [1, 2, 0, 0, 0]
/// assert pad_end([1, 2], up_to: 1, with: 0) == [1, 2]
/// ```
///
pub fn pad_end(list: List(a), up_to size: Int, with elem: a) -> List(a) {
  let missing = size - list.length(list)
  list.append(list, list.repeat(elem, missing))
}

/// Returns the itme at the given index in the list.
/// This runs in linear time!
///
pub fn at(list: List(a), index: Int) -> Result(a, Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case index <= 0 {
        True -> Ok(first)
        False -> at(rest, index - 1)
      }
  }
}

/// Returns the cross product of all the given lists. That is all the possible
/// combinations of elements, one from each list.
///
/// ```gleam
/// assert [[1, 2], [1, 3], [4, 2], [4, 3]]
///   == cross_product([[1, 4], [2, 3]])
/// ```
///
pub fn cross_product(lists: List(List(a))) -> List(List(a)) {
  case lists {
    [] -> [[]]
    [list, ..rest] -> {
      let products = cross_product(rest)
      list.flat_map(list, fn(value) {
        list.map(products, fn(product) { [value, ..product] })
      })
    }
  }
}

/// Compares two lists. Longer lists are always `Gt`, while shorter lists are
/// always `Lt`. If two lists have the same length, then they're compared
/// item-wise; the bigger one is the one with a bigger item appearing first.
///
/// ```gleam
/// assert Lt == compare([], [1, 2], int.compare)
/// assert Gt == compare([1, 2], [10], int.compare)
/// assert Eq == compare([], [], int.compare)
/// assert Gt == compare([1, 2, 3], [1, 1, 10], int.compare)
/// ```
///
pub fn compare(
  one: List(a),
  other: List(a),
  compare: fn(a, a) -> Order,
) -> Order {
  compare_loop(one, other, compare, Eq)
}

fn compare_loop(one, other, compare, outcome) {
  case one, other {
    [], [] -> outcome
    [_, ..], [] -> Gt
    [], [_, ..] -> Lt
    [first_one, ..one], [first_other, ..other] ->
      case outcome {
        Gt | Lt -> compare_loop(one, other, compare, outcome)
        Eq ->
          case compare(first_one, first_other) {
            Eq -> compare_loop(one, other, compare, Eq)
            Gt -> compare_loop(one, other, compare, Gt)
            Lt -> compare_loop(one, other, compare, Lt)
          }
      }
  }
}

/// Returns the element at the middle of the list.
///
/// ```gleam
/// assert Ok(2) == middle([4, 2, 5])
/// assert Ok(3) == middle([1, 6, 3, 4])
/// ```
///
pub fn middle(list: List(a)) -> Result(a, Nil) {
  case list {
    [middle] | [_, middle] -> Ok(middle)
    _ -> middle_loop(list, list)
  }
}

fn middle_loop(slow: List(a), fast: List(a)) {
  case slow, fast {
    [], [] -> Error(Nil)
    [middle, ..], [] -> Ok(middle)

    [], [_] -> Error(Nil)
    [middle, ..], [_] -> Ok(middle)

    [], [_, _, ..] -> panic
    [_, ..slow], [_, _, ..fast] -> middle_loop(slow, fast)
  }
}

/// Returns the maximum item in the list, according to the comparison function.
///
pub fn max(list: List(a), by compare: fn(a, a) -> Order) -> Result(a, Nil) {
  list.reduce(list, fn(one, other) {
    case compare(one, other) {
      Eq | Gt -> one
      Lt -> other
    }
  })
}
