import advent
import aoc_solutions/year_2024/day_05

pub fn main() {
  advent.year(2024)
  |> advent.timed
  |> advent.add_day(day_05.day())
  |> advent.run
}
