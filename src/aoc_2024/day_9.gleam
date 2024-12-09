import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
import gleam/string

pub type Block {
  Free(Int)
  File(id: Int, size: Int)
}

pub fn pt_1(blocks: List(Block)) {
  defragment_blocks(blocks)
  |> checksum
}

pub fn pt_2(blocks: List(Block)) {
  defragment_files(blocks)
  |> checksum
}

fn checksum(blocks: List(Block)) {
  checksum_loop(blocks, 0, 0)
}

fn checksum_loop(blocks: List(Block), index: Int, sum: Int) {
  case blocks {
    [] -> sum
    [File(size: 0, ..), ..rest] -> checksum_loop(rest, index, sum)
    [File(id:, size:), ..rest] ->
      checksum_loop([File(id, size - 1), ..rest], index + 1, sum + index * id)
    [Free(x), ..rest] -> checksum_loop(rest, index + x, sum)
  }
}

fn defragment_blocks(blocks: List(Block)) {
  defragment_blocks_loop(deque.from_list(blocks), [])
}

fn defragment_blocks_loop(disk: Deque(Block), result: List(Block)) {
  case result {
    [File(..), ..] | [] -> {
      case deque.pop_front(disk) {
        Ok(#(item, remaining)) ->
          defragment_blocks_loop(remaining, [item, ..result])
        Error(_) -> list.reverse(result)
      }
    }
    [Free(free), ..rest] -> {
      case deque.pop_back(disk) {
        // when the queue empty we are done
        Error(_) -> list.reverse(rest)
        Ok(#(Free(_), remaining)) -> defragment_blocks_loop(remaining, result)
        Ok(#(File(size:, ..) as file, remaining)) -> {
          case int.compare(size, free) {
            order.Lt ->
              defragment_blocks_loop(remaining, [
                Free(free - size),
                file,
                ..rest
              ])
            order.Eq -> defragment_blocks_loop(remaining, [file, ..rest])
            order.Gt -> {
              defragment_blocks_loop(
                remaining |> deque.push_back(File(..file, size: size - free)),
                [File(..file, size: free), ..rest],
              )
            }
          }
        }
      }
    }
  }
}

fn defragment_files(disk: List(Block)) {
  defragment_files_loop(disk, list.reverse(disk))
}

fn defragment_files_loop(disk: List(Block), options: List(Block)) {
  case options {
    [] -> disk
    [file, ..rest] -> {
      let updated_disks = insert_file(disk, file, [])
      defragment_files_loop(updated_disks, rest)
    }
  }
}

fn insert_file(disk, file, before) {
  case file, disk {
    Free(..), _ -> disk
    File(..) as a, [File(..) as b, ..rest] if a == b -> {
      list.reverse([b, ..before])
      |> list.append(rest)
    }
    File(..), [File(..) as f, ..rest] -> {
      insert_file(rest, file, [f, ..before])
    }
    File(size:, ..), [Free(free) as f, ..rest] if size > free -> {
      insert_file(rest, file, [f, ..before])
    }

    File(size:, ..) as f, [Free(free), ..rest] -> {
      list.reverse([f, ..before])
      |> list.append([Free(free - size), ..clear_file(rest, f)])
    }
    File(_, _), [] -> list.reverse(before)
  }
}

fn clear_file(blocks: List(Block), block: Block) {
  case block {
    Free(..) -> blocks
    File(size:, ..) as file -> {
      use b <- list.map(blocks)
      case file == b {
        True -> Free(size)
        False -> b
      }
    }
  }
}

fn pairs(input, result) {
  case input {
    [a, b, ..rest] -> pairs(rest, [#(a, b)])
    [] -> Ok(list.reverse(result))
    _ -> Error(Nil)
  }
}

pub fn parse(input: String) -> List(Block) {
  let assert Ok(seq) =
    string.split(input, "")
    |> list.try_map(int.parse)

  seq
  |> list.fold(#([], 0), fn(acc, value) {
    let #(items, file_id) = acc
    case items {
      [File(..), ..] -> #([Free(value), ..items], file_id)
      _ -> #([File(file_id, value), ..items], file_id + 1)
    }
  })
  |> pair.first
  |> list.reverse
}

// helper function for debugg output
pub fn blocks_to_string(blocks: List(Block)) -> String {
  list.fold(blocks, "", fn(str, block) {
    case block {
      Free(size) -> str <> string.repeat(".", size)
      File(id, size) -> str <> string.repeat(int.to_string(id), size)
    }
  })
}
