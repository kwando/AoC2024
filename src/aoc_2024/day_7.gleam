import gleam/int
import gleam/list
import gleam/string

pub type Equation {
  Equation(target: Int, terms: List(Int))
}

type Operation {
  Multiply
  Add
  Concat
}

pub fn pt_1(input: List(Equation)) {
  use sum, equation <- list.fold(input, 0)
  case try_solve(equation, [Multiply, Add]) {
    Ok(target) -> sum + target
    Error(_) -> sum
  }
}

pub fn pt_2(input: List(Equation)) {
  use sum, equation <- list.fold(input, 0)
  case try_solve(equation, [Multiply, Add, Concat]) {
    Ok(target) -> sum + target
    Error(_) -> sum
  }
}

fn try_solve(equation: Equation, ops: List(Operation)) {
  try_solve_loop(equation.terms, ops, equation.target)
}

fn try_solve_loop(terms: List(Int), ops: List(Operation), target: Int) {
  case terms {
    [value] if value == target -> Ok(value)
    [a, b, ..rest] -> {
      use _, op <- list.fold_until(ops, Error(Nil))
      case try_solve_loop([apply(op, a, b), ..rest], ops, target) {
        Ok(t) -> list.Stop(Ok(t))
        Error(Nil) -> list.Continue(Error(Nil))
      }
    }
    _ -> Error(Nil)
  }
}

fn apply(op: Operation, a: Int, b: Int) {
  case op {
    Multiply -> a * b
    Add -> a + b
    Concat -> concat_numbers(a, b)
  }
}

fn concat_numbers(a: Int, b: Int) {
  number_of_digits(b) * a + b
}

fn number_of_digits(n: Int) {
  case n {
    n if n < 0 -> number_of_digits(-n)
    n if n < 10 -> 10
    n -> number_of_digits(n / 10) * 10
  }
}

pub fn parse(input: String) -> List(Equation) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(target, values)) = string.split_once(line, ": ")
    let assert Ok(target) = int.parse(target)
    let assert Ok(terms) = string.split(values, " ") |> list.try_map(int.parse)

    Equation(target:, terms:)
  })
}
