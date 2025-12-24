import advent
import gleam/bool
import gleam/dict
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set.{type Set}
import gleam/string
import utils/extra/int_extra
import utils/extra/list_extra
import utils/structures/matrix
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

fn part_b(machines: List(Machine)) -> Int {
  let me = process.new_subject()
  list.each(machines, fn(machine) {
    process.spawn(fn() { process.send(me, solve(machine)) })
  })

  part_b_loop(me, list.length(machines), 0)
}

fn part_b_loop(me: Subject(Int), missing: Int, acc: Int) -> Int {
  case missing {
    0 -> acc
    _ -> {
      let steps = process.receive_forever(me)
      part_b_loop(me, missing - 1, acc + steps)
    }
  }
}

fn solve(machine: Machine) -> Int {
  let matrix =
    machine_to_equations(machine)
    |> matrix.new
    |> matrix.gauss

  let total_buttons = list.length(machine.buttons)
  let free_buttons =
    matrix.diagonal(matrix)
    |> list.take(total_buttons)
    |> list_extra.pad_end(up_to: total_buttons, with: 0)
    |> list.index_fold([], fn(acc, diagonal_value, index) {
      use <- bool.guard(when: diagonal_value != 0, return: acc)
      let assert Ok(button) = list_extra.at(machine.buttons, index)
      let assert Ok(upper_bound) =
        list.filter_map(button, list_extra.at(machine.joltage_requirements, _))
        |> list.reduce(int.min)

      [#(index, upper_bound), ..acc]
    })
    |> list.reverse

  let assert Ok(steps) =
    list.map(free_buttons, fn(pair) {
      let #(index, upper_bound) = pair
      list.range(0, upper_bound)
      |> list.map(fn(value) { #(index, value) })
    })
    |> list_extra.cross_product
    |> list.map(dict.from_list)
    |> list.filter_map(matrix.solve_system(matrix, _))
    |> list.map(fn(presses) { dict.values(presses) |> int.sum })
    |> list.reduce(int.min)

  steps
}

fn machine_to_equations(machine: Machine) -> List(List(Int)) {
  let Machine(indicator_lights: _, buttons:, joltage_requirements:) = machine
  list.index_map(joltage_requirements, fn(joltage, i) {
    list.map(buttons, fn(button) {
      case list.contains(button, i) {
        True -> 1
        False -> 0
      }
    })
    |> list.append([joltage])
  })
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
