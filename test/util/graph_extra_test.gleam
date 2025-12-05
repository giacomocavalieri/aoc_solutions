import gleam/int
import gleam/list
import gleam/order
import graph.{Node}
import utils/graph_extra
import utils/list_extra

pub fn connected_component_test() {
  assert [[1, 2, 3], [4, 5]]
    == graph.new()
    |> insert_nodes(1, 5)
    |> graph.insert_directed_edge(Nil, 1, 2)
    |> graph.insert_directed_edge(Nil, 2, 3)
    |> graph.insert_directed_edge(Nil, 3, 2)
    |> graph.insert_directed_edge(Nil, 4, 5)
    |> graph.insert_directed_edge(Nil, 5, 4)
    |> graph_extra.connected_components
    |> sort_ids
}

pub fn path_with_least_steps_test() {
  // 1 ----> 2 ----> 3 <----> 4 ----> 5
  //         ^______/ \        ^_____/|
  //                   \---> 6 <-----/
  //
  let graph =
    graph.new()
    |> insert_nodes(1, 6)
    |> graph.insert_directed_edge(Nil, 1, 2)
    |> graph.insert_directed_edge(Nil, 2, 3)
    |> graph.insert_directed_edge(Nil, 3, 2)
    |> graph.insert_directed_edge(Nil, 3, 4)
    |> graph.insert_directed_edge(Nil, 4, 3)
    |> graph.insert_directed_edge(Nil, 3, 6)
    |> graph.insert_directed_edge(Nil, 4, 5)
    |> graph.insert_directed_edge(Nil, 5, 4)
    |> graph.insert_directed_edge(Nil, 5, 6)

  assert Error(Nil) == graph_extra.path_with_least_steps(graph, from: 3, to: 1)
  assert Ok([3, 6]) == graph_extra.path_with_least_steps(graph, from: 3, to: 6)
  assert Ok([1, 2, 3, 6])
    == graph_extra.path_with_least_steps(graph, from: 1, to: 6)
  assert Ok([4, 3, 2])
    == graph_extra.path_with_least_steps(graph, from: 4, to: 2)
}

pub fn minimum_path_test() {
  let graph =
    graph.new()
    |> insert_nodes(1, 6)
    |> graph.insert_directed_edge(1, 2, labelled: 7)
    |> graph.insert_directed_edge(1, 3, labelled: 12)
    |> graph.insert_directed_edge(2, 3, labelled: 2)
    |> graph.insert_directed_edge(2, 4, labelled: 9)
    |> graph.insert_directed_edge(3, 5, labelled: 10)
    |> graph.insert_directed_edge(4, 6, labelled: 1)
    |> graph.insert_directed_edge(5, 4, labelled: 4)
    |> graph.insert_directed_edge(5, 6, labelled: 5)

  assert Ok(#([1, 2], 7))
    == graph_extra.minimum_path(graph, from: 1, to: 2, with: fn(cost) { cost })
  assert Ok(#([1, 2, 3], 9))
    == graph_extra.minimum_path(graph, from: 1, to: 3, with: fn(cost) { cost })
  assert Ok(#([1, 2, 4], 16))
    == graph_extra.minimum_path(graph, from: 1, to: 4, with: fn(cost) { cost })
  assert Ok(#([1, 2, 3, 5], 19))
    == graph_extra.minimum_path(graph, from: 1, to: 5, with: fn(cost) { cost })
  assert Ok(#([1, 2, 4, 6], 17))
    == graph_extra.minimum_path(graph, from: 1, to: 6, with: fn(cost) { cost })
  assert Ok(#([2, 3, 5], 12))
    == graph_extra.minimum_path(graph, from: 2, to: 5, with: fn(cost) { cost })
}

pub fn topological_sort_test() {
  assert Ok([6, 0, 1, 5, 4, 2, 3])
    == graph.new()
    |> insert_nodes(0, 6)
    |> graph.insert_directed_edge(0, 1, labelled: Nil)
    |> graph.insert_directed_edge(0, 2, labelled: Nil)
    |> graph.insert_directed_edge(1, 2, labelled: Nil)
    |> graph.insert_directed_edge(1, 5, labelled: Nil)
    |> graph.insert_directed_edge(2, 3, labelled: Nil)
    |> graph.insert_directed_edge(5, 3, labelled: Nil)
    |> graph.insert_directed_edge(5, 4, labelled: Nil)
    |> graph.insert_directed_edge(6, 1, labelled: Nil)
    |> graph.insert_directed_edge(6, 5, labelled: Nil)
    |> graph_extra.topological_sort
}

// HELPERS ---------------------------------------------------------------------

fn insert_nodes(
  graph: graph.Graph(direction, Nil, label),
  from: Int,
  to: Int,
) -> graph.Graph(direction, Nil, label) {
  list.range(from, to)
  |> list.map(Node(_, Nil))
  |> list.fold(from: graph, with: graph.insert_node)
}

fn sort_ids(ids: List(List(Int))) -> List(List(Int)) {
  list.map(ids, fn(list) { list.sort(list, int.compare) })
  |> list.sort(fn(one, other) {
    list_extra.compare(one, other, int.compare)
    |> order.negate
  })
}
