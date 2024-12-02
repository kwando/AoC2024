import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Levels =
  List(Int)

pub fn parse(input: String) -> List(Levels) {
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

pub fn pt_1(input: List(Levels)) {
  list.count(input, safe)
}

pub fn pt_2(input: List(Levels)) {
  list.count(input, fn(levels) { list.any(variations([], levels, []), safe) })
}

/// generate all combinations of the suffix list with 1 element removed.
/// the resulting list lists will be reversed but it is ok for this problem
fn variations(prefix: List(Int), suffix: List(Int), result: List(Levels)) {
  case suffix {
    [h, ..r] -> {
      let example = append(prefix, r)
      variations([h, ..prefix], r, [example, ..result])
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

fn increasing(levels: Levels) {
  case levels {
    [a, b, ..rest] if b > a && b - a <= 3 -> increasing([b, ..rest])
    [_] | [] -> True
    _ -> False
  }
}

fn decreasing(levels: Levels) {
  case levels {
    [a, b, ..rest] if b < a && a - b <= 3 -> decreasing([b, ..rest])
    [_] | [] -> True
    _ -> False
  }
}
