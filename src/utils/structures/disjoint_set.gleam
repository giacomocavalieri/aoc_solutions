import gleam/dict.{type Dict}
import gleam/result

pub opaque type DisjointSet(a) {
  DisjointSet(parents: Dict(a, Node(a)))
}

type Node(a) {
  Child(parent: a)
  Root(size: Int)
}

pub fn new() -> DisjointSet(a) {
  DisjointSet(parents: dict.new())
}

pub fn set_sizes(set: DisjointSet(a)) -> List(Int) {
  dict.fold(set.parents, from: [], with: fn(acc, _, value) {
    case value {
      Child(parent: _) -> acc
      Root(size:) -> [size, ..acc]
    }
  })
}

/// Returns the size of the set containing the given value. If the value doesn't
/// belong to any set, this returns `Error(Nil)`.
///
pub fn set_size(
  set: DisjointSet(a),
  containing value: a,
) -> Result(#(Int, DisjointSet(a)), Nil) {
  case size_root_loop(set.parents, value) {
    Error(_) -> Error(Nil)
    Ok(#(size, _root, parents)) -> Ok(#(size, DisjointSet(parents:)))
  }
}

/// If it's not already present, adds the given value to the disjoint set as a
/// new standalone point, not connected to any other existing group.
///
pub fn insert(set: DisjointSet(a), value: a) -> DisjointSet(a) {
  case dict.has_key(set.parents, value) {
    True -> set
    False -> DisjointSet(dict.insert(set.parents, value, Root(size: 1)))
  }
}

/// Merges two values in the disjoint set (if both are actually present).
///
pub fn merge(in set: DisjointSet(a), one x: a, and y: a) {
  let result = {
    use #(size_x, x, parents) <- result.try(size_root_loop(set.parents, x))
    use #(size_y, y, parents) <- result.map(size_root_loop(parents, y))

    case x == y {
      True -> DisjointSet(parents:)
      False ->
        case size_x < size_y {
          False -> {
            parents
            |> dict.insert(x, Child(parent: y))
            |> dict.insert(y, Root(size: size_x + size_y))
            |> DisjointSet
          }
          True ->
            parents
            |> dict.insert(y, Child(parent: x))
            |> dict.insert(x, Root(size: size_x + size_y))
            |> DisjointSet
        }
    }
  }

  case result {
    Ok(set) -> set
    Error(_) -> set
  }
}

fn size_root_loop(
  parents: Dict(a, Node(a)),
  value: a,
) -> Result(#(Int, a, Dict(a, Node(a))), Nil) {
  case dict.get(parents, value) {
    Error(_) -> Error(Nil)
    Ok(Root(size:)) -> Ok(#(size, value, parents))
    Ok(Child(parent:)) -> {
      let assert Ok(#(size, parent, parents)) = size_root_loop(parents, parent)
      let parents = dict.insert(parents, value, Child(parent:))
      Ok(#(size, parent, parents))
    }
  }
}
