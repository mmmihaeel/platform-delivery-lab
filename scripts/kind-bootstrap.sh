#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

CLUSTER_NAME="${KIND_CLUSTER_NAME:-platform-delivery-lab}"
ROOT="$(repo_root)"

require_command docker
require_command kubectl
require_command kind

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  kind create cluster --name "$CLUSTER_NAME" --config "$ROOT/k8s/kind/cluster.yaml"
fi

if [[ "${INSTALL_INGRESS_NGINX:-true}" == "true" ]]; then
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/kind/deploy.yaml
  kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
fi

for image in platform-delivery-lab/node-ts:dev platform-delivery-lab/go:dev platform-delivery-lab/java:dev platform-delivery-lab/php:dev; do
  if docker image inspect "$image" >/dev/null 2>&1; then
    kind load docker-image --name "$CLUSTER_NAME" "$image"
  fi
done

log "kind cluster ready: $CLUSTER_NAME"
