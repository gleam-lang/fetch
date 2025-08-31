/// Gleam equivalent of JavaScript [`AbortSignal`](https://developer.mozilla.org/docs/Web/API/AbortSignal).
pub type AbortSignal

/// Returns whether signal has already been aborted.
/// 
/// ```gleam
/// let aborted = abort_controller.new()
///   |> abort_controller.get_controller_signal
///   |> abort_signal.get_aborted
/// ```
/// 
/// Equivalent to JavaScript [`aborted`](https://developer.mozilla.org/docs/Web/API/AbortSignal/aborted).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalAborted")
pub fn get_aborted(signal: AbortSignal) -> Bool

/// Returns the specified reason for abortion.
/// 
/// Default reason is "AbortError".
/// 
/// ```gleam
/// let reason = abort_controller.new()
///   |> abort_controller.get_controller_signal
///   |> abort_signal.get_reason
/// ```
/// 
/// Equivalent to JavaScript [`reason`](https://developer.mozilla.org/docs/Web/API/AbortSignal/reason).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalReason")
pub fn get_reason(signal: AbortSignal) -> String

/// Creates new signal that is already aborted.
/// 
/// The default abort reason is "AbortError".
/// 
/// ```gleam
/// let signal = abort_signal.abort()
/// 
/// let req = request.new()
///   |> request.set_host("example.com")
///   |> request.set_path("/example")
/// 
/// let options =
///   fetch_options.new()
///   |> fetch_options.set_signal(signal)
/// 
/// fetch.send_with(req, options)
/// ```
/// 
/// Similar to JavaScript [`abort`](https://developer.mozilla.org/docs/Web/API/AbortController/abort).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalAbort")
pub fn abort() -> AbortSignal

/// Creates new signal that is already aborted with specified reason.
/// 
/// ```gleam
/// let signal = abort_signal.abort_with("Cancelled")
/// 
/// let req = request.new()
///   |> request.set_host("example.com")
///   |> request.set_path("/example")
/// 
/// let options =
///   fetch_options.new()
///   |> fetch_options.set_signal(signal)
/// 
/// fetch.send_with(req, options)
/// ```
/// 
/// Similar to JavaScript [`abort`](https://developer.mozilla.org/docs/Web/API/AbortController/abort).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalAbort")
pub fn abort_with(reason: String) -> AbortSignal

/// Creates new signal composed of multiple other signals.
/// 
/// This is useful, if you want to have a request that can either
/// timeout or be cancelled by the user.
/// 
/// ```gleam
/// let signal =
///   abort_controller.new()
///   |> abort_controller.get_controller_signal
/// 
/// let multi_signal = abort_signal.from([signal, abort_signal.timeout(500)])
/// ```
/// 
/// Equivalent to JavaScript ['any'](https://developer.mozilla.org/docs/Web/API/AbortSignal/any_static).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalFrom")
pub fn from(signals: List(AbortSignal)) -> AbortSignal

/// Creates new signal that will error on timeout after specified time.
/// 
/// The reason message is "TimeoutError", on unsupported browsers "TypeError".
/// 
/// ```gleam
/// let signal = abort_signal.timeout(500)
/// ```
/// 
/// Equivalent to JavaScript ['timeout'](https://developer.mozilla.org/docs/Web/API/AbortSignal/timeout_static).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortSignalTimeout")
pub fn timeout(time: Int) -> AbortSignal
