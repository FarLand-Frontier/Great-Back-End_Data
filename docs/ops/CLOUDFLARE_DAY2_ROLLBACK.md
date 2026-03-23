# CLOUDFLARE_DAY2_ROLLBACK

Date: 2026-03-23 (Asia/Shanghai)  
Scope: Great Back End Day-2 Task 5 (rollback rehearsal + incident controls)

> Purpose: Provide a safe, reversible Day-2 rollback path for Cloudflare Access + Tunnel/DNS exposure, then rehearse rollback and restoration once with measurable recovery timing.

## 1) Rollback intent and boundaries

This document is limited to Task 5 only:
1. One-command rollback actions
2. Rehearsal (rollback once + restore once)
3. Recovery-time measurement template (MRT/MTTR fields)
4. Verification checklist + evidence placeholders
5. Incident controls + communication notes

All values are masked. Do not place secrets/tokens/raw IDs in this file.

---

## 2) Preconditions before executing rollback

- Confirm change window is active and on-call owner is present.
- Confirm current state snapshot exists (Access policy state + DNS/tunnel state).
- Announce rollback start in incident channel before making changes.
- Assign roles:
  - Commander: `<MASKED_INCIDENT_COMMANDER>`
  - Executor: `<MASKED_EXECUTOR>`
  - Scribe/Timer: `<MASKED_SCRIBE>`

---

## 3) One-command rollback actions

Use **one** action from A and **one** action from B depending on incident type.

### A) Access policy rollback (disable/adjust)

#### Option A1 — temporary bypass (time-boxed) via CLI script
```bash
CF_API_TOKEN=<MASKED> CF_ACCOUNT_ID=<MASKED> CF_ACCESS_APP_ID=<MASKED> ./scripts/ops/cf-access-rollback.sh emergency-bypass --duration-min 15 --reason "day2 incident rollback"
```

Expected effect:
- Access policy is adjusted to restore controlled operator reachability quickly.
- Action is temporary and must be reverted in restore phase.

#### Option A2 — revert to previous policy snapshot (preferred when available)
```bash
CF_API_TOKEN=<MASKED> CF_ACCOUNT_ID=<MASKED> CF_ACCESS_APP_ID=<MASKED> ./scripts/ops/cf-access-rollback.sh apply-snapshot ./artifacts/access-policy-last-known-good.json
```

Expected effect:
- Access policy returns to last-known-good ruleset.

> If script path/name differs in your environment, keep the same one-command contract and update this runbook with the actual masked command string.

### B) Traffic path rollback (switch DNS target OR pause tunnel route)

#### Option B1 — switch DNS target to known-good origin
```bash
CF_API_TOKEN=<MASKED> CF_ZONE_ID=<MASKED> RECORD_ID=<MASKED> ./scripts/ops/cf-dns-rollback.sh switch-target --hostname <MASKED_HOST> --to <MASKED_KNOWN_GOOD_TARGET>
```

Expected effect:
- External hostname points to known-good backend target.

#### Option B2 — pause tunnel route exposure
```bash
TUNNEL_ID=<MASKED> ./scripts/ops/cf-tunnel-rollback.sh pause-route --hostname <MASKED_HOST>
```

Expected effect:
- Problematic tunnel route is paused/disabled to stop bad edge-origin path.

---

## 4) Restore commands (reverse rollback after stabilization)

After root cause is controlled and validation passes, restore intended Day-2 path.

### Access restore
```bash
CF_API_TOKEN=<MASKED> CF_ACCOUNT_ID=<MASKED> CF_ACCESS_APP_ID=<MASKED> ./scripts/ops/cf-access-rollback.sh restore-day2 --snapshot ./artifacts/access-policy-day2-approved.json
```

### DNS/Tunnel restore
```bash
CF_API_TOKEN=<MASKED> CF_ZONE_ID=<MASKED> RECORD_ID=<MASKED> ./scripts/ops/cf-dns-rollback.sh switch-target --hostname <MASKED_HOST> --to <MASKED_DAY2_TARGET>
```
_or_
```bash
TUNNEL_ID=<MASKED> ./scripts/ops/cf-tunnel-rollback.sh resume-route --hostname <MASKED_HOST>
```

---

## 5) Rehearsal procedure (mandatory: rollback once + restore once)

Perform in controlled window:

