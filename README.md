# platform-delivery-lab

`platform-delivery-lab` is a local-first platform engineering repository that packages four runtime services, routes them through Nginx and Apache, deploys Lambda workloads into LocalStack with Terraform, validates a Kubernetes path for kind, and wraps the operator flow with Make, Bash, Ansible, GitHub Actions, and Azure DevOps.

## Why this repository exists

The project shows how to package, route, validate, and operate a small multi-runtime platform without depending on paid cloud accounts. It is scoped for a portfolio repository, but every visible workflow is built to be runnable, reviewable, and operationally coherent.

## Feature highlights

- Multi-service Docker packaging for Node.js/TypeScript, Go, Java, and PHP workloads
- Primary edge routing through Nginx, with Apache handling the Java and PHP slice plus diagnostics
- LocalStack-backed Lambda packaging across Node.js/TypeScript, Go, Java, and PHP
- Executable Terraform stack for LocalStack, plus AWS, Azure, and GCP reference layouts
- Kubernetes base and local overlay structure for kind-based local deployment
- Ansible bootstrap workflow for workspace preparation and repository contract checks
- Make and Bash as the primary operator interface
- Validation pipelines in both GitHub Actions and Azure DevOps

## Technology stack

- Docker and Docker Compose
- Nginx and Apache HTTP Server
- Kubernetes and kind
- Terraform
- Ansible
- LocalStack
- Make
- Bash
- GitHub Actions
- Azure DevOps

## Architecture summary

The Compose stack exposes four runtime services directly on loopback-only ports for diagnostics and through two reverse proxies for routed access. Nginx is the default edge entrypoint on `:8085`; it owns the Node and Go paths and forwards the legacy path family to Apache. Apache listens on `:8086`, terminates the Java and PHP routes, and exposes `server-status` for diagnostics.

The infrastructure story is deliberately split into executable and reference layers. `infra/terraform/localstack` provisions a real LocalStack Lambda stack. `infra/terraform/aws`, `azure`, and `gcp` keep the same naming and variable conventions but remain reference-grade layouts. The Kubernetes path follows the same principle: manifests are valid, local-first, and kind-oriented, but they do not claim a managed-cloud deployment.

## Local topology

| Surface | Endpoint | Purpose |
| --- | --- | --- |
| Nginx | `http://127.0.0.1:8085/healthz` | Edge gateway health |
| Nginx | `http://127.0.0.1:8085/api/node/status` | Node service through Nginx |
| Nginx | `http://127.0.0.1:8085/api/go/status` | Go service through Nginx |
| Nginx | `http://127.0.0.1:8085/legacy/php/status` | PHP service through Apache via Nginx |
| Nginx | `http://127.0.0.1:8085/legacy/java/status` | Java service through Apache via Nginx |
| Apache | `http://127.0.0.1:8086/healthz` | Apache health |
| Apache | `http://127.0.0.1:8086/php/status` | PHP service through Apache |
| Apache | `http://127.0.0.1:8086/java/status` | Java service through Apache |
| Apache | `http://127.0.0.1:8086/server-status?auto` | Apache diagnostics |
| Direct service | `http://127.0.0.1:3007/status` | Node runtime API |
| Direct service | `http://127.0.0.1:3008/status` | Go runtime API |
| Direct service | `http://127.0.0.1:3009/status` | Java runtime API |
| Direct service | `http://127.0.0.1:3010/status` | PHP runtime API |
| LocalStack | `http://127.0.0.1:4566/_localstack/health` | LocalStack control plane |

## Quickstart

