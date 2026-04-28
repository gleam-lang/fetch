import gleam/fetch.{type FetchError}
import gleam/fetch/form_data
import gleam/http.{Get, Head, Options, Post}
import gleam/http/request
import gleam/http/response.{type Response, Response}
import gleam/javascript/promise
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn request_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.try_await(fetch.read_bytes_body)
  |> promise.await(fn(resp: Result(Response(BitArray), FetchError)) {
    let assert Ok(resp) = resp
    let assert 200 = resp.status
    let assert Ok("application/json") =
      response.get_header(resp, "content-type")
    let assert <<
      123,
      34,
      109,
      101,
      115,
      115,
      97,
      103,
      101,
      34,
      58,
      34,
      72,
      101,
      108,
      108,
      111,
      32,
      87,
      111,
      114,
      108,
      100,
      34,
      125,
    >> = resp.body
    promise.resolve(Ok(Nil))
  })
}

pub fn text_request_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp: Result(Response(String), FetchError)) {
    let assert Ok(resp) = resp
    let assert 200 = resp.status
    let assert Ok("application/json") =
      response.get_header(resp, "content-type")
    let assert "{\"message\":\"Hello World\"}" = resp.body
    promise.resolve(Ok(Nil))
  })
}

pub fn json_request_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.try_await(fetch.read_json_body)
  |> promise.await(fn(resp) {
    let assert Ok(resp) = resp
    let assert 200 = resp.status
    let assert Ok("application/json") =
      response.get_header(resp, "content-type")
    // // TODO: make assertions about body
    promise.resolve(Ok(Nil))
  })
}

pub fn get_request_discards_body_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.set_body("This gets dropped")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp: Result(Response(String), FetchError)) {
    let assert Ok(resp) = resp
    let assert 200 = resp.status
    let assert Ok("application/json") =
      response.get_header(resp, "content-type")
    let assert "{\"message\":\"Hello World\"}" = resp.body
    promise.resolve(Ok(Nil))
  })
}

pub fn head_request_discards_body_test() {
  let request =
    request.new()
    |> request.set_method(Head)
    |> request.set_host("postman-echo.com")
    |> request.set_path("/get")
    |> request.set_body("This gets dropped")

  use response <- promise.try_await(fetch.send(request))
  use response <- promise.await(fetch.read_text_body(response))
  let assert Ok(resp) = response
  let assert 200 = resp.status
  let assert Ok("application/json; charset=utf-8") =
    response.get_header(resp, "content-type")
  let assert "" = resp.body
  promise.resolve(Ok(Nil))
}

pub fn options_request_discards_body_test() {
  let req =
    request.new()
    |> request.set_method(Options)
    |> request.set_host("postman-echo.com")
    |> request.set_path("/get")
    |> request.set_body("This gets dropped")

  fetch.send(req)
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp) {
    let assert Ok(Response(status: 200, ..) as resp) = resp
    let assert Ok("text/html; charset=utf-8") =
      response.get_header(resp, "content-type")
    let assert "GET,HEAD,PUT,POST,DELETE,PATCH" = resp.body
    promise.resolve(Ok(Nil))
  })
}

pub fn form_data_keys_test() {
  let form_data = setup_form_data()
  form_data.keys(form_data) |> should.equal(["first-key", "second-key"])
  form_data.contains(form_data, "first-key") |> should.equal(True)
  form_data.contains(form_data, "third-key") |> should.equal(False)
  let form_data = form_data.delete(form_data, "first-key")
  form_data.keys(form_data) |> should.equal(["second-key"])
}

pub fn form_data_get_test() {
  let form_data = setup_form_data()
  form_data.get(form_data, "second-key") |> should.equal(["second-value"])
  use content <- promise.await(form_data.get_bits(form_data, "second-key"))
  content
  |> should.equal([<<"second-value":utf8>>, <<"second-value-bits":utf8>>])
  promise.resolve(Nil)
}

