import advent
import aoc_solutions/year_2024/day_05
import utils/advent_util

pub fn main() {
  advent.year(2024)
  |> advent.timed
  |> advent_util.download_if_token
  |> advent.add_day(day_05.day())
  |> advent.run
}
