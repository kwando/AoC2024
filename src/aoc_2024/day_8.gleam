import aoc/vec2.{type Vec2, translate, within_bounds}
import gleam/dict
import gleam/list
import gleam/option
import gleam/set
import gleam/string

pub type AntennaMap {
  AntennaMap(positions: dict.Dict(String, List(Vec2)), bounds: Vec2)
}

pub fn pt_1(input: AntennaMap) {
  use antinodes, antenna_pos, direction, bounds <- count_antinodes(input)
  let antinode_pos = translate(antenna_pos, direction)
  case within_bounds(lower: #(0, 0), upper: bounds, position: antinode_pos) {
    False -> antinodes
    True -> set.insert(antinodes, antinode_pos)
  }
}

pub fn pt_2(input: AntennaMap) {
  count_antinodes(input, nodes_in_line)
}

fn nodes_in_line(antinodes, pos, vector, upper) {
  case within_bounds(position: pos, upper: upper, lower: #(0, 0)) {
    True -> {
      nodes_in_line(
        set.insert(antinodes, pos),
        translate(pos, vector),
        vector,
        upper,
      )
    }
    False -> antinodes
  }
}

fn count_antinodes(
  map: AntennaMap,
  collect_nodes: fn(set.Set(Vec2), Vec2, Vec2, Vec2) -> set.Set(Vec2),
) {
  {
    use visitied, _, positions <- dict.fold(map.positions, set.new())
    use visitied, #(pos1, pos2) <- list.fold(
      list.combination_pairs(positions),
      visitied,
    )

    let dx = pos2.0 - pos1.0
    let dy = pos2.1 - pos1.1

    visitied
    |> collect_nodes(pos1, #(-dx, -dy), map.bounds)
    |> collect_nodes(pos2, #(dx, dy), map.bounds)
  }
  |> set.size
}

pub fn parse(input: String) -> AntennaMap {
  let #(positions, bounds) = {
    let lines = string.split(input, "\n")
    use acc, line, y <- list.index_fold(lines, #(dict.new(), #(0, 0)))
    use #(antennas, _), cell, x <- list.index_fold(string.split(line, ""), acc)
    case cell {
      "." -> #(antennas, #(x, y))

      cell -> #(
        dict.upsert(antennas, cell, fn(old) {
          [#(x, y), ..option.unwrap(old, [])]
        }),
        #(x, y),
      )
    }
  }

  AntennaMap(positions:, bounds:)
}
