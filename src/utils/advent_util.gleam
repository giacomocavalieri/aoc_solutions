import advent.{type Year}
import envoy
import gleam/string

/// Panics using the given value's string representation as the error message.
/// Useful in combination with the `advent` runner to debug print values, since
/// it doesn't show the output of `echo`.
///
pub fn debug(value: a) -> b {
  panic as string.inspect(value)
}

pub fn download_if_token(year: Year) -> Year {
  case envoy.get("AOC_SESSION_TOKEN") {
    Ok(session_token) -> advent.download_missing_days(year, session_token)
    Error(_) -> year
  }
}
