# Great Back End Day-1 Tail Closure — Writing Plan

> **For implementer:** TDD mandatory. For each task: write failing test → run to confirm fail → implement minimum change → run pass → commit.

**Context:** Day-1 MVP tasks (1~10) are completed, but project is not fully closed due to build stability and production gate requirements.

**Closure Goal:**
1) Eliminate dev/runtime file noise via proper `.gitignore` policy.
2) Stabilize production build by adding required Next.js root layout.
3) Add minimum auth gate for app/API under Cloudflare Access + in-app guard model.
4) Lock release readiness with explicit verification checklist.

---

## Task 1: Runtime artifacts ignore policy hardening

**Files:**
- Modify: `code/.gitignore`
- Modify: `code/apps/web/.gitignore`
- Create: `code/apps/web/tests/tooling/gitignore-runtime-artifacts.test.ts`

**Step 1: Write failing test**
- Assert ignore patterns include: `.turbo`, `coverage`, `*.tsbuildinfo`, `next-env.d.ts`, `.env*.local`, common package-manager debug logs.

**Step 2: Run test — confirm FAIL**
- Command: `pnpm -C code/apps/web test tests/tooling/gitignore-runtime-artifacts.test.ts`

**Step 3: Implement**
- Add missing ignore patterns at both repo root and app-level `.gitignore`.

**Step 4: Re-run — confirm PASS**

**Step 5: Commit**
- `git add code/.gitignore code/apps/web/.gitignore code/apps/web/tests/tooling/gitignore-runtime-artifacts.test.ts && git commit -m "chore: harden gitignore for runtime artifacts"`

---

## Task 2: Build blocker fix — add required Next.js root layout

**Files:**
- Create: `code/apps/web/src/app/layout.tsx`
- (If needed) Create: `code/apps/web/src/app/globals.css`
- Create: `code/apps/web/tests/ui/root-layout.test.tsx`

**Step 1: Write failing test**
- Assert root layout renders `<html>` + `<body>` and can wrap children.

**Step 2: Run test — confirm FAIL**
- `pnpm -C code/apps/web test tests/ui/root-layout.test.tsx`

**Step 3: Implement minimum layout**
- Minimal semantic layout, no extra styling complexity.

**Step 4: Re-run tests + build**
- `pnpm -C code/apps/web test tests/ui/root-layout.test.tsx`
- `pnpm -C code/apps/web build`
- Expected: build no longer fails on missing root layout.

**Step 5: Commit**
- `git add code/apps/web/src/app/layout.tsx code/apps/web/src/app/globals.css code/apps/web/tests/ui/root-layout.test.tsx && git commit -m "fix: add required next root layout for stable production build"`

---

## Task 3: Cloudflare Access header gate (server-side baseline)

**Files:**
- Create: `code/apps/web/src/lib/auth/cloudflareAccess.ts`
- Create: `code/apps/web/src/middleware.ts`
- Create: `code/apps/web/tests/security/cloudflare-access-gate.test.ts`

**Step 1: Write failing tests**
- Requests without expected Access identity header are denied (401/redirect per route class).
- Requests with valid Access identity pass.

**Step 2: Run tests — confirm FAIL**

**Step 3: Implement minimum gate**
- Middleware checks Access identity header and applies allow/deny policy for protected paths.

**Step 4: Re-run — confirm PASS**

**Step 5: Commit**
- `git add code/apps/web/src/lib/auth/cloudflareAccess.ts code/apps/web/src/middleware.ts code/apps/web/tests/security/cloudflare-access-gate.test.ts && git commit -m "feat: add cloudflare access header gate baseline"`

---

## Task 4: In-app role gate for admin/copy + sensitive APIs

**Files:**
- Create: `code/apps/web/src/lib/auth/rolePolicy.ts`
- Modify: `code/apps/web/src/app/admin/copy/page.tsx`
- Modify: `code/apps/web/src/app/api/admin/copy/save/route.ts`
- Create: `code/apps/web/tests/security/role-policy.test.ts`

**Step 1: Write failing tests**
- Role `editor` can access chat + copy edit pages, but cannot hit owner-only admin/security APIs.
- Missing role context denied.

**Step 2: Run fail**

**Step 3: Implement**
- Centralized role policy helper + route-level enforcement.

**Step 4: Re-run pass**

**Step 5: Commit**
- `git add code/apps/web/src/lib/auth/rolePolicy.ts code/apps/web/src/app/admin/copy/page.tsx code/apps/web/src/app/api/admin/copy/save/route.ts code/apps/web/tests/security/role-policy.test.ts && git commit -m "feat: enforce in-app role policy for admin and api routes"`

---

## Task 5: End-to-end release verification for day-1 closure

**Files:**
- Create: `data/docs/ops/DAY1_CLOSURE_VERIFICATION.md`
- (Optional) Create: `code/apps/web/tests/e2e/day1-closure.spec.ts`

**Step 1: Write failing verification checks**
- Checklist must include: clean git status after `pnpm dev`, passing tests, passing build, auth gate sanity, PWA installability sanity.

**Step 2: Run checks and record baseline failures**

**Step 3: Implement/fix any residual issues surfaced by checklist**

**Step 4: Final verification commands**
- `pnpm -C code/apps/web test`
- `pnpm -C code/apps/web build`
- manual smoke: run `pnpm -C code/apps/web dev` then confirm no unwanted untracked runtime files

**Step 5: Commit**
- `git add data/docs/ops/DAY1_CLOSURE_VERIFICATION.md code/apps/web/tests/e2e/day1-closure.spec.ts && git commit -m "docs: add day1 closure verification checklist"`

---

## Task 6: Governance close-out (required by collaboration protocol)

**Files:**
- Update: `data/docs/plans/2026-03-23-great-back-end-mvp-writing-plan.md`
- Update: `data/docs/plans/2026-03-23-great-back-end-day1-tail-closure-writing-plan.md`
- Update: `data/docs/30-planning/MILESTONES.md`

**Steps:**
1. Mark completed items and evidence links (commit hashes + test/build outputs).
2. `git add` + `git commit` in both repos.
3. `git push` both repos.
4. Sync updates to Notion "临时指挥所 / Progression".

**Completion Definition:**
- No day-1 known blockers remain.
- Build passes reproducibly.
- Auth baseline enforced.
- Runtime file noise controlled by ignore policy.
- Plan and milestone docs fully synced.
