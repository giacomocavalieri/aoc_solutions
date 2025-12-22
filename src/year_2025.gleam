import advent
import aoc_solutions/year_2025/day_01
import aoc_solutions/year_2025/day_02
import aoc_solutions/year_2025/day_03
import aoc_solutions/year_2025/day_04
import aoc_solutions/year_2025/day_05
import aoc_solutions/year_2025/day_06
import aoc_solutions/year_2025/day_07
import aoc_solutions/year_2025/day_08
import aoc_solutions/year_2025/day_09
import aoc_solutions/year_2025/day_10
import aoc_solutions/year_2025/day_11
import aoc_solutions/year_2025/day_12
import utils/advent_util

pub fn main() -> Nil {
  advent.year(2025)
  |> advent_util.download_if_token
  |> advent.timed
  |> advent.with_timeout(seconds: 15)
  |> advent.add_day(day_01.day())
  |> advent.add_day(day_02.day())
  |> advent.add_day(day_03.day())
  |> advent.add_day(day_04.day())
  |> advent.add_day(day_05.day())
  |> advent.add_day(day_06.day())
  |> advent.add_day(day_07.day())
  |> advent.add_day(day_08.day())
  |> advent.add_day(day_09.day())
  |> advent.add_day(day_10.day())
  |> advent.add_day(day_11.day())
  |> advent.add_day(day_12.day())
  |> advent.add_padding_days(up_to: 12)
  |> advent.run
}