pub fn form_data_set_test() {
  let form_data =
    setup_form_data()
    |> form_data.set("first-key", "anything")
    |> form_data.set_bits("second-key", <<"anything":utf8>>)
  form_data.get(form_data, "first-key") |> should.equal(["anything"])
  form_data.get(form_data, "second-key") |> should.equal([])
  use fst_content <- promise.await(form_data.get_bits(form_data, "first-key"))
  use snd_content <- promise.await(form_data.get_bits(form_data, "second-key"))
  fst_content |> should.equal([<<"anything":utf8>>])
  snd_content |> should.equal([<<"anything":utf8>>])
  promise.resolve(Nil)
}

@external(javascript, "./gleam_fetch_test_ffi.mjs", "get_header")
fn get_header(request: fetch.FetchRequest, name: String) -> Result(String, Nil)

pub fn form_data_request_removes_content_type_test() {
  let req =
    request.new()
    |> request.set_method(Post)
    |> request.set_host("example.com")
    |> request.set_path("/upload")
    |> request.prepend_header(
      "content-type",
      "application/x-www-form-urlencoded",
    )
    |> request.set_body(form_data.new())

  let fetch_req = fetch.form_data_to_fetch_request(req)
  get_header(fetch_req, "content-type")
  |> should.not_equal(Ok("application/x-www-form-urlencoded"))
}

pub fn stream_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")
  use response <- promise.await(fetch.send(req))
  let assert Ok(response) = response

  let assert Ok(reader) = fetch.stream_body(response)

  use chunk <- promise.await(fetch.read_chunk(reader))
  assert chunk == Ok(option.Some(<<"{\"message\":\"Hello World\"}">>))

  use chunk <- promise.await(fetch.read_chunk(reader))
  assert chunk == Ok(option.None)

  promise.resolve(Nil)
}

fn setup_form_data() {
  form_data.new()
  |> form_data.append("first-key", "first-value")
  |> form_data.append_bits("first-key", <<"first-value-bits":utf8>>)
  |> form_data.append("second-key", "second-value")
  |> form_data.append_bits("second-key", <<"second-value-bits":utf8>>)
}

// Node only supports `redirect` option.
pub fn complex_fetch_options_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options =
    fetch.fetch_options()
    |> fetch.cache(fetch.NoStore)
    |> fetch.mode(fetch.Cors)
    |> fetch.credentials(fetch.CredentialsOmit)
    |> fetch.keepalive(True)
    |> fetch.priority(fetch.High)
    |> fetch.redirect(fetch.Follow)

  use result <- promise.await(fetch.send_options(req, options))

  let assert Ok(resp) = result
  let assert 200 = resp.status

  promise.resolve(Nil)
}

// Node doesn't support `cache` option, let's check that it passes at least.
// For further reference see:
// https://github.com/node-fetch/node-fetch#class-request
pub fn fetch_cache_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options_default =
    fetch.fetch_options()
    |> fetch.cache(fetch.Default)

  let options_no_store =
    fetch.fetch_options()
    |> fetch.cache(fetch.NoStore)

  let options_reload =
    fetch.fetch_options()
    |> fetch.cache(fetch.Reload)

  let options_no_cache =
    fetch.fetch_options()
    |> fetch.cache(fetch.NoCache)

  let options_force_cache =
    fetch.fetch_options()
    |> fetch.cache(fetch.ForceCache)

  use result_default <- promise.await(fetch.send_options(req, options_default))
  use result_no_store <- promise.await(fetch.send_options(req, options_no_store))
  use result_reload <- promise.await(fetch.send_options(req, options_reload))
  use result_no_cache <- promise.await(fetch.send_options(req, options_no_cache))
  use result_force_cache <- promise.await(fetch.send_options(
    req,
    options_force_cache,
  ))

  let assert Ok(resp) = result_default
  let assert 200 = resp.status
  let assert Ok(resp) = result_no_store
  let assert 200 = resp.status
  let assert Ok(resp) = result_reload
  let assert 200 = resp.status
  let assert Ok(resp) = result_no_cache
  let assert 200 = resp.status
  let assert Ok(resp) = result_force_cache
  let assert 200 = resp.status

  promise.resolve(Nil)
}

