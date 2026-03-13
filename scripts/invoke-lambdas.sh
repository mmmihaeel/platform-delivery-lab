#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

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

# shellcheck disable=SC2016
PHP_HANDLER_OUTPUT="$(
  powershell.exe -NoProfile -Command '$payload = @{source="platform-delivery-lab-smoke"} | ConvertTo-Json -Compress; $payload | php lambdas/php/handler.php' | tr -d '\r'
)"
assert_contains "$PHP_HANDLER_OUTPUT" "\"runtime\":\"php8.3\""

log "LocalStack Lambda invocations completed"
