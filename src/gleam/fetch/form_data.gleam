//// `FormData` are common structures on the web to send both string data, and
//// blob. They're the default standard when using a `<form>` on a web page,
//// and they're still a simple way to send files from a frontend to a backend.
////
//// To simplify management of form data, JavaScript exposes a structure called
//// `FormData` that handles all the complicated details for you. JavaScript
//// `FormData` are compatible with every standards functions, like `fetch` or
//// `xmlHttpRequest`.
////
//// To maximise compatibility between JavaScript and Gleam, `gleam_fetch`
//// exposes bindings to JavaScript
//// [`FormData`](https://developer.mozilla.org/docs/Web/API/FormData).

import gleam/javascript/promise.{type Promise}

/// Form data represents form fields and their values, as a set of key/value
/// pairs. Keys are always strings, while values can be either strings or blob.
/// Form data can be used in conjuction with `fetch`, and uses the same format a
/// form would use with the encoding type were set to `"multipart/form-data"`.
/// Form data can have multiple values for a same key, and those values can be
/// of any type (string or blob).
///
/// `FormData` are bindings on native JavaScript
/// [`FormData`](https://developer.mozilla.org/docs/Web/API/FormData) object.
/// `FormData` can easily be manipulated with the corresponding functions that
/// ensure correct conversions between JavaScript & Gleam.
pub type FormData

/// Create a new empty `FormData`.
@external(javascript, "../../gleam_fetch_ffi.mjs", "newFormData")
pub fn new() -> FormData

/// Append a key/string pair.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append("key1", "value2")
/// |> form_data.append("key2", "value1")
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "appendFormData")
pub fn append(form_data: FormData, key: String, value: String) -> FormData

/// Append a key/bitarray pair.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append_bits("key1", <<"value1">>)
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.append_bits("key2", <<"value1">>)
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "appendBitsFormData")
pub fn append_bits(
  form_data: FormData,
  key: String,
  value: BitArray,
) -> FormData

/// Set key/string pair, and replace any existing value for the specified key.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.set("key1", "value3")
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "setFormData")
pub fn set(form_data: FormData, key: String, value: String) -> FormData

/// Set key/bitarray pair, and replace any existing value for the specified key.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.set_bits("key1", <<"value3">>)
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "setBitsFormData")
pub fn set_bits(form_data: FormData, key: String, value: BitArray) -> FormData

/// Remove a key and all its existing values.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.delete("key1")
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "deleteFormData")
pub fn delete(form_data: FormData, key: String) -> FormData

/// Get String values associated with a key. If you're looking to also get
/// binary values, take a look at [`get_bits`](#get_bits).
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.get("key1")
/// // -> ["value1"]
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "getFormData")
pub fn get(form_data: FormData, key: String) -> List(String)

/// Get all values associated with a key, whether they're String or BitArray.
/// Be careful, due to the nature of `FormData`, reading the blobs requires
/// a `Promise`.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append_bits("key1", <<"value2">>)
/// |> form_data.get_bits("key1")
/// // -> promise.resolve([<<"value1">>, <<"value2">>])
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "getBitsFormData")
pub fn get_bits(form_data: FormData, key: String) -> Promise(List(BitArray))

/// Read if the key exists in the data.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.contains("key1")
/// // -> True
///
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.contains("key2")
/// // -> False
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "hasFormData")
pub fn contains(form_data: FormData, key: String) -> Bool

/// Returns all keys present in the data.
///
/// ```gleam
/// form_data.new()
/// |> form_data.append("key1", "value1")
/// |> form_data.append("key2", "value2")
/// |> form_data.keys
/// // -> ["key1", "key2"]
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "keysFormData")
pub fn keys(form_data: FormData) -> List(String)
