# LocalStack Lambda

## Summary

The Lambda layer is built around two ideas:

- package all four runtimes locally
- keep the default executable LocalStack path stable and explicit

## Packaging matrix

| Runtime | Source path | Output |
| --- | --- | --- |
| Node.js / TypeScript | `lambdas/node-ts` | `dist/lambdas/node-ts/function.zip` |
| Go | `lambdas/go` | `dist/lambdas/go/function.zip` |
| Java | `lambdas/java` | `dist/lambdas/java/function.zip` |
| PHP custom runtime | `lambdas/php` | `dist/lambdas/php/function.zip` |

## Default deploy path

The executable Terraform stack deploys these functions to LocalStack:

- `platform-delivery-lab-node-runtime`
- `platform-delivery-lab-java-runtime`

## Packaged-only artifacts

These runtimes remain part of the packaging story without being part of the default LocalStack deploy path:

- Go
- PHP

That boundary is intentional. It keeps the repository honest about what is consistently exercised in the local environment while still demonstrating multi-runtime packaging.

## Commands

```bash
make lambda-package
make tf-apply-localstack
make lambda-smoke
```

## Validation model

`make lambda-smoke` validates:

- Node and Java through LocalStack invocation
- PHP through the local handler contract
- packaged artifact presence for Go

## Related documents

- [terraform.md](terraform.md)
- [deployment-flow.md](deployment-flow.md)
- [runbooks.md](runbooks.md)
