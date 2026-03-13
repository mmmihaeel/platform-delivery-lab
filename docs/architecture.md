# Architecture

## Summary

`platform-delivery-lab` models a compact local platform with four application runtimes, two reverse proxies, one executable LocalStack-backed Terraform path, a local Kubernetes path, and a delivery layer that mirrors the same operator workflow in CI.

The repository is intentionally local-first. It is designed to show packaging discipline, routing design, infrastructure structure, and validation quality without implying managed-cloud deployment.

## Platform layers

| Layer | Components | Design intent |
| --- | --- | --- |
| Operator interface | Make, Bash, Ansible | Keep the default workflow discoverable and reproducible |
| Runtime platform | Docker Compose, Nginx, Apache, Node, Go, Java, PHP | Provide one reviewable local runtime surface with direct and proxied paths |
| Serverless path | LocalStack, Terraform, Lambda packages | Demonstrate packaging and deployment structure without paid AWS usage |
| Kubernetes path | k8s manifests, Kustomize overlay, kind | Show a clean local cluster path alongside Compose |
| Delivery layer | GitHub Actions, Azure DevOps | Reuse the same local-first controls in CI |

## Design decisions

### Local-first by default

Every default path runs on a workstation or inside a CI runner through Docker, LocalStack, or a kind cluster. The repository does not depend on a paid cloud account for its executable workflows.

### Deliberate reverse proxy split

Nginx is the primary edge tier. Apache owns the Java and PHP runtime slice and exposes proxy diagnostics. That makes both proxies part of one traffic story instead of parallel examples.

### Shared runtime contract

Each demo service exposes:

- `/healthz`
- `/status`
- consistent JSON metadata for service name, runtime, environment, and request context

The shared contract keeps smoke checks, docs, and reviewer expectations aligned across all four runtimes.

### Executable versus reference infrastructure

The Terraform layout distinguishes between:

- executable infrastructure under `infra/terraform/localstack`
- reference architecture layouts under `infra/terraform/aws`, `infra/terraform/azure`, and `infra/terraform/gcp`

That split keeps the repository honest. Reviewers can inspect cross-cloud structure without the documentation overstating what the repository applies by default.

### Explicit Lambda execution boundary

All four Lambda runtimes are packaged locally. Node and Java are part of the default LocalStack deploy and invoke path. Go and PHP remain part of the packaging story without being presented as a larger default LocalStack execution matrix than the local environment consistently supports.

## Execution boundaries

| Area | Default status |
| --- | --- |
| Docker Compose platform | Executable |
| Reverse proxy routing | Executable |
| LocalStack Lambda packaging | Executable |
| LocalStack Terraform apply | Executable |
| Kubernetes render path | Executable |
| kind-based cluster path | Executable when kind is available |
| AWS / Azure / GCP Terraform layouts | Reference only |

## Related documents

- [quickstart.md](quickstart.md)
- [topology.md](topology.md)
- [reverse-proxy.md](reverse-proxy.md)
- [terraform.md](terraform.md)
- [ci-cd.md](ci-cd.md)
