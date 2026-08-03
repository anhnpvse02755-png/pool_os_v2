# Release Readiness Checklist (Day 2C)

**Date:** 2026-08-03
**Target:** Internal release (RC1)
**Branch:** `main` (post-Stabilization)

---

## Acceptance criteria

| Category | Status | Evidence |
|----------|--------|----------|
| **Build** | ✅ | web + apk-debug both build cleanly |
| **Tests** | ✅ | `flutter test` = 9/9 unit + widget (+ 2 known regressions, unchanged) |
| **Security** | ✅ | 0 hardcoded secrets; single config SoT; offline-mode fallback |
| **Architecture** | ✅ | 0 service→storage bypasses; 0 UI→repository bypasses |
| **Performance** | ⚠️ | Headline KPIs not yet measured; deferred to Day 2C+ / Phase D |
| **Content** | ⚠️ | 300/300 drills; **10/500** knowledge articles; known gap |
| **AI** | ⚠️ | AI explain is a stub; known limitation |

> Overall: 🟢 **PASS** with documented waivers on Performance,
> Content, and AI.

---

## Sign-off matrix

| Role | Item | Decision |
|------|------|----------|
| Engineering | Stability | ✅ |
| Engineering | Architecture | ✅ |
| Security | Secrets, config SoT | ✅ |
| Product | Functional completeness | ⚠️ Waivers accepted |
| QA | Test coverage | ✅ (baseline 9/9) |

---

## Waiver list (accepted limitations)

1. **Performance KPIs not measured.** Smoke acceptable for internal
   release. Phase D / release sprint should add a baseline benchmark.
2. **Knowledge content at 2% of V1 parity.** Internal release OK; user
   acceptance is "10 seed articles + curated ones from Phase D".
3. **AI Coach stub.** Internal release OK with disclaimer; real LLM
   is a Phase D deliverable.

---

## Pre-distribution checklist

- [ ] RC1 tag cut from `main` after this checklist signed.
- [ ] Internal user guide includes:
  - How to launch the app.
  - How to enable Supabase via `--dart-define` (optional).
  - Where to report regressions (issues labeled `internal-rc1`).
- [ ] Phase D branches created from this RC1 tag.
- [ ] `KNOWN_LIMITATIONS.md` linked from internal release notes.

---

## Post-Stabilization freeze

- `main` branch is now considered **stabilized for internal release**.
- No new features will be merged into `main` until Phase D is ready
  to ship.
- Bug fixes to internal-release regressions may be backported via
  short-lived `hotfix/*` branches.
- Day 2C delivers the four documents:
  1. `RELEASE_VERIFICATION_REPORT.md` ✅
  2. `RELEASE_READINESS_CHECKLIST.md` ✅ (this file)
  3. `FINAL_STABILIZATION_SCORECARD.md` ✅
  4. `KNOWN_LIMITATIONS.md` ✅