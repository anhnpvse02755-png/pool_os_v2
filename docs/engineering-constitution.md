# Engineering Constitution

> **The principles that govern how Pool OS is built.**
> **Origin:** Sprint 2 architectural decision (2026-08-05).
> **Status:** Adopted. Supersedes ad-hoc testing conventions.

## Preamble

This document is the long-form answer to one question:

> *How do we ship features fast without trading away quality?*

The answer is **not** "test everything" or "test nothing". Both
extremes fail. This constitution picks the middle ground that fits
Pool OS at its current stage: a Flutter app in active feature
development, with a small team, where speed matters but data
correctness is non-negotiable.

---

## Article 1 — The One-Line Rule

> **Test every business rule. Test every bug once. Don't test
> framework behavior or trivial UI rendering.**

Three corollaries:

1. **Business rules** — anything that computes money, score, ranking,
   statistics, debt, or transforms data permanently — must have a
   unit test.
2. **Bugs** — every bug that is fixed must ship with a regression
   test that fails on the buggy code and passes on the fix.
3. **Skip** — Flutter's framework, padding, color, animation, and
   text style choices are not testable as business behavior. Don't
   write tests for them.

If a reviewer asks "why is this test here?", the answer must be one
of the three above. If none fits, delete the test.

---

## Article 2 — Test Tiers

Every test belongs to exactly one tier. The tier decides what to
test, how much, and what gate it gates.

### Tier 1 — Critical (mandatory, gates every release)

**Scope:** business rules whose wrongness loses data, money, or
trust.

Examples:

- Knowledge migration V1 → V2
- Match scoring and statistics aggregation
- Personal best repository transactions
- Weekly report generation
- AI drill recommendation logic
- Debt / coffee calculation
- Repository import / export
- Streak calculation
- Coach profile aggregation

**Required test types:** unit test, plus a regression test for any
bug ever filed against this module.

**Gate:** every Engineering Gate run. See Article 3.

**Owner:** the engineer who changes the code. No commit to Tier 1
files merges without updating the matching tests.

### Tier 2 — Important (test the flow, not the pixels)

**Scope:** feature modules that users depend on daily — Knowledge,
Equipment, Coach, Reports, Training, Session.

**Test what:**

- Search and filter behavior
- CRUD for primary entities
- Main navigation between top-level screens

**Do not test:**

- Icon, padding, color, animation
- Text style and font choice
- Layout refactor whose semantics are unchanged
- Loading spinners and skeleton placeholders

**Coverage target:** roughly **2–5 widget tests per module**, written
as **one end-to-end flow test** rather than many isolated unit
tests. Example: a Knowledge flow test covers search, open, back as
one scenario.

**Gate:** module smoke before sprint close. Not gating per-PR unless
the PR touches that module.

### Tier 3 — UI flows (Playwright, no widget tests)

**Scope:** visual / interactive surfaces where the value is the
user journey, not the function calls.

Examples: full Knowledge browsing flow, match recording flow with
camera, on-boarding.

**How to verify:**

- **Smoke test** via Playwright flow.
- **Manual QA** for visual polish.
- **No widget tests** — these would cost more to maintain than they
  save.

**When it runs:** **CI on every PR** (per Sprint 2 decision).
Playwright is slow but flake-prone; the gate's job is to catch
*catastrophic* flow breakage (screen does not render, navigation
crashes), not pixel-level regressions.

**Example smoke flow:**

```
Open app
  → Open Knowledge
  → Search "kick"
  → Open first result
  → Back
PASS
```

If the flow reaches the end, it passes. We do not assert on
specific text or styling inside Tier 3.

### Tier 4 — Visual (no Golden tests)

Flutter's Golden tests are high maintenance and low value for a
fast-moving Flutter app where visual design is still evolving.

**Skip Golden tests.** Verify visual changes via manual QA on the
three target platforms (Android phone, Android tablet, Web desktop).

---

## Article 3 — The Sprint Gates

Every Sprint must close with three gates passing. Each gate has a
script. The gates run in order; a failure stops the sprint close.

### Gate 1 — Engineering Gate (automated)

| Step | Command | Pass condition |
|---|---|---|
| 1 | `flutter analyze` | 0 errors. Warnings / info allowed but tracked. |
| 2 | `scripts/run_critical_suite.sh` | All Tier 1 tests pass. |
| 3 | `flutter build web --release` | Exit code 0. |
| 4 | `flutter build apk --debug` | Exit code 0. |

