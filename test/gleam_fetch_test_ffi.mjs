import { Ok, Error } from "./gleam.mjs";

export function get_header(request, name) {
  const value = request.headers.get(name);
  if (value === null) {
    return new Error(undefined);
  }
  return new Ok(value);
}
