import gleeunit
import zipbeam

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn open_invalid_test() {
  assert zipbeam.open(<<>>) == Error(Nil)
}

pub fn empty_in_memory_test() {
  let zip = zipbeam.new() |> zipbeam.create_in_memory
  let assert Ok(handle) = zipbeam.open(zip)
  assert zipbeam.files(handle) == Ok([])
  assert zipbeam.close(handle) == Nil
  assert zipbeam.files(handle) == Error(Nil)
}

pub fn files_memory_test() {
  let zip =
    zipbeam.new()
    |> zipbeam.add_file("a", <<1, 2, 3>>)
    |> zipbeam.add_file("b", <<2, 3>>)
    |> zipbeam.create_in_memory
  let assert Ok(handle) = zipbeam.open(zip)
  assert zipbeam.files(handle)
    == Ok([
      zipbeam.File(path: "b", size_bytes: 2),
      zipbeam.File(path: "a", size_bytes: 3),
    ])
  assert zipbeam.get(handle, "a") == Ok(<<1, 2, 3>>)
  assert zipbeam.get(handle, "b") == Ok(<<2, 3>>)
  assert zipbeam.get(handle, "c") == Error(Nil)
  assert zipbeam.close(handle) == Nil
  assert zipbeam.get(handle, "a") == Error(Nil)
}

pub fn duplicate_paths_test() {
  let zip =
    zipbeam.new()
    |> zipbeam.add_file("a", <<1>>)
    |> zipbeam.add_file("a", <<2, 3, 4, 5>>)
    |> zipbeam.add_file("b", <<2, 3>>)
    |> zipbeam.add_file("c", <<2, 3, 4>>)
    |> zipbeam.create_in_memory
  let assert Ok(handle) = zipbeam.open(zip)
  assert zipbeam.files(handle)
    == Ok([
      zipbeam.File(path: "c", size_bytes: 3),
      zipbeam.File(path: "b", size_bytes: 2),
      zipbeam.File(path: "a", size_bytes: 4),
      zipbeam.File(path: "a", size_bytes: 1),
    ])
  assert zipbeam.get(handle, "a") == Ok(<<2, 3, 4, 5>>)
  assert zipbeam.get(handle, "b") == Ok(<<2, 3>>)
  assert zipbeam.get(handle, "c") == Ok(<<2, 3, 4>>)
  assert zipbeam.get(handle, "d") == Error(Nil)
  assert zipbeam.close(handle) == Nil
}
