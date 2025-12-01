import gleam/string

pub fn debug(value: a) -> b {
  panic as string.inspect(value)
}
