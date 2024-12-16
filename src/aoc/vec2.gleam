pub type Vec2 =
  #(Int, Int)

pub fn rotate90(vec: Vec2) {
  #(-vec.1, vec.0)
}

pub fn rotate90ccw(vec: Vec2) {
  #(vec.1, -vec.0)
}

pub fn translate(v: Vec2, d: Vec2) -> Vec2 {
  #(v.0 + d.0, v.1 + d.1)
}

pub fn multiply(v1: Vec2, v2: Vec2) {
  #(v1.0 * v2.0, v1.1 * v2.1)
}

pub fn within_bounds(position pos: Vec2, lower lower: Vec2, upper upper: Vec2) {
  let #(x, y) = pos
  x >= lower.0 && x <= upper.0 && y >= lower.1 && y <= upper.1
}