Note: **only Tier 1 is run by default** during a sprint. Running the
full test suite on every change is too slow. The full suite runs on
the clean-clone Repository Health gate (see
`docs/REPOSITORY_HEALTH_CHECKLIST.md`).

### Gate 2 — Functional Gate (semi-automated)

| Step | Method | Pass condition |
|---|---|---|
| 1 | Smoke test new flows manually | New feature can be exercised end-to-end. |
| 2 | Regression test for any bug fixed | Bug-fix commit ships with a test that fails without the fix. |
| 3 | Playwright tier 3 flows | All flows complete without crash. |

### Gate 3 — Product Gate (manual)

| Step | Method | Pass condition |
|---|---|---|
| 1 | Product Owner review | Owner signs off on Acceptance Criteria. |
| 2 | Acceptance Criteria checklist | All ACs checked. |

---

## Article 4 — The Test Budget

Per sprint:

- **80–90%** of engineering effort on **feature code**.
- **10–20%** of engineering effort on **tests and QA**.

**Concrete example:**

- Sprint writes ~2,000 lines of feature code.
- Co-located test code: **300–500 lines** is healthy.
- **3,000+ lines of test for 2,000 lines of code is a smell.**
  Either the tests are testing the framework, or the feature is too
  thin to justify its weight.

The budget is not a hard cap — it is a heuristic. The rule of thumb:

> If you find yourself writing more test than feature, ask why.
> Either you are testing the wrong thing, or you are building
> something the user does not need.

---

## Article 5 — Critical Suite Definition

The "Critical Suite" is the precise set of Tier 1 tests that Gate 1
runs. It is **declared explicitly** in `test/CRITICAL_SUITE.md`, not
discovered by tag or folder.

Why explicit and not tag-based?

- A manifest is auditable: code review can verify "this Tier 1 file
  is in the manifest".
- A manifest is stable: we do not depend on every contributor
  remembering to tag their test.
- A manifest is greppable: `grep -r "tier-1" test/` shows the
  inventory.

To add a test to the Critical Suite:

1. Add the file path to `test/CRITICAL_SUITE.md`.
2. Add a one-line rationale describing what business rule it
   protects.
3. Update `scripts/run_critical_suite.sh` to include the new path.

To remove a test from the Critical Suite:

1. Move the test to `test/non_critical/`.
2. Remove the entry from `test/CRITICAL_SUITE.md`.
3. Justify the demotion in the PR description.

---

## Article 6 — Bug-Fix Rule

Every bug fix has three parts:

1. **The fix** — code that resolves the bug.
2. **The regression test** — a test that fails on the buggy code and
   passes on the fix.
3. **The rationale** — a comment in the test explaining what bug
   this guards against.

A PR that fixes a bug but does not add a regression test is
**rejected by review** unless the bug is in a Tier 3 or 4 area
(visual, framework behavior). For Tier 1 and Tier 2, the regression
test is non-negotiable.

---

## Article 7 — When This Constitution Changes

This document changes only when:

- A new tier is added or removed.
- The Test Budget ratio shifts.
- A new mandatory gate is introduced.
- A decision is made to switch testing frameworks.

Changes to this document require:

1. A PR with the diff.
2. A retrospective note in `docs/RETROSPECTIVE_<sprint>.md`.
3. Sign-off from the engineering lead.

**Stable things do not need frequent amendment.** If the constitution
is being touched every sprint, the constitution is not doing its job.

---

## Appendix A — Quick reference

| What | Where |
|---|---|
| Full Constitution | `docs/engineering-constitution.md` (this file) |
| Critical Suite manifest | `test/CRITICAL_SUITE.md` |
| Critical Suite runner (Bash) | `scripts/run_critical_suite.sh` |
| Critical Suite runner (PowerShell) | `scripts/run_critical_suite.ps1` |
| Full Engineering Gate | `scripts/run_full_gates.sh` |
| Repository Health Checklist | `docs/REPOSITORY_HEALTH_CHECKLIST.md` |
| Playwright Tier 3 flows | `tests/00-*.spec.ts` |

## Appendix B — Decision log

- **2026-08-05** — Adopted. Tier 1-4 model, 10-20% test budget,
  Playwright on every PR, explicit Critical Suite manifest. See
  `docs/SPRINT_2_HANDOFF.md` for the originating discussion.
