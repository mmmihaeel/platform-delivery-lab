#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

ACTION="${1:-syntax-check}"
ROOT="$(repo_root)"
DOCKER_ROOT="$(docker_mount_path "$ROOT")"
RUNNER_IMAGE="platform-delivery-lab/ansible-runner:local"
INVENTORY="ansible/inventory/local.ini"

run_ansible() {
  local playbook="$1"
  shift

  if have_command ansible-playbook; then
    (
      cd "$ROOT"
      ansible-playbook "$playbook" -i "$INVENTORY" "$@"
    )
    return
  fi

  if have_command python; then
    local venv_dir="$ROOT/tmp/ansible-venv"
    local ansible_binary=""

    if [[ ! -x "$venv_dir/Scripts/ansible-playbook.exe" && ! -x "$venv_dir/bin/ansible-playbook" ]]; then
      python -m venv "$venv_dir"
      if [[ -x "$venv_dir/Scripts/pip.exe" ]]; then
        "$venv_dir/Scripts/pip.exe" install --quiet ansible-core==2.17.10
      else
        "$venv_dir/bin/pip" install --quiet ansible-core==2.17.10
      fi
    fi

    if [[ -x "$venv_dir/Scripts/ansible-playbook.exe" ]]; then
      ansible_binary="$venv_dir/Scripts/ansible-playbook.exe"
    else
      ansible_binary="$venv_dir/bin/ansible-playbook"
    fi

    (
      cd "$ROOT"
      "$ansible_binary" "$playbook" -i "$INVENTORY" "$@"
    )
    return
  fi

  docker build -q -t "$RUNNER_IMAGE" -f "$ROOT/docker/ansible/Dockerfile" "$ROOT" >/dev/null
  docker run --rm -v "$DOCKER_ROOT:/workspace" -w /workspace "$RUNNER_IMAGE" ansible-playbook "$playbook" -i "$INVENTORY" "$@"
}

case "$ACTION" in
syntax-check)
  run_ansible ansible/playbooks/bootstrap.yml --syntax-check
  run_ansible ansible/playbooks/validate.yml --syntax-check
  ;;
run)
  run_ansible ansible/playbooks/bootstrap.yml
  ;;
validate)
  run_ansible ansible/playbooks/validate.yml
  ;;
*)
  fail "Unsupported action: $ACTION"
  ;;
esac
