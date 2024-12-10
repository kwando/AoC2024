import aoc/vec2.{type Vec2}
import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import gleam/string

pub type TrailMap {
  TrailMap(map: dict.Dict(vec2.Vec2, Int), heads: List(Vec2))
}

pub fn pt_1(map: TrailMap) {
  use count, pos <- list.fold(map.heads, 0)

  count
  + {
    find_paths(map, pos)
    |> set.fold(set.new(), fn(acc, path) {
      case path {
        [last_pos, ..] -> set.insert(acc, last_pos)
        _ -> acc
      }
    })
    |> set.size
  }
}

pub fn pt_2(map: TrailMap) {
  use count, pos <- list.fold(map.heads, 0)
  count
  + {
    find_paths(map, pos)
    |> set.size
  }
}

fn find_paths(map: TrailMap, start_pos: Vec2) {
  find_paths_loop(map.map, -1, start_pos, [], set.new())
}

const directions = [#(0, -1), #(1, 0), #(0, 1), #(-1, 0)]

fn find_paths_loop(map, current_height, pos, seen, found_paths) {
  case dict.get(map, pos) {
    Ok(9) if current_height == 8 -> {
      set.insert(found_paths, [pos, ..seen])
    }
    Ok(value) if current_height + 1 == value -> {
      use found_nines, dir <- list.fold(directions, found_paths)
      find_paths_loop(
        map,
        value,
        vec2.translate(pos, dir),
        [pos, ..seen],
        found_nines,
      )
    }
    Ok(_) -> found_paths
    Error(_) -> found_paths
  }
}

pub fn parse(input: String) -> TrailMap {
  let map = {
    use map, line, row <- list.index_fold(string.split(input, "\n"), dict.new())
    use map, value, col <- list.index_fold(string.split(line, ""), map)

    let assert Ok(value) = int.parse(value)
    dict.insert(map, #(col, row), value)
  }
  let heads = {
    use acc, pos, value <- dict.fold(map, [])
    case value {
      0 -> [pos, ..acc]
      _ -> acc
    }
  }
  TrailMap(map:, heads:)
}
