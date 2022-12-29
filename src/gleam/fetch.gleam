import gleam/http/request.{Request}
import gleam/http/response.{Response}
import gleam/dynamic.{Dynamic}
import gleam/javascript/promise.{Promise}

pub type FetchError {
  NetworkError(String)
  UnableToReadBody
  InvalidJsonBody
}

pub external type FetchBody

pub external type FetchRequest

pub external type FetchResponse

pub external fn raw_send(
  FetchRequest,
) -> Promise(Result(FetchResponse, FetchError)) =
  "../ffi.mjs" "raw_send"

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

pub external fn to_fetch_request(Request(String)) -> FetchRequest =
  "../ffi.mjs" "to_fetch_request"

pub external fn from_fetch_response(FetchResponse) -> Response(FetchBody) =
  "../ffi.mjs" "from_fetch_response"

pub external fn read_text_body(
  Response(FetchBody),
) -> Promise(Result(Response(String), FetchError)) =
  "../ffi.mjs" "read_text_body"

pub external fn read_json_body(
  Response(FetchBody),
) -> Promise(Result(Response(Dynamic), FetchError)) =
  "../ffi.mjs" "read_json_body"
