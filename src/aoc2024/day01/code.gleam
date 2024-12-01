import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile

type ParsedInput =
  #(List(Int), List(Int))

pub fn main() {
  let assert Ok(input) = simplifile.read("src/aoc2024/day01/input.txt")

  let data = parse(input)

  part1(data)
  |> io.debug

  part2(data)
  |> io.debug
}

fn part1(input: ParsedInput) {
  compute_diff(
    list.sort(input.0, int.compare),
    list.sort(input.1, int.compare),
    0,
  )
}

fn part2(data: ParsedInput) {
  let freq = make_bag(data.1)

  use acc, loc <- list.fold(data.0, 0)
  acc + loc * number_of_copies(freq, loc)
}

fn parse(input: String) -> ParsedInput {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, line) {
    let assert Ok(#(a, b)) = string.split_once(line, "   ")
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)
    #([a, ..acc.0], [b, ..acc.1])
  })
}

fn make_bag(input: List(a)) -> dict.Dict(a, Int) {
  list.fold(input, dict.new(), fn(acc, loc) {
    dict.upsert(acc, loc, fn(count) { option.unwrap(count, 0) + 1 })
  })
}

fn number_of_copies(bag: dict.Dict(a, Int), value: a) -> Int {
  dict.get(bag, value) |> result.unwrap(0)
}

fn compute_diff(left: List(Int), right: List(Int), sum: Int) {
  case left, right {
    [], [] -> sum
    [l1, ..r1], [l2, ..r2] -> {
      compute_diff(r1, r2, int.absolute_value(l1 - l2) + sum)
    }
    _, _ -> panic as "lists are not even length"
  }
}
