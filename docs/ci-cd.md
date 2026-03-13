# CI/CD

## GitHub Actions

`.github/workflows/ci.yml` runs:

- `make validate`
- `make up`
- `make smoke`
- `make tf-apply-localstack`
- `make lambda-smoke`

## Azure DevOps

`azure-pipelines.yml` mirrors the same split:

- static validation stage
- integration stage with Compose and LocalStack

## Validation parity

Both systems are intentionally aligned with the local operator flow. The pipelines validate packaging, routing, Terraform structure, Kubernetes rendering, Ansible syntax, and the LocalStack Lambda path instead of pretending to deploy to a real cloud environment.
