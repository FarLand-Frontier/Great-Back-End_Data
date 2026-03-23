# CLOUDFLARE_ACCESS_POLICY_DAY2

> Purpose: Define Day 2 Cloudflare Access application setup, identity policy structure, `CF_ACCESS_AUD` mapping, and safe verification/rollback notes.

## Scope
This document covers **Task 3 only**:
1. Access application creation
2. IdP auth flow setup
3. Session TTL recommendation
4. Allowlist policy structure (developer/user)
5. `CF_ACCESS_AUD` mapping
6. Verification checklist + evidence placeholders
7. Rollback-safe notes

---

## 1) Access Application Creation (Day-2 Hostname)

### Inputs (from baseline)
- External hostname: `<https://YOUR_EXTERNAL_HOSTNAME>`
- Access app display name: `<great-back-end-day2-access-app>`
- Session duration target: `7d` to `30d` (MVP)

### Steps (Cloudflare Zero Trust UI)
1. Open **Zero Trust Dashboard** → **Access** → **Applications**.
2. Click **Add an application**.
3. Select **Self-hosted**.
4. Set:
   - **Application name:** `<great-back-end-day2-access-app>`
   - **Domain:** `<YOUR_EXTERNAL_HOSTNAME>`
   - **Path:** `/*` (or equivalent full coverage)
5. Save draft and proceed to policy configuration.

### Required output
- Access application created and attached to Day-2 external hostname.

---

## 2) IdP Authentication Flow Setup

### Preconditions
- Existing IdP integration already configured in Zero Trust (OIDC/SAML/Google/Microsoft/etc.).
- IdP ownership and user directory sync are managed by platform owner.

### Steps
1. In the Access application, open **Authentication** / **Login methods**.
2. Enable the existing provider(s) intended for Day-2 rollout.
3. Confirm login prompt behavior:
   - Unauthenticated user hitting app URL is redirected to Cloudflare Access challenge.
   - After successful IdP auth, user returns to the requested app URL.
4. Keep all provider secrets/tokens hidden; do not copy raw values into docs.

### Auth flow (expected)
1. User browses `https://<YOUR_EXTERNAL_HOSTNAME>`.
2. Cloudflare Access checks session cookie/token.
3. If no valid session: redirect to configured IdP.
4. IdP authenticates user and returns assertion/token.
5. Access evaluates policies and grants/denies.
6. Allowed users receive app session and can reach upstream.

---

## 3) Session TTL Recommendation (MVP)

### Recommendation
- Set Access app session duration to **7–30 days**.

### Suggested default
- Start with **14 days** for MVP, then tighten/expand based on incident posture and user friction.

### Rationale
- `7d` reduces stale-session risk.
- `30d` minimizes re-auth friction for low-risk internal usage.
- Keep within approved range until post-rollout review.

---

## 4) Allowlist Policy Structure (Developer/User)

Use ordered allow policies so role intent is explicit and auditable.

### Policy order (top to bottom)
1. **Allow — Developer**
   - Include: developer email allowlist and/or developer IdP group.
   - Example include selectors:
     - Emails: `<dev1@example.com>`, `<dev2@example.com>`
     - Group: `<idp_group_developer>`
2. **Allow — User**
   - Include: business user email allowlist and/or user IdP group.
   - Example include selectors:
     - Emails: `<user1@example.com>`, `<user2@example.com>`
     - Group: `<idp_group_user>`
3. **Implicit deny**
   - Anyone not matching Allow policies is denied.

### Notes
- Prefer IdP groups over long static email lists once stable.
- Keep developer and user scopes separate to preserve downstream role mapping clarity.
- Do not insert broad “everyone in org” rules during MVP unless explicitly approved.

---

## 5) `CF_ACCESS_AUD` Mapping

After creating the Access application:
1. Open app details and locate **Audience / AUD** value.
2. Copy value into deployment env mapping as:
   - `CF_ACCESS_AUD=<access_app_audience_value>`
3. Store only masked value in docs.

### Masked recording format
- `CF_ACCESS_AUD`: `<cf_aud_************************>`

### Cross-check
- `CF_ACCESS_AUD` in app runtime env must equal Access app audience exactly.
- Mismatch must fail token validation by design.

---

## 6) Verification Checklist (Task-3 Gate)

- [ ] Access application exists and is bound to Day-2 hostname.
- [ ] IdP login method enabled and challenge redirects correctly.
- [ ] Session TTL configured within `7d`–`30d` range.
- [ ] Allow policy structure includes distinct `Developer` and `User` allow rules.
- [ ] `CF_ACCESS_AUD` captured from Access app and mapped (masked in docs).
- [ ] Unauthenticated browser request is challenged.
- [ ] Authenticated developer request passes to app.

Suggested checks:
```bash
curl -I https://<YOUR_EXTERNAL_HOSTNAME>
# Expect Access challenge/redirect when unauthenticated
```

```bash
# Browser test (manual):
# 1) Open external URL in private window
# 2) Complete IdP login as developer identity
# 3) Confirm app landing succeeds
```

---

## 7) Evidence Placeholders

- Access application name: `<EVIDENCE_ACCESS_APP_NAME>`
- Access application ID: `<EVIDENCE_ACCESS_APP_ID>`
- Hostname binding screenshot/log: `<EVIDENCE_ACCESS_HOST_BINDING>`
- Enabled IdP provider(s): `<EVIDENCE_IDP_PROVIDER_LIST>`
- Session TTL setting proof: `<EVIDENCE_SESSION_TTL>`
- Developer policy proof: `<EVIDENCE_POLICY_DEVELOPER>`
- User policy proof: `<EVIDENCE_POLICY_USER>`
- Masked `CF_ACCESS_AUD` capture: `<EVIDENCE_CF_ACCESS_AUD_MASKED>`
- Unauthenticated challenge proof: `<EVIDENCE_UNAUTH_CHALLENGE>`
- Authenticated developer pass proof: `<EVIDENCE_AUTH_PASS_DEVELOPER>`

---

## 8) Rollback-Safe Notes

If Access policy blocks valid traffic unexpectedly, prefer reversible changes:

1. **Emergency temporary access adjustment (short-lived)**
   - Modify policy order or add tightly scoped temporary allow for on-call developer only.
   - Time-box and remove after incident.
2. **Do not delete app/tunnel first**
   - Keep artifacts intact for rapid restore and auditing.
3. **Preserve `CF_ACCESS_AUD` mapping history**
   - If app is recreated and audience changes, update env and redeploy intentionally.
4. **Record every rollback action**
   - Who changed what, when, why, and restoration timestamp.

Rollback success criteria:
- Legitimate developer access restored.
- Unauthorized access still blocked.
- Final policy state documented with evidence placeholders updated.

---

Last Updated: 2026-03-23
