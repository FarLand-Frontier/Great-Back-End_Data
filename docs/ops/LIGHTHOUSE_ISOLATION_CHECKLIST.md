# Lighthouse Isolation Readiness Checklist

> **Purpose:** Verify logical isolation between Lighthouse instances and partner access control.

## Overview

This checklist ensures the Great Back End system properly enforces:
1. **Partner isolation** - Partners cannot access owner-only endpoints
2. **Cross-Lighthouse isolation** - Different Lighthouse instances cannot access each other's resources
3. **Instance policy enforcement** - Access control is implemented and tested

---

## Pre-Deployment Checklist

### 1. Instance Policy Configuration

- [ ] `InstancePolicy` class implemented in `src/lib/instancePolicy.ts`
- [ ] Policy version defined (currently `1.0`)
- [ ] Role enumeration includes: `OWNER`, `PARTNER`, `LIGHTHOUSE`
- [ ] Lighthouse instance IDs defined: `LIGHTHOUSE_A`, `LIGHTHOUSE_B`

### 2. Access Control Rules

| Role | Owner Resource | Lighthouse Resource | Cross-Lighthouse |
|------|-----------------|---------------------|------------------|
| OWNER | ✅ Allowed | ✅ Allowed | ✅ Allowed |
| PARTNER | ❌ Denied | ✅ Allowed | N/A |
| LIGHTHOUSE | ❌ Denied | ✅ Self only | ❌ Denied |

### 3. Test Coverage

- [ ] Test file created: `tests/security/instance-policy.test.ts`
- [ ] All 6 tests passing:
  - [ ] Partner cannot access owner endpoint
  - [ ] Partner can access lighthouse endpoint
  - [ ] Owner can access both endpoints
  - [ ] Cross-lighthouse isolation enforced
  - [ ] Lighthouse can access own resources
  - [ ] Structured access result with metadata

### 4. Integration Points

- [ ] `InstancePolicy` can be imported by API routes
- [ ] Policy check can be used in `/api/chat/send` route
- [ ] Policy check can be used in `/api/admin/*` routes

---

## Runtime Verification

### Manual Test Scenarios

1. **Partner Access Test**
   ```bash
   # As partner role, try to access owner endpoint
   curl -X POST https://api.example.com/api/chat/send \
     -H "X-Role: partner" \
     -H "X-Endpoint: owner" \
     -d '{"message": "test"}'
   # Expected: 403 Forbidden
   ```

2. **Lighthouse Cross-Instance Test**
   ```bash
   # As lighthouse-a, try to access lighthouse-b resources
   curl -X POST https://api.example.com/api/chat/send \
     -H "X-Role: lighthouse" \
     -H "X-Instance-Id: lighthouse-a" \
     -H "X-Target-Instance: lighthouse-b" \
     -d '{"message": "test"}'
   # Expected: 403 Forbidden
   ```

3. **Owner Full Access Test**
   ```bash
   # As owner, access any endpoint
   curl -X POST https://api.example.com/api/chat/send \
     -H "X-Role: owner" \
     -d '{"message": "test"}'
   # Expected: 200 OK
   ```

---

## Security Considerations

1. **Credential Isolation**: Lighthouse instances must use separate credentials
2. **Endpoint Segregation**: Owner and Lighthouse use different API endpoints
3. **Audit Logging**: All access denial events should be logged
4. **No Cross-Talk**: Network policies should prevent direct Lighthouse-to-Lighthouse communication

---

## Rollback Plan

If isolation fails in production:
1. Disable partner access to Lighthouse endpoints
2. Revoke cross-instance tokens
3. Review `InstancePolicy` logic
4. Re-run full test suite before re-enabling

---

## Related Files

- **Implementation**: `code/apps/web/src/lib/instancePolicy.ts`
- **Tests**: `code/apps/web/tests/security/instance-policy.test.ts`
- **API Integration**: `code/apps/web/src/app/api/chat/send/route.ts`

## Day 2 Cloudflare Rollout Reference

- Day 2 baseline freeze doc: `docs/ops/CLOUDFLARE_DAY2_BASELINE.md`
- Day 2 execution plan: `docs/plans/2026-03-24-great-back-end-day2-cloudflare-rollout-writing-plan.md`

---

*Last Updated: 2026-03-23*
*Policy Version: 1.0*
