import aoc/vec2.{type Vec2, rotate90, translate}
import gleam/dict
import gleam/list
import gleam/set
import gleam/string

pub type Map =
  dict.Dict(Vec2, String)

pub type ParseResult =
  #(Map, Vec2)

pub fn pt_1(input: ParseResult) {
  let #(map, start_pos) = input

  walk_map(map, start_pos, #(0, -1))
  |> set.size()
}

pub fn pt_2(input: ParseResult) {
  let #(map, start_pos) = input

  let possible_positions =
    map
    |> walk_map(start_pos, #(0, -1))
    |> set.delete(start_pos)

  let map_with_obstacle_at = fn(pos: Vec2) { dict.insert(map, pos, "#") }

  set.fold(possible_positions, 0, fn(number_of_loops, pos) {
    case map_with_obstacle_at(pos) |> detect_loop(start_pos, #(0, -1)) {
      True -> number_of_loops + 1
      False -> number_of_loops
    }
  })
}

pub fn parse(input: String) -> ParseResult {
  let init = #(dict.new(), #(0, 0))
  use map, line, y <- list.index_fold(string.split(input, "\n"), init)
  use #(map, guard_pos), cell, x <- list.index_fold(string.split(line, ""), map)
  case cell {
    "^" -> #(dict.insert(map, #(x, y), "."), #(x, y))
    "#" | "." -> #(dict.insert(map, #(x, y), cell), guard_pos)
    x -> panic as { "invalid char: " <> x }
  }
}

fn walk_map(map: Map, at: Vec2, direction: Vec2) {
  walk_map_loop(map, at, direction, set.new())
}

fn walk_map_loop(map: Map, at: Vec2, direction: Vec2, visitied: set.Set(Vec2)) {
  let next_pos = translate(at, direction)
  let visitied = set.insert(visitied, at)
  case dict.get(map, next_pos) {
    Error(_) -> visitied

    Ok(".") -> walk_map_loop(map, next_pos, direction, set.insert(visitied, at))
    Ok("#") -> {
      walk_map_loop(map, at, rotate90(direction), visitied)
    }
    Ok(_) -> panic
  }
}

fn detect_loop(map: Map, at: Vec2, direction: Vec2) {
  detect_loop_loop(map, at, direction, set.new())
}

fn detect_loop_loop(
  map: Map,
  at: Vec2,
  direction: Vec2,
  seen_obstacles: set.Set(#(Vec2, Vec2)),
) {
  let next_pos = translate(at, direction)
  case dict.get(map, next_pos) {
    Error(_) -> False
    Ok(".") -> detect_loop_loop(map, next_pos, direction, seen_obstacles)
    Ok("#") -> {
      case set.contains(seen_obstacles, #(next_pos, direction)) {
        True -> True
        False ->
          detect_loop_loop(
            map,
            at,
            rotate90(direction),
            seen_obstacles |> set.insert(#(next_pos, direction)),
          )
      }
    }
    Ok(_) -> panic
  }
}
