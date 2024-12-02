import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() {
  let assert Ok(data) = simplifile.read("src/aoc2024/day02/input.txt")
  let parsed_input = parse(data)

  parsed_input
  |> pt_1
  |> io.debug

  parsed_input
  |> pt_2
  |> io.debug
}

fn parse(input: String) {
  input
  |> string.trim_end
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(numbers) =
      string.split(line, " ")
      |> list.map(int.parse)
      |> result.all

    numbers
  })
}

fn pt_1(input) {
  list.count(input, safe)
}

fn pt_2(input) {
  list.count(input, fn(levels) { list.any(without([], levels, []), safe) })
}

fn without(prefix: List(Int), suffix: List(Int), result: List(List(Int))) {
  case suffix {
    [h, ..r] -> {
      let example = append(prefix, r)
      without([h, ..prefix], r, [example, ..result])
    }
    [] -> result
  }
}

fn append(prefix: List(Int), suffix: List(Int)) {
  case suffix {
    [] -> prefix
    [n, ..rest] -> append([n, ..prefix], rest)
  }
}

fn safe(levels) {
  increasing(levels) || decreasing(levels)
}

fn increasing(levels: List(Int)) {
  case levels {
    [a, b, ..rest] if b > a && b - a <= 3 -> increasing([b, ..rest])
    [_] | [] -> True
    _ -> False
  }
}

fn decreasing(levels: List(Int)) {
  case levels {
    [a, b, ..rest] if b < a && a - b <= 3 -> decreasing([b, ..rest])
    [_] | [] -> True
    _ -> False
  }
}
