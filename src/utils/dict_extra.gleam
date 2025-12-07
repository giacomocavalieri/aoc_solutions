import gleam/dict.{type Dict}

pub fn replace_value(
  dict: Dict(k, v),
  old one: v,
  with replacement: v,
) -> Dict(k, v) {
  dict.map_values(dict, fn(_key, value) {
    case value == one {
      True -> replacement
      False -> value
    }
  })
}
