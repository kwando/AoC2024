import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string

pub opaque type ParseResult {
  ParseResult(rules: set.Set(#(Int, Int)), updates: List(List(Int)))
}

pub fn pt_1(input: ParseResult) {
  use sum, update <- list.fold(input.updates, 0)
  case is_valid(update, input.rules) {
    True -> {
      let assert Ok(m) = middle(update)
      sum + m
    }
    False -> sum
  }
}

pub fn pt_2(input: ParseResult) {
  use sum, update <- list.fold(input.updates, 0)
  case is_valid(update, input.rules) {
    False -> {
      let assert Ok(m) = middle(sort_update(update, input.rules))
      sum + m
    }
    True -> sum
  }
}

fn is_valid(update, rules) {
  update == sort_update(update, rules)
}

fn middle(update) {
  update |> list.drop(list.length(update) / 2) |> list.first
}

fn sort_update(update, rules) {
  use a, b <- list.sort(update)
  case set.contains(rules, #(a, b)) {
    True -> order.Gt
    False -> order.Lt
  }
}

pub fn parse(input: String) -> ParseResult {
  let assert Ok(#(first, second)) = string.split_once(input, "\n\n")

  let rules = {
    use d, line <- list.fold(string.split(first, "\n"), set.new())
    let assert Ok([requirement, page]) =
      line
      |> string.split("|")
      |> list.try_map(int.parse)

    set.insert(d, #(page, requirement))
  }

  let assert Ok(updates) =
    second
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.split(",")
      |> list.try_map(int.parse)
    })
    |> result.all

  ParseResult(updates:, rules:)
}
