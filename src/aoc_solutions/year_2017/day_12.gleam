import advent
import gleam/list
import gleam/option
import gleam/set
import gleam/string
import graph.{type Graph, type Undirected, Node}
import utils/extra/graph_extra
import utils/extra/int_extra

pub fn day() {
  advent.Day(
    day: 12,
    parse:,
    part_a:,
    expected_a: option.Some(306),
    wrong_answers_a: [305],
    part_b:,
    expected_b: option.Some(200),
    wrong_answers_b: [],
  )
}

fn part_a(network: Graph(Undirected, Nil, Nil)) -> Int {
  let reachable_from_0 =
    network
    |> graph_extra.reachable(in: _, from: 0)
    |> set.size

  reachable_from_0 + 1
}

fn part_b(network: Graph(Undirected, Nil, Nil)) -> Int {
  graph_extra.connected_components(network)
  |> list.length
}

fn parse(string: String) -> Graph(Undirected, Nil, Nil) {
  let lines = string.split(string.trim_end(string), on: "\n")
  use graph, line <- list.fold(over: lines, from: graph.new())
  let assert [program, programs] = string.split(line, on: " <-> ") as "no"

  let program = int_extra.expect(program)
  let graph = graph_extra.insert_node_if_missing(graph, Node(program, Nil))

  string.split(programs, on: ", ")
  |> list.map(int_extra.expect)
  |> list.fold(graph, fn(graph, reached) {
    graph.insert_undirected_edge(graph, Nil, between: program, and: reached)
  })
}
