import { createServer } from "node:http";
import os from "node:os";

const port = Number(process.env.PORT ?? "3007");
const serviceName = process.env.SERVICE_NAME ?? "node-runtime-api";
const runtime = process.env.SERVICE_RUNTIME ?? "nodejs20-typescript";
const version = process.env.SERVICE_VERSION ?? "1.0.0";
const environment = process.env.PLATFORM_ENV ?? "local";

function routeMetadata(requestPath: string) {
  const segments = requestPath.split("/").filter(Boolean);
  const routeKey = segments.at(-1) ?? "";
  const routeGroup = segments.length > 1 ? segments.slice(0, -1).join("/") : "root";

  return { routeKey, routeGroup };
}

function respond(response: import("node:http").ServerResponse, statusCode: number, payload: unknown) {
  response.writeHead(statusCode, { "Content-Type": "application/json" });
  response.end(JSON.stringify(payload));
}

const server = createServer((request, response) => {
  const requestUrl = new URL(request.url ?? "/", `http://${request.headers.host ?? "localhost"}`);
  const { routeKey, routeGroup } = routeMetadata(requestUrl.pathname);
  const payload = {
    service: serviceName,
    runtime,
    version,
    environment,
    hostname: os.hostname(),
    requestPath: requestUrl.pathname,
    routeGroup,
    forwardedFor: request.headers["x-forwarded-for"] ?? null,
    forwardedHost: request.headers["x-forwarded-host"] ?? null,
    forwardedProto: request.headers["x-forwarded-proto"] ?? null
  };

  if (requestUrl.pathname === "/") {
    respond(response, 200, {
      ...payload,
      status: "ok",
      endpoints: ["/healthz", "/status"]
    });
    return;
  }

  if (routeKey === "healthz") {
    respond(response, 200, { ...payload, status: "ok" });
    return;
  }

  if (routeKey === "status") {
    respond(response, 200, {
      ...payload,
      status: "ok",
      diagnostics: {
        method: request.method ?? "GET",
        userAgent: request.headers["user-agent"] ?? null
      }
    });
    return;
  }

  respond(response, 404, { ...payload, status: "not_found" });
});

server.listen(port, () => {
  console.log(`${serviceName} listening on ${port}`);
});