// Node doesn't support `credentials` option, let's check that it passes at least.
// For further reference see:
// https://github.com/node-fetch/node-fetch#class-request
pub fn fetch_credentials_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options_omit =
    fetch.fetch_options()
    |> fetch.credentials(fetch.CredentialsOmit)

  let options_same_origin =
    fetch.fetch_options()
    |> fetch.credentials(fetch.CredentialsSameOrigin)

  let options_include =
    fetch.fetch_options()
    |> fetch.credentials(fetch.CredentialsInclude)

  use result_omit <- promise.await(fetch.send_options(req, options_omit))
  use result_same_origin <- promise.await(fetch.send_options(
    req,
    options_same_origin,
  ))
  use result_include <- promise.await(fetch.send_options(req, options_include))

  let assert Ok(resp) = result_omit
  let assert 200 = resp.status
  let assert Ok(resp) = result_same_origin
  let assert 200 = resp.status
  let assert Ok(resp) = result_include
  let assert 200 = resp.status

  promise.resolve(Nil)
}

// Node doesn't support `keepalive` option, let's check that it passes at least.
// For further reference see:
// https://github.com/node-fetch/node-fetch#class-request
pub fn fetch_keepalive_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options_keepalive =
    fetch.fetch_options()
    |> fetch.keepalive(True)

  let options_no_keepalive =
    fetch.fetch_options()
    |> fetch.keepalive(False)

  use result_keepalive <- promise.await(fetch.send_options(
    req,
    options_keepalive,
  ))
  use result_no_keepalive <- promise.await(fetch.send_options(
    req,
    options_no_keepalive,
  ))

  let assert Ok(resp) = result_keepalive
  let assert 200 = resp.status
  let assert Ok(resp) = result_no_keepalive
  let assert 200 = resp.status

  promise.resolve(Nil)
}

// Node doesn't support `mode` option, let's check that it passes at least.
// For further reference see:
// https://github.com/node-fetch/node-fetch#class-request
pub fn fetch_mode_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options_same_origin =
    fetch.fetch_options()
    |> fetch.mode(fetch.SameOrigin)

  let options_cors =
    fetch.fetch_options()
    |> fetch.mode(fetch.Cors)

  let options_no_cors =
    fetch.fetch_options()
    |> fetch.mode(fetch.NoCors)

  use result_same_origin <- promise.await(fetch.send_options(
    req,
    options_same_origin,
  ))
  use result_cors <- promise.await(fetch.send_options(req, options_cors))
  use result_no_cors <- promise.await(fetch.send_options(req, options_no_cors))

  let assert Ok(resp) = result_same_origin
  let assert 200 = resp.status
  let assert Ok(resp) = result_cors
  let assert 200 = resp.status
  let assert Ok(resp) = result_no_cors
  let assert 200 = resp.status

  promise.resolve(Nil)
}

// It's difficult to test `priority` as it just increases the probability
// of finishing first
pub fn fetch_priority_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options_high =
    fetch.fetch_options()
    |> fetch.priority(fetch.High)

  let options_low =
    fetch.fetch_options()
    |> fetch.priority(fetch.Low)

  let options_auto =
    fetch.fetch_options()
    |> fetch.priority(fetch.Auto)

  use result_high <- promise.await(fetch.send_options(req, options_high))
  use result_low <- promise.await(fetch.send_options(req, options_low))
  use result_auto <- promise.await(fetch.send_options(req, options_auto))

  let assert Ok(resp) = result_high
  let assert 200 = resp.status
  let assert Ok(resp) = result_low
  let assert 200 = resp.status
  let assert Ok(resp) = result_auto
  let assert 200 = resp.status

  promise.resolve(Nil)
}

pub fn fetch_redirect_test() {
  // Initiates redirect
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("postman-echo.com")

  let options_follow =
    fetch.fetch_options()
    |> fetch.redirect(fetch.Follow)

  let options_error =
    fetch.fetch_options()
    |> fetch.redirect(fetch.Error)

  let options_manual =
    fetch.fetch_options()
    |> fetch.redirect(fetch.Manual)

  use result_follow <- promise.await(fetch.send_options(req, options_follow))
  use result_error <- promise.await(fetch.send_options(req, options_error))
  use result_manual <- promise.await(fetch.send_options(req, options_manual))

  let assert Ok(resp) = result_follow
  let assert 200 = resp.status
  let assert Error(_) = result_error
  let assert Ok(resp) = result_manual
  let assert 302 = resp.status

  promise.resolve(Nil)
}
