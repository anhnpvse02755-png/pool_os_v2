# Sprint 2C — Coach Parity Kickoff

> **Branch:** `feature/parity/coach`
> **Base:** `origin/main` at `11b4fed` (post-Sprint 2B merge)
> **Owner:** TBD
> **Started:** 2026-08-05
> **Status:** SPEC — awaiting approval before coding
> **Constitution:** `docs/engineering-constitution.md` (8 Articles)
> **Predecessor:** Sprint 2B — Match Parity (PR #4, merged)
> **Retrospective:** `docs/SPRINT_2B_RETRO.md`

---

## 1. Why this sprint

Sprint 2B closed the Match module. Coach is the third
player-facing domain and the AI-backed recommendation engine.

| Module | Sprint | State |
|---|---|---|
| Knowledge | Sprint 1 | Shipped |
| Equipment | 2A | Shipped (PR #3) |
| Match | 2B | Shipped (PR #4) |
| **Coach** | **2C** | **<-- This sprint** |
| Training | 2D | Queued |

Coach is **smaller than Match** (426 LOC total vs 3,419) but more
questionable in quality: observations recorded during the
sprint-inventory work flagged real bugs (`CoachProfileAggregator`
returns non-zero `matchesAnalyzed` for empty repository) and
widely-distributed dead code. Tier B + the same discipline as
2A/2B applies.

## 2. Scope decision (locked)

Per the same sign-off pattern as 2A/2B:

- **Depth:** Aggregator correctness + recommendation engine
  sanity + dead-code cleanup. AI/ML model behavior is out of
  scope (we never had a real model — all recommendations are
  heuristic).
- **Tier 1:** Add `coach_profile_aggregator_test.dart` to the
  Critical Suite if AC-1 ships and the empty-repository bug is
  fixed.
- **Recommendations:** Cover the `DrillRecommendationV2`
  scoring path with a small smoke. Cold-start path is implicit
  via the same test.
- **Weakness signals:** Promote to Tier 1 if extending the
  aggregator test already covers it; otherwise leave in Tier 2.

## 3. Module inventory (V2 today)

### Models

| File | Lines | Status |
|---|---|---|
| `lib/data/models/coach_recommendation_model.dart` | 47 | Complete (`AIRecommendation`, `RecommendationType`, `CoachingSession`, `WeeklyAnalysis`, `StreakInfo`) |
| `lib/data/models/coach_recommendation_model.g.dart` | (generated) | Companion to model |

### Repos

| File | Lines | Status |
|---|---|---|
| `lib/data/impl/local_ai_coach_repository.dart` | 142 | 6 methods: recommendations, history, weekly analysis, streak |

### Services

| File | Lines | Status |
|---|---|---|
| `lib/domain/services/coach_profile_aggregator.dart` | 171 | Rollup of profile from match history + scoring |
| `lib/domain/services/drill_recommender_v2.dart` | 82 | Knowledge-gap-aware drill recommendation |
| `lib/domain/services/match_weakness_signals.dart` | 66 | Pure value class — 9 weakness counts + `toTags()` |

### UI

| File | Lines | Status |
|---|---|---|
| `lib/presentation/widgets/coach_profile_panel.dart` | (≈80) | Renders `CoachProfile` |
| `lib/presentation/widgets/progress_card.dart` | (≤80) | Training progress UI (not strictly Coach) |

### Tests

| File | Status |
|---|---|
| `test/coach_profile_aggregator_test.dart` | **Already exists** (Tier 1) — verified during Sprint 1 baseline |

## 4. Gap analysis — V1 to V2

### Already present in V2

- `CoachProfile` value class with skill scores + tone summary.
- `CoachProfileAggregator.generate()` reads from `IMatchRepository`.
- `DrillRecommendationV2` with knowledge-gap-aware scoring.
- `MatchWeaknessSignals` with `toTags()` for drill matching.
- `LocalAICoachRepository` with 6 methods.
- Tier 1 test for `CoachProfileAggregator` already exists.

### Gaps to close during this sprint

| Gap | Severity | Action |
|---|---|---|
| **Empty-repository bug** (`CoachProfileAggregator.generate()` returns non-zero matchesAnalyzed with empty repo) | High | Fix + regression test; this is the V1-like bug Article 6 anticipates. |
| **No test for `DrillRecommendationV2` scoring** | Medium | Add to Tier 1 if it stays small. |
| **No test for `MatchWeaknessSignals.toTags()`** | Low | Cover in the aggregator test (signals flow up). |
| **Dead code in Coach domain** | TBD | Audit at AC-3. |

### Out of scope this sprint

- Real ML model. Recommendations remain heuristic.
- UI redesign of `coach_profile_panel.dart`.
- Cross-domain dashboards (Knowledge + Coach) integration.
- Backend sync (Supabase removed in 2B).

## 5. Acceptance Criteria

Per Constitution Article 8 (Evidence over Artifacts), this sprint
has 4 ACs — same shape as 2A and 2B.

### AC-1: CoachProfileAggregator critical-suite coverage

**GIVEN** `test/coach_profile_aggregator_test.dart` exists from
Sprint 1 baseline
**WHEN** sprint closes
**THEN** the test file is **expanded** to cover the empty-
repository bug plus a small number of additional invariants. The
sprint ships:

1. **Empty-repository case** — `generate('p1')` with no matches
   for the player returns `matchesAnalyzed == 0`,
   `wins == 0`, `losses == 0`, `winRate == 0.0`, `skillScores`
   empty or zero-filled, and `tone` falls back to a known safe
   default. This is the regression test for the bug observed in
   pre-sprint work.
2. **Window filter** — matches older than the window are
   excluded from aggregates.
3. **Win/loss tally** — given 2 wins + 3 losses in the window,
   `wins == 2`, `losses == 3`, `winRate = 2/5 = 0.4`.
4. **Rack-level aggregation** — easy misses, position errors,
   fouls are summed across all racks in the window.
5. **Tone classification** — given a known win rate + recent
   trend, the `tone` field is one of
   `"Hot" / "Steady" / "Slumping" / "Rising"`.
6. **Cold-start (no matches) recommendation** — paired with
   `DrillRecommendationV2.coldStart()`, returns foundation-tier
   drills in the order of the library.

The file MUST be added to `test/CRITICAL_SUITE.md` and both
runner scripts if not already (Sprint 1 baseline already
includes it).

### AC-2: DrillRecommendationV2 widget smoke

Per Article 8, one widget smoke is sufficient for Tier B.

`test/widget/coach_recommendation_panel_test.dart` asserts
exactly:

1. Coach profile panel mounts without crash.
2. Recommendation section renders (or empty-state CTA).
3. Tapping a recommendation does not throw.

No score assertions, no trend chart testing, no knowledge-gap
edge cases. Manual QA on a real device.

### AC-3: Dead code audit + cleanup

Audit the Coach domain for unused code paths. Candidates known
right now:

- `progress_card.dart` (UI widget, may be referenced by Training
  not Coach — verify)
- Generated `.g.dart` companions that lost their source
- Any other dead code surfaced during the audit

**Preconditions to verify before deletion:**

1. `grep -rn "ProgressCard\|progress_card" lib/ test/` returns
   only true consumers (not just the file itself).
2. `flutter analyze` 0 errors after removal.
3. `bash scripts/run_critical_suite.sh` still PASS.

**Order of removal** (single commit):

1. Delete confirmed-dead files.
2. Remove barrel exports / unused imports.
3. Re-run gates.

**If grep is non-empty**, deletion BLOCKED. Mark `@Deprecated`
with TODO pointing to this AC.

### AC-4: Critical Suite manifest sync

If AC-1 expanded `coach_profile_aggregator_test.dart`, the
manifest count and rationale need an update. The file was
already in the Sprint 1 baseline at index 9, so this AC is
**mostly a verification**: confirm the file is still referenced
in `test/CRITICAL_SUITE.md`, both runners, and the rationale
mentions the Sprint 2C additions.

### What is explicitly NOT in this sprint

- Real ML / AI recommendation model.
- Cross-domain dashboards.
- Coach UI redesign.
- `SPRINT_2C_VERIFICATION.md` — gate output is the verification.
- Per-AC scorecard.

## 6. Definition of Done

Sprint 2C is closed when all of the following are true:

- [ ] All 4 Acceptance Criteria verified.
- [ ] `bash scripts/run_critical_suite.sh` PASS (12 files).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.
- [ ] Commit history follows Constitution conventions.
- [ ] Branch ready for PR review.

## 7. Verification gate scope (locked per Constitution)

This sprint is a **Coach-domain sprint** classified as **Tier B**.
Per Articles 5 and 8:

- **Tier 1 (Critical Suite):** expand `coach_profile_aggregator_test.dart`
  to cover the empty-repo bug + a few additional invariants.
- **Tier 2 (widget tests):** exactly one smoke (3 assertions).
- **Tier 3 (Playwright):** not in this sprint.
- **Tier 4 (visual):** no Golden tests; manual QA only.

Other domains (Knowledge, Equipment, Match, Training, Profile,
Session) **must not** be touched in this sprint except where a
shared provider requires a one-line update (with justification
in commit body).

## 8. Effort budget

Per Article 4 (10-20% test, 80-90% feature). Anticipated split:

| Phase | Effort | Notes |
|---|---|---|
| Spec & inventory | already done | this document |
| Repo test (Tier 1, AC-1) | ~40% | 6 cases, including the empty-repo fix |
| Widget smoke (Tier 2, AC-2) | ~10% | 3 assertions |
| Dead-code cleanup (AC-3) | ~15% | audit + 1-2 deletions |
| Manifest sync (AC-4) | ~5% | verification + small edits |
| Verification (gates) | ~30% | Critical Suite + analyze + builds |

The empty-repository bug is the highest-value item in this sprint
because it is exactly the kind of latent bug Article 6 + Article 8
anticipate catching with a Tier 1 test.

## 9. Out-of-scope reminders

- Replacing the heuristic recommender with a real model.
- Touching screens outside the Coach domain.
- Refactoring `coach_profile_panel.dart` beyond what AC-2
  requires.
- Creating `SPRINT_2C_VERIFICATION.md`.

## 10. Sprint Exit Criteria

Sprint 2C **exits** when **every checkbox below is true**.

### Engineering gate (the only automated gate)

- [ ] `bash scripts/run_critical_suite.sh` PASS (12 files).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.

### Functional smoke (manual)

- [ ] Coach profile panel opens and renders profile.
- [ ] Recommendation section shows current recommendations.
- [ ] Tapping a recommendation navigates to the drill.

### Hygiene

- [ ] PR opened with reference to this kickoff doc.
- [ ] Branch `feature/parity/coach` ready to merge.
- [ ] No `SPRINT_2C_VERIFICATION.md` (Article 8).

### Decision: "Ready for Sprint 2D"

When ALL of the above are checked, sprint is closed. Sprint 2D
(Training Parity) opens with a new branch from the merge of 2C.

## 11. References

- `docs/engineering-constitution.md` — Articles 5-8.
- `docs/SPRINT_2B_KICKOFF.md` — preceding sprint spec.
- `docs/SPRINT_2B_RETRO.md` — retro confirming Article 8 worked.
- `lib/domain/services/coach_profile_aggregator.dart` — domain service.
- `lib/domain/services/drill_recommender_v2.dart` — recommender.
- `lib/domain/services/match_weakness_signals.dart` — value class.
- `lib/data/impl/local_ai_coach_repository.dart` — repo.
- `test/coach_profile_aggregator_test.dart` — existing Tier 1 (Sprint 1 baseline).

## 12. Commit conventions

1. First commit: `test(coach): extend aggregator critical-suite coverage`.
2. If empty-repo bug is fixed: split into a separate commit
   `fix(coach): empty-repository returns zero-state` (Article 6).
3. Subsequent commits scoped to one AC each.
4. Tag final commit: `chore(sprint2c): close — sprint 2C verification`.

## 13. Decision log

- **2026-08-05** — Sprint 2C scope locked.
- **2026-08-05** — `feature/parity/coach` branch created at `11b4fed`.
- **2026-08-05** — Article 8 carried forward from 2A/2B; same 4-AC
  shape.
- **2026-08-05** — Empty-repository bug in `CoachProfileAggregator`
  flagged as AC-1 highest-value item.
- **2026-08-05** — `progress_card.dart` flagged as AC-3 audit
  candidate (may be Training-domain, not Coach).