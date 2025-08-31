import gleam/fetch.{type FetchError}
import gleam/fetch/abort_controller
import gleam/fetch/abort_signal
import gleam/fetch/fetch_options
import gleam/fetch/form_data
import gleam/http.{Get, Head, Options}
import gleam/http/request
import gleam/http/response.{type Response, Response}
import gleam/javascript/promise
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

fn setup_form_data() {
  form_data.new()
  |> form_data.append("first-key", "first-value")
  |> form_data.append_bits("first-key", <<"first-value-bits":utf8>>)
  |> form_data.append("second-key", "second-value")
  |> form_data.append_bits("second-key", <<"second-value-bits":utf8>>)
}

pub fn abort_controller_test() {
  let controller = abort_controller.new()
  controller
  |> abort_controller.abort()

  let signal =
    controller
    |> abort_controller.get_controller_signal()

  let assert True = abort_signal.get_aborted(signal)
  let assert "AbortError" = abort_signal.get_reason(signal)
}

pub fn abort_controller_reason_test() {
  let controller = abort_controller.new()
  controller
  |> abort_controller.abort_with("User error")

  let signal =
    controller
    |> abort_controller.get_controller_signal()

  let assert True = abort_signal.get_aborted(signal)
  let assert "User error" = abort_signal.get_reason(signal)
}

pub fn abort_one_of_signals_test() {
  let signal =
    abort_controller.new()
    |> abort_controller.get_controller_signal

  let multi_signal = abort_signal.from([signal, abort_signal.abort()])

  let assert False = abort_signal.get_aborted(signal)
  let assert True = abort_signal.get_aborted(multi_signal)
  let assert "AbortError" = abort_signal.get_reason(multi_signal)
}

pub fn abort_one_of_signals_with_reason_test() {
  let signal =
    abort_controller.new()
    |> abort_controller.get_controller_signal

  let multi_signal =
    abort_signal.from([signal, abort_signal.abort_with("Failing")])

  let assert False = abort_signal.get_aborted(signal)
  let assert True = abort_signal.get_aborted(multi_signal)
  let assert "Failing" = abort_signal.get_reason(multi_signal)
}

pub fn abort_timeout_signal_test() {
  // This should instantly timeout.
  let signal = abort_signal.timeout(0)

  let req =
    request.new()
    |> request.set_host("example.com")
    |> request.set_path("/example")

  let options =
    fetch_options.new()
    |> fetch_options.set_signal(signal)

  use result <- promise.await(fetch.send_with(req, options))

  let assert Error(_) = result
  let assert True = abort_signal.get_aborted(signal)
  let assert "TimeoutError" = abort_signal.get_reason(signal)
  promise.resolve(Nil)
}

pub fn abort_fetch_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let controller = abort_controller.new()

  let signal = controller |> abort_controller.get_controller_signal

  let options =
    fetch_options.new()
    |> fetch_options.set_signal(signal)
    |> fetch_options.set_cache(fetch_options.NoStore)

  abort_controller.abort(controller)
  use result <- promise.await(fetch.send_with(req, options))

  let assert Error(_) = result
  promise.resolve(Nil)
}

pub fn complex_fetch_options_test() {
  let req =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  let options =
    fetch_options.new()
    |> fetch_options.set_cache(fetch_options.NoStore)
    |> fetch_options.set_cors(fetch_options.Cors)
    |> fetch_options.set_credentials(fetch_options.CredentialsOmit)
    |> fetch_options.set_keepalive(True)
    |> fetch_options.set_priority(fetch_options.High)
    |> fetch_options.set_redirect(fetch_options.Follow)

  use result <- promise.await(fetch.send_with(req, options))
  let assert Ok(_) = result
  promise.resolve(Nil)
}
