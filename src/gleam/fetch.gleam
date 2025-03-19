import gleam/dynamic.{type Dynamic}
import gleam/fetch/form_data.{type FormData}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/javascript/promise.{type Promise}

/// Fetch errors can be due to a network error or a runtime error. A common
/// mistake is to try to consume the response body twice, or to try to read the
/// response body as JSON while it's not a valid JSON.
///
/// Take note that a 500 response is not considered as an error: it is a
/// successful request, which indicates the server triggers an error.
pub type FetchError {
  /// A network error occured, maybe because user lost network connection,
  /// because the network took to long to answer, or because the
  /// server timed out.
  NetworkError(String)
  /// Fetch is unable to read body, for example when body as already been read
  /// once.
  UnableToReadBody
  InvalidJsonBody
}

pub type FetchBody

/// Gleam equivalent of JavaScript [`Request`](https://developer.mozilla.org/docs/Web/API/Request).
pub type FetchRequest

/// Gleam equivalent of JavaScript [`Response`](https://developer.mozilla.org/docs/Web/API/Response).
pub type FetchResponse

/// Call directly `fetch` with a `Request`, and convert the result back to Gleam.
/// Let you get back a `FetchResponse` instead of the Gleam
/// `gleam/http/response.Response` data.
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> fetch.to_fetch_request
/// |> fetch.raw_send
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "raw_send")
pub fn raw_send(a: FetchRequest) -> Promise(Result(FetchResponse, FetchError))

/// Call `fetch` with a Gleam `Request(String)`, and convert the result back
/// to Gleam. Use it to send strings or JSON stringified.
///
/// If you're looking for something more low-level, take a look at
/// [`raw_send`](#raw_send).
///
/// ```gleam
/// let my_data = json.object([#("field", "value")])
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body(json.to_string(my_data))
/// |> request.set_header("content-type", "application/json")
/// |> fetch.send
/// ```
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

/// Call `fetch` with a Gleam `Request(FormData)`, and convert the result back
/// to Gleam. Request will be sent as a `multipart/form-data`, and should be
/// decoded as-is on servers.
///
/// If you're looking for something more low-level, take a look at
/// [`raw_send`](#raw_send).
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body({
///   form_data.new()
///   |> form_data.append("key", "value")
/// })
/// |> fetch.send_form_data
/// ```
pub fn send_form_data(
  request: Request(FormData),
) -> Promise(Result(Response(FetchBody), FetchError)) {
  request
  |> form_data_to_fetch_request
  |> raw_send
  |> promise.try_await(fn(resp) {
    promise.resolve(Ok(from_fetch_response(resp)))
  })
}

/// Call `fetch` with a Gleam `Request(FormData)`, and convert the result back
/// to Gleam. Binary will be sent as-is, and you probably want a proper
/// content-type added.
///
/// If you're looking for something more low-level, take a look at
/// [`raw_send`](#raw_send).
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body(<<"data">>)
/// |> request.set_header("content-type", "application/octet-stream")
/// |> fetch.send_form_data
/// ```
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

/// Convert a Gleam `Request(String)` to a JavaScript
/// [`Request`](https://developer.mozilla.org/docs/Web/API/Request), where
/// `body` is a string.
///
/// Can be used in conjuction with `raw_send`, or when you need to reuse your
/// `Request` in JavaScript FFI.
///
/// ```gleam
/// let request =
///   request.new()
///   |> request.set_host("example.com")
///   |> request.set_path("/example")
/// fetch.to_fetch_request(request)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "to_fetch_request")
pub fn to_fetch_request(a: Request(String)) -> FetchRequest

/// Convert a Gleam `Request(FormData)` to a JavaScript
/// [`Request`](https://developer.mozilla.org/docs/Web/API/Request), where
/// `body` is a JavaScript `FormData` object.
///
/// Can be used in conjuction with `raw_send`, or when you need to reuse your
/// `Request` in JavaScript FFI.
///
/// ```gleam
/// let request =
///   request.new()
///   |> request.set_host("example.com")
///   |> request.set_path("/example")
///   |> request.set_body({
///     form_data.new()
///     |> form_data.append("key", "value")
///   })
/// fetch.form_data_to_fetch_request(request)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "form_data_to_fetch_request")
pub fn form_data_to_fetch_request(a: Request(FormData)) -> FetchRequest

/// Convert a Gleam `Request(BitArray)` to a JavaScript
/// [`Request`](https://developer.mozilla.org/docs/Web/API/Request), where
/// `body` is a JavaScript `UInt8Array` object.
///
/// Can be used in conjuction with `raw_send`, or when you need to reuse your
/// `Request` in JavaScript FFI.
///
/// ```gleam
/// let request =
///   request.new()
///   |> request.set_host("example.com")
///   |> request.set_path("/example")
///   |> request.set_body(<<"data">>)
/// fetch.bitarray_request_to_fetch_request(request)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "bitarray_request_to_fetch_request")
pub fn bitarray_request_to_fetch_request(a: Request(BitArray)) -> FetchRequest

/// Convert a JavaScript [`Response`](https://developer.mozilla.org/docs/Web/API/Response)
/// into a Gleam `Response(FetchBody)`. Can be used with the result of
/// `raw_send`, or with some data received through the FFI.
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> fetch.to_fetch_request
/// |> fetch.raw_send
/// |> promise.map_try(fetch.from_fetch_response)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "from_fetch_response")
pub fn from_fetch_response(a: FetchResponse) -> Response(FetchBody)

/// Read a response body as a BitArray. Returns an error when the body is not a
/// valid BitArray. Because `fetch.send` returns a `Promise` and every
/// functions to read response body are also asynchronous, take care to properly
/// use `gleam/javascript/promise` to combine them.
///
/// ```gleam
/// let my_data = json.object([#("field", "value")])
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body(json.to_string(my_data))
/// |> request.set_header("content-type", "application/json")
/// |> fetch.send
/// |> promise.try_await(fetch.read_bytes_body)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "read_bytes_body")
pub fn read_bytes_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(BitArray), FetchError))

/// Read a response body as a String. Returns an error when the body is not a
/// valid String. Because `fetch.send` returns a `Promise` and every
/// functions to read response body are also asynchronous, take care to properly
/// use `gleam/javascript/promise` to combine them.
///
/// ```gleam
/// let my_data = json.object([#("field", "value")])
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body(json.to_string(my_data))
/// |> request.set_header("content-type", "application/json")
/// |> fetch.send
/// |> promise.try_await(fetch.read_text_body)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "read_text_body")
pub fn read_text_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(String), FetchError))

/// Read a response body as a JSON. Returns an error when the body is not a
/// valid String. Because `fetch.send` returns a `Promise` and every
/// functions to read response body are also asynchronous, take care to properly
/// use `gleam/javascript/promise` to combine them.
///
/// Once read, you probably want to use
/// [`gleam/dynamic/decode`](https://hexdocs.pm/gleam_stdlib/gleam/dynamic/decode.html)
/// to decode its content in proper Gleam data.
///
/// ```gleam
/// let my_data = json.object([#("field", "value")])
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_body(json.to_string(my_data))
/// |> request.set_header("content-type", "application/json")
/// |> fetch.send
/// |> promise.try_await(fetch.read_json_body)
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "read_json_body")
pub fn read_json_body(
  a: Response(FetchBody),
) -> Promise(Result(Response(Dynamic), FetchError))
