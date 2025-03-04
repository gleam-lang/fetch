import gleam/fetch.{type FetchError}
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
  content |> should.equal([<<"second-value":utf8>>])
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
  fst_content |> should.equal([])
  snd_content |> should.equal([<<"anything":utf8>>])
  promise.resolve(Nil)
}

fn setup_form_data() {
  form_data.new()
  |> form_data.append("first-key", "first-value")
  |> form_data.append_bits("first-key", <<"first-value":utf8>>)
  |> form_data.append("second-key", "second-value")
  |> form_data.append_bits("second-key", <<"second-value":utf8>>)
}
