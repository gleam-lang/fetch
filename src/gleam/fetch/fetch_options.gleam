import gleam/dynamic.{type Dynamic}
import gleam/fetch/abort_signal.{type AbortSignal}

/// Gleam equivalent of JavaScript [`RequestInit`](https://developer.mozilla.org/docs/Web/API/RequestInit).
pub type FetchOptions

/// Cache options, for details see [`cache`](https://developer.mozilla.org/docs/Web/API/RequestInit#cache).
pub type Cache {
  Default
  NoStore
  Reload
  NoCache
  ForceCache
  OnlyIfCached
}

/// Credentials options, for details see [`credentials`](https://developer.mozilla.org/docs/Web/API/RequestInit#credentials).
pub type Credentials {
  CredentialsOmit
  CredentialsSameOrigin
  CredentialsInclude
}

/// Cors options, for details see [`mode`](https://developer.mozilla.org/docs/Web/API/RequestInit#mode).
pub type Cors {
  SameOrigin
  Cors
  NoCors
  Navigate
}

/// Priority options, for details see [`priority`](https://developer.mozilla.org/docs/Web/API/RequestInit#priority).
pub type Priority {
  High
  Low
  Auto
}

/// Redirect options, for details see [`redirect`](https://developer.mozilla.org/docs/Web/API/RequestInit#redirect).
pub type Redirect {
  Follow
  Error
  Manual
}

/// Creates new empty `FetchOptions` object.
///
/// Useful if more precise control over fetch is required, such as 
/// using signals, cache options and so on.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_cache(fetch_options.NoStore)
/// ```
@external(javascript, "../../gleam_fetch_ffi.mjs", "newFetchOptions")
pub fn new() -> FetchOptions

/// Sets the [`cache`](https://developer.mozilla.org/docs/Web/API/RequestInit#cache) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_cache(fetch_options.NoStore)
/// ```
pub fn set_cache(fetch_options: FetchOptions, cache: Cache) -> FetchOptions {
  set_key(
    fetch_options,
    "cache",
    dynamic.from(case cache {
      Default -> "default"
      NoStore -> "no-store"
      Reload -> "reload"
      NoCache -> "no-cache"
      ForceCache -> "force-cache"
      OnlyIfCached -> "only-if-cached"
    }),
  )
}

/// Sets the [`credentials`](https://developer.mozilla.org/docs/Web/API/RequestInit#credentials) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_credentials(fetch_options.CredentialsOmit)
/// ```
pub fn set_credentials(
  fetch_options: FetchOptions,
  credentials: Credentials,
) -> FetchOptions {
  set_key(
    fetch_options,
    "credentials",
    dynamic.from(case credentials {
      CredentialsOmit -> "omit"
      CredentialsSameOrigin -> "same-origin"
      CredentialsInclude -> "include"
    }),
  )
}

/// Sets the [`keepalive`](https://developer.mozilla.org/docs/Web/API/RequestInit#keepalive) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_keepalive(True)
/// ```
pub fn set_keepalive(
  fetch_options: FetchOptions,
  keepalive: Bool,
) -> FetchOptions {
  set_key(fetch_options, "keepalive", dynamic.from(keepalive))
}

/// Sets the [`cors`](https://developer.mozilla.org/docs/Web/API/RequestInit#mode) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_cors(fetch_options.SameOrigin)
/// ```
pub fn set_cors(fetch_options: FetchOptions, cors: Cors) -> FetchOptions {
  set_key(
    fetch_options,
    "mode",
    dynamic.from(case cors {
      SameOrigin -> "same-origin"
      Cors -> "cors"
      NoCors -> "no-cors"
      Navigate -> "navigate"
    }),
  )
}

/// Sets the [`priority`](https://developer.mozilla.org/docs/Web/API/RequestInit#priority) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_cors(fetch_options.High)
/// ```
pub fn set_priority(
  fetch_options: FetchOptions,
  priority: Priority,
) -> FetchOptions {
  set_key(
    fetch_options,
    "priority",
    dynamic.from(case priority {
      High -> "high"
      Low -> "low"
      Auto -> "auto"
    }),
  )
}

/// Sets the [`redirect`](https://developer.mozilla.org/docs/Web/API/RequestInit#redirect) option of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_redirect(fetch_options.Follow)
/// ```
pub fn set_redirect(
  fetch_options: FetchOptions,
  redirect: Redirect,
) -> FetchOptions {
  set_key(
    fetch_options,
    "redirect",
    dynamic.from(case redirect {
      Follow -> "follow"
      Error -> "error"
      Manual -> "manual"
    }),
  )
}

/// Sets the [`signal`](https://developer.mozilla.org/docs/Web/API/RequestInit#signal) of `FetchOptions`.
///
/// ```gleam
/// let options = fetch_options.new()
///   |> fetch_options.set_signal(abort_signal.abort())
/// ```
pub fn set_signal(
  fetch_options: FetchOptions,
  signal: AbortSignal,
) -> FetchOptions {
  set_key(fetch_options, "signal", dynamic.from(signal))
}

/// Generic function that sets specified option in the `FetchOptions` object.
/// 
/// In JavaScript, this object is simply represented as `{}` with no type-checking,
/// so when implementing new features, you should consult
/// [documentation](https://developer.mozilla.org/docs/Web/API/RequestInit)
/// for valid and sensible keys and values.
@external(javascript, "../../gleam_fetch_ffi.mjs", "setKeyFetchOptions")
fn set_key(
  fetch_options: FetchOptions,
  key: String,
  value: Dynamic,
) -> FetchOptions
