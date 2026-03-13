#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

docker_mount_path() {
  local path="$1"

  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$path"
    return
  fi

  printf '%s\n' "$path"
}

log() {
  printf '[platform-delivery-lab] %s\n' "$*"
}

fail() {
  log "ERROR: $*"
  exit 1
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

resolve_command() {
  local candidate

  for candidate in "$1" "$1.exe" "$1.cmd"; do
    if have_command "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

require_command() {
  local command_name="$1"

  have_command "$command_name" || fail "Required command not found: $command_name"
}

ensure_env_file() {
  local root
  root="$(repo_root)"

  if [[ ! -f "$root/.env" && -f "$root/.env.example" ]]; then
    cp "$root/.env.example" "$root/.env"
  fi
}

compose() {
  local root
  root="$(repo_root)"
  (
    cd "$root"
    docker compose --project-name platform-delivery-lab "$@"
  )
}

wait_for_http() {
  local url="$1"
  local retries="${2:-30}"
  local sleep_seconds="${3:-2}"
  local attempt=1

  while ((attempt <= retries)); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi

    sleep "$sleep_seconds"
    attempt=$((attempt + 1))
  done

  fail "Timed out waiting for $url"
}

assert_contains() {
  local content="$1"
  local expected="$2"

  if [[ "$content" != *"$expected"* ]]; then
    fail "Expected response to contain: $expected"
  fi
}

wait_for_localstack() {
  local endpoint="http://${LOCALSTACK_HOST:-127.0.0.1}:${LOCALSTACK_EDGE_PORT:-4566}/_localstack/health"
  local retries=40
  local attempt=1
  local body=""

  while ((attempt <= retries)); do
    if body="$(curl -fsS "$endpoint" 2>/dev/null)" && { [[ "$body" == *"\"lambda\": \"available\""* ]] || [[ "$body" == *"\"lambda\": \"running\""* ]]; }; then
      return 0
    fi

    sleep 3
    attempt=$((attempt + 1))
  done

  fail "Timed out waiting for LocalStack Lambda readiness"
}
