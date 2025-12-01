import gleam/list
import utils/int_extra

pub fn count_digits_test() {
  assert 1 == int_extra.count_digits(0)
  assert 1 == int_extra.count_digits(1)
  assert 1 == int_extra.count_digits(2)
  assert 2 == int_extra.count_digits(10)
  assert 2 == int_extra.count_digits(11)
  assert 2 == int_extra.count_digits(19)
  assert 2 == int_extra.count_digits(99)
  assert 3 == int_extra.count_digits(100)
  assert 3 == int_extra.count_digits(-100)
}

pub fn numbers_test() {
  assert int_extra.numbers(sized: 0) == []
  assert int_extra.numbers(sized: 1) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  assert int_extra.numbers(sized: 2) == list.range(10, 99)
}

pub fn repeat_test() {
  assert int_extra.repeat(1, times: 2) == 11
  assert int_extra.repeat(12, times: 3) == 121_212
  assert int_extra.repeat(123, times: 1) == 123
}
