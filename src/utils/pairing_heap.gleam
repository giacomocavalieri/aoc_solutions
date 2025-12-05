import gleam/order.{type Order, Eq, Gt, Lt}

pub opaque type PairingHeap(k, v) {
  PairingHeap(compare: fn(k, k) -> Order, root: Node(k, v))
}

pub type Node(k, v) {
  Empty
  Node(key: k, value: v, heaps: List(Node(k, v)))
}

pub fn new(compare: fn(k, k) -> Order) -> PairingHeap(k, v) {
  PairingHeap(compare:, root: Empty)
}

/// Removes the minimum value from the heap.
/// This function runs in `O(logn)` time.
///
pub fn delete_min(heap: PairingHeap(k, v)) -> PairingHeap(k, v) {
  case heap.root {
    Empty -> heap
    Node(key: _, value: _, heaps:) ->
      PairingHeap(..heap, root: merge_node_pairs(heaps, heap.compare))
  }
}

/// Adds an element to the pairing heap.
/// This function runs in `O(1)` time.
///
pub fn insert(heap: PairingHeap(k, v), key: k, value: v) -> PairingHeap(k, v) {
  let root = merge_nodes(Node(key:, value:, heaps: []), heap.root, heap.compare)
  PairingHeap(..heap, root:)
}

/// Gets the minimum value in the heap, if any.
/// This function runs in `O(1)` time.
///
pub fn min(heap: PairingHeap(k, v)) -> Result(#(k, v), Nil) {
  case heap.root {
    Node(key:, value:, heaps: _) -> Ok(#(key, value))
    Empty -> Error(Nil)
  }
}

/// Returns the minimum value in the heap and the remaining heap.
/// This function runs in `O(logn)` time.
///
pub fn split_min(
  heap: PairingHeap(k, v),
) -> Result(#(k, v, PairingHeap(k, v)), Nil) {
  case min(heap) {
    Error(_) -> Error(Nil)
    Ok(#(k, v)) -> Ok(#(k, v, delete_min(heap)))
  }
}

/// Merges two heaps together, assuming they have the same comparison function.
/// This function runs in `O(1)` time.
///
pub fn merge(
  one: PairingHeap(k, v),
  with other: PairingHeap(k, v),
) -> PairingHeap(k, v) {
  PairingHeap(..one, root: merge_nodes(one.root, other.root, one.compare))
}

fn merge_nodes(
  one: Node(k, v),
  other: Node(k, v),
  compare: fn(k, k) -> Order,
) -> Node(k, v) {
  case one, other {
    node, Empty | Empty, node -> node
    Node(key:, value:, heaps:), Node(other_key, other_value, other_heaps) ->
      case compare(key, other_key) {
        Gt -> Node(other_key, other_value, [one, ..other_heaps])
        Eq | Lt -> Node(key, value, [other, ..heaps])
      }
  }
}

fn merge_node_pairs(
  nodes: List(Node(k, v)),
  compare: fn(k, k) -> Order,
) -> Node(k, v) {
  case nodes {
    [] -> Empty
    [first] -> first
    [first, second, ..rest] ->
      merge_nodes(
        merge_nodes(first, second, compare),
        merge_node_pairs(rest, compare),
        compare,
      )
  }
}
