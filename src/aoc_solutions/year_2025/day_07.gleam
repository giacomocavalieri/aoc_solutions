import advent
import gleam/int
import gleam/list
import gleam/option

pub fn day() {
  advent.Day(
    day: 07,
    parse: fn(string) { string },
    part_a:,
    expected_a: option.Some(1590),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(20_571_740_188_555),
    wrong_answers_b: [],
  )
}

fn part_a(input: String) -> Int {
  start_a(input, [])
}

fn start_a(grid: String, rays: List(Int)) -> Int {
  case grid {
    "." <> rest -> start_a(rest, [0, ..rays])
    "S" <> rest -> start_a(rest, [1, ..rays])
    "\n" <> rest -> loop_a(rest, list.reverse(rays), [], 0)
    _ -> panic as "invalid AoC input"
  }
}

fn loop_a(
  grid: String,
  rays: List(Int),
  new_rays: List(Int),
  splits: Int,
) -> Int {
  case grid, rays {
    "^" <> rest, [0, ..rays] -> loop_a(rest, rays, [0, ..new_rays], splits)
    "^." <> rest, [1, _, ..rays] -> {
      let assert [_, ..new_rays] = new_rays
      loop_a(rest, rays, [1, 0, 1, ..new_rays], splits + 1)
    }
    "." <> rest, [ray, ..rays] -> loop_a(rest, rays, [ray, ..new_rays], splits)
    "\n" <> rest, [] -> loop_a(rest, list.reverse(new_rays), [], splits)
    "", _ -> splits
    _, _ -> panic as "unreachable"
  }
}

fn part_b(input: String) -> Int {
  start_b(input, [])
}

fn start_b(grid: String, rays: List(Int)) -> Int {
  case grid {
    "." <> rest -> start_b(rest, [0, ..rays])
    "S" <> rest -> start_b(rest, [1, ..rays])
    "\n" <> rest -> loop_b(rest, list.reverse(rays), [])
    _ -> panic as "unreachable"
  }
}

fn loop_b(grid: String, rays: List(Int), new_rays: List(Int)) -> Int {
  case grid, rays {
    "^." <> rest, [n, m, ..rays] -> {
      let assert [o, ..new_rays] = new_rays
      loop_b(rest, rays, [n + m, 0, n + o, ..new_rays])
    }
    "." <> rest, [ray, ..rays] -> loop_b(rest, rays, [ray, ..new_rays])
    "\n" <> rest, [] -> loop_b(rest, list.reverse(new_rays), [])
    "", _ -> int.sum(new_rays)
    _, _ -> panic as "unreachable"
  }
}
