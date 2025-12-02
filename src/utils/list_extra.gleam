pub fn init(list: List(a)) -> List(a) {
  case list {
    [] -> []
    [_] -> []
    [first, ..rest] -> [first, ..init(rest)]
  }
}
