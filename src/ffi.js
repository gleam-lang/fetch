import { Ok, Error, List } from "./gleam.js";
import { to_string as uri_to_string } from "gleam-packages/gleam_stdlib/gleam/uri.js";
import {
  Response,
  req_to_uri,
  method_to_string,
} from "gleam-packages/gleam_http/gleam/http.js";
import { NetworkError } from "gleam-packages/gleam_fetch/gleam/fetch.js";

export async function send(request) {
  let response;
  let js_request = gleam_to_js_request(request);
  try {
    response = await fetch(js_request);
  } catch (error) {
    return new Error(new NetworkError(error.toString()));
  }
  return new Ok(js_to_gleam_response(response));
}

function js_to_gleam_response(response) {
  return new Response(
    response.status,
    List.fromArray([...response.headers]),
    response
  );
}

function gleam_to_js_request(request) {
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

export async function get_text_body(response) {
  try {
    return new Ok(await response.body.text());
  } catch (error) {
    return new Error(undefined);
  }
}

export async function get_json_body(response) {
  try {
    return new Ok(await response.body.json());
  } catch (error) {
    return new Error(undefined);
  }
}
