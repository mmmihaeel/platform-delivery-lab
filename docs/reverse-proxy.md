# Reverse Proxy

## Summary

The proxy layer is intentionally two-tier:

- Nginx is the edge gateway
- Apache owns the Java and PHP runtime slice plus server diagnostics

That split makes the routing model clear and gives the repository a stronger traffic story than a single catch-all proxy.

## Nginx responsibilities

Nginx listens on `:8085` and owns:

- `/healthz`
- `/diagnostics/routes`
- `/api/node/*`
- `/api/go/*`
- `/legacy/*`
- `/diagnostics/apache-status`

`/legacy/*` is deliberately chained through Apache.

## Apache responsibilities

Apache listens on `:8086` and owns:

- `/healthz`
- `/routes`
- `/php/*`
- `/java/*`
- `/legacy/php/*`
- `/legacy/java/*`
- `/server-status`

## Route model

| Route | Traffic path |
| --- | --- |
| `/api/node/*` | Nginx -> Node |
| `/api/go/*` | Nginx -> Go |
| `/legacy/php/*` | Nginx -> Apache -> PHP |
| `/legacy/java/*` | Nginx -> Apache -> Java |
| `/php/*` | Apache -> PHP |
| `/java/*` | Apache -> Java |
| `/diagnostics/apache-status` | Nginx -> Apache `server-status` |

## Diagnostics

| Endpoint | Purpose |
| --- | --- |
| `http://127.0.0.1:8085/diagnostics/routes` | Nginx route map |
| `http://127.0.0.1:8085/diagnostics/apache-status?auto` | Apache status through Nginx |
| `http://127.0.0.1:8086/routes` | Apache route map |
| `http://127.0.0.1:8086/server-status?auto` | Direct Apache status |

## Related documents

- [topology.md](topology.md)
- [runbooks.md](runbooks.md)
- [quickstart.md](quickstart.md)
