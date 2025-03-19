# Gleam Fetch

<a href="https://github.com/gleam-lang/fetch/releases"><img src="https://img.shields.io/github/release/gleam-lang/fetch" alt="GitHub release"></a>
<a href="https://discord.gg/Fm8Pwmy"><img src="https://img.shields.io/discord/768594524158427167?color=blue" alt="Discord chat"></a>

Make HTTP requests in Gleam JavaScript with Fetch.

```sh
gleam add gleam_fetch@1 gleam_http
```

```gleam
pub fn main() {
  let assert Ok(req) = request.to("https://example.com")

  // Send the HTTP request to the server
  use resp <- promise.try_await(fetch.send(req))
  use resp <- promise.try_await(fetch.read_text_body(resp))

  // We get a response record back
  resp.status
  // -> 200

  response.get_header(resp, "content-type")
  // -> Ok("text/html; charset=UTF-8")

  promise.resolve(Ok(Nil))
}
```

Documentation can be found at [https://hexdocs.pm/gleam_fetch](https://hexdocs.pm/gleam_fetch).

> [!WARNING]
> If you are running your Gleam project on the Erlang target (the default for
> new Gleam projects) then you will want to use a different library which can
> run on Erlang, such as [`gleam_httpc`](https://github.com/gleam-lang/httpc).
