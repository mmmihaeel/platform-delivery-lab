package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
)

type payload struct {
	Service        string  `json:"service"`
	Runtime        string  `json:"runtime"`
	Version        string  `json:"version"`
	Environment    string  `json:"environment"`
	Hostname       string  `json:"hostname"`
	RequestPath    string  `json:"requestPath"`
	RouteGroup     string  `json:"routeGroup"`
	ForwardedFor   string  `json:"forwardedFor,omitempty"`
	ForwardedHost  string  `json:"forwardedHost,omitempty"`
	ForwardedProto string  `json:"forwardedProto,omitempty"`
	Status         string  `json:"status"`
	Diagnostics    *detail `json:"diagnostics,omitempty"`
}

type detail struct {
	Method    string `json:"method"`
	UserAgent string `json:"userAgent,omitempty"`
}

func normalizeRoute(path string) (string, string) {
	trimmed := strings.Trim(path, "/")
	if trimmed == "" {
		return "", "root"
	}

	segments := strings.Split(trimmed, "/")
	routeKey := segments[len(segments)-1]
	if len(segments) == 1 {
		return routeKey, "root"
	}

	return routeKey, strings.Join(segments[:len(segments)-1], "/")
}

func writeJSON(w http.ResponseWriter, statusCode int, response payload) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(response)
}

func main() {
	serviceName := getenv("SERVICE_NAME", "go-runtime-api")
	runtime := getenv("SERVICE_RUNTIME", "go")
	version := getenv("SERVICE_VERSION", "1.0.0")
	environment := getenv("PLATFORM_ENV", "local")
	port := getenv("PORT", "3008")
	hostname, _ := os.Hostname()

	handler := func(w http.ResponseWriter, r *http.Request) {
		routeKey, routeGroup := normalizeRoute(r.URL.Path)
		response := payload{
			Service:        serviceName,
			Runtime:        runtime,
			Version:        version,
			Environment:    environment,
			Hostname:       hostname,
			RequestPath:    r.URL.Path,
			RouteGroup:     routeGroup,
			ForwardedFor:   r.Header.Get("X-Forwarded-For"),
			ForwardedHost:  r.Header.Get("X-Forwarded-Host"),
			ForwardedProto: r.Header.Get("X-Forwarded-Proto"),
			Status:         "ok",
		}

		switch {
		case r.URL.Path == "/":
			writeJSON(w, http.StatusOK, response)
		case routeKey == "healthz":
			writeJSON(w, http.StatusOK, response)
		case routeKey == "status":
			response.Diagnostics = &detail{
				Method:    r.Method,
				UserAgent: r.UserAgent(),
			}
			writeJSON(w, http.StatusOK, response)
		default:
			response.Status = "not_found"
			writeJSON(w, http.StatusNotFound, response)
		}
	}

	http.HandleFunc("/", handler)

	log.Printf("%s listening on :%s", serviceName, port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getenv(name string, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}

	return fallback
}
