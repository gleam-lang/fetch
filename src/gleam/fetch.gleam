import gleam/http.{Request, Response}
import gleam/javascript/promise.{Promise}

pub type FetchError {
  NetworkError(String)
}

pub external type FetchBody

pub external fn send(
  Request(String),
) -> Promise(Result(Response(FetchBody), FetchError)) =
  "../ffi.js" "send"
