# Topology

## Service map

| Component | Runtime | Internal port | External port | Notes |
| --- | --- | --- | --- | --- |
| `node-app` | Node.js/TypeScript | `3007` | `3007` | Direct diagnostics and Nginx upstream |
| `go-app` | Go | `3008` | `3008` | Direct diagnostics and Nginx upstream |
| `java-app` | Java 11 | `3009` | `3009` | Direct diagnostics and Apache upstream |
| `php-app` | PHP 8.3 | `3010` | `3010` | Direct diagnostics and Apache upstream |
| `nginx` | Nginx | `80` | `8085` | Primary edge entrypoint |
| `apache` | Apache HTTP Server | `80` | `8086` | Legacy/runtime slice and diagnostics |
| `localstack` | LocalStack | `4566` | `4566` | Lambda, IAM, Logs, S3 |

## Route ownership

| Route | Owner | Upstream |
| --- | --- | --- |
| `/api/node/*` | Nginx | `node-app` |
| `/api/go/*` | Nginx | `go-app` |
| `/legacy/php/*` | Nginx | Apache, then `php-app` |
| `/legacy/java/*` | Nginx | Apache, then `java-app` |
| `/diagnostics/apache-status` | Nginx | Apache |
| `/php/*` | Apache | `php-app` |
| `/java/*` | Apache | `java-app` |
| `/server-status` | Apache | Apache mod_status |

## Kubernetes topology

The Kubernetes overlay mirrors the service layout without reproducing both proxies in-cluster. The local overlay includes:

- one namespace
- one shared `ConfigMap`
- one local demo `Secret`
- four deployments
- four services
- one ingress with path-based routing

For kind, the ingress path is exposed through:

- host port `8090` for HTTP
- host port `8443` for HTTPS
