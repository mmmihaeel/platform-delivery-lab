# Roadmap

## Near-term improvements

- add policy validation for Terraform and Kubernetes resources
- add SBOM generation and image-signing examples to the CI path
- add optional host-specific LocalStack execution profiles for the packaged-only Go and PHP Lambda artifacts

## Later improvements

- add lightweight local observability examples such as metrics or traces
- add richer release metadata around packaged artifacts
- add a second Kubernetes overlay for a more production-shaped local review path

## Guardrails

Future changes should preserve the current repository character:

- local-first by default
- clear executable versus reference boundaries
- no paid-cloud requirement for the main review path
