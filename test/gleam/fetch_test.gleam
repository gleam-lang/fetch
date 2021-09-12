import gleam/fetch.{FetchBody, FetchError}
import gleam/http.{Get, Head, Options, Response}
import gleam/list
import gleam/javascript/promise

pub fn request_test() {
  let req =
    http.default_req()
    |> http.set_method(Get)
    |> http.set_host("test-api.service.hmrc.gov.uk")
    |> http.set_path("/hello/world")
    |> http.prepend_req_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.then(fn(resp: Result(Response(FetchBody), FetchError)) {
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json") = http.get_resp_header(resp, "content-type")
    fetch.get_text_body(resp)
  })
  |> promise.map(fn(x) { assert Ok("{\"message\":\"Hello World\"}") = x })
}

pub fn get_request_discards_body_test() {
  let req =
    http.default_req()
    |> http.set_method(Get)
    |> http.set_host("test-api.service.hmrc.gov.uk")
    |> http.set_path("/hello/world")
    |> http.set_req_body("This gets dropped")
    |> http.prepend_req_header("accept", "application/vnd.hmrc.1.0+json")

  fetch.send(req)
  |> promise.then(fn(resp: Result(Response(FetchBody), FetchError)) {
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json") = http.get_resp_header(resp, "content-type")
    fetch.get_text_body(resp)
  })
  |> promise.map(fn(x) { assert Ok("{\"message\":\"Hello World\"}") = x })
}

pub fn head_request_discards_body_test() {
  let req =
    http.default_req()
    |> http.set_method(Head)
    |> http.set_host("postman-echo.com")
    |> http.set_path("/get")
    |> http.set_req_body("This gets dropped")

  fetch.send(req)
  |> promise.then(fn(resp: Result(Response(FetchBody), FetchError)) {
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("application/json; charset=utf-8") =
      http.get_resp_header(resp, "content-type")
    fetch.get_text_body(resp)
  })
  |> promise.map(fn(x) { assert Ok("") = x })
}

pub fn options_request_discards_body_test() {
  let req =
    http.default_req()
    |> http.set_method(Options)
    |> http.set_host("postman-echo.com")
    |> http.set_path("/get")
    |> http.set_req_body("This gets dropped")

  fetch.send(req)
  |> promise.then(fn(resp: Result(Response(FetchBody), FetchError)) {
    assert Ok(resp) = resp
    assert 200 = resp.status
    assert Ok("text/html; charset=utf-8") =
      http.get_resp_header(resp, "content-type")
    fetch.get_text_body(resp)
  })
  |> promise.map(fn(x) { assert Ok("GET,HEAD,PUT,POST,DELETE,PATCH") = x })
}
