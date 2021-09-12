import { Ok, Error, List } from "./gleam.js";
import { to_string as uri_to_string } from "gleam-packages/gleam_stdlib/gleam/uri.js";
import {
  Response,
  req_to_uri,
  method_to_string,
} from "gleam-packages/gleam_http/gleam/http.js";
import {
  NetworkError,
  InvalidJsonBody,
  UnableToReadBody,
} from "gleam-packages/gleam_fetch/gleam/fetch.js";

export async function raw_send(request) {
  try {
    return new Ok(await fetch(request));
  } catch (error) {
    return new Error(new NetworkError(error.toString()));
  }
}

export function from_fetch_response(response) {
  return new Response(
    response.status,
    List.fromArray([...response.headers]),
    response
  );
}

export function to_fetch_request(request) {
  let url = uri_to_string(req_to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method,
  };
  if (method !== "GET" && method !== "HEAD") options.body = request.body;
  return new globalThis.Request(url, options);
}

function make_headers(headersList) {
  let headers = new globalThis.Headers();
  for (let [k, v] of headersList) headers.append(k.toLowerCase(), v);
  return headers;
}

export async function read_text_body(response) {
  try {
    let body = await response.body.text();
    return new Ok(response.withFields({ body }));
  } catch (error) {
    return new Error(new UnableToReadBody());
  }
}

export async function read_json_body(response) {
  try {
    let body = await response.body.json();
    return new Ok(response.withFields({ body }));
  } catch (error) {
    return new Error(new InvalidJsonBody());
  }
}
