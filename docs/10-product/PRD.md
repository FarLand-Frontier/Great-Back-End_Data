# PRD (MVP)

## Goal
Build a secure web admin panel to interact with OpenClaw without SSH port-forwarding.

## Scope (M1)
- Login (MFA-ready)
- Chat with main agent
- Basic status dashboard
- Audit log (login + operations)

## Non-goals (M1)
- Multi-tenant isolation
- Billing
- Complex workflow automation

## Success Metrics
- Stable web access from local browser
- No direct public exposure of OpenClaw localhost endpoint
- Core flows usable within 3 days
