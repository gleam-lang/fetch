import gleam/http.{Request, Response}
import gleam/javascript/promise.{Promise}
import gleam/dynamic.{Dynamic}

pub type FetchError {
  NetworkError(String)
}

pub external type FetchBody

pub external fn send(
  Request(String),
) -> Promise(Result(Response(FetchBody), FetchError)) =
  "../ffi.js" "send"

pub external fn get_text_body(
  Response(FetchBody),
) -> Promise(Result(String, Nil)) =
  "../ffi.js" "get_text_body"

pub external fn get_json_body(
  Response(FetchBody),
) -> Promise(Result(Dynamic, Nil)) =
  "../ffi.js" "get_json_body"
