import gleam/fetch.{FetchError}
import gleam/http.{Get, Head, Options}
import gleam/http/response.{Response}
import gleam/http/request
import gleam/javascript/promise
import gleeunit

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
  |> promise.try_await(fetch.read_text_body)
  |> promise.await(fn(resp: Result(Response(String), FetchError)) {
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json") = response.get_header(resp, "content-type")
    assert "{\"message\":\"Hello World\"}" = resp.body
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
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json") = response.get_header(resp, "content-type")
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
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json") = response.get_header(resp, "content-type")
    assert "{\"message\":\"Hello World\"}" = resp.body
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
  assert Ok(resp) = response
  assert 200 = resp.status
  assert Ok("application/json; charset=utf-8") =
    response.get_header(resp, "content-type")
  assert "" = resp.body
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
    assert Ok(Response(status: 200, ..) as resp) = resp
    assert Ok("text/html; charset=utf-8") =
      response.get_header(resp, "content-type")
    assert "GET,HEAD,PUT,POST,DELETE,PATCH" = resp.body
    promise.resolve(Ok(Nil))
  })
}
