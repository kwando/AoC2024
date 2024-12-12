import aoc/vec2.{type Vec2, rotate90, translate}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/set
import gleam/string

pub fn pt_1(input: dict.Dict(Vec2, String)) {
  input
  |> get_regions()
  |> list.fold(0, fn(acc, region) {
    acc + get_perimeter(region) * set.size(region)
  })
}

pub fn pt_2(input: dict.Dict(Vec2, String)) {
  input
  |> get_regions()
  |> list.fold(0, fn(acc, region) { acc + get_sides(region) * set.size(region) })
}

const directions = [#(0, 1), #(1, 0), #(-1, 0), #(0, -1)]

fn get_sides(region: set.Set(Vec2)) {
  use corners, position <- set.fold(region, 0)
  use corners, direction <- list.fold(directions, corners)
  case
    // outside corner
    !set.contains(region, translate(position, direction))
    && !set.contains(region, translate(position, vec2.rotate90(direction)))
    // inside corner
    || set.contains(region, translate(position, direction))
    && set.contains(region, translate(position, rotate90(direction)))
    && !set.contains(
      region,
      translate(position, translate(direction, rotate90(direction))),
    )
  {
    True -> corners + 1
    False -> corners
  }
}

fn get_regions(map: dict.Dict(Vec2, String)) -> List(set.Set(Vec2)) {
  get_regions_loop(map, set.from_list(dict.keys(map)), [])
}

fn get_regions_loop(map: dict.Dict(Vec2, String), left: set.Set(Vec2), result) {
  case set.to_list(left) {
    [next, ..] -> {
      let assert Ok(kind) = dict.get(map, next)
      let region = get_region(map, next, kind, set.new())

      get_regions_loop(map, set.difference(left, region), [region, ..result])
    }
    [] -> result
  }
}

fn get_perimeter(region) {
  use count, square <- set.fold(region, 0)
  use count, direction <- list.fold(directions, count)
  case set.contains(region, vec2.translate(square, direction)) {
    True -> count
    False -> count + 1
  }
}

fn get_region(map, position, kind: String, seen) {
  case dict.get(map, position) {
    Ok(k) if k == kind -> {
      case set.contains(seen, position) {
        True -> seen
        False -> {
          list.fold(directions, seen, fn(seen, dir) {
            get_region(
              map,
              vec2.translate(position, dir),
              kind,
              seen |> set.insert(position),
            )
          })
        }
      }
    }
    Error(_) -> seen
    Ok(_) -> seen
  }
}

pub fn parse(input: String) -> dict.Dict(Vec2, String) {
  use acc, line, row <- list.index_fold(string.split(input, "\n"), dict.new())
  use acc, region, col <- list.index_fold(string.split(line, ""), acc)
  dict.insert(acc, #(col, row), region)
}
