SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: help bootstrap validate up down restart smoke lint docker-validate k8s-validate k8s-apply tf-init tf-validate tf-apply-localstack tf-destroy-localstack ansible-check ansible-run lambda-package lambda-smoke clean

help:
	@echo "Available targets:"
	@echo "  make bootstrap            - prepare local files and run Ansible bootstrap checks"
	@echo "  make validate             - run the local validation suite"
	@echo "  make up                   - build and start the Docker stack"
	@echo "  make down                 - stop the Docker stack"
	@echo "  make restart              - rebuild the Docker stack"
	@echo "  make smoke                - verify direct and proxied service endpoints"
	@echo "  make lint                 - lint Bash scripts and validate Compose syntax"
	@echo "  make docker-validate      - render Docker Compose configuration"
	@echo "  make k8s-validate         - render and dry-run Kubernetes manifests"
	@echo "  make k8s-apply            - apply the local Kubernetes overlay to the active cluster"
	@echo "  make tf-init              - initialize the executable LocalStack Terraform stack"
	@echo "  make tf-validate          - validate the LocalStack Terraform stack"
	@echo "  make tf-apply-localstack  - deploy LocalStack Lambda functions with Terraform"
	@echo "  make tf-destroy-localstack - remove LocalStack Lambda functions"
	@echo "  make ansible-check        - syntax-check Ansible playbooks"
	@echo "  make ansible-run          - run the Ansible bootstrap workflow"
	@echo "  make lambda-package       - build Lambda artifacts for every runtime"
	@echo "  make lambda-smoke         - invoke LocalStack-managed Lambda functions"
	@echo "  make clean                - remove generated artifacts and temporary state"

bootstrap:
	cp -n .env.example .env || true
	mkdir -p dist/lambdas tmp/localstack
	chmod +x scripts/*.sh scripts/lib/*.sh infra/localstack/*.sh || true
	bash ./scripts/ansible-bootstrap.sh run

validate: lint docker-validate lambda-package tf-init tf-validate k8s-validate ansible-check

up:
	cp -n .env.example .env || true
	docker compose up -d --build

down:
	docker compose down --remove-orphans --volumes

restart: down up

smoke:
	bash ./scripts/smoke-test.sh

lint:
	bash ./scripts/lint.sh

docker-validate:
	docker compose config -q

k8s-validate:
	bash ./scripts/k8s-validate.sh validate

k8s-apply:
	bash ./scripts/k8s-validate.sh apply

tf-init:
	bash ./scripts/terraform-localstack.sh init

tf-validate:
	bash ./scripts/terraform-localstack.sh validate

tf-apply-localstack:
	bash ./scripts/terraform-localstack.sh apply

tf-destroy-localstack:
	bash ./scripts/terraform-localstack.sh destroy

ansible-check:
	bash ./scripts/ansible-bootstrap.sh syntax-check

ansible-run:
	bash ./scripts/ansible-bootstrap.sh run

lambda-package:
	bash ./scripts/package-lambdas.sh

lambda-smoke:
	bash ./scripts/invoke-lambdas.sh

clean:
	rm -rf dist tmp apps/node-ts/node_modules apps/node-ts/dist apps/java/target apps/go/server apps/go/server.exe lambdas/node-ts/node_modules lambdas/node-ts/build lambdas/go/main lambdas/go/bootstrap lambdas/java/target infra/terraform/localstack/.terraform infra/terraform/localstack/.terraform.lock.hcl infra/terraform/localstack/terraform.tfstate* || true
