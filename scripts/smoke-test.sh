#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ensure_env_file

wait_for_http "http://127.0.0.1:${NODE_PORT:-3007}/healthz"
wait_for_http "http://127.0.0.1:${GO_PORT:-3008}/healthz"
wait_for_http "http://127.0.0.1:${JAVA_PORT:-3009}/healthz"
wait_for_http "http://127.0.0.1:${PHP_PORT:-3010}/healthz"
wait_for_http "http://127.0.0.1:${NGINX_PORT:-8085}/healthz"
wait_for_http "http://127.0.0.1:${APACHE_PORT:-8086}/healthz"
wait_for_localstack

assert_contains "$(curl -fsS "http://127.0.0.1:${NODE_PORT:-3007}/status")" "\"service\":\"node-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${GO_PORT:-3008}/status")" "\"service\":\"go-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${JAVA_PORT:-3009}/status")" "\"service\":\"java-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${PHP_PORT:-3010}/status")" "\"service\":\"php-runtime-api\""

assert_contains "$(curl -fsS "http://127.0.0.1:${NGINX_PORT:-8085}/api/node/status")" "\"service\":\"node-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${NGINX_PORT:-8085}/api/go/status")" "\"service\":\"go-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${NGINX_PORT:-8085}/legacy/php/status")" "\"service\":\"php-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${NGINX_PORT:-8085}/legacy/java/status")" "\"service\":\"java-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${NGINX_PORT:-8085}/diagnostics/apache-status?auto")" "ServerVersion"

assert_contains "$(curl -fsS "http://127.0.0.1:${APACHE_PORT:-8086}/php/status")" "\"service\":\"php-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${APACHE_PORT:-8086}/java/status")" "\"service\":\"java-runtime-api\""
assert_contains "$(curl -fsS "http://127.0.0.1:${APACHE_PORT:-8086}/server-status?auto")" "ServerVersion"

log "Smoke checks passed"
