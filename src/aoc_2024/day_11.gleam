import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string

pub fn pt_1(rocks: dict.Dict(Int, Int)) {
  list.range(1, 25)
  |> list.fold(rocks, fn(rocks, _) { cached_blink(rocks) })
  |> dict.values
  |> int.sum
}

pub fn pt_2(rocks: dict.Dict(Int, Int)) {
  list.range(1, 75)
  |> list.fold(rocks, fn(rocks, _) { cached_blink(rocks) })
  |> dict.values
  |> int.sum
}

fn cached_blink(rocks: dict.Dict(Int, Int)) -> dict.Dict(Int, Int) {
  use acc, h, value <- dict.fold(rocks, dict.new())
  case h {
    0 -> dict.upsert(acc, 1, add_or_increment(_, value))
    n -> {
      let assert Ok(digits) = int.digits(n, 10)
      let number_of_digits = list.length(digits)
      case int.is_even(number_of_digits) {
        False -> dict.upsert(acc, h * 2024, add_or_increment(_, value))
        True -> {
          let assert Ok(left) =
            int.undigits(list.take(digits, number_of_digits / 2), 10)
          let assert Ok(right) =
            int.undigits(list.drop(digits, number_of_digits / 2), 10)

          acc
          |> dict.upsert(left, add_or_increment(_, value))
          |> dict.upsert(right, add_or_increment(_, value))
        }
      }
    }
  }
}

fn add_or_increment(x, value) {
  case x {
    option.None -> value
    option.Some(existing) -> existing + value
  }
}

pub fn parse(input: String) -> dict.Dict(Int, Int) {
  let assert Ok(rocks) =
    string.split(input, " ")
    |> list.try_map(int.parse)

  list.fold(rocks, dict.new(), fn(acc, rock) {
    dict.upsert(acc, rock, add_or_increment(_, 1))
  })
}
