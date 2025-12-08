pub type GbSet(a)

@external(erlang, "gb_sets", "from_list")
pub fn from_list(list: List(a)) -> GbSet(a)

@external(erlang, "gb_sets_ffi", "insert")
pub fn insert(set: GbSet(a), element: a) -> GbSet(a)

@external(erlang, "gb_sets", "intersection")
pub fn intersection(one: GbSet(a), other: GbSet(a)) -> GbSet(a)

@external(erlang, "gb_sets_ffi", "next")
pub fn next(set: GbSet(a)) -> Result(#(a, GbSet(a)), Nil)

@external(erlang, "gb_sets", "is_empty")
pub fn is_empty(set: GbSet(a)) -> Bool

@external(erlang, "gb_sets", "new")
pub fn new() -> GbSet(a)

@external(erlang, "gb_sets", "difference")
pub fn difference(one: GbSet(a), remove other: GbSet(a)) -> GbSet(a)
