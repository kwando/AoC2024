import gary
import gary/array
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub fn pt_1(input: ParseResult) {
  let #(state, program) = input
  run_program(state, program).out
  |> list.map(int.to_string)
  |> string.join(",")
}

pub fn run_program(state: State, program) {
  case get_instruction(program, state.pc) {
    Ok(#(i, o)) -> {
      state
      |> run_instruction(i, o)
      |> run_program(program)
    }

    Error(..) -> State(..state, out: list.reverse(state.out))
  }
}

fn get_instruction(program, pc: Int) {
  case array.get(program, pc), array.get(program, pc + 1) {
    Ok(option.Some(i)), Ok(option.Some(o)) -> Ok(#(i, o))
    _, _ -> Error(Nil)
  }
}

pub fn run_instruction(state, instruction: Int, operand: Int) {
  case instruction {
    0 ->
      State(
        ..state,
        a: state.a / int_pow(2, read(state, operand)),
        pc: state.pc + 2,
      )

    1 ->
      State(
        ..state,
        b: int.bitwise_exclusive_or(state.b, operand),
        pc: state.pc + 2,
      )

    2 -> State(..state, b: read(state, operand) % 8, pc: state.pc + 2)

    3 ->
      case state.a {
        0 -> State(..state, pc: state.pc + 2)
        _ -> State(..state, pc: operand)
      }

    4 ->
      State(
        ..state,
        b: int.bitwise_exclusive_or(state.b, state.c),
        pc: state.pc + 2,
      )

    5 ->
      State(
        ..state,
        out: [read(state, operand) % 8, ..state.out],
        pc: state.pc + 2,
      )

    6 ->
      State(
        ..state,
        b: state.a / int_pow(2, read(state, operand)),
        pc: state.pc + 2,
      )

    7 ->
      State(
        ..state,
        c: state.a / int_pow(2, read(state, operand)),
        pc: state.pc + 2,
      )
    op -> panic as { "unknown operation: " <> int.to_string(op) }
  }
}

fn int_pow(a: Int, exp: Int) {
  let assert Ok(r) = int.power(a, int.to_float(exp))
  float.truncate(r)
}

fn read(state: State, operand: Int) {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> state.a
    5 -> state.b
    6 -> state.c
    _ -> panic
  }
}

fn is_prefix_of(prefix: List(a), source: List(a)) {
  case prefix, source {
    [], _ -> True
    [a, ..a_rest], [b, ..b_rest] if a == b -> is_prefix_of(a_rest, b_rest)
    _, _ -> False
  }
}

fn search_for_a(goal, acc, state, program) {
  use <- bool.guard(list.is_empty(acc), Error(Nil))
  let assert [next, ..rest] = acc
  let trial_quine =
    run_program(State(..state, a: next), program).out |> list.reverse
  use <- bool.guard(trial_quine == goal, Ok(next))
  case is_prefix_of(trial_quine, goal) {
    True -> {
      list.range(0, 7)
      |> list.map(fn(n) { next * 8 + n })
      |> list.append(rest)
      |> search_for_a(goal, _, state, program)
    }
    False -> search_for_a(goal, rest, state, program)
  }
}

pub fn pt_2(input: ParseResult) {
  input.1
  |> array.to_list
  |> list.map(fn(x) { option.unwrap(x, -1) })
  |> list.reverse
  |> search_for_a(list.range(0, 7), input.0, input.1)
  |> result.unwrap(-1)
}

pub type State {
  State(a: Int, b: Int, c: Int, pc: Int, out: List(Int))
}

pub type ParseResult =
  #(State, gary.ErlangArray(option.Option(Int)))

pub fn parse(input: String) -> ParseResult {
  let assert Ok(#(reg, instrs)) = string.split_once(input, "\n\n")

  let assert Ok([a, b, c]) =
    string.split(reg, "\n")
    |> list.map(string.split(_, ": "))
    |> list.try_map(list.last)
    |> result.try(fn(x) { list.try_map(x, int.parse) })

  let assert Ok(instrs) =
    instrs
    |> string.split(": ")
    |> list.last
    |> result.try(fn(x) {
      x
      |> string.split(",")
      |> list.try_map(int.parse)
    })
  let instrs =
    instrs
    |> list.map(option.Some)
    |> array.from_list(default: option.None)

  #(State(a:, b:, c:, pc: 0, out: []), instrs)
}
