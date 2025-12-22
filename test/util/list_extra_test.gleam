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

pub fn cross_product_test() {
  assert list_extra.cross_product([[1, 2], [3, 4]])
    == [[1, 3], [1, 4], [2, 3], [2, 4]]

  assert list_extra.cross_product([[1], [3, 4]]) == [[1, 3], [1, 4]]

  assert list_extra.cross_product([[1, 2, 3], [5, 6], [7, 8]])
    == [
      [1, 5, 7],
      [1, 5, 8],
      [1, 6, 7],
      [1, 6, 8],
      [2, 5, 7],
      [2, 5, 8],
      [2, 6, 7],
      [2, 6, 8],
      [3, 5, 7],
      [3, 5, 8],
      [3, 6, 7],
      [3, 6, 8],
    ]
}
