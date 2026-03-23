# Cloudflare Day 2 Baseline

> **Purpose:** Freeze Day 2 Cloudflare rollout baseline values before tunnel/access changes.

## Target Mapping

- **Target app external URL:** `<https://YOUR_EXTERNAL_HOSTNAME>`
- **Local upstream:** `<http://127.0.0.1:3000>`
- **Cloudflare application name:** `<great-back-end-day2-access-app>`

## Environment Key Mapping (Masked)

| Env Key | Intended Mapping | Baseline Value (Masked) |
|---|---|---|
| `CF_ACCESS_AUD` | Cloudflare Access application audience (`aud`) | `<cf_aud_************************>` |
| `ACCESS_DEVELOPER_EMAILS` | Initial developer allowlist (comma-separated emails) | `<dev1@example.com,dev2@example.com>` |
| `NEXT_PUBLIC_AUTH_ENTRY_URL` | Browser entry URL for auth challenge | `<https://YOUR_EXTERNAL_HOSTNAME>` |

## Ownership

- **Owner:** `<owner_name_or_team>`

## Status Checklist

- [ ] Target app external URL confirmed
- [ ] Local upstream confirmed
- [ ] Cloudflare application name confirmed
- [ ] `CF_ACCESS_AUD` captured and masked in baseline
- [ ] `ACCESS_DEVELOPER_EMAILS` list confirmed
- [ ] `NEXT_PUBLIC_AUTH_ENTRY_URL` confirmed
- [ ] Baseline reviewed by owner

---

*Last Updated: 2026-03-23*
