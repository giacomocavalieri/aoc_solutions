import gleam/int
import gleam/order.{Eq, Gt, Lt}
import utils/extra/list_extra

pub fn compare_test() {
  assert Lt == list_extra.compare([], [1, 2], int.compare)
  assert Gt == list_extra.compare([1, 2], [10], int.compare)
  assert Eq == list_extra.compare([], [], int.compare)
  assert Gt == list_extra.compare([1, 2, 3], [1, 1, 10], int.compare)
}

pub fn middle_test() {
  assert Error(Nil) == list_extra.middle([])
  assert Ok(1) == list_extra.middle([1])
  assert Ok(2) == list_extra.middle([1, 2])
  assert Ok(2) == list_extra.middle([1, 2, 3])
  assert Ok(3) == list_extra.middle([1, 2, 3, 4])
  assert Ok(3) == list_extra.middle([1, 2, 3, 4, 5])
  assert Ok(4) == list_extra.middle([1, 2, 3, 4, 5, 6])
}
