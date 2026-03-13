# Deployment Flow

## Compose flow

1. `make bootstrap`
2. `make up`
3. `make smoke`
4. `make down`

## LocalStack flow

1. `make lambda-package`
2. `make tf-apply-localstack`
3. `make lambda-smoke`

## Kubernetes flow

1. `bash ./scripts/kind-bootstrap.sh`
2. `make k8s-apply`
3. `kubectl get all -n platform-delivery-lab`

## Validation flow

1. `make validate`
2. `make up`
3. `make smoke`
4. `make tf-apply-localstack`
5. `make lambda-smoke`
