import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{Match}

pub opaque type Instruction {
  Multiply(Int, Int)
  Enable
  Disable
}

pub fn parse(input: String) -> List(Instruction) {
  let assert Ok(regex) =
    regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\)")

  use match <- list.map(regexp.scan(regex, input))
  case match {
    Match(_, [Some(a), Some(b)]) -> {
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      Multiply(a, b)
    }
    Match("do()", []) -> Enable
    Match("don't()", []) -> Disable
    _ -> panic as "invalid instruction"
  }
}

pub fn pt_1(input: List(Instruction)) {
  use sum, instruction <- list.fold(input, 0)
  case instruction {
    Multiply(a, b) -> sum + a * b
    _ -> sum
  }
}

pub fn pt_2(input: List(Instruction)) {
  {
    use #(enabled, sum), instruction <- list.fold(input, #(True, 0))
    case enabled, instruction {
      True, Multiply(a, b) -> #(True, sum + a * b)
      _, Enable -> #(True, sum)
      _, Disable -> #(False, sum)
      _, _ -> #(enabled, sum)
    }
  }.1
}
