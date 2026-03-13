# Kubernetes

## Goal

The Kubernetes path shows how the same service set can be represented as clean local manifests and applied to a kind cluster. It is a local deployment path, not a managed-cluster claim.

## Layout

| Path | Purpose |
| --- | --- |
| `k8s/base/` | Shared manifests for namespace, config, secret, deployments, services, and ingress |
| `k8s/overlays/local/` | Local image tags and environment labels |
| `k8s/kind/cluster.yaml` | kind cluster definition with ingress-friendly host ports |

## Resources in scope

The base manifests include:

- one namespace
- one shared `ConfigMap`
- one demo `Secret`
- four deployments
- four services
- one ingress

The ingress routes `/node`, `/go`, `/java`, and `/php` to the corresponding services.

## Validation

```bash
make k8s-validate
```

That command renders the local overlay and validates that the expected workload kinds appear in the output. It is the default repository-level Kubernetes check.

## kind workflow

```bash
bash ./scripts/kind-bootstrap.sh
make k8s-apply
kubectl get all -n platform-delivery-lab
```

When kind is used, the ingress controller is exposed through:

- `http://127.0.0.1:8090`
- `https://127.0.0.1:8443`

## Image expectations

The local overlay references the same image names built for the Compose path:

- `platform-delivery-lab/node-ts:dev`
- `platform-delivery-lab/go:dev`
- `platform-delivery-lab/java:dev`
- `platform-delivery-lab/php:dev`

## Boundary

This path is intended for local rendering and local cluster validation. It is not used as the default CI integration target and it does not imply AKS, EKS, GKE, or another managed platform.

## Related documents

- [topology.md](topology.md)
- [deployment-flow.md](deployment-flow.md)
- [quickstart.md](quickstart.md)
