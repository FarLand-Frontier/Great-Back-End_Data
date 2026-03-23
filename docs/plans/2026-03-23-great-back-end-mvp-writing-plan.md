# Great Back End MVP Implementation Plan

> **For implementer:** Use TDD throughout. Write failing test first. Watch it fail. Then implement.

**Goal:** Deliver an iPhone-installable PWA MVP in 10 days: chat-first UI, new/history sessions, dashboard, editable copy write-back to data repo, logical isolation support.

**Architecture:** Next.js app (web + API routes) with server-side proxy to OpenClaw gateway, PostgreSQL for app metadata/audit, data-repo-backed copy/config export pipeline. Root and lighthouse OpenClaw instances are isolated by endpoint and credentials.

**Tech Stack:** Next.js 15 + TypeScript, Vitest/Playwright, Prisma/Postgres, Web Push, Cloudflare Access headers.

---

## Task 1: Scaffold code workspace and test harness

**Files:**
- Create: `code/apps/web/package.json`
- Create: `code/apps/web/vitest.config.ts`
- Create: `code/apps/web/tests/smoke/app-smoke.test.ts`
- Create: `code/apps/web/README.md`

**Step 1: Write the failing test**
- Add `app-smoke.test.ts` expecting app config module export to exist.

**Step 2: Run test — confirm it fails**
- Command: `pnpm -C code/apps/web test`
- Expected: FAIL (`Cannot find module` / missing export)

**Step 3: Write minimal implementation**
- Add minimal config module and scripts in package.json.

**Step 4: Run test — confirm it passes**
- Command: `pnpm -C code/apps/web test`
- Expected: PASS

**Step 5: Commit**
- `git add code/apps/web && git commit -m "chore: scaffold web app test harness"`

---

## Task 2: Chat-first home screen with editable placeholder contract

**Files:**
- Create: `code/apps/web/src/app/page.tsx`
- Create: `code/apps/web/src/lib/uiCopy.ts`
- Create: `code/apps/web/tests/ui/chat-home.test.tsx`
- Create: `data/config/ui-copy.json` (contract definition)

**Step 1: Write the failing test**
- Assert home renders title, placeholder, and 3 quick prompts from `uiCopy` contract.

**Step 2: Run test — confirm it fails**
- Command: `pnpm -C code/apps/web test tests/ui/chat-home.test.tsx`
- Expected: FAIL (missing component/data source)

**Step 3: Write minimal implementation**
- Render chat-first shell and load defaults from `ui-copy` contract.

**Step 4: Run test — confirm it passes**
- Command: same as above
- Expected: PASS

**Step 5: Commit**
- `git add code/apps/web data/config/ui-copy.json && git commit -m "feat: add chat-first home with editable copy contract"`

---

## Task 3: New conversation + history list APIs

**Files:**
- Create: `code/apps/web/src/app/api/sessions/new/route.ts`
- Create: `code/apps/web/src/app/api/sessions/list/route.ts`
- Create: `code/apps/web/src/lib/sessionStore.ts`
- Create: `code/apps/web/tests/api/sessions-api.test.ts`

**Step 1: Write the failing test**
- Cover create session returns id, list returns most recent first.

**Step 2: Run test — confirm it fails**
- `pnpm -C code/apps/web test tests/api/sessions-api.test.ts`
- Expected: FAIL

**Step 3: Write minimal implementation**
- Implement in-memory store abstraction (to be swapped for Prisma).

**Step 4: Run test — confirm it passes**
- Expected: PASS

**Step 5: Commit**
- `git add code/apps/web && git commit -m "feat: implement session create/list api"`

---

## Task 4: Gateway proxy for chat send (lighthouse endpoint)

**Files:**
- Create: `code/apps/web/src/app/api/chat/send/route.ts`
- Create: `code/apps/web/src/lib/openclawClient.ts`
- Create: `code/apps/web/tests/api/chat-send.test.ts`

**Step 1: Write the failing test**
- Mock downstream gateway, verify route forwards with partner-safe endpoint key.

**Step 2: Run test — confirm it fails**
- `pnpm -C code/apps/web test tests/api/chat-send.test.ts`

