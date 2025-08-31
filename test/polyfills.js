import { default as fetch, Headers, Request, Response, AbortSignal, AbortController } from "node-fetch";

if (!globalThis.fetch) {
  globalThis.fetch = fetch;
  globalThis.Headers = Headers;
  globalThis.Request = Request;
  globalThis.Response = Response;
  globalThis.AbortController = AbortController;
  globalThis.AbortSignal = AbortSignal;
}
