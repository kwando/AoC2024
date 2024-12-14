import aoc/vec2.{type Vec2}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Robot {
  Robot(pos: Vec2, velocity: Vec2)
}

pub fn pt_1(robots: List(Robot)) {
  safety_factor(robots, size: #(101, 103), seconds: 100)
}

pub fn pt_2(robots: List(Robot)) {
  find_xmas_tree(robots, size: #(101, 103), max_seconds: 10_000)
  |> result.unwrap(-1)
}

fn find_xmas_tree(
  robots: List(Robot),
  size size: Vec2,
  max_seconds max_seconds: Int,
) {
  find_xmas_tree_loop(robots, size, 0, max_seconds)
}

fn find_xmas_tree_loop(
  robots: List(Robot),
  size: Vec2,
  second: Int,
  max_time: Int,
) {
  use <- bool.guard(when: second >= max_time, return: Error(Nil))
  let map =
    simulate(robots, size, second)
    |> map_to_string(size)

  case string.contains(map, "###########") {
    True -> Ok(second)
    False -> find_xmas_tree_loop(robots, size, second + 1, max_time)
  }
}

fn safety_factor(robots: List(Robot), size size: Vec2, seconds time: Int) {
  simulate(robots, size, time)
  |> list.group(fn(x) { quadrant(x.pos, size) })
  |> dict.delete(0)
  |> dict.fold(1, fn(acc, _quadrant, robots) { acc * list.length(robots) })
}

fn simulate(robots: List(Robot), size: Vec2, time: Int) {
  list.map(robots, fn(robot) {
    let assert Ok(x) =
      int.modulo({ robot.velocity.0 * time + robot.pos.0 }, size.0)
    let assert Ok(y) =
      int.modulo({ robot.velocity.1 * time + robot.pos.1 }, size.1)

    Robot(..robot, pos: #(x, y))
  })
}

fn map_to_string(robots: List(Robot), size: Vec2) -> String {
  let lut = list.group(robots, fn(rob) { rob.pos })
  use acc, y <- list.fold(list.range(0, size.1 - 1), "")
  {
    use acc, x <- list.fold(list.range(0, size.0 - 1), acc)
    acc
    <> case dict.get(lut, #(x, y)) {
      Ok(_) -> "#"
      Error(_) -> " "
    }
  }
  <> "\n"
}

fn quadrant(pos: Vec2, size: Vec2) {
  let mx = size.0 / 2
  let my = size.1 / 2

  case pos {
    #(x, y) if x < mx && y < my -> 1
    #(x, y) if x > mx && y < my -> 2
    #(x, y) if x < mx && y > my -> 3
    #(x, y) if x > mx && y > my -> 4
    #(x, y) if x == mx || y == my -> 0
    _ -> panic as "bad quadrant"
  }
}

pub fn parse(input: String) -> List(Robot) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok([px, py, vx, vy]) =
    string.split(line, " ")
    |> list.map(string.split(_, "="))
    |> list.try_map(list.last)
    |> result.unwrap([])
    |> list.flat_map(string.split(_, ","))
    |> list.try_map(int.parse)

  Robot(pos: #(px, py), velocity: #(vx, vy))
}
