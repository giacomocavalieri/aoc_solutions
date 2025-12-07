import advent
import gleam/dict
import gleam/list
import gleam/option
import gleam/string
import graph.{type Graph, Node}
import utils/graph_extra
import utils/string_extra

pub fn day() {
  advent.Day(
    day: 06,
    parse:,
    part_a:,
    expected_a: option.Some(150_150),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(352),
    wrong_answers_b: [],
  )
}

fn part_a(orbits) {
  let com = string_extra.hash("COM")
  use count, node <- list.fold(graph.nodes(orbits), 0)

  let assert Ok(path) = graph_extra.path_with_least_steps(orbits, com, node.id)
  count + list.length(path) - 1
}

fn part_b(orbits: Graph(_, n, l)) -> Int {
  let assert Ok(path) =
    graph_extra.path_with_least_steps(
      orbits,
      orbited(in: orbits, by: "YOU"),
      orbited(in: orbits, by: "SAN"),
    )

  list.length(path) - 1
}

fn orbited(in graph: Graph(direction, value, label), by node: String) -> Int {
  let assert Ok(context) = graph.get_context(graph, string_extra.hash(node))
  let assert [orbited] = dict.keys(context.outgoing)
  orbited
}

fn parse(input: String) {
  let lines = string.trim_end(input) |> string.split(on: "\n")
  use graph, line <- list.fold(lines, graph.new())
  let assert [one, other] = string.split(line, on: ")")

  let one_id = string_extra.hash(one)
  let other_id = string_extra.hash(other)

  graph
  |> graph_extra.insert_node_if_missing(Node(one_id, one))
  |> graph_extra.insert_node_if_missing(Node(other_id, other))
  |> graph.insert_undirected_edge(Nil, one_id, other_id)
}
