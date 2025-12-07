import advent
import aoc_solutions/year_2017/day_12
import utils/advent_util

pub fn main() {
  advent.year(2017)
  |> advent.timed
  |> advent_util.download_if_token
  |> advent.add_day(day_12.day())
  |> advent.run
}
