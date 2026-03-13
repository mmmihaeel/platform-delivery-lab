# Security

## Scope

This repository is built for local validation and review, not for production hardening claims. Even within that boundary, the defaults are intentionally disciplined.

## Baseline posture

| Area | Default posture |
| --- | --- |
| Secrets | No committed `.env`, local demo secret values only |
| Network exposure | Service ports published on loopback only |
| Serverless emulation | LocalStack instead of a paid AWS account |
| Validation | CI reruns packaging, smoke, and LocalStack checks |

## Local secrets handling

- `.env` is created locally from `.env.example` and ignored by Git
- Kubernetes secrets are demo-only values intended for local review
- generated artifacts and temporary state are written under ignored paths such as `dist/` and `tmp/`

## Container posture

- reviewer-facing access goes through Nginx and Apache rather than broad host exposure
- application services use purpose-specific images per runtime
- diagnostic ports remain on `127.0.0.1` for local-only access

## Dependency and supply chain posture

- Node dependencies are lockfile-backed
- Terraform versions are pinned in CI
- the validation flow rebuilds and repackages Lambda artifacts on each run

## Boundary

The repository does not claim:

- hardened production deployment defaults
- managed secret storage
- cloud IAM hardening beyond the local emulation path

## Related documents

- [architecture.md](architecture.md)
- [runbooks.md](runbooks.md)
- [ci-cd.md](ci-cd.md)