1. **Baseline capture (T0)**
   - Record current Access policy version, DNS/tunnel route status, app health endpoint.
2. **Execute rollback (T1)**
   - Run one Access rollback command (A1 or A2).
   - Run one traffic rollback command (B1 or B2).
3. **Verify rollback state (T2)**
   - Confirm expected emergency behavior is active.
4. **Execute restore (T3)**
   - Run Access restore command.
   - Run DNS/tunnel restore command.
5. **Verify restored state (T4)**
   - Confirm Day-2 intended behavior recovered.
6. **Capture timing + evidence**
   - Compute rollback recovery time and restore recovery time.

### Timing capture template (MRT/MTTR)

| Field | Value |
|---|---|
| Incident/Rehearsal ID | `<EVIDENCE_REHEARSAL_ID>` |
| T0 Baseline timestamp | `<YYYY-MM-DD HH:mm:ss +08:00>` |
| T1 Rollback command issued | `<YYYY-MM-DD HH:mm:ss +08:00>` |
| T2 Rollback verified | `<YYYY-MM-DD HH:mm:ss +08:00>` |
| T3 Restore command issued | `<YYYY-MM-DD HH:mm:ss +08:00>` |
| T4 Restore verified | `<YYYY-MM-DD HH:mm:ss +08:00>` |
| Rollback MRT (T2 - T1) | `<MM:SS>` |
| Restore MRT (T4 - T3) | `<MM:SS>` |
| Overall MTTR (T4 - T1) | `<MM:SS>` |
| Recorder | `<MASKED_NAME>` |
| Notes | `<EVIDENCE_TIMING_NOTES>` |

---

## 6) Verification checklist (execution gate)

- [ ] Rollback command for Access policy executed once.
- [ ] Rollback command for DNS target switch or tunnel pause executed once.
- [ ] Rollback state verified (expected emergency behavior observed).
- [ ] Restore commands executed once (Access + DNS/tunnel).
- [ ] Restored Day-2 state verified.
- [ ] MRT/MTTR values recorded.
- [ ] Evidence placeholders filled with masked artifacts.
- [ ] Incident log updated with who/when/why.

---

## 7) Evidence placeholders

- Rehearsal window approval: `<EVIDENCE_CHANGE_WINDOW_APPROVAL>`
- Access rollback command output (masked): `<EVIDENCE_ACCESS_ROLLBACK_OUTPUT>`
- DNS/tunnel rollback output (masked): `<EVIDENCE_TRAFFIC_ROLLBACK_OUTPUT>`
- Rollback verification (`curl`/browser/log): `<EVIDENCE_ROLLBACK_VERIFICATION>`
- Access restore output (masked): `<EVIDENCE_ACCESS_RESTORE_OUTPUT>`
- DNS/tunnel restore output (masked): `<EVIDENCE_TRAFFIC_RESTORE_OUTPUT>`
- Restore verification (`curl`/browser/log): `<EVIDENCE_RESTORE_VERIFICATION>`
- MRT/MTTR table snapshot: `<EVIDENCE_TIMING_TABLE>`
- Final incident note/link: `<EVIDENCE_INCIDENT_LOG_LINK>`

---

## 8) Incident controls and communication notes

### Operational controls
- Time-box emergency bypass (example: 15 minutes max) and track expiry owner.
- Avoid destructive actions first (do **not** delete app/tunnel as first response).
- Serialize changes: one executor, one command at a time, verify after each.
- Require explicit command read-back before execution.
- Keep audit trail: command, operator, timestamp, result.

### Communication controls
- Start message template:
  - `"[ROLLBACK-START] Day2 incident <ID>. Executing Access + traffic rollback. Commander=<MASKED>, Executor=<MASKED>."`
- Stabilization message template:
  - `"[ROLLBACK-STABLE] Emergency path active. Verifying blast radius + preparing restore."`
- Restore message template:
  - `"[RESTORE-START] Executing Day2 restore commands for Access + traffic path."`
- Closure template:
  - `"[INCIDENT-CLOSE] Day2 path restored. MRT=<MM:SS>, MTTR=<MM:SS>. Evidence logged."`

### Safety notes
- Never post raw credentials or full token strings in chat/docs.
- Use masked hostnames/IDs in shared channels.
- If verification fails at any step, halt further changes and escalate to commander.

---

Last Updated: 2026-03-23
