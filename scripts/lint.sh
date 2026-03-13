#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
DOCKER_ROOT="$(docker_mount_path "$ROOT")"

mapfile -t shell_files < <(
  cd "$ROOT"
  find scripts infra/localstack -type f -name "*.sh" | sort
)

if [[ "${#shell_files[@]}" -eq 0 ]]; then
  fail "No shell scripts found"
fi

if have_command shellcheck; then
  (
    cd "$ROOT"
    shellcheck -x "${shell_files[@]}"
  )
else
  docker run --rm -v "$DOCKER_ROOT:/workspace" -w /workspace koalaman/shellcheck-alpine:stable shellcheck -x "${shell_files[@]}"
fi

if have_command shfmt; then
  (
    cd "$ROOT"
    shfmt -d "${shell_files[@]}"
  )
else
  docker run --rm -v "$DOCKER_ROOT:/workspace" -w /workspace mvdan/shfmt:v3.10.0 -d "${shell_files[@]}"
fi

compose config -q
log "Lint checks completed"
