# zipbeam

Bindings to Erlang's zip module.

[![Package Version](https://img.shields.io/hexpm/v/zipbeam)](https://hex.pm/packages/zipbeam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/zipbeam/)

```sh
gleam add zipbeam@1
```
```gleam
import zipbeam

pub fn create_zip() -> BitArray {
  // Create a zip archive with a couple of files in it
  zipbeam.new()
  |> zipbeam.add_file("a", <<1, 2, 3>>)
  |> zipbeam.add_file("b", <<2, 3>>)
  |> zipbeam.create_in_memory
}

pub fn open_zip(zip: BitArray) -> Nil {
  // Open the zip archives
  let assert Ok(handle) = zipbeam.open(zip)

  // List the files inside. You must always check they are the size you expect
  // before extracting the content, to prevent zip-bomb attacks.
  assert zipbeam.files(handle)
    == Ok([
      zipbeam.File(path: "nubi.jpg", size_bytes: 12_440),
      zipbeam.File(path: "oshii.jpg", size_bytes: 20_278),
    ])

  // Get files
  let assert Ok(_data) = zipbeam.get(handle, "oshii.jpg")
}
```

Documentation can be found at <https://hexdocs.pm/zipbeam>.
