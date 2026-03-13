# Quickstart

## Prerequisites

- Docker Desktop or an equivalent Docker engine
- Bash
- Make
- Terraform
- `kubectl`
- `kind` for the live Kubernetes path

## First successful run

```bash
make bootstrap
make up
make smoke
```

Expected result:

- all service containers are healthy
- Nginx and Apache routes respond
- LocalStack health is reachable

## Lambda workflow

```bash
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

Expected result:

- all Lambda packages are written to `dist/lambdas/`
- Terraform deploys the LocalStack stack
- Node and Java functions invoke successfully
- the local PHP handler contract is validated

## Tear down

```bash
make down
```
