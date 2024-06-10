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

pub type FetchResponse

@external(javascript, "../gleam_fetch_ffi.mjs", "raw_send")
pub fn raw_send(a: FetchRequest) -> Promise(Result(FetchResponse, FetchError))

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

pub fn send_bits(
  request: Request(BitArray),
) -> Promise(Result(Response(FetchBody), FetchError)) {
  request
  |> bitarray_request_to_fetch_request
  |> raw_send
  |> promise.try_await(fn(resp) {
    promise.resolve(Ok(from_fetch_response(resp)))
  })
}

@external(javascript, "../gleam_fetch_ffi.mjs", "to_fetch_request")
pub fn to_fetch_request(a: Request(String)) -> FetchRequest

@external(javascript, "../gleam_fetch_ffi.mjs", "bitarray_request_to_fetch_request")
pub fn bitarray_request_to_fetch_request(a: Request(BitArray)) -> FetchRequest

@external(javascript, "../gleam_fetch_ffi.mjs", "from_fetch_response")
pub fn from_fetch_response(a: FetchResponse) -> Response(FetchBody)

@external(javascript, "../gleam_fetch_ffi.mjs", "read_bytes_body")
pub fn read_bytes_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(BitArray), FetchError))

@external(javascript, "../gleam_fetch_ffi.mjs", "read_text_body")
pub fn read_text_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(String), FetchError))

@external(javascript, "../gleam_fetch_ffi.mjs", "read_json_body")
pub fn read_json_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(Dynamic), FetchError))
