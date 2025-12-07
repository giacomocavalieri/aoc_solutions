import gleam/dict
import gleam/int
import gleam/list
import gleam/set.{type Set}
import graph.{type Directed, type Graph, type Node, Context}
import utils/gb_set.{type GbSet}
import utils/pairing_heap.{type PairingHeap}

/// Adds a node if not already present.
///
pub fn insert_node_if_missing(
  graph: Graph(d, n, l),
  node: Node(n),
) -> Graph(d, n, l) {
  case graph.has_node(graph, node.id) {
    True -> graph
    False -> graph.insert_node(graph, node)
  }
}

/// Adds an edge if one between the two nodes is not already present.
///
pub fn insert_directed_edge_if_missing(
  graph: Graph(Directed, value, label),
  labelled label: label,
  from one: Int,
  to other: Int,
) -> Graph(Directed, value, label) {
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
  graph: Graph(d, n, l),
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
  in graph: Graph(d, n, l),
  from source: Int,
  to destination: Int,
  with cost: fn(l) -> Int,
) -> Result(#(List(Int), Int), Nil) {
  let paths =
    pairing_heap.new(int.compare)
    |> pairing_heap.insert(0, [source])
  minimum_path_loop(graph, destination, cost, paths)
}

fn minimum_path_loop(
  graph: Graph(d, n, l),
  destination: Int,
  cost: fn(l) -> Int,
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
pub fn connected_components(graph: Graph(d, n, l)) -> List(Set(Int)) {
  connected_components_loop(graph, [])
}

fn connected_components_loop(
  graph: Graph(d, n, l),
  acc: List(Set(Int)),
) -> List(Set(Int)) {
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
  in graph: Graph(d, n, l),
) -> #(Set(Int), Graph(d, n, l)) {
  let reachable_nodes =
    reachable(from: node.id, in: graph)
    |> set.insert(node.id)

  let rest =
    set.fold(over: reachable_nodes, from: graph, with: graph.remove_node)

  #(reachable_nodes, rest)
}

/// Returns a list of all the nodes reachable from the given one in the graph.
///
pub fn reachable(from node: Int, in graph: Graph(d, n, l)) -> Set(Int) {
  case graph.match(graph, node) {
    Error(_) -> set.new()
    Ok(#(node, rest)) ->
      dict.fold(node.outgoing, set.new(), with: fn(reachables, neighbour, _) {
        reachables
        |> set.insert(neighbour)
        |> set.union(reachable(neighbour, rest))
      })
  }
}

/// Returns a possible topological sort of the graph if it doesn't contain
/// any cycle.
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

fn has_incoming_edges(graph: Graph(d, n, l), node: Int) -> Bool {
  case graph.get_context(graph, node) {
    Error(_) -> False
    Ok(Context(incoming:, ..)) -> !dict.is_empty(incoming)
  }
}

fn has_edges(graph: Graph(d, n, l)) -> Bool {
  list.any(graph.nodes(graph), fn(node) {
    case graph.get_context(graph, node.id) {
      Error(_) -> False
      Ok(Context(incoming:, node: _, outgoing:)) ->
        !dict.is_empty(incoming) || !dict.is_empty(outgoing)
    }
  })
}

/// Returns all maximal cliques in the given graph using the Bron–Kerbosch
/// algorithm.
///
/// A maximal clique is a group of nodes where all nodes are connected to each
/// other in the graph.
///
pub fn maximal_cliques(graph: Graph(direction, label, value)) -> List(Set(Int)) {
  let unexplored =
    graph.nodes(graph)
    |> list.map(fn(node) { node.id })
    |> gb_set.from_list

  maximal_cliques_loop(graph, set.new(), unexplored, gb_set.new())
}

/// Ritorna tutte le clique composte da:
/// - `nodes` that are part of the clique
/// - `unexplored` the nodes that could be added later
/// - `visited` nodes whose cliques we've already explored (and so we shouldn't
///   search again)
///
/// All nodes in `unexplored` and `visited` are connected to all the nodes in
/// the clique.
///
fn maximal_cliques_loop(
  graph: Graph(direction, label, value),
  clique: Set(Int),
  unexplored: GbSet(Int),
  visited: GbSet(Int),
) -> List(Set(Int)) {
  case gb_set.is_empty(unexplored) {
    True ->
      case gb_set.is_empty(visited) {
        // If the visited set is not empty, that means there's other nodes that
        // are part of the current clique that we have already explored. So this
        // clique is not the maximal one.
        False -> []
        // Otherwise, it means we've found a maximal clique. There's no other
        // nodes that are connected to it and don't appear in `clique`.
        True -> [clique]
      }

    // Otherwise there's still nodes to explore. We'll keep expanding the
    // clique one level at a time.
    False -> maximal_cliques_inner_loop(graph, clique, unexplored, visited, [])
  }
}

fn maximal_cliques_inner_loop(
  graph: Graph(direction, label, value),
  clique: Set(Int),
  unexplored: GbSet(Int),
  visited: GbSet(Int),
  acc: List(Set(Int)),
) {
  // We go over all the unexplored nodes and one by one we add it to the clique,
  // one by one.
  case gb_set.next(unexplored) {
    Error(_) -> acc
    Ok(#(next, unexplored_rest)) -> {
      let assert Ok(context) = graph.get_context(graph, next)
      let reached = dict.keys(context.outgoing) |> gb_set.from_list
      let acc =
        maximal_cliques_loop(
          graph,
          set.insert(clique, next),
          // Only keep the nodes that are still fully connected to the clique.
          gb_set.intersection(reached, unexplored),
          gb_set.intersection(reached, visited),
        )
        |> list.append(acc)

      // We go to the nect node now, keeping track that it's no longer to
      // explore and it has already been explored.
      let visited = gb_set.insert(visited, next)
      maximal_cliques_inner_loop(graph, clique, unexplored_rest, visited, acc)
    }
  }
}
