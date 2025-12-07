import advent.{type Year}
import envoy

pub fn download_if_token(year: Year) -> Year {
  case envoy.get("AOC_SESSION_TOKEN") {
    Ok(session_token) -> advent.download_missing_days(year, session_token)
    Error(_) -> year
  }
}
