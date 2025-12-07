import advent
import aoc_solutions/year_2019/day_06
import utils/advent_util

pub fn main() {
  advent.year(2019)
  |> advent.timed
  |> advent_util.download_if_token
  |> advent.add_day(day_06.day())
  |> advent.run
}
