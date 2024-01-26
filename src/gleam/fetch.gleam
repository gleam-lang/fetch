import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/dynamic.{type Dynamic}
import gleam/javascript/promise.{type Promise}

pub type FetchError {
  NetworkError(String)
  UnableToReadBody
  InvalidJsonBody
}

pub type FetchBody

pub type FetchRequest

pub type FetchRequestOptions

pub type FetchResponse

@external(javascript, "../ffi.mjs", "raw_send")
pub fn raw_send(a: FetchRequest) -> Promise(Result(FetchResponse, FetchError))

@external(javascript, "../ffi.mjs", "raw_send_with_options")
pub fn raw_send_with_options(
  a: FetchRequest,
  b: FetchRequestOptions,
) -> Promise(Result(FetchResponse, FetchError))

pub fn send(
  request: Request(String),
) -> Promise(Result(Response(FetchBody), FetchError)) {
  request
  |> to_fetch_request
  |> raw_send
  |> promise.try_await(fn(resp) {
    promise.resolve(Ok(from_fetch_response(resp)))
  })
}

@external(javascript, "../ffi.mjs", "to_fetch_request")
pub fn to_fetch_request(a: Request(String)) -> FetchRequest

@external(javascript, "../ffi.mjs", "from_fetch_response")
pub fn from_fetch_response(a: FetchResponse) -> Response(FetchBody)

@external(javascript, "../ffi.mjs", "read_text_body")
pub fn read_text_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(String), FetchError))

@external(javascript, "../ffi.mjs", "read_json_body")
pub fn read_json_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(Dynamic), FetchError))

@external(javascript, "../ffi.mjs", "make_options")
pub fn make_options() -> FetchRequestOptions

@external(javascript, "../ffi.mjs", "update_options")
fn update_options(
  a: FetchRequestOptions,
  key: String,
  value: Dynamic,
) -> FetchRequestOptions

pub type CredentialsOption {
  Include
  SameOrigin
  Omit
}

pub fn with_credentials(
  o: FetchRequestOptions,
  v: CredentialsOption,
) -> FetchRequestOptions {
  let encoded_value = case v {
    Include -> "include"
    SameOrigin -> "same-origin"
    Omit -> "omit"
  }
  update_options(o, "credentials", dynamic.from(encoded_value))
}
