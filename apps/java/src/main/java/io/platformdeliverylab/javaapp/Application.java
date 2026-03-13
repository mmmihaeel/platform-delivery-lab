package io.platformdeliverylab.javaapp;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public final class Application {
  private Application() {}

  public static void main(String[] args) throws IOException {
    String portValue = env("PORT", "3009");
    int port = Integer.parseInt(portValue);
    HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
    server.createContext("/", Application::handleRequest);
    server.start();
    System.out.printf("%s listening on %d%n", env("SERVICE_NAME", "java-runtime-api"), port);
  }

  private static void handleRequest(HttpExchange exchange) throws IOException {
    String path = exchange.getRequestURI().getPath();
    List<String> filteredSegments =
        List.of(path.split("/")).stream().filter(segment -> !segment.isBlank()).collect(Collectors.toList());
    String routeKey = filteredSegments.isEmpty() ? "" : filteredSegments.get(filteredSegments.size() - 1);
    String routeGroup =
        filteredSegments.size() > 1
            ? String.join("/", filteredSegments.subList(0, filteredSegments.size() - 1))
            : "root";
    int statusCode = 200;
    String status = "ok";

    if (!"/".equals(path) && !"healthz".equals(routeKey) && !"status".equals(routeKey)) {
      statusCode = 404;
      status = "not_found";
    }

    StringBuilder body = new StringBuilder();
    body.append("{")
        .append("\"service\":\"").append(json(env("SERVICE_NAME", "java-runtime-api"))).append("\",")
        .append("\"runtime\":\"").append(json(env("SERVICE_RUNTIME", "java11"))).append("\",")
        .append("\"version\":\"").append(json(env("SERVICE_VERSION", "1.0.0"))).append("\",")
        .append("\"environment\":\"").append(json(env("PLATFORM_ENV", "local"))).append("\",")
        .append("\"hostname\":\"").append(json(hostname())).append("\",")
        .append("\"requestPath\":\"").append(json(path)).append("\",")
        .append("\"routeGroup\":\"").append(json(routeGroup)).append("\",")
        .append("\"forwardedFor\":\"").append(json(header(exchange, "X-Forwarded-For"))).append("\",")
        .append("\"forwardedHost\":\"").append(json(header(exchange, "X-Forwarded-Host"))).append("\",")
        .append("\"forwardedProto\":\"").append(json(header(exchange, "X-Forwarded-Proto"))).append("\",")
        .append("\"status\":\"").append(json(status)).append("\"");

    if ("status".equals(routeKey)) {
      body.append(",\"diagnostics\":{\"method\":\"")
          .append(json(exchange.getRequestMethod()))
          .append("\",\"userAgent\":\"")
          .append(json(header(exchange, "User-Agent")))
          .append("\"}");
    }

    body.append("}");
    byte[] responseBytes = body.toString().getBytes(StandardCharsets.UTF_8);
    exchange.getResponseHeaders().add("Content-Type", "application/json");
    exchange.sendResponseHeaders(statusCode, responseBytes.length);

    try (OutputStream outputStream = exchange.getResponseBody()) {
      outputStream.write(responseBytes);
    }
  }

  private static String env(String key, String fallback) {
    return Optional.ofNullable(System.getenv(key)).filter(value -> !value.isBlank()).orElse(fallback);
  }

  private static String header(HttpExchange exchange, String key) {
    return Optional.ofNullable(exchange.getRequestHeaders().getFirst(key)).orElse("");
  }

  private static String hostname() {
    try {
      return InetAddress.getLocalHost().getHostName();
    } catch (IOException exception) {
      return "unknown";
    }
  }

  private static String json(String value) {
    return value.replace("\\", "\\\\").replace("\"", "\\\"");
  }
}
