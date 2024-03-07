import gleam/fetch.{type FetchError}
import gleam/http.{Get, Head, Options}
import gleam/http/response.{type Response, Response}
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
