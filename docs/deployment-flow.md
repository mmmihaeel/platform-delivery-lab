# Deployment Flow

## Summary

The repository has four operator flows that fit together:

| Flow | Goal | Primary commands |
| --- | --- | --- |
| Local runtime | Start the Compose platform and validate routing | `make bootstrap`, `make up`, `make smoke` |
| LocalStack Lambda | Package and apply the executable Lambda path | `make lambda-package`, `make tf-apply-localstack`, `make lambda-smoke` |
| Kubernetes | Validate or apply the local cluster path | `make k8s-validate`, `bash ./scripts/kind-bootstrap.sh`, `make k8s-apply` |
| CI integration | Re-run the same local-first controls in hosted CI | `make validate`, `make up`, `make smoke`, `make tf-apply-localstack`, `make lambda-smoke` |

## Compose flow

```bash
make bootstrap
make up
make smoke
make down
```

This is the default operator path for reviewers. It proves the packaging, routing, and proxy diagnostics story before the serverless workflow is applied.

## LocalStack flow

```bash
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

This flow packages all Lambda runtimes, deploys the executable Node and Java functions with Terraform, and validates the local PHP handler contract alongside the deployed functions.

## Kubernetes flow

```bash
make k8s-validate
bash ./scripts/kind-bootstrap.sh
make k8s-apply
kubectl get all -n platform-delivery-lab
```

The Kubernetes path is local and explicit. It is not represented as a managed-cloud deployment.

## CI flow

Both CI systems split the workflow into:

1. a validation phase
2. an integration phase with the Compose stack and LocalStack
3. teardown of the ephemeral runtime environment

## Related documents

- [quickstart.md](quickstart.md)
- [ci-cd.md](ci-cd.md)
- [terraform.md](terraform.md)
- [kubernetes.md](kubernetes.md)
