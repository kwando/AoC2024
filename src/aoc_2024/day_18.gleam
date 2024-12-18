import aoc/vec2.{type Vec2}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import gleamy/priority_queue
import pocket_watch

const size = #(70, 70)

const steps = 1024

pub fn pt_1(input: List(vec2.Vec2)) {
  let map =
    input
    |> list.take(steps)
    |> list.fold(empty_grid(size.0, size.1), fn(acc, position) {
      dict.insert(acc, position, "#")
    })

  let q =
    priority_queue.from_list(
      [Next(0, manhattan_distance(#(0, 0), size), #(0, 0))],
      fn(a, b) { int.compare(a.score, b.score) },
    )
  find_path(q, size, map, set.new())
  |> result.unwrap(-1)
}

pub fn pt_2(input: List(vec2.Vec2)) {
  use <- pocket_watch.simple("pt_2")
  let grid = empty_grid(size.0, size.1)
  let initial_queue =
    priority_queue.from_list(
      [Next(0, manhattan_distance(#(0, 0), size), #(0, 0))],
      fn(a, b) { int.compare(a.score, b.score) },
    )

  list.fold_until(input, #(grid, Error(Nil)), fn(grid, position) {
    let map = dict.insert(grid.0, position, "#")
    case find_path(initial_queue, size, map, set.new()) {
      Ok(_) -> list.Continue(#(map, grid.1))
      Error(_) -> list.Stop(#(map, Ok(position)))
    }
  }).1
  |> result.map(fn(coord) {
    int.to_string(coord.0) <> "," <> int.to_string(coord.1)
  })
  |> result.unwrap("failure")
}

fn manhattan_distance(position: Vec2, target: Vec2) {
  int.absolute_value(position.0 - target.0)
  + int.absolute_value(position.1 - target.1)
}

fn empty_grid(rows: Int, cols: Int) {
  use acc, row <- list.fold(list.range(0, rows), dict.new())
  use acc, col <- list.fold(list.range(0, cols), acc)
  dict.insert(acc, #(col, row), ".")
}

pub type Next {
  Next(length: Int, score: Int, position: vec2.Vec2)
}

fn find_path(
  queue,
  goal: Vec2,
  blocks: dict.Dict(Vec2, String),
  visited: set.Set(Vec2),
) {
  case priority_queue.pop(queue) {
    Error(_) -> Error(Nil)
    Ok(#(Next(..) as head, remaining)) -> {
      //io.debug(head)
      case head.position == goal {
        True -> Ok(head.length)
        False -> {
          let updated_queue =
            [#(0, 1), #(1, 0), #(-1, 0), #(0, -1)]
            |> list.fold(remaining, fn(q, direction) {
              let next_pos = vec2.translate(head.position, direction)
              use <- bool.guard(
                when: !is_free(blocks, next_pos)
                  || set.contains(visited, next_pos),
                return: q,
              )
              priority_queue.push(
                q,
                Next(
                  head.length + 1,
                  score: head.length + 1 + manhattan_distance(next_pos, goal),
                  position: next_pos,
                ),
              )
            })

          find_path(
            updated_queue,
            goal,
            blocks,
            visited |> set.insert(head.position),
          )
        }
      }
    }
  }
}

fn is_free(map, position) {
  dict.get(map, position) == Ok(".")
}

pub fn parse(input: String) -> List(vec2.Vec2) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert Ok([x, y]) = string.split(line, ",") |> list.try_map(int.parse)
    #(x, y)
  })
}
