# Architecture

## Platform shape

The repository models a compact local platform with four runtime services and one serverless control plane:

- Node.js/TypeScript service
- Go service
- Java service
- PHP service
- LocalStack-backed Lambda workloads

The goal is not to simulate a full production estate. The goal is to show how a platform engineer packages and operates multiple runtimes with consistent entrypoints, validation, routing, and infrastructure structure.

## Design decisions

### Local-first by default

Every default workflow runs on a developer workstation through Docker, LocalStack, or a local Kubernetes cluster. The repository avoids cloud-only setup and does not claim live managed environments.

### Two-tier reverse proxy model

Nginx is the default edge entrypoint. Apache owns the Java and PHP slice and exposes server diagnostics. Nginx forwards the legacy routes into Apache, which makes both proxies part of one traffic story instead of parallel decorations.

### Shared runtime contract

Every service exposes:

- `/healthz`
- `/status`
- JSON metadata for service name, runtime, version, environment, request path, and forwarded headers

That shared contract keeps smoke tests and docs consistent across runtimes.

### Executable versus reference infrastructure

The Terraform layout separates real execution from reference architecture:

- `infra/terraform/localstack` is executable and validated
- `infra/terraform/aws`, `azure`, and `gcp` are reference-grade structures using the same naming inputs

### Explicit packaging boundaries for Lambda

All four Lambda runtimes are built locally. Node and Java are part of the default LocalStack invoke path. Go and PHP remain packaged artifacts in the default workflow because their LocalStack execution behavior is less stable on this host profile than the Node and Java paths.

## Operational layers

### Bash and Make

Bash scripts implement the operator workflows and Make keeps them discoverable.

### Ansible

Ansible prepares the workspace and verifies the repository contract.

### CI/CD

GitHub Actions and Azure DevOps call the same local-first validation flow used on a workstation.
