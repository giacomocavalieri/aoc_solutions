import advent
import aoc_solutions/year_2025/day_01
import aoc_solutions/year_2025/day_02
import aoc_solutions/year_2025/day_03

pub fn main() -> Nil {
  advent.year(2025)
  |> advent.add_day(day_01.day())
  |> advent.add_day(day_02.day())
  |> advent.add_day(day_03.day())
  |> advent.add_padding_days(up_to: 12)
  |> advent.show_timings
  |> advent.run
}
