# Fetch

<a href="https://github.com/gleam-lang/fetch/releases"><img src="https://img.shields.io/github/release/gleam-lang/fetch" alt="GitHub release"></a>
<a href="https://discord.gg/Fm8Pwmy"><img src="https://img.shields.io/discord/768594524158427167?color=blue" alt="Discord chat"></a>
![test](https://github.com/gleam-lang/fetch/workflows/test/badge.svg?branch=main)

Bindings to JavaScript's built in HTTP client, `fetch`.

```gleam
import gleam/fetch
import gleam/http.{Get}
import gleam/http/request
import gleam/http/response
import gleam/javascript/promise.{try_await}

pub fn main() {
  // Prepare a HTTP request record
  let request = request.new()
    |> request.set_method(Get)
    |> request.set_host("test-api.service.hmrc.gov.uk")
    |> request.set_path("/hello/world")
    |> request.prepend_header("accept", "application/vnd.hmrc.1.0+json")

  // Send the HTTP request to the server
  use response <- try_await(fetch.send(request))
  use response <- try_await(fetch.read_text_body(response))

  // We get a response record back
  assert Response(status: 200, ..) = response

  assert Ok("text/html; charset=utf-8") =
    http.get_resp_header(resp, "content-type")

  assert "{\"message\":\"Hello World\"}" = resp.body

  promise.resolve(Ok(Nil))
}
```
