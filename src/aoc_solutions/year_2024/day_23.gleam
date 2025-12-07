import advent
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string
import graph.{type Graph, type Undirected}
import utils/graph_extra
import utils/string_extra

pub fn day() {
  advent.Day(
    day: 23,
    parse:,
    part_a:,
    expected_a: option.Some(1173),
    wrong_answers_a: [5598],
    part_b:,
    expected_b: option.Some("cm,de,ez,gv,hg,iy,or,pw,qu,rs,sn,uc,wq"),
    wrong_answers_b: ["cg,cn,lj,mn,na,pv,xv,xw,yi,yy,zh,zx"],
  )
}

fn part_a(network: Graph(Undirected, String, Nil)) -> Int {
  groups_of_three(in: network)
  |> set.size
}

fn groups_of_three(in network: Graph(Undirected, String, Nil)) -> Set(List(Int)) {
  use groups, node <- list.fold(graph.nodes(network), set.new())
  let assert Ok(context) = graph.get_context(network, node.id)

  case node.value {
    "t" <> _ -> {
      let groups_of_two_neighbours =
        context.outgoing
        |> dict.keys
        |> list.combination_pairs

      use groups, #(one, other) <- list.fold(groups_of_two_neighbours, groups)
      case graph.has_edge(network, one, other) {
        False -> groups
        True ->
          list.sort([node.id, one, other], int.compare)
          |> set.insert(groups, _)
      }
    }
    _ -> groups
  }
}

fn part_b(network: Graph(Undirected, String, Nil)) -> String {
  let assert [max_clique, ..] =
    graph_extra.maximal_cliques(network)
    |> list.sort(fn(one, other) { int.compare(set.size(other), set.size(one)) })

  set.to_list(max_clique)
  |> list.map(fn(id) {
    let assert Ok(matched) = graph.get_context(network, id)
    matched.node.value
  })
  |> list.sort(string.compare)
  |> string.join(with: ",")
}

fn parse(input: String) -> Graph(Undirected, String, Nil) {
  let lines = string.trim_end(input) |> string.split(on: "\n")
  use graph, line <- list.fold(lines, from: graph.new())
  let assert [one, other] = string.split(line, on: "-")
  let id_one = string_extra.hash(one)
  let id_other = string_extra.hash(other)

  graph_extra.insert_node_if_missing(graph, graph.Node(id_one, one))
  |> graph_extra.insert_node_if_missing(graph.Node(id_other, other))
  |> graph.insert_undirected_edge(Nil, between: id_one, and: id_other)
}
