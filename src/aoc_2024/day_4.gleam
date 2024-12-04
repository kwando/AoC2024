import gleam/dict
import gleam/list
import gleam/string

type Vec2 =
  #(Int, Int)

type Map =
  dict.Dict(#(Int, Int), String)

pub fn pt_1(map: Map) {
  let directions = [
    #(0, 1),
    #(1, 1),
    #(1, 0),
    #(1, -1),
    #(0, -1),
    #(-1, -1),
    #(-1, 0),
    #(-1, 1),
  ]
  use count, start <- list.fold(dict.keys(map), 0)
  use count, direction <- list.fold(directions, count)

  case get_word(map, start, direction, 4, []) {
    ["X", "M", "A", "S"] -> count + 1
    _ -> count
  }
}

pub fn pt_2(map: Map) {
  use count, start, _ <- dict.fold(map, 0)

  case
    get_word(map, start, #(1, 1), 3, []),
    get_word(map, translate(start, #(2, 0)), #(-1, 1), 3, [])
  {
    ["M", "A", "S"], ["M", "A", "S"]
    | ["S", "A", "M"], ["M", "A", "S"]
    | ["M", "A", "S"], ["S", "A", "M"]
    | ["S", "A", "M"], ["S", "A", "M"]
    -> count + 1
    _, _ -> count
  }
}

pub fn parse(input: String) -> Map {
  let map = dict.new()
  use map, row, y <- list.index_fold(string.split(input, "\n"), map)
  use map, letter, x <- list.index_fold(string.split(row, ""), map)
  dict.insert(map, #(x, y), letter)
}

fn translate(v: Vec2, d: Vec2) -> Vec2 {
  #(v.0 + d.0, v.1 + d.1)
}

// the return value word is reversed, but it doesnt matter for this problem
fn get_word(map, pos: Vec2, direction, length: Int, letters: List(String)) {
  case length {
    0 -> letters
    _ -> {
      case dict.get(map, pos) {
        Ok(letter) ->
          get_word(map, translate(pos, direction), direction, length - 1, [
            letter,
            ..letters
          ])
        Error(_) -> letters
      }
    }
  }
}
