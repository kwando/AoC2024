import aoc/vec2.{type Vec2, translate}
import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleamy/priority_queue

pub type ParseResult {
  ParseResult(map: dict.Dict(Vec2, String), start: Vec2, goal: Vec2)
}

pub type Next {
  Next(position: Vec2, direction: Vec2, score: Int, path: set.Set(Vec2))
}

pub fn pt_1(input: ParseResult) {
  let result =
    collect_nodes(
      input.map,
      input.goal,
      new_queue()
        |> priority_queue.push(Next(
          position: input.start,
          direction: #(1, 0),
          score: 0,
          path: set.new(),
        )),
      set.new(),
      NoPathFound,
    )

  case result {
    FoundPath(score:, ..) -> score
    NoPathFound -> -1
  }
}

pub fn pt_2(input: ParseResult) {
  let result =
    collect_nodes(
      input.map,
      input.goal,
      new_queue()
        |> priority_queue.push(Next(
          position: input.start,
          direction: #(1, 0),
          score: 0,
          path: set.new(),
        )),
      set.new(),
      NoPathFound,
    )

  case result {
    FoundPath(_, nodes) -> set.size(nodes)
    NoPathFound -> -1
  }
}

fn new_queue() {
  priority_queue.new(fn(a: Next, b: Next) { int.compare(a.score, b.score) })
}

fn is_wall(grid, position) {
  dict.get(grid, position) == Ok("#")
}

pub type CollectResult {
  NoPathFound
  FoundPath(score: Int, nodes: set.Set(Vec2))
}

fn collect_nodes(map, goal, queue, visited, collect_result: CollectResult) {
  case priority_queue.pop(queue) {
    Ok(#(Next(..) as head, tail)) -> {
      case head.position == goal {
        True -> {
          case collect_result {
            FoundPath(score:, ..) if score > head.score -> {
              collect_nodes(
                map,
                goal,
                tail,
                visited,
                FoundPath(head.score, head.path),
              )
            }

            FoundPath(score:, nodes:) if score == head.score -> {
              collect_nodes(
                map,
                goal,
                tail,
                visited,
                FoundPath(
                  head.score,
                  nodes |> set.union(head.path) |> set.insert(goal),
                ),
              )
            }

            NoPathFound -> {
              collect_nodes(
                map,
                goal,
                tail,
                visited,
                FoundPath(head.score, head.path |> set.insert(goal)),
              )
            }

            FoundPath(_, _) as best -> best
          }
        }
        False -> {
          let visited = set.insert(visited, #(head.position, head.direction))

          let queue =
            [
              #(
                head.score + 1,
                translate(head.position, head.direction),
                head.direction,
              ),
              #(head.score + 1000, head.position, vec2.rotate90(head.direction)),
              #(
                head.score + 1000,
                head.position,
                vec2.rotate90ccw(head.direction),
              ),
            ]
            |> list.filter(fn(alt) {
              !set.contains(visited, #(alt.1, alt.2)) && !is_wall(map, alt.1)
            })
            |> list.fold(tail, fn(q, alt) {
              priority_queue.push(
                q,
                Next(
                  score: alt.0,
                  position: alt.1,
                  direction: alt.2,
                  path: set.insert(head.path, head.position),
                ),
              )
            })

          collect_nodes(map, goal, queue, visited, collect_result)
        }
      }
    }
    Error(_) -> collect_result
  }
}

pub fn parse(input: String) -> ParseResult {
  let #(map, start, goal) = {
    use acc, line, row <- list.index_fold(
      string.split(input, "\n"),
      #(dict.new(), #(-1, -1), #(-1, -1)),
    )
    use #(map, start, goal), cell, col <- list.index_fold(
      string.split(line, ""),
      acc,
    )
    case cell {
      "S" -> #(dict.insert(map, #(col, row), "."), #(col, row), goal)
      "E" -> #(dict.insert(map, #(col, row), "."), start, #(col, row))
      "#" | "." -> #(dict.insert(map, #(col, row), cell), start, goal)
      _ -> panic
    }
  }

  ParseResult(map:, start:, goal:)
}
