import gleam/dynamic.{type Dynamic}
import gleam/fetch/form_data.{type FormData}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/javascript/promise.{type Promise}
import gleam/list
import gleam/option.{type Option, None, Some}

/// Fetch errors can be due to a network error or a runtime error. A common
/// mistake is to try to consume the response body twice, or to try to read the
/// response body as JSON while it's not a valid JSON.
///
/// Take note that a 500 response is not considered as an error: it is a
/// successful request, which indicates the server triggers an error.
pub type FetchError {
  /// A network error occurred, maybe because user lost network connection,
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

/// Reference to a [`ReadableStreamDefaultReader`](https://developer.mozilla.org/docs/Web/API/ReadableStreamDefaultReader).
/// Use [`bytes_reader`](#bytes_reader) to get a reader from a [`FetchBody`](#FetchBody),
/// Pull from the reader with [`next_bytes`](#next_bytes).
///
/// The stream is locked to until the body is fully consumed or the reader is garbage collected.
/// Attempting to acquire a second reader from the same response body will return an `Error`.
pub type BytesReader

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
/// Can be used in conjunction with `raw_send`, or when you need to reuse your
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
/// Can be used in conjunction with `raw_send`, or when you need to reuse your
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
/// Can be used in conjunction with `raw_send`, or when you need to reuse your
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

/// Get a [`BytesReader`](#BytesReader) for a responses body.
/// Returns an error if the body has already been consumed or a reader has already been acquired.
///
/// Use [`next_bytes`](#next_bytes) to pull individual chunks.
/// Prefer [`stream_bytes_body`](#stream_bytes_body) that exposes an API to fold over all chunks.
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> fetch.send
/// |> promise.try_await(fn(response) {
///   case fetch.bytes_reader(response) {
///     Error(e) -> promise.resolve(Error(e))
///     Ok(reader) ->
///       fetch.stream_bytes(reader, <<>>, fn(acc, chunk) {
///         promise.resolve(list.Continue(bit_array.append(acc, chunk)))
///       })
///   }
/// })
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "bytes_reader")
pub fn bytes_reader(
  response: Response(FetchBody),
) -> Result(BytesReader, FetchError)

/// Pull the next chunk from a [`BytesReader`](#BytesReader).
///
/// Returns:
/// - `Ok(Some(bytes))` — a chunk was read successfully
/// - `Ok(None)` — the stream is exhausted
/// - `Error(UnableToReadBody)` — the stream errored
///
/// For most use cases, prefer [`stream_bytes`](#stream_bytes) which handles
/// the loop for you. Use `next_bytes` directly when you need fine-grained
/// control over chunk processing, for example to pause between chunks or
/// process them conditionally.
///
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> fetch.send
/// |> promise.try_await(fn(response) {
///   let assert Ok(reader) = fetch.bytes_reader(response)
///   fetch.next_bytes(reader)
/// })
/// |> promise.map(fn(result) {
///   case result {
///     Ok(Some(bytes)) -> // process chunk
///     Ok(None) -> // stream done
///     Error(e) -> // handle error
///   }
/// })
/// ```
@external(javascript, "../gleam_fetch_ffi.mjs", "next_bytes")
pub fn next_bytes(
  reader: BytesReader,
) -> Promise(Result(Option(BitArray), FetchError))

/// Stream the body as chunks of bytes to the given callback function.
/// The returned promise will complete when the body has finished streaming.
///
/// Any error in streaming the body is reported as a UnableToReadBody failure.
///
/// For example count total bytes streamed.
/// ```gleam
/// request.new()
/// |> request.set_host("example.com")
/// |> request.set_path("/example")
/// |> request.set_header("content-type", "application/json")
/// |> fetch.send
/// |> promise.try_await(fetch.stream_bytes_body(0, fn(count, chunk) {
///   promise.resolve(list.Continue(count + bit_array.byte_size(chunk)))
/// }))
/// ```
pub fn stream_bytes_body(
  response: Response(FetchBody),
  acc: a,
  callback: fn(a, BitArray) -> Promise(list.ContinueOrStop(a)),
) -> Promise(Result(a, FetchError)) {
  case bytes_reader(response) {
    Ok(reader) -> do_stream_bytes(reader, acc, callback)
    Error(reason) -> promise.resolve(Error(reason))
  }
}

fn do_stream_bytes(
  reader: BytesReader,
  acc: a,
  callback: fn(a, BitArray) -> Promise(list.ContinueOrStop(a)),
) -> Promise(Result(a, FetchError)) {
  use chunk <- promise.try_await(next_bytes(reader))
  case chunk {
    None -> promise.resolve(Ok(acc))
    Some(bytes) -> {
      use return <- promise.await(callback(acc, bytes))
      case return {
        list.Stop(value) -> promise.resolve(Ok(value))
        list.Continue(acc) -> do_stream_bytes(reader, acc, callback)
      }
    }
  }
}
