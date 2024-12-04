import gleam/dict
import gleam/list
import gleam/string

pub fn pt_1(input: String) {
  let letters =
    input
    |> string.trim_end
    |> string.to_graphemes

  let #(maxx, maxy, map) =
    letters
    |> list.fold(#(0, 0, dict.new()), fn(acc, letter) {
      case letter {
        "\n" -> #(0, acc.1 + 1, acc.2)
        letter -> #(
          acc.0 + 1,
          acc.1,
          dict.insert(acc.2, #(acc.0, acc.1), letter),
        )
      }
    })

  let maxx = maxx - 1

  let start_points =
    map
    |> dict.to_list()
    |> list.filter_map(fn(entry) {
      case entry.1 {
        "X" -> Ok(entry.0)
        _ -> Error(Nil)
      }
    })

  let result =
    {
      use start <- list.map(start_points)
      use direction <- list.map(directions)
      letters_in_direction(map, start, direction, 4, [])
    }
    |> list.flatten
    |> list.count(fn(letters) {
      case letters {
        ["X", "M", "A", "S"] -> True
        _ -> False
      }
    })
}

type Pos =
  #(Int, Int)

const directions = [
  #(0, 1), #(1, 1), #(1, 0), #(1, -1), #(0, -1), #(-1, -1), #(-1, 0), #(-1, 1),
]

fn translate(v: Pos, d: Pos) -> Pos {
  #(v.0 + d.0, v.1 + d.1)
}

fn letters_in_direction(
  map,
  pos: Pos,
  direction,
  length: Int,
  letters: List(String),
) {
  case length {
    0 -> list.reverse(letters)
    _ -> {
      case dict.get(map, pos) {
        Ok(letter) ->
          letters_in_direction(
            map,
            translate(pos, direction),
            direction,
            length - 1,
            [letter, ..letters],
          )
        Error(_) -> list.reverse(letters)
      }
    }
  }
}

pub fn pt_2(input: String) {
  let letters =
    input
    |> string.trim_end
    |> string.to_graphemes

  let #(maxx, maxy, map) =
    letters
    |> list.fold(#(0, 0, dict.new()), fn(acc, letter) {
      case letter {
        "\n" -> #(0, acc.1 + 1, acc.2)
        letter -> #(
          acc.0 + 1,
          acc.1,
          dict.insert(acc.2, #(acc.0, acc.1), letter),
        )
      }
    })

  use #(start, _) <- list.count(dict.to_list(map))

  is_mas(letters_in_direction(map, start, #(1, 1), 3, []))
  && is_mas(
    letters_in_direction(map, translate(start, #(2, 0)), #(-1, 1), 3, []),
  )
}

fn is_mas(letters) {
  case letters {
    ["M", "A", "S"] -> True
    ["S", "A", "M"] -> True
    _ -> False
  }
}
