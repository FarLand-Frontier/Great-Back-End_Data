# Great Back End — Design v1

## Mission (10-day demo)
Deliver an iPhone-installable PWA demo by anniversary date, focused on reducing OpenClaw operation complexity.

## Confirmed decisions
- Product line: A (PWA) primary, B (native shell) reserved.
- First screen: Chat-first (ChatGPT-like).
- Editable copy: Admin editable + write-back to data repo + git versioning.
- Permission model for partner: B (chat + copy editing), no root controls.
- Isolation model: logical isolation on same server via `lighthouse` user and separate OpenClaw instance.

## Architecture
- Edge: Cloudflare Tunnel + Access
- App: Next.js (web + API/BFF)
- Storage: Postgres (config, session metadata, audit logs)
- Agent bridge: server-side only to OpenClaw gateways
- Gateway split:
  - root user instance (owner)
  - lighthouse instance (partner sandbox)

## Hard design principles
1. **Repo independence is mandatory**
   - `code` contains executable source only.
   - `data` contains mutable content/config/docs only.
2. **One-way invocation**
   - code reads data via versioned API/files; data never imports code.
3. **No cross-repo secret leakage**
   - `.env*` ignored everywhere; no secret in data repo.
4. **Write-back contract**
   - Admin content edits => persist to DB => export to `data/config/*.json` => auto-commit with audit info.
5. **Auditability first**
   - Every dashboard config change records actor/time/diff.

## .gitignore baseline
- code: node_modules, .next, dist, coverage, .env*, logs, temp artifacts
- data: .env*, generated cache, sync temp files; docs/config are tracked

## User experience (MVP)
- Installable PWA (iOS Add to Home Screen)
- Chat with preconfigured agent
- New chat / history list
- Dashboard: token usage, task status/progress, health summary
- Secure terminal panel (restricted commands / sandbox scope)
- Push notifications: task completion, failures, replies

## Risks
- iOS web push compatibility/permission friction
- terminal safety boundaries
- OpenClaw multi-instance stability under one host
