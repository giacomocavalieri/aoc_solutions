import advent
import gleam/list
import gleam/option
import gleam/set.{type Set}
import utils/point.{type Point, Point}

pub fn day() {
  advent.Day(
    day: 04,
    parse:,
    part_a:,
    expected_a: option.Some(1569),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(9280),
    wrong_answers_b: [],
  )
}

fn part_a(rolls: Set(Point)) -> Int {
  use count, roll <- set.fold(over: rolls, from: 0)
  case is_reachable(roll, rolls) {
    True -> count + 1
    False -> count
  }
}

fn part_b(rolls: Set(Point)) -> Int {
  let leftover = remove_loop(rolls, set.to_list(rolls))
  set.size(rolls) - set.size(leftover)
}

fn is_reachable(roll: Point, rolls: Set(Point)) -> Bool {
  set.contains(rolls, roll)
  && is_reachable_loop(rolls, point.neighbours(roll), 0)
}

fn is_reachable_loop(
  rolls: Set(Point),
  neighbours_to_check: List(Point),
  neighbours: Int,
) -> Bool {
  case neighbours_to_check {
    [] -> neighbours < 4
    // If we've found 4+ neighbours then there's no need to keep checking and
    // we can just return False: we know the roll can't be reached!
    [_, ..] if neighbours >= 4 -> False
    [neighbour, ..rest] ->
      case set.contains(rolls, neighbour) {
        True -> is_reachable_loop(rolls, rest, neighbours + 1)
        False -> is_reachable_loop(rolls, rest, neighbours)
      }
  }
}

fn remove_loop(rolls: Set(Point), to_check: List(Point)) {
  case list.filter(to_check, keeping: is_reachable(_, rolls)) {
    [] -> rolls
    [_, ..] as reachable_rolls -> {
      let to_check =
        reachable_rolls
        |> list.flat_map(point.neighbours)
        |> list.filter(keeping: set.contains(rolls, _))
        |> list.unique

      remove_loop(set.drop(rolls, reachable_rolls), to_check)
    }
  }
}

fn parse(input: String) -> Set(Point) {
  parse_loop(input, 0, 0, set.new())
}

fn parse_loop(input: String, x: Int, y: Int, points: Set(Point)) -> Set(Point) {
  case input {
    "" -> points
    "\n" <> rest -> parse_loop(rest, 0, y + 1, points)
    "@" <> rest -> parse_loop(rest, x + 1, y, set.insert(points, Point(x:, y:)))
    "." <> rest -> parse_loop(rest, x + 1, y, points)
    _ -> panic as "unexpected AoC input"
  }
}
