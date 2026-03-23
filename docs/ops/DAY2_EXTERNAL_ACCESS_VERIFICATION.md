# DAY2 External Access Verification

Date: 2026-03-23 (Asia/Shanghai)
Scope: Great Back End Day-2 Task 4 (app-side auth/role integration verification under Cloudflare Access)

## 1) Objective

Verify that external access behavior matches the Day-2 rollout contract:
- `unauthentic-user`: all APIs denied
- `user`: business APIs only
- `developer`: full APIs including `admin/copy` and `admin/copy/save`
- Page behavior for unauthenticated traffic: unauthorized page first, then countdown redirect
- `aud` mismatch must be rejected

All secrets in this document must remain masked.

---

## 2) Verification matrix (expected results)

### Identity/role matrix

| Identity | Business APIs | Admin APIs (`admin/copy`, `admin/copy/save`) | Expected HTTP |
|---|---|---|---|
| `unauthentic-user` | Denied | Denied | `401`/`403` (policy deny)
| `user` | Allowed | Denied | Business: `2xx`; Admin: `403`
| `developer` | Allowed | Allowed | `2xx`

### Page behavior matrix

| Scenario | Expected behavior |
|---|---|
| Unauthenticated page request | Show unauthorized page first |
| Unauthorized page lifecycle | Countdown then redirect to configured auth entry URL |

### Token audience matrix

| Scenario | Expected behavior |
|---|---|
| `aud` matches `CF_ACCESS_AUD` | Token accepted (subject to role policy) |
| `aud` mismatches `CF_ACCESS_AUD` | Request rejected (no role bypass) |

---

## 3) Runbook steps (commands + evidence placeholders)

### A. Local quality gates before external smoke checks

```bash
pnpm -C code/apps/web test
pnpm -C code/apps/web build
```

Evidence placeholders:
- Test result summary: `<EVIDENCE_TEST_SUMMARY>`
- Build result summary: `<EVIDENCE_BUILD_SUMMARY>`

### B. External smoke checks (unauth/user/developer)

Run from an external network path that reaches the Cloudflare hostname.

```bash
# Unauthenticated API (should be denied)
curl -i https://<MASKED_HOST>/api/<BUSINESS_ENDPOINT>

# User identity API checks (business allowed, admin denied)
# Use valid user session/cookie or token from Access flow; do not paste raw token into docs.
curl -i https://<MASKED_HOST>/api/<BUSINESS_ENDPOINT> -H "Cookie: <MASKED_USER_SESSION>"
curl -i https://<MASKED_HOST>/api/admin/copy -H "Cookie: <MASKED_USER_SESSION>"

# Developer identity API checks (full allow)
curl -i https://<MASKED_HOST>/api/admin/copy -H "Cookie: <MASKED_DEV_SESSION>"
curl -i https://<MASKED_HOST>/api/admin/copy/save -H "Cookie: <MASKED_DEV_SESSION>"
```

Evidence placeholders:
- Unauth deny proof: `<EVIDENCE_UNAUTH_API_DENY>`
- User business allow proof: `<EVIDENCE_USER_BUSINESS_ALLOW>`
- User admin deny proof: `<EVIDENCE_USER_ADMIN_DENY>`
- Developer admin allow proof: `<EVIDENCE_DEV_ADMIN_ALLOW>`

### C. Page behavior verification (unauth page first + countdown redirect)

Manual browser check (private/incognito recommended):
1. Open `https://<MASKED_HOST>/` without valid Access/app session.
2. Confirm unauthorized page is shown first.
3. Confirm countdown is visible and reaches redirect.
4. Confirm redirect target is auth entry URL (`NEXT_PUBLIC_AUTH_ENTRY_URL`, masked in docs).

Evidence placeholders:
- Unauthorized page screenshot/log: `<EVIDENCE_UNAUTH_PAGE_FIRST>`
- Countdown behavior proof: `<EVIDENCE_COUNTDOWN_VISIBLE>`
- Redirect proof: `<EVIDENCE_COUNTDOWN_REDIRECT>`

### D. `aud` mismatch rejection verification

Use a token/session where audience does **not** match `CF_ACCESS_AUD` (or simulate mismatch in test harness).

Expected: request rejected (no downstream access).

Evidence placeholders:
- Mismatch scenario description: `<EVIDENCE_AUD_MISMATCH_SCENARIO>`
- Rejection proof (`401`/`403` + log snippet): `<EVIDENCE_AUD_MISMATCH_REJECTED>`
- Masked configured `CF_ACCESS_AUD`: `<EVIDENCE_CF_ACCESS_AUD_MASKED>`

---

## 4) Verification checklist (Task-4 completion gate)

- [ ] `pnpm -C code/apps/web test` passed.
- [ ] `pnpm -C code/apps/web build` passed.
- [ ] Unauthenticated user denied for all API checks.
- [ ] `user` can access business APIs only.
- [ ] `developer` can access full APIs including `admin/copy` + `admin/copy/save`.
- [ ] Unauthenticated page shows first, then countdown redirect occurs.
- [ ] `aud` mismatch rejection is confirmed.
- [ ] Evidence placeholders updated with masked, non-secret artifacts.

---

## 5) Notes / guardrails

- Never store raw session cookies, JWTs, IdP assertions, or unmasked host secrets in this file.
- Use redacted snippets for logs/screenshots.
- Any deviation from the matrix is a Day-2 blocker until triaged.

Last Updated: 2026-03-23