```bash
make bootstrap
make up
make smoke
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

Shut the platform down with:

```bash
make down
```

## Operator commands

```bash
make validate
make docker-validate
make lint
make k8s-validate
make tf-init
make tf-validate
make ansible-check
make lambda-package
make lambda-smoke
```

## Reverse proxy model

- Nginx is the primary edge layer. It owns `/api/node/`, `/api/go/`, `/legacy/`, and `/diagnostics/apache-status`.
- Apache owns `/php/`, `/java/`, `/legacy/php/`, `/legacy/java/`, and `/server-status`.
- Direct service ports stay published only on loopback for diagnostics, smoke tests, and local comparison.

## Kubernetes path

`k8s/base` defines the namespace, shared config, four deployments, four services, and an ingress resource. `k8s/overlays/local` is the default local overlay. `k8s/kind/cluster.yaml` defines the kind cluster shape and ingress-facing host ports.

Validation does not require a live cluster:

```bash
make k8s-validate
```

For a live local cluster:

```bash
bash ./scripts/kind-bootstrap.sh
make k8s-apply
```

## Terraform path

`infra/terraform/localstack` is the executable stack. It creates the LocalStack IAM role, deploys Node and Java Lambda functions, and exposes packaged Go and PHP artifacts as outputs for follow-on work.

The cloud-specific directories are intentionally honest reference layouts:

- `infra/terraform/aws`
- `infra/terraform/azure`
- `infra/terraform/gcp`

They preserve provider, variable, and naming conventions without pretending that the repository provisions paid environments by default.

## Ansible path

Ansible handles workspace bootstrap and repository contract checks through:

- `ansible/playbooks/bootstrap.yml`
- `ansible/playbooks/validate.yml`

The repository uses a containerized Ansible runner fallback when a local `ansible-playbook` binary is unavailable.

## LocalStack and Lambda path

`make lambda-package` builds all four Lambda artifacts locally:

- Node.js/TypeScript
- Go
- Java
- PHP custom-runtime bundle

`make tf-apply-localstack` deploys the Node and Java functions to LocalStack and keeps the Go and PHP packages available as packaged-only artifacts. `make lambda-smoke` invokes the deployed Node and Java functions and validates the local PHP handler contract.

## CI/CD

GitHub Actions and Azure DevOps both run the same local-first validation flow:

- repository validation
- Lambda packaging
- Terraform validation
- Kubernetes manifest rendering
- Compose startup
- proxy and service smoke tests
- LocalStack Terraform apply
- LocalStack Lambda smoke tests

## Repository structure

- `apps/` runtime services
- `ansible/` inventory, group variables, and playbooks
- `docker/` proxy and runner definitions
- `docs/` architecture, topology, workflows, runbooks, and boundaries
- `infra/localstack/` LocalStack ready hooks
- `infra/terraform/` executable and reference Terraform layouts
- `k8s/` Kubernetes base, overlay, and kind assets
- `lambdas/` multi-runtime Lambda source code
- `scripts/` Bash automation

## Scope boundaries

- The repository is local-first and portfolio-oriented.
- LocalStack replaces paid AWS infrastructure for the executable serverless path.
- The AWS, Azure, and GCP Terraform directories are reference architectures, not claimed live environments.
- Node and Java Lambda functions are part of the default LocalStack smoke flow.
- Go and PHP Lambda artifacts are packaged and validated locally; they are intentionally kept outside the default LocalStack invoke path to avoid flaky runtime behavior on this host profile.

## Future improvements

- Add kubeconform or policy-as-code validation for the Kubernetes overlay
- Add image signing and SBOM generation to the CI flow
- Extend the packaged-only Go and PHP Lambda artifacts into alternative LocalStack execution paths when the host runtime is known-good

## Documentation

- [architecture.md](docs/architecture.md)
- [topology.md](docs/topology.md)
- [quickstart.md](docs/quickstart.md)
- [reverse-proxy.md](docs/reverse-proxy.md)
- [deployment-flow.md](docs/deployment-flow.md)
- [kubernetes.md](docs/kubernetes.md)
- [terraform.md](docs/terraform.md)
- [ansible.md](docs/ansible.md)
- [localstack-lambda.md](docs/localstack-lambda.md)
- [ci-cd.md](docs/ci-cd.md)
- [runbooks.md](docs/runbooks.md)
- [security.md](docs/security.md)
- [roadmap.md](docs/roadmap.md)
