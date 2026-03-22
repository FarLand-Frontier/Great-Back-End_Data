# Architecture v1

- Edge: Cloudflare Tunnel + Access
- App: Next.js (web + API)
- Data: Postgres (+ Prisma)
- Agent bridge: server-side proxy to OpenClaw gateway (loopback)

## Security
- OpenClaw gateway remains 127.0.0.1 only
- Access policy enforced by Cloudflare Access
- App-level RBAC and audit logging
