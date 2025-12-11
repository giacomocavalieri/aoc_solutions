import advent
import gleam/bool
import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn day() {
  advent.Day(
    day: 11,
    parse:,
    part_a:,
    expected_a: option.Some(649),
    wrong_answers_a: [],
    part_b:,
    expected_b: option.Some(458_948_453_421_420),
    wrong_answers_b: [],
  )
}

type Cache =
  Dict(#(String, String), Int)

fn part_a(graph: Dict(String, List(String))) -> Int {
  let #(steps, _) = paths(dict.new(), in: graph, from: "you", to: "out")
  steps
}

fn part_b(graph: Dict(String, List(String))) -> Int {
  let cache = dict.new()
  let #(svr_to_fft, cache) = paths(cache, in: graph, from: "svr", to: "fft")
  let #(fft_to_dac, cache) = paths(cache, in: graph, from: "fft", to: "dac")
  let #(dac_to_out, cache) = paths(cache, in: graph, from: "dac", to: "out")
  let #(svt_to_dac, cache) = paths(cache, in: graph, from: "svr", to: "dac")
  let #(dac_to_fft, cache) = paths(cache, in: graph, from: "dac", to: "fft")
  let #(fft_to_out, _) = paths(cache, in: graph, from: "fft", to: "out")

  { svr_to_fft * fft_to_dac * dac_to_out }
  + { svt_to_dac * dac_to_fft * fft_to_out }
}

fn paths(
  cache: Cache,
  in graph: Dict(String, List(String)),
  from start: String,
  to end: String,
) -> #(Int, Cache) {
  use <- cached(cache, #(start, end))
  use <- bool.guard(when: start == end, return: #(1, cache))

  let outputs = dict.get(graph, start) |> result.unwrap(or: [])
  list.fold(over: outputs, from: #(0, cache), with: fn(acc, output) {
    let #(steps, cache) = acc
    let #(new_steps, cache) = paths(cache, graph, from: output, to: end)
    #(steps + new_steps, cache)
  })
}

fn cached(
  cache: Dict(k, v),
  key: k,
  fun: fn() -> #(v, Dict(k, v)),
) -> #(v, Dict(k, v)) {
  case dict.get(cache, key) {
    Ok(steps) -> #(steps, cache)
    Error(_) -> {
      let #(result, cache) = fun()
      #(result, dict.insert(cache, key, result))
    }
  }
}

fn parse(input: String) -> Dict(String, List(String)) {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert [node, outputs] = string.split(line, on: ": ")
    let outputs = string.split(outputs, on: " ")
    #(node, outputs)
  })
  |> dict.from_list
}
