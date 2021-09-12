import gleam/http.{Request, Response}
import gleam/javascript/promise.{Promise}
import gleam/dynamic.{Dynamic}

pub type FetchError {
  NetworkError(String)
  UnableToReadBody
  InvalidJsonBody
}

pub external type FetchBody

pub external fn send(
  Request(String),
) -> Promise(Result(Response(FetchBody), FetchError)) =
  "../ffi.js" "send"

pub external fn read_text_body(
  Response(FetchBody),
) -> Promise(Result(Response(String), FetchError)) =
  "../ffi.js" "read_text_body"

pub external fn read_json_body(
  Response(FetchBody),
) -> Promise(Result(Response(Dynamic), FetchError)) =
  "../ffi.js" "read_json_body"
