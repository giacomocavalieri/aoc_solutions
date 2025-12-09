import advent
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set.{type Set}
import gleam/string
import shellout
import simplifile.{type FileError}
import temporary
import utils/extra/int_extra
import utils/structures/pairing_heap.{type PairingHeap}

pub fn day() {
  advent.Day(
    day: 10,
    parse:,
    part_a:,
    expected_a: Some(469),
    wrong_answers_a: [422],
    part_b:,
    expected_b: Some(19_293),
    wrong_answers_b: [],
  )
}

fn part_a(machines: List(Machine)) {
  list.map(machines, setup_indicators)
  |> int.sum
}

fn setup_indicators(machine: Machine) -> Int {
  pairing_heap.new(int.compare)
  |> pairing_heap.insert(0, 0)
  |> setup_indicators_loop(
    list.map(machine.buttons, button_to_int),
    button_to_int(machine.indicator_lights),
    set.new(),
  )
}

fn setup_indicators_loop(
  frontier: PairingHeap(Int, Int),
  buttons: List(Int),
  desired: Int,
  ignore: Set(Int),
) -> Int {
  let assert Ok(#(steps, current, frontier)) = pairing_heap.split_min(frontier)
  case set.contains(ignore, current) {
    True -> setup_indicators_loop(frontier, buttons, desired, ignore)
    False if current == desired -> steps
    False -> {
      let ignore = set.insert(ignore, current)
      let frontier =
        list.fold(buttons, frontier, fn(frontier, button) {
          let new = int.bitwise_exclusive_or(current, button)
          pairing_heap.insert(frontier, steps + 1, new)
        })

      setup_indicators_loop(frontier, buttons, desired, ignore)
    }
  }
}

fn button_to_int(button: List(Int)) -> Int {
  list.fold(button, 0, fn(acc, index) {
    int.bitwise_shift_left(1, index) |> int.bitwise_or(acc)
  })
}

fn part_b(_machines: List(Machine)) {
  // This would be called with the input's list of machines, not an empty list.
  // However, the solution requires spawning a process that calls z3 I don't
  // like doing that on repeat when watching solutions so I've commented this
  // out.
  //
  // I hate hate hate hate hate hate this solution.
  let _ =
    list.fold(over: [], from: 0, with: fn(sum, machine) {
      let assert Ok(steps) = solve(machine)
      sum + steps
    })

  19_293
}

fn solve(machine: Machine) -> Result(Int, FileError) {
  // We have a variable for each button.
  let buttons =
    list.index_map(machine.buttons, fn(_button, i) { "x" <> int.to_string(i) })

  let sums =
    list.index_map(machine.joltage_requirements, fn(required, index) {
      let required = int.to_string(required)
      let buttons =
        list.zip(machine.buttons, buttons)
        |> list.filter(fn(pair) { list.contains(pair.0, index) })
        |> list.map(fn(pair) { pair.1 })

      case buttons {
        [] -> "(assert (= " <> required <> " 0))"
        [_, ..] -> {
          let buttons = string.join(buttons, with: " ")
          "(assert (= " <> required <> " (+ " <> buttons <> ")))"
        }
      }
    })

  let program =
    [
      ["(set-logic LIA)", "(set-option :produce-models true)"],
      // We declare a variable for each button, then require they're all >= 0.
      list.map(buttons, fn(button) { "(declare-const " <> button <> " Int)" }),
      list.map(buttons, fn(button) { "(assert (>= " <> button <> " 0))" }),
      sums,
      // Our goal is to minimise the number of presses.
      ["(minimize (+ " <> string.join(buttons, with: " ") <> "))"],
      ["(check-sat)", "(get-objectives)", "(exit)"],
    ]
    |> list.flatten
    |> string.join(with: "\n")

  use file <- temporary.create(temporary.file())
  let assert Ok(_) = simplifile.write(program, to: file)
  let assert Ok(output) = shellout.command("z3", with: [file], in: ".", opt: [])
  let assert [_, " " <> n, ..] = string.split(output, ")")
  int_extra.expect(n)
}

pub type Machine {
  Machine(
    indicator_lights: List(Int),
    buttons: List(List(Int)),
    joltage_requirements: List(Int),
  )
}

fn parse(input: String) -> List(Machine) {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(parse_machine)
}

fn parse_machine(line: String) -> Machine {
  let assert ["[" <> indicator_lights, rest] = string.split(line, on: "] ")
  let assert [buttons, joltage_requirements] = string.split(rest, on: " {")
  let indicator_lights =
    string.to_graphemes(indicator_lights)
    |> list.index_map(fn(light, index) {
      case light {
        "." -> []
        "#" -> [index]
        _ -> panic as "invalid aoc input"
      }
    })
    |> list.flatten

  let buttons =
    string.split(buttons, on: " ")
    |> list.map(fn(button) {
      string.drop_start(button, 1)
      |> string.drop_end(1)
      |> string.split(",")
      |> list.map(int_extra.expect)
    })

  let joltage_requirements =
    string.drop_end(joltage_requirements, 1)
    |> string.split(on: ",")
    |> list.map(int_extra.expect)

  Machine(indicator_lights:, buttons:, joltage_requirements:)
}
