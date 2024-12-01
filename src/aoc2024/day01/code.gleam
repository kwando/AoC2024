import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("src/aoc2024/day01/input.txt")

  let assert Ok(data) = parse(input)

  part1(data)
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

fn parse(input) {
  input
  |> string.split("\n")
  |> list.filter(fn(x) { x != "" })
  |> list.map(fn(line) {
    let assert Ok(numbers) =
      line
      |> string.split("   ")
      |> list.try_map(int.parse)

    numbers
  })
  |> list.fold(#([], []), fn(acc, elem) {
    let assert [a, b] = elem

    #([a, ..acc.0], [b, ..acc.1])
  })
  |> Ok
}
