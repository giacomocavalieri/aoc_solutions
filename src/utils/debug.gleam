import gleam/string

/// Panics using the given value's string representation as the error message.
/// Useful in combination with the `advent` runner to debug print values, since
/// it doesn't show the output of `echo`.
///
pub fn debug(value: a) -> b {
  panic as string.inspect(value)
}
