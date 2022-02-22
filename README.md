# Fetch

<a href="https://github.com/gleam-lang/fetch/releases"><img src="https://img.shields.io/github/release/gleam-lang/fetch" alt="GitHub release"></a>
<a href="https://discord.gg/Fm8Pwmy"><img src="https://img.shields.io/discord/768594524158427167?color=blue" alt="Discord chat"></a>
![test](https://github.com/gleam-lang/fetch/workflows/test/badge.svg?branch=main)

Bindings to JavaScript's built in HTTP client, `fetch`.

```gleam
import gleam/fetch
import gleam/http.{Get}
import gleam/javascript/promise

pub fn main() {
  // Prepare a HTTP request record
  let req = http.default_req()
    |> http.set_method(Get)
    |> http.set_host("test-api.service.hmrc.gov.uk")
    |> http.set_path("/hello/world")
    |> http.prepend_req_header("accept", "application/vnd.hmrc.1.0+json")

  // Send the HTTP request to the server
  req
  |> fetch.send
  |> promise.then_try(fetch.read_text_body)
  |> promise.then(fn(resp) {
    // We get a response record back
    assert Ok(Response(status: 200, ..) as resp) = resp

    assert Ok("text/html; charset=utf-8") =
      http.get_resp_header(resp, "content-type")

    assert "{\"message\":\"Hello World\"}" = resp.body

    promise.resolve(Ok(Nil))
  })
}
```
