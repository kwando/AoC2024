pub type Vec2 =
  #(Int, Int)

pub fn rotate90(vec: Vec2) {
  #(-vec.1, vec.0)
}

pub fn translate(v: Vec2, d: Vec2) -> Vec2 {
  #(v.0 + d.0, v.1 + d.1)
}