**Step 3: Write minimal implementation**
- Add server-only proxy with endpoint selection (`owner|lighthouse`).

**Step 4: Run test — confirm it passes**
- Expected: PASS

**Step 5: Commit**
- `git add code/apps/web && git commit -m "feat: add server-side gateway proxy for chat send"`

---

## Task 5: Dashboard cards (token usage / task status / health)

**Files:**
- Create: `code/apps/web/src/app/dashboard/page.tsx`
- Create: `code/apps/web/src/app/api/dashboard/summary/route.ts`
- Create: `code/apps/web/tests/ui/dashboard.test.tsx`

**Step 1: Write failing test**
- Assert three cards render and show fallback states.

**Step 2: Run test fail**
- `pnpm -C code/apps/web test tests/ui/dashboard.test.tsx`

**Step 3: Minimal implementation**
- Render cards; use mocked summary endpoint.

**Step 4: Re-run pass**

**Step 5: Commit**
- `git add code/apps/web && git commit -m "feat: add dashboard summary cards"`

---

## Task 6: Admin copy editor + write-back export contract

**Files:**
- Create: `code/apps/web/src/app/admin/copy/page.tsx`
- Create: `code/apps/web/src/app/api/admin/copy/save/route.ts`
- Create: `code/apps/web/src/lib/exportToDataRepo.ts`
- Create: `code/apps/web/tests/api/copy-save.test.ts`
- Modify: `data/config/ui-copy.json`

**Step 1: Failing test**
- Save API must persist and emit export payload matching `data/config/ui-copy.json` schema.

**Step 2: Run fail**

**Step 3: Minimal implementation**
- Save + queue export event (git write-back worker later).

**Step 4: Run pass**

**Step 5: Commit**
- `git add code/apps/web data/config/ui-copy.json && git commit -m "feat: copy editor with data-repo export contract"`

---

## Task 7: Audit log pipeline for config changes

**Files:**
- Create: `code/apps/web/src/lib/audit.ts`
- Create: `code/apps/web/src/app/api/audit/list/route.ts`
- Create: `code/apps/web/tests/api/audit.test.ts`

**Step 1-5:** same TDD loop, ensure actor/time/diff recorded.

---

## Task 8: PWA installability + iPhone UX checks

**Files:**
- Create: `code/apps/web/public/manifest.webmanifest`
- Create: `code/apps/web/src/app/sw.ts`
- Create: `code/apps/web/tests/e2e/pwa-install.spec.ts`

**Step 1-5:** TDD loop, confirm install prompt path + offline shell.

---

## Task 9: Notifications (web push baseline)

**Files:**
- Create: `code/apps/web/src/app/api/push/subscribe/route.ts`
- Create: `code/apps/web/src/app/api/push/test/route.ts`
- Create: `code/apps/web/tests/api/push.test.ts`

**Step 1-5:** TDD loop, verify subscription stored + test push triggered.

---

## Task 10: Logical isolation readiness checklist (lighthouse)

**Files:**
- Create: `data/docs/ops/LIGHTHOUSE_ISOLATION_CHECKLIST.md`
- Create: `code/apps/web/src/lib/instancePolicy.ts`
- Create: `code/apps/web/tests/security/instance-policy.test.ts`

**Step 1-5:** TDD loop, ensure partner role cannot hit owner endpoint.

---

Plan saved. Two execution options:

1. **Subagent-Driven** — dispatch a fresh sub-agent per task, with review between tasks.
2. **Manual** — execute tasks directly in sequence.

---

## Day-1 Closure Status Update (2026-03-23)

Status: **Closed (tail tasks verified)**

Evidence snapshot:
- Verification doc: `docs/ops/DAY1_CLOSURE_VERIFICATION.md`
- Final test command: `pnpm -C apps/web test` → PASS (14 files / 47 tests)
- Final build command: `pnpm -C apps/web build` → PASS
- Dev runtime noise check: `git status --porcelain` unchanged before/after short `pnpm -C apps/web dev` run
- Security/authorization sanity: unauthorized flow + role policy unchanged (`developer` / `user` / `unauthentic-user`)
