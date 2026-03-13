#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ACTION="${1:-validate}"
ROOT="$(repo_root)"
TF_DIR="$ROOT/infra/terraform/localstack"
TERRAFORM_BIN=""
TERRAFORM_IMAGE="hashicorp/terraform:1.14.1"
USE_DOCKER_TERRAFORM=false

if resolve_command terraform >/dev/null 2>&1; then
  TERRAFORM_BIN="$(resolve_command terraform)"
else
  fail "Terraform is required to validate or apply the LocalStack stack"
fi

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
export TF_VAR_localstack_endpoint="http://${LOCALSTACK_HOST:-127.0.0.1}:${LOCALSTACK_EDGE_PORT:-4566}"

if [[ "$TERRAFORM_BIN" == *.exe ]]; then
  USE_DOCKER_TERRAFORM=true
  export TF_VAR_localstack_endpoint="http://host.docker.internal:${LOCALSTACK_EDGE_PORT:-4566}"
fi

run_terraform() {
  if [[ "$USE_DOCKER_TERRAFORM" == "true" ]]; then
    docker run --rm \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e AWS_DEFAULT_REGION \
      -e TF_VAR_localstack_endpoint \
      -v "$ROOT:/workspace" \
      -w /workspace/infra/terraform/localstack \
      "$TERRAFORM_IMAGE" "$@"
    return
  fi

  "$TERRAFORM_BIN" -chdir="$TF_DIR" "$@"
}

case "$ACTION" in
init)
  run_terraform init -input=false
  ;;
validate)
  run_terraform init -input=false >/dev/null
  run_terraform validate
  ;;
apply)
  if [[ ! -f "$ROOT/dist/lambdas/node-ts/function.zip" || ! -f "$ROOT/dist/lambdas/go/function.zip" || ! -f "$ROOT/dist/lambdas/java/function.zip" ]]; then
    bash "$ROOT/scripts/package-lambdas.sh"
  fi
  wait_for_localstack
  run_terraform init -input=false >/dev/null
  run_terraform apply -input=false -auto-approve
  ;;
destroy)
  wait_for_localstack
  run_terraform init -input=false >/dev/null
  run_terraform destroy -input=false -auto-approve
  ;;
*)
  fail "Unsupported action: $ACTION"
  ;;
esac
