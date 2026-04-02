import {
  Result$Ok,
  Result$Error,
  List$Empty,
  List$NonEmpty,
  BitArray$BitArray,
} from "./gleam.mjs";
import { to_string as uri_to_string } from "../gleam_stdlib/gleam/uri.mjs";
import { method_to_string } from "../gleam_http/gleam/http.mjs";
import { Option$Some, Option$None } from "../gleam_stdlib/gleam/option.mjs";
import { to_uri } from "../gleam_http/gleam/http/request.mjs";
import {
  Response$Response,
  map as map_response,
} from "../gleam_http/gleam/http/response.mjs";
import {
  FetchError$NetworkError,
  FetchError$InvalidJsonBody,
  FetchError$UnableToReadBody,
} from "../gleam_fetch/gleam/fetch.mjs";

export async function raw_send(request) {
  try {
    return Result$Ok(await fetch(request));
  } catch (error) {
    return Result$Error(FetchError$NetworkError(error.toString()));
  }
}

export function from_fetch_response(response) {
  let headers = [...response.headers].reverse();
  return Response$Response(response.status, arrayToList(headers), response);
}

function request_common(request) {
  let url = uri_to_string(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method,
  };
  return [url, options];
}

export function to_fetch_request(request) {
  let [url, options] = request_common(request);
  if (options.method !== "GET" && options.method !== "HEAD")
    options.body = request.body;
  return new globalThis.Request(url, options);
}

export function form_data_to_fetch_request(request) {
  let [url, options] = request_common(request);
  if (options.method !== "GET" && options.method !== "HEAD")
    options.body = request.body;
  // Remove `content-type`, because the browser will add the correct header by itself.
  options.headers.delete("content-type");

  return new globalThis.Request(url, options);
}

export function bitarray_request_to_fetch_request(request) {
  let [url, options] = request_common(request);
  if (options.method !== "GET" && options.method !== "HEAD")
    options.body = request.body.rawBuffer;
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
    body = await response.body.arrayBuffer();
  } catch (error) {
    return Result$Error(FetchError$UnableToReadBody());
  }
  body = BitArray$BitArray(new Uint8Array(body));
  return Result$Ok(map_response(response, () => body));
}

export async function read_text_body(response) {
  let body;
  try {
    body = await response.body.text();
  } catch (error) {
    return Result$Error(FetchError$UnableToReadBody());
  }
  return Result$Ok(map_response(response, () => body));
}

export async function read_json_body(response) {
  let body;
  try {
    body = await response.body.json();
  } catch (error) {
    return Result$Error(FetchError$InvalidJsonBody());
  }
  return Result$Ok(map_response(response, () => body));
}

export function stream_body(response) {
  try {
    // The "body" of the Gleam response is the full fetch response,
    // hence the double call to body.
    const reader = response.body.body.getReader();
    return Result$Ok(reader);
  } catch (error) {
    return Result$Error(FetchError$UnableToReadBody());
  }
}

export async function read_chunk(reader) {
  try {
    const { done, value } = await reader.read();
    if (done) return Result$Ok(Option$None());
    return Result$Ok(Option$Some(BitArray$BitArray(value)));
  } catch (error) {
    return Result$Error(undefined);
  }
}

// FormData functions.

export function newFormData() {
  return new FormData();
}

function cloneFormData(formData) {
  const f = new FormData();
  for (const [key, value] of formData.entries()) f.append(key, value);
  return f;
}

export function appendFormData(formData, key, value) {
  const f = cloneFormData(formData);
  f.append(key, value);
  return f;
}

export function setFormData(formData, key, value) {
  const f = cloneFormData(formData);
  f.set(key, value);
  return f;
}

export function appendBitsFormData(formData, key, value) {
  const f = cloneFormData(formData);
  f.append(key, new Blob([value.rawBuffer]));
  return f;
}

export function setBitsFormData(formData, key, value) {
  const f = cloneFormData(formData);
  f.set(key, new Blob([value.rawBuffer]));
  return f;
}

export function deleteFormData(formData, key) {
  const f = cloneFormData(formData);
  f.delete(key);
  return f;
}

export function getFormData(formData, key) {
  const data = [...formData.getAll(key)].filter(
    (data) => typeof data === "string",
  );
  data.reverse();
  return arrayToList(data);
}

function arrayToList(array) {
  let list = List$Empty();
  for (const element of array) {
    list = List$NonEmpty(element, list);
  }
  return list;
}

export async function getBitsFormData(formData, key) {
  const data = [...formData.getAll(key)];
  const encode = new TextEncoder();
  const blobs = data.map(async (value) => {
    if (typeof value === "string") {
      const encoded = encode.encode(value);
      return BitArray$BitArray(encoded);
    } else {
      const buffer = await value.arrayBuffer();
      const bytes = new Uint8Array(buffer);
      return BitArray$BitArray(bytes);
    }
  });
  const bytes = await Promise.all(blobs);
  bytes.reverse();
  return arrayToList(bytes);
}

export function hasFormData(formData, key) {
  return formData.has(key);
}

export function keysFormData(formData) {
  const result = new Set();
  for (const key of formData.keys()) {
    result.add(key);
  }
  return arrayToList([...result].reverse());
}
