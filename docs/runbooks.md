# Runbooks

## Stack does not start

```bash
docker compose ps
docker compose logs --tail=100
```

## Proxy route fails

Check the direct service first:

```bash
curl.exe -fsS http://127.0.0.1:3007/status
curl.exe -fsS http://127.0.0.1:3008/status
curl.exe -fsS http://127.0.0.1:3009/status
curl.exe -fsS http://127.0.0.1:3010/status
```

Then compare the routed path:

```bash
curl.exe -fsS http://127.0.0.1:8085/api/node/status
curl.exe -fsS http://127.0.0.1:8086/java/status
```

## LocalStack Lambda issue

```bash
docker compose logs localstack
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

## Kubernetes render issue

```bash
make k8s-validate
kubectl kustomize k8s/overlays/local
```

## Reset the workspace

```bash
make down
make clean
make bootstrap
```
