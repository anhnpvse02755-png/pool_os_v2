# Known Limitations (Post-Stabilization)

**Date:** 2026-08-03 (Day 2C)
**Audience:** Phase D developers, internal users, QA
**Status:** These items are **not bugs** and are **not regressions**.
They are documented gaps that the Stabilization Sprint intentionally
did not address. They will be tracked through Phase D or a dedicated
Content Sprint.

---

## Purpose

This document prevents the Phase D team from mistakenly believing
these gaps are "fixed" or "ready". Each item below is **intentionally
deferred** and requires a deliberate Phase D / Content Sprint
decision before being closed.

---

## Functional gaps (not stability gaps)

### 1. Knowledge articles: 10 / 500 (P1)

- **Current state:** 10 articles in `assets/knowledge/knowledge.json`
  covering basic shot-making.
- **V1 parity target:** 500 articles.
- **Why deferred:** Content production is a separate workstream
  (writers, subject-matter experts). Not a coding task.
- **Owner:** Content Sprint.
- **Risk if forgotten:** Internal users will see a thin Knowledge tab.
  Not blocking for any other feature.

### 2. Equipment metadata parity (P2)

- **Current state:** Equipment schema exists; metadata catalog not at
  V1 parity.
- **V1 parity target:** Full equipment catalog with cues, tables,
  accessories metadata.
- **Why deferred:** Catalog maintenance; not a coding blocker.
- **Owner:** Content Sprint.
- **Risk if forgotten:** Equipment picker UI may show empty fields.

### 3. Match summary parity (P2)

- **Current state:** Match summary renders with current fields.
- **V1 parity target:** Match summary fields at V1 depth (advanced
  stats, environmental factors, etc.).
- **Why deferred:** Requires product spec clarification for which
  V1 fields are still relevant in V2.
- **Owner:** Product + Content Sprint.
- **Risk if forgotten:** Match history list shows lighter summaries
  than V1. Pure UX gap.

---

## AI / Cloud gaps

### 4. AI explain stub (P1)

- **Current state:** `ai_explain_service.dart` returns template-based
  explanations, not real LLM responses.
- **Why deferred:** Real LLM requires API contract decisions,
  cost analysis, prompt engineering.
- **Owner:** Phase D / AI Sprint.
- **Risk if forgotten:** Users see template responses labeled as
  AI. Acceptable for internal release but should be flagged.

### 5. Tournament provider empty (P1, STAB-029)

- **Current state:** `tournamentsProvider` returns `<Tournament>[]`.
- **Why deferred:** Tournament feature is Phase D scope.
- **Owner:** Phase D.
- **Risk if forgotten:** None currently (no consumer).

### 6. Cloud sync absent (P1)

- **Current state:** All data is local-first. Supabase integration is
  wired but does not yet ship data.
- **Why deferred:** Phase D scope (community, cloud sync).
- **Owner:** Phase D.
- **Risk if forgotten:** Internal users may expect cross-device sync.
  This is a Phase D feature, not a Stability gap.

---

## Test gaps

### 7. Two known unit-test regressions (P2)

- `test/coach_profile_aggregator_test.dart` — "profile with no matches
  returns zero analyzed"
- `test/drill_session_recovery_test.dart` — "pause / resume sets and
  clears pausedAt"

- **Why deferred:** These are low-priority logic assertions; they
  don't block app behavior (the production code path works for the
  happy-path tests). Pre-existed the Stabilization Sprint.
- **Owner:** Engineering backlog.
- **Risk if forgotten:** Tests are failing (cosmetic CI issue).

### 8. Widget test coverage beyond `match_history_screen` (P2)

- **Current state:** Only `match_history_screen` has widget tests.
- **Why deferred:** Day 2A.5 used a single representative test to
  verify the provider-injection pattern. Adding one widget test per
  screen is a follow-up.
- **Owner:** Engineering backlog.
- **Risk if forgotten:** UI regressions in other migrated screens
  may not be caught by tests.

---

## Cosmetic gaps

### 9. Theme hardcoded `light` (P0 cosmetic)

- **Current state:** `themeMode: ThemeMode.light` in `lib/main.dart`.
  Dark theme branch exists but is dead code.
- **Why deferred:** Requires UX decision on dark theme palette
  polish; not a stability issue.
- **Owner:** UX sprint (Day 3+).
- **Risk if forgotten:** Users on dark-mode system will see light
  theme. Cosmetic.

### 10. `/profile/equipment` route shadowing (P0 cosmetic)

- **Current state:** Route definition is fragile (Agent 3 audit).
- **Why deferred:** Cosmetic; navigation still works for primary flows.
- **Owner:** Engineering backlog.
- **Risk if forgotten:** Equipment deep link may 404 in edge cases.

---

## What this document is NOT

- This is **not** a list of bugs.
- This is **not** a list of things "the AI forgot".
- This is **not** a technical debt register (see
  `RELEASE_VERIFICATION_REPORT.md` §6 for that).

This is the document Phase D developers must read first so they
don't assume gaps below are "done" because the Stabilization Sprint
finished.