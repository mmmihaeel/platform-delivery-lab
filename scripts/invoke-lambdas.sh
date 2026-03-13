#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

PHP_BIN="${PHP_BIN:-$(resolve_command php || true)}"

ensure_env_file
wait_for_localstack

if ! compose exec -T localstack sh -lc "command -v awslocal >/dev/null 2>&1"; then
  fail "LocalStack container does not provide awslocal"
fi

if [[ ! -f "$(repo_root)/dist/lambdas/go/function.zip" ]]; then
  fail "Go Lambda package is missing"
fi

invoke_lambda() {
  local function_name="$1"
  local output_file="/tmp/${function_name}.json"

  compose exec -T localstack sh -lc \
    "awslocal lambda invoke --function-name '${function_name}' '${output_file}' >/dev/null && cat '${output_file}'"
}

assert_contains "$(invoke_lambda "platform-delivery-lab-node-runtime")" "\"runtime\":\"nodejs20-typescript\""
assert_contains "$(invoke_lambda "platform-delivery-lab-java-runtime")" "\"runtime\":\"java11\""

invoke_php_handler() {
  local handler_path
  handler_path="$(repo_root)/lambdas/php/handler.php"
  local payload='{"source":"platform-delivery-lab-smoke"}'
  local output=""

  if [[ -n "$PHP_BIN" ]] && output="$(printf '%s' "$payload" | "$PHP_BIN" "$handler_path" 2>/dev/null)"; then
    printf '%s\n' "$output"
    return 0
  fi

  if have_command powershell.exe; then
    output="$(
      powershell.exe -NoProfile -Command "\$payload = @{source='platform-delivery-lab-smoke'} | ConvertTo-Json -Compress; \$payload | php '$(host_path "$handler_path")'" | tr -d '\r'
    )"
    printf '%s\n' "$output"
    return 0
  fi

  fail "Unable to execute the local PHP Lambda handler"
}

PHP_HANDLER_OUTPUT="$(invoke_php_handler)"
assert_contains "$PHP_HANDLER_OUTPUT" "\"runtime\":\"php8.3\""

log "LocalStack Lambda invocations completed"
