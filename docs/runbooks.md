# Runbooks

## Use these runbooks for

- stack startup failures
- proxy routing issues
- LocalStack and Lambda issues
- Kubernetes render problems
- workspace reset after a broken validation run

## Stack does not start

```bash
docker compose ps
docker compose logs --tail=100
```

If one service is unhealthy, inspect its direct health endpoint and the container logs before debugging the proxies.

## Proxy route fails

Check the direct services first:

```bash
curl -fsS http://127.0.0.1:3007/status
curl -fsS http://127.0.0.1:3008/status
curl -fsS http://127.0.0.1:3009/status
curl -fsS http://127.0.0.1:3010/status
```

Then compare routed access:

```bash
curl -fsS http://127.0.0.1:8085/api/node/status
curl -fsS http://127.0.0.1:8085/api/go/status
curl -fsS http://127.0.0.1:8086/java/status
curl -fsS http://127.0.0.1:8086/php/status
```

## LocalStack Lambda issue

```bash
docker compose logs localstack
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

If Terraform succeeds but Lambda invocation fails, verify LocalStack health and the function names returned by Terraform outputs.

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

## Related documents

- [quickstart.md](quickstart.md)
- [reverse-proxy.md](reverse-proxy.md)
- [localstack-lambda.md](localstack-lambda.md)
