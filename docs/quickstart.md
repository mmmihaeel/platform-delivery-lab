# Quickstart

## Prerequisites

- Docker Desktop or another Docker engine with Compose support
- Bash
- Make
- Terraform
- `kubectl` for manifest rendering or cluster inspection
- `kind` only if you want to exercise the live Kubernetes path

## Five-minute path

```bash
make bootstrap
make up
make smoke
```

Expected result:

- all service containers are healthy
- Nginx and Apache health endpoints respond
- direct and proxied status endpoints return the expected service metadata
- LocalStack health is reachable

## Lambda path

```bash
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

Expected result:

- all Lambda artifacts are written under `dist/lambdas/`
- the LocalStack Terraform stack applies successfully
- Node and Java Lambda functions invoke successfully
- the local PHP handler contract validates successfully

## Clean shutdown

```bash
make down
```

## Next documents

- [architecture.md](architecture.md)
- [reverse-proxy.md](reverse-proxy.md)
- [terraform.md](terraform.md)
- [runbooks.md](runbooks.md)
