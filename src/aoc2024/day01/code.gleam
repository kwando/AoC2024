import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("src/aoc2024/day01/input.txt")

  let assert Ok(data) = parse(input)

  part1(data)
  |> io.debug

  part2(data)
  |> io.debug
}

fn part1(input: #(List(Int), List(Int))) {
  compute_diff(
    list.sort(input.0, int.compare),
    list.sort(input.1, int.compare),
    0,
  )
}

fn compute_diff(l1: List(Int), l2: List(Int), sum: Int) {
  case l1, l2 {
    [], [] -> sum
    [l1, ..r1], [l2, ..r2] -> {
      compute_diff(r1, r2, int.absolute_value(l1 - l2) + sum)
    }
    _, _ -> panic as "lists are not even length"
  }
}

fn part2(data: #(List(Int), List(Int))) {
  let freq = make_bag(data.1)

  use acc, loc <- list.fold(data.0, 0)
  acc + loc * { dict.get(freq, loc) |> result.unwrap(0) }
}

fn parse(input) {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, line) {
    let assert Ok([a, b]) =
      line
      |> string.split("   ")
      |> list.try_map(int.parse)

    #([a, ..acc.0], [b, ..acc.1])
  })
  |> Ok
}

fn make_bag(input: List(a)) -> dict.Dict(a, Int) {
  list.fold(input, dict.new(), fn(acc, loc) {
    dict.upsert(acc, loc, fn(count) { option.unwrap(count, 0) + 1 })
  })
}
