# Kubernetes

## Layout

- `k8s/base/` shared manifests
- `k8s/overlays/local/` local image tags and labels
- `k8s/kind/cluster.yaml` kind cluster definition

## Resources

The base manifests include:

- namespace
- shared `ConfigMap`
- local demo `Secret`
- deployments for Node, Go, Java, and PHP
- services for Node, Go, Java, and PHP
- ingress for path-based routing

## Validation

```bash
make k8s-validate
```

This renders the local overlay and verifies that the expected workload kinds are present in the output.

## kind path

```bash
bash ./scripts/kind-bootstrap.sh
make k8s-apply
```

The kind cluster exposes the ingress controller through host port `8090`.

## Image expectations

The local overlay references the same image names built by Compose:

- `platform-delivery-lab/node-ts:dev`
- `platform-delivery-lab/go:dev`
- `platform-delivery-lab/java:dev`
- `platform-delivery-lab/php:dev`
