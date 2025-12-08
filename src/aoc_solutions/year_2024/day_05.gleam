import advent
import gleam/list
import gleam/option
import gleam/string
import graph.{Node}
import utils/extra/graph_extra
import utils/extra/int_extra
import utils/extra/list_extra

pub fn day() {
  advent.Day(
    day: 05,
    parse:,
    part_a:,
    expected_a: option.Some(5452),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(4598),
    wrong_answers_b: [],
  )
}

fn part_a(input: #(List(#(Int, Int)), List(List(Int)))) -> Int {
  let #(rules, updates) = input

  use sum, update <- list.fold(over: updates, from: 0)
  case sorted(update, according_to: rules) == update {
    False -> sum
    True -> {
      let assert Ok(middle) = list_extra.middle(update)
      sum + middle
    }
  }
}

fn sorted(update: List(Int), according_to rules: List(#(Int, Int))) -> List(Int) {
  let assert Ok(sorted) =
    list.fold(rules, graph.new(), fn(rules, rule) {
      let #(from, to) = rule
      case list.contains(update, from) && list.contains(update, to) {
        False -> rules
        True ->
          graph_extra.insert_node_if_missing(rules, Node(from, Nil))
          |> graph_extra.insert_node_if_missing(Node(to, Nil))
          |> graph_extra.insert_directed_edge_if_missing(Nil, from, to)
      }
    })
    |> graph_extra.topological_sort

  sorted
}

fn part_b(input: #(List(#(Int, Int)), List(List(Int)))) -> Int {
  let #(rules, updates) = input
  use sum, update <- list.fold(over: updates, from: 0)
  case sorted(update, according_to: rules) {
    sorted if sorted != update -> {
      let assert Ok(middle) = list_extra.middle(sorted)
      sum + middle
    }
    _ -> sum
  }
}

fn parse(input: String) -> #(List(#(Int, Int)), List(List(Int))) {
  let assert [rules, updates] = string.split(string.trim(input), on: "\n\n")
  #(parse_rules(rules), parse_updates(updates))
}

fn parse_rules(lines: String) -> List(#(Int, Int)) {
  list.map(string.split(lines, on: "\n"), fn(rule) {
    let assert [before, after] = string.split(rule, on: "|")
    #(int_extra.expect(before), int_extra.expect(after))
  })
}

fn parse_updates(lines: String) -> List(List(Int)) {
  string.split(lines, on: "\n")
  |> list.map(fn(line) {
    string.split(line, on: ",")
    |> list.map(int_extra.expect)
  })
}
