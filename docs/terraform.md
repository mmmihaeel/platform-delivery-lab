# Terraform

## Executable stack

`infra/terraform/localstack` is the executable Terraform path. It contains:

- provider configuration for LocalStack
- reusable naming inputs through `platform_context`
- reusable Lambda deployment logic through `lambda_function`
- Node and Java Lambda deployment
- packaged-only outputs for Go and PHP artifacts

## Commands

```bash
make tf-init
make tf-validate
make tf-apply-localstack
```

## Module structure

- `modules/platform_context`
- `modules/lambda_function`

## Reference layouts

The following directories are reviewable cloud-specific reference layouts:

- `infra/terraform/aws`
- `infra/terraform/azure`
- `infra/terraform/gcp`

They preserve provider and variable structure without claiming that the repository provisions paid environments by default.
