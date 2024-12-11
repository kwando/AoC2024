import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let rocks = parse(input)

  list.range(1, 25)
  |> list.fold(rocks, fn(rocks, _) { blink(rocks) })
  |> list.length
}

pub fn pt_2(input: String) {
  let rocks = parse(input)

  list.range(1, 75)
  |> list.fold(rocks, fn(rocks, i) {
    io.debug(#("gen", i))
    blink(rocks)
  })
  |> list.length
}

fn blink(rocks: List(Int)) {
  case rocks {
    [h, ..rest] -> {
      case h {
        0 -> [1, ..blink(rest)]
        n -> {
          let assert Ok(digits) = int.digits(n, 10)
          let number_of_digits = list.length(digits)
          case number_of_digits % 2 == 0 {
            True -> {
              let assert Ok(left) =
                int.undigits(list.take(digits, number_of_digits / 2), 10)
              let assert Ok(right) =
                int.undigits(list.drop(digits, number_of_digits / 2), 10)
              [left, right, ..blink(rest)]
            }
            False -> [n * 2024, ..blink(rest)]
          }
        }
      }
    }
    [] -> []
  }
}

fn parse(input: String) {
  let assert Ok(rocks) =
    string.split(input, " ")
    |> list.try_map(int.parse)

  rocks
}
