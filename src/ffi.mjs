import { Ok, Error, List, toBitArray } from "./gleam.mjs";
import { to_string as uri_to_string } from "../gleam_stdlib/gleam/uri.mjs";
import { method_to_string } from "../gleam_http/gleam/http.mjs";
import { to_uri } from "../gleam_http/gleam/http/request.mjs";
import { Response } from "../gleam_http/gleam/http/response.mjs";
import {
  NetworkError,
  InvalidJsonBody,
  UnableToReadBody,
} from "../gleam_fetch/gleam/fetch.mjs";

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
  let url = uri_to_string(to_uri(request));
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

export async function read_bytes_body(response) {
  let body;
  try {
    body = await response.body.arrayBuffer()
  } catch (error) {
    return new Error(new UnableToReadBody());
  }
  return new Ok(response.withFields({ body: toBitArray(new Uint8Array(body)) }));
}

export async function read_text_body(response) {
  let body;
  try {
    body = await response.body.text();
  } catch (error) {
    return new Error(new UnableToReadBody());
  }
  return new Ok(response.withFields({ body }));
}

export async function read_json_body(response) {
  try {
    let body = await response.body.json();
    return new Ok(response.withFields({ body }));
  } catch (error) {
    return new Error(new InvalidJsonBody());
  }
}
