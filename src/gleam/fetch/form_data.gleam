pub type FormData

@external(javascript, "../../gleam_fetch_ffi.mjs", "newFormData")
pub fn new() -> FormData

@external(javascript, "../../gleam_fetch_ffi.mjs", "appendFormData")
pub fn append(form_data: FormData, key: String, value: String) -> FormData

@external(javascript, "../../gleam_fetch_ffi.mjs", "appendBitsFormData")
pub fn append_bits(
  form_data: FormData,
  key: String,
  value: BitArray,
) -> FormData

@external(javascript, "../../gleam_fetch_ffi.mjs", "setFormData")
pub fn set(form_data: FormData, key: String, value: String) -> FormData

@external(javascript, "../../gleam_fetch_ffi.mjs", "setBitsFormData")
pub fn set_bits(form_data: FormData, key: String, value: BitArray) -> FormData
