import aoc_2024/day_17
import gleeunit/should

pub fn example_1_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 0
  Register B: 0
  Register C: 9

  Program: 2,6",
    )

  day_17.run_program(state, progam).b
  |> should.equal(1)
}

pub fn example_2_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 10
  Register B: 0
  Register C: 0

  Program: 5,0,5,1,5,4",
    )

  day_17.run_program(state, progam).out
  |> should.equal([0, 1, 2])
}

pub fn example_3_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 2024
  Register B: 0
  Register C: 0

  Program: 0,1,5,4,3,0",
    )

  let state = day_17.run_program(state, progam)

  state.out
  |> should.equal([4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0])

  state.a
  |> should.equal(0)
}

pub fn example_4_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 0
  Register B: 29
  Register C: 0

  Program: 1,7",
    )

  let state = day_17.run_program(state, progam)

  state.b
  |> should.equal(26)
}

pub fn example_5_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 0
  Register B: 2024
  Register C: 43690

  Program: 4,0",
    )

  let state = day_17.run_program(state, progam)

  state.b
  |> should.equal(44_354)
}

pub fn example_full_test() {
  let #(state, progam) =
    day_17.parse(
      "Register A: 729
      Register B: 0
      Register C: 0

      Program: 0,1,5,4,3,0",
    )

  let state = day_17.run_program(state, progam)

  state.out
  |> should.equal([4, 6, 3, 5, 6, 3, 5, 2, 1, 0])
}
