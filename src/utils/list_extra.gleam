import gleam/order.{type Order, Eq, Gt, Lt}

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
