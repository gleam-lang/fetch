import gleam/fetch/abort_signal.{type AbortSignal}

/// Gleam equivalent of JavaScript [`AbortController`](https://developer.mozilla.org/docs/Web/API/AbortController).
pub type AbortController

/// `AbortController` allows aborting fetch request using `AbortSignal` with 
/// specified reason.
///
/// The signal has to obtained using `get_controller_signal`, then the fetch can
/// be aborted commonly, either by user action or by timeout.
///
/// Equivalent to JavaScript [`AbortController`](https://developer.mozilla.org/docs/Web/API/AbortController).
@external(javascript, "../../gleam_fetch_ffi.mjs", "newAbortController")
pub fn new() -> AbortController

/// Aborts the signal bound to the controller.
///
/// The default abort reason is "AbortError".
/// 
/// ```gleam
/// let controller = abort_controller.new()
/// controller
/// |> abort_controller.abort()
/// ```
///
/// Similar to JavaScript [`abort`](https://developer.mozilla.org/docs/Web/API/AbortController/abort).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortControllerAbort")
pub fn abort(abort_controller: AbortController) -> Nil

/// Aborts the signal bound to the controller with specified reason.
///
/// ```gleam
/// let controller = abort_controller.new()
/// controller
/// |> abort_controller.abort_with("Cancelled operation")
/// ```
///
/// Similar to JavaScript [`abort`](https://developer.mozilla.org/docs/Web/API/AbortController/abort).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortControllerAbort")
pub fn abort_with(abort_controller: AbortController, reason: String) -> Nil

/// Returns the associated ['AbortSignal'](https://developer.mozilla.org/docs/Web/API/AbortSignal).
/// 
/// The signal is commonly then passed to the `FetchOptions`.
///
/// ```gleam
/// let signal = abort_controller.new().get_controller_signal()
/// let options = fetch_options.new()
///   |> fetch_options.set_signal(signal)
/// ```
///
/// Equivalent to JavaScript [`signal`](https://developer.mozilla.org/docs/Web/API/AbortController/signal).
@external(javascript, "../../gleam_fetch_ffi.mjs", "abortControllerGetSignal")
pub fn get_controller_signal(abort_controller: AbortController) -> AbortSignal
