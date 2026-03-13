package io.platformdeliverylab.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import java.util.LinkedHashMap;
import java.util.Map;

public class Handler {
  public Map<String, Object> handleRequest(Map<String, Object> event, Context context) {
    Map<String, Object> response = new LinkedHashMap<>();
    response.put("runtime", "java11");
    response.put("status", "ok");
    response.put("version", "1.0.0");
    response.put("requestId", context != null ? context.getAwsRequestId() : "local");
    response.put("eventType", event != null ? event.getOrDefault("source", "unknown") : "unknown");
    return response;
  }
}
