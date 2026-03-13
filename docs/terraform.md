# Terraform

## Summary

Terraform is one of the strongest visible pieces of the repository. The structure is split into one executable path and three reviewable reference layouts.

## Executable stack

`infra/terraform/localstack` is the active Terraform stack. It contains:

- LocalStack-aware AWS provider configuration
- shared naming inputs through `modules/platform_context`
- reusable Lambda deployment logic through `modules/lambda_function`
- an executable IAM role for LocalStack Lambda
- Node and Java Lambda deployment resources
- outputs for the packaged-only Go and PHP artifacts

## Resources created by the executable path

| Resource type | Purpose |
| --- | --- |
| IAM role | Execution role for LocalStack Lambda resources |
| Lambda function | Node.js / TypeScript runtime example |
| Lambda function | Java runtime example |
| CloudWatch log groups | LocalStack-backed logging surface for deployed functions |

## Commands

```bash
make tf-init
make tf-validate
make tf-apply-localstack
make tf-destroy-localstack
```

## Module structure

| Module | Responsibility |
| --- | --- |
| `modules/platform_context` | Naming, labels, and environment metadata |
| `modules/lambda_function` | Reusable Lambda resource packaging and configuration |

## Reference layouts

The following directories are intentionally reviewable but not part of the default executable flow:

- `infra/terraform/aws`
- `infra/terraform/azure`
- `infra/terraform/gcp`

They preserve naming, variable structure, and provider intent without claiming that the repository provisions paid environments by default.

## Boundary

The repository applies Terraform only to LocalStack in the default path. Any reviewer-facing cloud discussion should treat the AWS, Azure, and GCP directories as architecture reference material.

## Related documents

- [localstack-lambda.md](localstack-lambda.md)
- [architecture.md](architecture.md)
- [ci-cd.md](ci-cd.md)
