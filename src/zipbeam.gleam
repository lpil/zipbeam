pub opaque type ZipBuilder {
  ZipBuilder(files: List(#(String, BitArray)))
}

/// A reference to an open zip archive, returned by `open`.
///
pub type ZipHandle

/// A file within a zip archive.
///
pub type File {
  File(path: String, size_bytes: Int)
}

pub fn new() -> ZipBuilder {
  ZipBuilder([])
}

/// Add a file to the builder, to be included in the zip archive.
///
pub fn add_file(
  builder: ZipBuilder,
  at path: String,
  containing contents: BitArray,
) -> ZipBuilder {
  ZipBuilder(files: [#(path, contents), ..builder.files])
}

/// Create a zip archive.
///
@external(erlang, "zipbeam_ffi", "create_in_memory")
pub fn create_in_memory(builder: ZipBuilder) -> BitArray

/// Open a zip archive. Returns an error if the data given could not be parsed
/// as a zip archive.
///
/// The archive must be closed with `close`.
///
/// The handle is closed if the process that originally opened the archive
/// dies.
///
@external(erlang, "zipbeam_ffi", "open")
pub fn open(zip: BitArray) -> Result(ZipHandle, Nil)

/// List the files in the zip archive, including their uncompressed sized.
///
/// Returns an error if the handle has already been closed.
///
@external(erlang, "zipbeam_ffi", "files")
pub fn files(handle: ZipHandle) -> Result(List(File), Nil)

/// Get a file from the archive.
///
/// ## Security
///
/// You must always check the size of the file with `files` before extracting a
/// file, to prevent zip-bomb attacks.
///
@external(erlang, "zipbeam_ffi", "get")
pub fn get(handle: ZipHandle, path: String) -> Result(BitArray, Nil)

/// Close the handle.
///
@external(erlang, "zipbeam_ffi", "close")
pub fn close(handle: ZipHandle) -> Nil
