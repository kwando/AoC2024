import gleam/int
import gleam/list
import gleam/result
import gleam/string

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

type Levels =
  List(Int)

pub fn pt_1(input: List(Levels)) {
  list.count(input, safe)
}

pub fn pt_2(input: List(Levels)) {
  list.count(input, tolerant_safe([], _))
}

/// generate all combinations of the suffix list with 1 element removed.
/// the resulting list lists will be reversed but it is ok for this problem
fn tolerant_safe(prefix: List(Int), suffix: List(Int)) -> Bool {
  case suffix {
    [skipped_level, ..rest] -> {
      case safe(append(prefix, rest)) {
        True -> True
        False -> tolerant_safe([skipped_level, ..prefix], rest)
      }
    }
    [] -> False
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
