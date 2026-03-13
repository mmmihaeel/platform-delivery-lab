# LocalStack Lambda

## Packaged runtimes

The repository packages Lambda artifacts for:

- Node.js/TypeScript
- Go
- Java
- PHP custom-runtime bundle

Artifacts are written to `dist/lambdas/`.

## Default deploy path

The executable LocalStack Terraform stack deploys:

- `platform-delivery-lab-node-runtime`
- `platform-delivery-lab-java-runtime`

## Packaged-only artifacts

The default workflow keeps these artifacts packaged and locally validated without invoking them in LocalStack:

- Go
- PHP

That boundary is deliberate. The artifacts remain part of the multi-runtime packaging story, while the default LocalStack smoke path stays stable on this host profile.

## Commands

```bash
make lambda-package
make tf-apply-localstack
make lambda-smoke
```
