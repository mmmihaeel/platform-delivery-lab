#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
DIST_DIR="$ROOT/dist/lambdas"
PYTHON_BIN="${PYTHON_BIN:-$(resolve_command python3 || true)}"
GO_BIN="${GO_BIN:-$(resolve_command go || true)}"
MVN_BIN="${MVN_BIN:-$(resolve_command mvn || true)}"
PHP_BIN="${PHP_BIN:-$(resolve_command php || true)}"
NPM_BIN="${NPM_BIN:-$(resolve_command npm || true)}"

if [[ -z "$PYTHON_BIN" ]]; then
  fail "python3 is required to create zip archives"
fi

if [[ -z "$GO_BIN" ]]; then
  fail "Go is required to package the Go Lambda"
fi

if [[ -z "$MVN_BIN" ]] && ! have_command powershell.exe; then
  fail "Maven is required to package the Java Lambda"
fi

if [[ -z "$PHP_BIN" ]] && ! have_command powershell.exe; then
  fail "PHP is required to package the PHP Lambda"
fi

if [[ -z "$NPM_BIN" ]]; then
  fail "npm is required to package the Node.js Lambda"
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/node-ts" "$DIST_DIR/go" "$DIST_DIR/java" "$DIST_DIR/php"

zip_directory() {
  local source_dir="$1"
  local destination="$2"

  "$PYTHON_BIN" - "$source_dir" "$destination" <<'PY'
import os
import sys
import zipfile

source_dir = sys.argv[1]
destination = sys.argv[2]

with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
    for root, _, files in os.walk(source_dir):
        for filename in files:
            full_path = os.path.join(root, filename)
            archive.write(full_path, os.path.relpath(full_path, source_dir))
PY
}

zip_files() {
  local destination="$1"
  shift

  "$PYTHON_BIN" - "$destination" "$@" <<'PY'
import os
import sys
import zipfile

destination = sys.argv[1]
files = sys.argv[2:]

with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
    for file_path in files:
        archive.write(file_path, os.path.basename(file_path))
PY
}

log "Packaging Node.js Lambda"
(
  cd "$ROOT/lambdas/node-ts"
  "$NPM_BIN" ci --quiet
  "$NPM_BIN" run build --silent
)
zip_directory "$ROOT/lambdas/node-ts/build" "$DIST_DIR/node-ts/function.zip"

log "Packaging Go Lambda"
(
  cd "$ROOT/lambdas/go"
  "$GO_BIN" mod download
  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 "$GO_BIN" build -o main ./main.go
)
zip_files "$DIST_DIR/go/function.zip" "$ROOT/lambdas/go/main"

log "Packaging Java Lambda"
(
  cd "$ROOT/lambdas/java"

  if [[ -n "$MVN_BIN" ]] && "$MVN_BIN" -q -DskipTests package >/dev/null 2>&1; then
    :
  elif have_command powershell.exe; then
    powershell.exe -NoProfile -Command "Set-Location '$(host_path "$ROOT/lambdas/java")'; mvn -q -DskipTests package" >/dev/null
  else
    fail "Unable to package Java Lambda with Maven"
  fi
)
"$PYTHON_BIN" - "$ROOT/lambdas/java/target/lambda-java.jar" "$DIST_DIR/java/function.zip" <<'PY'
import os
import sys
import tempfile
import zipfile

jar_file = sys.argv[1]
destination = sys.argv[2]

with tempfile.TemporaryDirectory() as temp_dir:
    with zipfile.ZipFile(jar_file, "r") as jar_archive:
        jar_archive.extractall(temp_dir)

    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as lambda_archive:
        for root, _, files in os.walk(temp_dir):
            for filename in files:
                full_path = os.path.join(root, filename)
                lambda_archive.write(full_path, os.path.relpath(full_path, temp_dir))
PY

log "Packaging PHP Lambda runtime bundle"
chmod +x "$ROOT/lambdas/php/bootstrap"

if [[ -n "$PHP_BIN" ]] && "$PHP_BIN" -l "$ROOT/lambdas/php/handler.php" >/dev/null 2>&1; then
  :
elif have_command powershell.exe; then
  powershell.exe -NoProfile -Command "php -l '$(host_path "$ROOT/lambdas/php/handler.php")'" >/dev/null
else
  fail "Unable to validate PHP Lambda handler"
fi

zip_files "$DIST_DIR/php/function.zip" "$ROOT/lambdas/php/bootstrap" "$ROOT/lambdas/php/handler.php"

rm -rf "$ROOT/lambdas/node-ts/node_modules" "$ROOT/lambdas/node-ts/build" "$ROOT/lambdas/java/target"
rm -f "$ROOT/lambdas/go/main" "$ROOT/lambdas/go/bootstrap"

log "Lambda artifacts written to dist/lambdas"
