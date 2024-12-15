import aoc/vec2.{type Vec2, translate}
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type ParseResult {
  ParseResult(map: dict.Dict(Vec2, String), moves: List(Vec2), robot: Vec2)
}

pub fn pt_1(input: ParseResult) {
  let #(map, _) = {
    use #(map, robot), move <- list.fold(input.moves, #(input.map, input.robot))
    move_robot(map, robot, move)
  }

  dict.fold(map, 0, fn(acc, key, value) {
    case value {
      "O" -> acc + coordinate(key)
      _ -> acc
    }
  })
}

fn coordinate(pos: Vec2) {
  pos.1 * 100 + pos.0
}

fn move_robot(map, robot: Vec2, move: Vec2) {
  let next_pos = translate(robot, move)
  case dict.get(map, next_pos) {
    Ok(".") -> #(map, next_pos)
    Ok("O") -> {
      case find_space(map, next_pos, move) {
        Ok(free_space) -> {
          #(
            map
              |> dict.insert(free_space, "O")
              |> dict.insert(next_pos, "."),
            next_pos,
          )
        }
        Error(_) -> #(map, robot)
      }
    }
    Ok(_) | Error(_) -> #(map, robot)
  }
}

fn find_space(map, position, direction) {
  case dict.get(map, position) {
    Ok("#") -> Error(Nil)
    Ok("O") -> find_space(map, translate(position, direction), direction)
    Ok(".") -> Ok(position)
    Error(_) -> Ok(position)
    Ok(char) -> panic as { "unreachable " <> char }
  }
}

pub fn pt_2(input: ParseResult) {
  let #(map, _) = {
    let map = widen_map(input.map)
    let robot = vec2.multiply(input.robot, #(2, 1))
    use #(map, robot), move <- list.fold(input.moves, #(map, robot))
    move_robot2(map, robot, move)
  }

  use acc, pos, value <- dict.fold(map, 0)
  case value {
    "[" -> acc + coordinate(pos)
    _ -> acc
  }
}

pub fn move_robot2(map, robot, move) {
  let next_pos = translate(robot, move)
  case dict.get(map, next_pos) {
    Ok(".") -> #(map, next_pos)
    Ok("[") | Ok("]") -> {
      case move {
        #(_, 0) -> {
          case push_horizontal(map, next_pos, move) {
            Ok(map) -> #(map, next_pos)
            Error(_) -> #(map, robot)
          }
        }
        #(0, _) -> {
          case push_vertical(map, next_pos, move) {
            Ok(map) -> #(map, next_pos)
            Error(_) -> #(map, robot)
          }
        }
        _ -> panic
      }
    }
    Ok(_) | Error(_) -> #(map, robot)
  }
}

fn push_horizontal(map, position, direction: Vec2) {
  let next_pos = translate(position, direction)
  case dict.get(map, next_pos) {
    Ok("#") -> Error(Nil)
    Ok(".") -> {
      let assert Ok(value) = dict.get(map, position)
      Ok(dict.insert(map, next_pos, value))
    }
    Ok("[") | Ok("]") -> {
      let assert Ok(value) = dict.get(map, position)
      case push_horizontal(map, next_pos, direction) {
        Ok(map) -> {
          Ok(dict.insert(map, next_pos, value) |> dict.insert(position, "."))
        }
        Error(Nil) -> Error(Nil)
      }
    }
    Error(_) -> panic
    Ok(char) -> panic as { "unknown char" <> string.inspect(char) }
  }
}

fn push_vertical(map, position, direction: Vec2) {
  let assert Ok(value) = dict.get(map, position)

  case value {
    "]" -> push_vertical(map, position |> translate(#(-1, 0)), direction)
    "[" -> {
      let left_next = translate(position, direction)
      let right_next = translate(left_next, #(1, 0))
      let assert Ok(left) = dict.get(map, left_next)
      let assert Ok(right) = dict.get(map, right_next)

      case left, right {
        "[", "]" | "]", "[" | "]", "." | ".", "[" | ".", "." -> {
          map
          |> push_vertical(left_next, direction)
          |> result.try(push_vertical(_, right_next, direction))
          |> result.map(fn(map) {
            map
            |> dict.insert(left_next, "[")
            |> dict.insert(right_next, "]")
            |> dict.insert(position, ".")
            |> dict.insert(position |> translate(#(1, 0)), ".")
          })
        }
        "#", _ -> Error(Nil)
        _, "#" -> Error(Nil)
        x, y -> panic as string.inspect(#(x, y))
      }
    }
    "#" -> Error(Nil)
    "." -> Ok(map)
    c -> panic as { "unexpected char " <> string.inspect(c) }
  }
}

fn widen_map(map: dict.Dict(Vec2, String)) {
  use acc, pos, cell <- dict.fold(map, dict.new())
  case cell {
    "#" ->
      acc
      |> dict.insert(#(pos.0 * 2, pos.1), "#")
      |> dict.insert(#(pos.0 * 2 + 1, pos.1), "#")
    "." ->
      acc
      |> dict.insert(#(pos.0 * 2, pos.1), ".")
      |> dict.insert(#(pos.0 * 2 + 1, pos.1), ".")
    "O" ->
      acc
      |> dict.insert(#(pos.0 * 2, pos.1), "[")
      |> dict.insert(#(pos.0 * 2 + 1, pos.1), "]")
    _ -> acc
  }
}

pub fn parse(input: String) -> ParseResult {
  let assert [map_str, instr_str] = string.split(input, "\n\n")

  let #(map, robot) = {
    use acc, line, row <- list.index_fold(
      string.split(map_str, "\n"),
      #(dict.new(), #(-1, -1)),
    )
    use #(map, robot), value, col <- list.index_fold(
      string.split(line, ""),
      acc,
    )
    case value {
      "@" -> {
        #(dict.insert(map, #(col, row), "."), #(col, row))
      }
      cell -> #(dict.insert(map, #(col, row), cell), robot)
    }
  }

  let moves =
    instr_str
    |> string.replace("\n", "")
    |> string.split("")
    |> list.map(fn(value) {
      case value {
        ">" -> #(1, 0)
        "<" -> #(-1, 0)
        "v" -> #(0, 1)
        "^" -> #(0, -1)
        _ -> panic as "invalid move"
      }
    })

  ParseResult(map:, moves:, robot:)
}

pub fn print_map(map: dict.Dict(Vec2, String), robot: Vec2) {
  let bounds = {
    use pos, key, _ <- dict.fold(map, #(0, 0))
    #(int.max(key.0, pos.0), int.max(key.1, pos.1))
  }
  use acc, row <- list.fold(list.range(0, bounds.1), "")
  {
    use acc, col <- list.fold(list.range(0, bounds.0), acc)
    let pos = #(col, row)
    case pos == robot {
      True -> acc <> "@"
      False -> {
        case dict.get(map, #(col, row)) {
          Ok(v) -> acc <> v
          Error(_) -> acc <> " "
        }
      }
    }
  }
  <> "\n"
}
