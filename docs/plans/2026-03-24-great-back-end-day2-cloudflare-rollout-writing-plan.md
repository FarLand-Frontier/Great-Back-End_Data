# Great Back End — Day 2 Cloudflare Rollout Writing Plan

> **Goal:** Make the site externally reachable through Cloudflare with controlled authentication and safe rollback.

## Outcome Definition (Day 2)

By end of Day 2:
- External URL is reachable from public network.
- Access authentication is enforced.
- Unauthorized users cannot call any API.
- Role behavior matches baseline (`developer` / `user` / `unauthentic-user`).
- Rollback path is tested and documented.

---

## Task 1: Environment readiness and config freeze

**Files:**
- Update: `data/docs/ops/LIGHTHOUSE_ISOLATION_CHECKLIST.md`
- Create: `data/docs/ops/CLOUDFLARE_DAY2_BASELINE.md`

**Steps:**
1. Record target app URL, local upstream target, and planned Cloudflare app name.
2. Freeze baseline env keys:
   - `CF_ACCESS_AUD`
   - `ACCESS_DEVELOPER_EMAILS`
   - `NEXT_PUBLIC_AUTH_ENTRY_URL`
3. Confirm local app health before edge rollout:
   - `pnpm -C code/apps/web test`
   - `pnpm -C code/apps/web build`

**Verification:**
- Baseline doc exists and contains full key/value owner map (values can be masked).

---

## Task 2: Cloudflare Tunnel provisioning

**Files:**
- Create: `data/docs/ops/CLOUDFLARE_TUNNEL_RUNBOOK.md`

**Steps:**
1. Create/verify tunnel.
2. Bind hostname to tunnel (DNS CNAME via Cloudflare).
3. Route tunnel to Lighthouse web upstream.
4. Validate edge-to-origin connectivity with temporary allow policy.

**Verification:**
- External hostname resolves and returns app response (before Access lock-down test).

**Progress Note (Task 2):**
- Status: ✅ Runbook drafted at `data/docs/ops/CLOUDFLARE_TUNNEL_RUNBOOK.md`.
- Coverage: prerequisites, tunnel create/verify, DNS binding, Lighthouse upstream routing, validation checklist, rollback quick actions.

**Evidence Placeholders:**
- Tunnel UUID: `<EVIDENCE_TUNNEL_UUID>`
- Hostname: `<EVIDENCE_HOSTNAME>`
- `cloudflared tunnel list` output/snippet: `<EVIDENCE_TUNNEL_LIST>`
- DNS resolution proof (`dig +short`): `<EVIDENCE_DNS_RESULT>`
- External curl response (`curl -I https://...`): `<EVIDENCE_EDGE_RESPONSE>`
- Rollback rehearsal note: `<EVIDENCE_ROLLBACK_NOTE>`

---

## Task 3: Cloudflare Access app and policy setup

**Files:**
- Create: `data/docs/ops/CLOUDFLARE_ACCESS_POLICY_DAY2.md`

**Steps:**
1. Create Access application for Day-2 hostname.
2. Configure IdP auth flow (existing provider).
3. Set session policy (target: 7–30 days for MVP).
4. Define allowlist identities/groups for initial rollout.
5. Capture Access audience value and map to `CF_ACCESS_AUD`.

**Verification:**
- Unauthenticated browser requests are challenged.
- Authenticated developer requests pass.

---

## Task 4: App-side auth/role integration verification

**Files:**
- Update: `data/docs/ops/DAY1_CLOSURE_VERIFICATION.md`
- Create: `data/docs/ops/DAY2_EXTERNAL_ACCESS_VERIFICATION.md`

**Steps:**
1. Verify API behavior:
   - unauthentic user: all API denied
   - user: business APIs only
   - developer: full APIs including admin copy/save
2. Verify page behavior:
   - unauth page shown first, then countdown redirect
3. Verify `aud` mismatch rejection.

**Verification commands:**
- `pnpm -C code/apps/web test`
- `pnpm -C code/apps/web build`
- endpoint smoke checks from external network

---

## Task 5: Rollback rehearsal and incident controls

**Files:**
- Create: `data/docs/ops/CLOUDFLARE_DAY2_ROLLBACK.md`

**Steps:**
1. Define one-command rollback actions:
   - disable/adjust Access policy
   - switch DNS target or pause tunnel route
2. Validate rollback and restore once.
3. Record mean recovery time.

**Verification:**
- Rollback path executed at least once in rehearsal.

---

## Task 6: Governance close-out

**Files:**
- Update: `data/docs/plans/2026-03-24-great-back-end-day2-cloudflare-rollout-writing-plan.md`
- Update: `data/docs/30-planning/MILESTONES.md`
- Update: `data/docs/PROJECT_OVERVIEW.md`

**Steps:**
1. Mark completed checks with evidence links.
2. Commit and push data repo updates.
3. Sync final Day-2 status to Notion (临时指挥所 / Progression).

---

## Acceptance Criteria

- External URL is reachable.
- Access login and session behavior works as intended.
- API deny/allow matrix matches role policy.
- `aud` verification is active.
- Rollback runbook exists and was rehearsal-tested.
- Docs + milestones + Notion are synced.
