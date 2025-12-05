import advent
import aoc_solutions/year_2025/day_01
import aoc_solutions/year_2025/day_02
import aoc_solutions/year_2025/day_03
import aoc_solutions/year_2025/day_04
import aoc_solutions/year_2025/day_05

pub fn main() -> Nil {
  advent.year(2025)
  |> advent.timed
  |> advent.add_day(day_01.day())
  |> advent.add_day(day_02.day())
  |> advent.add_day(day_03.day())
  |> advent.add_day(day_04.day())
  |> advent.add_day(day_05.day())
  |> advent.add_padding_days(up_to: 12)
  |> advent.run
}
