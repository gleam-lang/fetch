import { Ok, Error, List, toBitArray, toList } from "./gleam.mjs";
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

function request_common(request) {
  let url = uri_to_string(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method,
  };
  return [url, options]
}

export function to_fetch_request(request) {
  let [url, options] = request_common(request)
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body;
  return new globalThis.Request(url, options);
}

export function form_data_to_fetch_request(request) {
  let [url, options] = request_common(request)
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body;
  // Remove `content-type`, because the browser will add the correct header by itself.
  delete options.headers['content-type']
  return new globalThis.Request(url, options);
}

export function bitarray_request_to_fetch_request(request) {
  let [url, options] = request_common(request)
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body.rawBuffer;
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

// FormData functions.

export function newFormData() {
  return new FormData()
}

function cloneFormData(formData) {
  const f = new FormData()
  for (const [key, value] of formData.entries()) f.append(key, value)
  return f
}

export function appendFormData(formData, key, value) {
  const f = cloneFormData(formData)
  f.append(key, value)
  return f
}

export function setFormData(formData, key, value) {
  const f = cloneFormData(formData)
  f.set(key, value)
  return f
}

export function appendBitsFormData(formData, key, value) {
  const f = cloneFormData(formData)
  f.append(key, new Blob([value.rawBuffer]))
  return f
}

export function setBitsFormData(formData, key, value) {
  const f = cloneFormData(formData)
  f.set(key, new Blob([value.rawBuffer]))
  return f
}

export function deleteFormData(formData, key) {
  const f = cloneFormData(formData)
  f.delete(key)
  return f
}

export function getFormData(formData, key) {
  const data = [...formData.getAll(key)]
  return toList(data.filter(value => typeof value === 'string'))
}

export async function getBitsFormData(formData, key) {
  const data = [...formData.getAll(key)]
  const encode = new TextEncoder()
  const blobs = data.map(async (value) => {
    if (typeof value === 'string') {
      const encoded = encode.encode(value)
      return toBitArray(encoded)
    } else {
      const buffer = await value.arrayBuffer()
      const bytes = new Uint8Array(buffer)
      return toBitArray(bytes)
    }
  })
  const bytes = await Promise.all(blobs)
  return toList(bytes)
}

export function hasFormData(formData, key) {
  return formData.has(key)
}

export function keysFormData(formData) {
  const result = new Set()
  for (const key of formData.keys()) {
    result.add(key)
  }
  return toList([...result])
}
