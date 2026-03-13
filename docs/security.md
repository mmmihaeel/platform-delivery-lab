# Security

## Scope

The repository is built for local validation and review. It does not claim hardened production deployment, but it does keep the defaults disciplined:

- no committed secrets
- loopback-only service publishing
- explicit `.env.example`
- LocalStack instead of paid AWS accounts

## Local secrets handling

- `.env` is created locally and ignored by Git
- Kubernetes secrets are local demo values only
- Lambda packages and temporary artifacts live under ignored paths

## Container posture

- application services run with minimal images where practical
- direct ports stay published on `127.0.0.1`
- reverse proxies own the reviewer-facing entrypoints

## Supply chain posture

- Node dependencies are lockfile-backed
- Terraform providers are version-pinned
- CI validates packaging and smoke paths on every change
