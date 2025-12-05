import gleam/dict
import gleam/int
import gleam/list
import graph.{type Directed, type Graph, type Node, Context}
import utils/pairing_heap.{type PairingHeap}

/// Adds a node if not already present.
///
pub fn insert_node_if_missing(
  graph: Graph(direction, value, label),
  node: Node(value),
) -> Graph(direction, value, label) {
  case graph.has_node(graph, node.id) {
    True -> graph
    False -> graph.insert_node(graph, node)
  }
}

/// Adds an edge if one between the two nodes is not already present.
///
pub fn insert_directed_edge_if_missing(
  graph: Graph(Directed, a, label),
  labelled label: label,
  from one: Int,
  to other: Int,
) -> Graph(Directed, a, label) {
  case graph.has_edge(graph, from: one, to: other) {
    True -> graph
    False ->
      graph.insert_directed_edge(graph, labelled: label, from: one, to: other)
  }
}

/// Returns the path that takes the least amount of steps to go from a source to
/// a destination in the given grap - if any!
///
pub fn path_with_least_steps(
  graph: Graph(Directed, a, label),
  from source: Int,
  to destination: Int,
) -> Result(List(Int), Nil) {
  case minimum_path(graph, from: source, to: destination, with: fn(_) { 1 }) {
    Error(_) -> Error(Nil)
    Ok(#(path, _)) -> Ok(path)
  }
}

/// Returns the minimum path (and associated cost) going from one node to the,
/// other using the Dijkstra algorithm.
///
pub fn minimum_path(
  in graph,
  from source,
  to destination,
  with cost: fn(label) -> Int,
) -> Result(#(List(Int), Int), Nil) {
  let paths =
    pairing_heap.new(int.compare)
    |> pairing_heap.insert(0, [source])
  minimum_path_loop(graph, destination, cost, paths)
}

fn minimum_path_loop(
  graph: Graph(direction, value, label),
  destination: Int,
  cost: fn(label) -> Int,
  paths: PairingHeap(Int, List(Int)),
) -> Result(#(List(Int), Int), Nil) {
  case pairing_heap.split_min(paths) {
    // There's no remaining paths to explore, and we haven't found anything!
    Error(_) | Ok(#(_, [], _)) -> Error(Nil)

    // We've reached the path with the minimum cost associated that arrives at
    // the destination, we can just return it!
    Ok(#(path_cost, [frontier, ..] as path, _)) if frontier == destination ->
      Ok(#(list.reverse(path), path_cost))

    // Otherwise we keep exploring from the unexplored path with the minimum
    // cost associated. Its first node is the unexplored frontier that we need
    // to keep expanding until we find the destination (or a dead end).
    Ok(#(path_cost, [frontier, ..] as path, paths)) ->
      case graph.match(graph, frontier) {
        // This path is a dead end, there's nothing left here. We still explore,
        // the reamining paths in hope of finding the destination.
        Error(_) -> minimum_path_loop(graph, destination, cost, paths)
        // Otherwise for each of the outgoing nodes we increase the path (and
        // associated cost), add them back to the priority queue to explore and
        // keep exploring
        Ok(#(frontier, unexplored)) ->
          dict.fold(frontier.outgoing, paths, fn(paths, next, label) {
            let new_cost = path_cost + cost(label)
            pairing_heap.insert(paths, new_cost, [next, ..path])
          })
          |> minimum_path_loop(unexplored, destination, cost, _)
      }
  }
}

/// Returns a list with the ids of the nodes making up the connected components
/// of the graph.
///
pub fn connected_components(
  graph: Graph(direction, value, label),
) -> List(List(Int)) {
  connected_components_loop(graph, [])
}

fn connected_components_loop(
  graph: Graph(direction, value, label),
  acc: List(List(Int)),
) -> List(List(Int)) {
  case graph.match_any(graph) {
    Error(_) -> acc
    Ok(#(context, _)) -> {
      let #(component, rest) =
        connected_component(from: context.node, in: graph)
      connected_components_loop(rest, [component, ..acc])
    }
  }
}

fn connected_component(
  from node: Node(value),
  in graph: Graph(direction, value, label),
) -> #(List(Int), Graph(direction, value, label)) {
  let reachable_nodes = connected_nodes(from: node.id, in: graph)
  let rest =
    list.fold(over: reachable_nodes, from: graph, with: graph.remove_node)

  #(reachable_nodes, rest)
}

fn connected_nodes(from node: Int, in graph: Graph(_, _, _)) -> List(Int) {
  case graph.match(graph, node) {
    Error(_) -> []
    Ok(#(first, rest)) ->
      dict.merge(first.outgoing, first.incoming)
      |> dict.fold(from: [], with: fn(reachables, neighbour, _) {
        [connected_nodes(neighbour, rest), ..reachables]
      })
      |> list.prepend([first.node.id])
      |> list.flatten
  }
}

///
pub fn topological_sort(
  graph: Graph(Directed, value, label),
) -> Result(List(Int), Nil) {
  let leaves =
    list.filter_map(graph.nodes(graph), fn(node) {
      case has_incoming_edges(graph, node.id) {
        True -> Error(Nil)
        False -> Ok(node.id)
      }
    })

  topological_sort_loop(leaves, graph, [])
}

fn topological_sort_loop(
  leaves: List(Int),
  graph: Graph(Directed, value, label),
  sort: List(Int),
) -> Result(List(Int), Nil) {
  case leaves {
    [] ->
      case has_edges(graph) {
        True -> Error(Nil)
        False -> Ok(list.reverse(sort))
      }

    [leaf, ..leaves] ->
      case graph.get_context(graph, leaf) {
        Error(_) -> topological_sort_loop(leaves, graph, sort)
        Ok(Context(outgoing:, ..)) -> {
          let #(graph, leaves) =
            dict.fold(outgoing, #(graph, leaves), fn(acc, next, _) {
              let #(graph, leaves) = acc
              let graph =
                graph.remove_directed_edge(graph, from: leaf, to: next)
              case has_incoming_edges(graph, next) {
                True -> #(graph, leaves)
                False -> #(graph, [next, ..leaves])
              }
            })

          topological_sort_loop(leaves, graph, [leaf, ..sort])
        }
      }
  }
}

fn has_incoming_edges(graph: Graph(direction, value, label), node: Int) -> Bool {
  case graph.get_context(graph, node) {
    Error(_) -> False
    Ok(Context(incoming:, ..)) -> !dict.is_empty(incoming)
  }
}

fn has_edges(graph: Graph(direction, value, label)) -> Bool {
  list.any(graph.nodes(graph), fn(node) {
    case graph.get_context(graph, node.id) {
      Error(_) -> False
      Ok(Context(incoming:, node: _, outgoing:)) ->
        !dict.is_empty(incoming) || !dict.is_empty(outgoing)
    }
  })
}
