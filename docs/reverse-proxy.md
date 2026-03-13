# Reverse Proxy

## Nginx

Nginx is the default edge gateway. It terminates the public local routes on `:8085` and owns:

- `/healthz`
- `/diagnostics/routes`
- `/api/node/*`
- `/api/go/*`
- `/legacy/*`
- `/diagnostics/apache-status`

The `/legacy/*` path is intentionally chained through Apache so the platform has one clear ingress tier and one downstream runtime-specific tier.

## Apache

Apache listens on `:8086` and owns:

- `/healthz`
- `/routes`
- `/php/*`
- `/java/*`
- `/legacy/php/*`
- `/legacy/java/*`
- `/server-status`

Apache is where the Java and PHP runtime slice lives. That keeps the routing split deliberate:

- Nginx: edge concerns and direct Node/Go routes
- Apache: runtime slice, legacy path handling, diagnostics

## Diagnostic flow

- `http://127.0.0.1:8085/diagnostics/routes`
- `http://127.0.0.1:8085/diagnostics/apache-status?auto`
- `http://127.0.0.1:8086/routes`
- `http://127.0.0.1:8086/server-status?auto`
