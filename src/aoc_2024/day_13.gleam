import aoc/vec2
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/result
import gleam/string

pub type Game {
  Game(a: vec2.Vec2, b: vec2.Vec2, price: vec2.Vec2)
}

pub fn parse(input: String) -> List(Game) {
  let assert Ok(button_pattern) =
    regexp.from_string("X=?\\+?(-?\\d+),\\s*Y=?\\+?(-?\\d+)")
  {
    use block <- list.map(string.split(input, "\n\n"))
    let assert [[ax, ay], [bx, by], [tx, ty]] =
      regexp.scan(button_pattern, block)
      |> list.map(fn(line) {
        list.map(line.submatches, fn(opt) {
          let assert option.Some(v) = opt
          let assert Ok(v) = int.parse(v)
          v
        })
      })
    Game(a: #(ax, ay), b: #(bx, by), price: #(tx, ty))
  }
}

pub fn pt_1(input: List(Game)) {
  list.map(input, tokens)
  |> result.partition
  |> pair.first
  |> int.sum
}

pub fn pt_2(input: List(Game)) {
  input
  |> list.map(fn(x) {
    Game(
      ..x,
      price: vec2.translate(x.price, #(10_000_000_000_000, 10_000_000_000_000)),
    )
  })
  |> list.map(tokens)
  |> result.partition
  |> pair.first
  |> int.sum
}

fn tokens(game: Game) {
  // px = c*ax + d*bx
  // py = c*ay + d*by
  //
  // px - d*bx = c*ax
  // py - d*by = c*ay
  //
  // (px - d*bx) / ax = c
  // (py - d*by) / ay = c
  //
  // (px - d*bx) / ax = (py - d*by) / ay
  //
  // ay(px - d*bx) = ax(py - d*by)
  //
  // ay*px - d*bx*ay = ax*py - d*by*ax
  //
  // ay*px - ax*py = d*(bx*ay - by*ax)
  // d = (ay*px - ax*py)/(bx*ay - by*ax)
  //
  // px - d*bx = c*ax
  // (px - d*bx)/ax = c
  //
  let #(ax, ay) = game.a
  let #(bx, by) = game.b
  let #(px, py) = game.price

  let d = { ay * px - ax * py } / { bx * ay - by * ax }
  let c = { px - d * bx } / ax

  case #(c * ax + d * bx, c * ay + d * by) == game.price {
    True -> Ok(3 * c + d)
    False -> Error(Nil)
  }
}
