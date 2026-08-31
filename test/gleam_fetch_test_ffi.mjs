import { Ok, Error } from "./gleam.mjs";

export function get_header(request, name) {
  const value = request.headers.get(name);
  if (value === null) {
    return new Error(undefined);
  }
  return new Ok(value);
}

// A response whose body stream fails partway, to exercise `read_chunk`'s
// error path without needing the network.
export function erroring_response() {
  const body = new ReadableStream({
    pull(controller) {
      controller.error(new Error("stream broke"));
    },
  });
  return new Response(body, { status: 200 });
}
