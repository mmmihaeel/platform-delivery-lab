#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ACTION="${1:-validate}"
ROOT="$(repo_root)"
DOCKER_ROOT="$(docker_mount_path "$ROOT")"
OVERLAY="k8s/overlays/local"

run_kubectl() {
  if have_command kubectl; then
    (
      cd "$ROOT"
      kubectl "$@"
    )
    return
  fi

  docker run --rm -v "$DOCKER_ROOT:/workspace" -w /workspace bitnami/kubectl:1.34.1 kubectl "$@"
}

case "$ACTION" in
render)
  run_kubectl kustomize "$OVERLAY" >/dev/null
  log "Kubernetes manifests rendered successfully"
  ;;
validate)
  rendered_file="$(mktemp)"
  run_kubectl kustomize "$OVERLAY" >"$rendered_file"
  grep -q "kind: Deployment" "$rendered_file"
  grep -q "kind: Service" "$rendered_file"
  grep -q "kind: Ingress" "$rendered_file"
  rm -f "$rendered_file"
  log "Kubernetes manifests rendered successfully"
  ;;
apply)
  require_command kubectl
  (
    cd "$ROOT"
    kubectl apply -k "$OVERLAY"
  )
  ;;
*)
  fail "Unsupported action: $ACTION"
  ;;
esac
