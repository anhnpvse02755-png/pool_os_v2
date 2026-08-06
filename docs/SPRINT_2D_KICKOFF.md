# Sprint 2D — Training Parity Kickoff

> **Branch:** `feature/parity/training`
> **Base:** `origin/main` at `2b09adb` (post-Sprint 2C merge)
> **Owner:** TBD
> **Started:** 2026-08-06
> **Status:** SPEC — awaiting approval before coding
> **Constitution:** `docs/engineering-constitution.md` (8 Articles)
> **Predecessor:** Sprint 2C — Coach Parity (PR #9, merged)
> **Retrospective:** `docs/SPRINT_2C_RETRO.md` (TODO — write after sprint close)

---

## 1. Why this sprint

Sprint 2C closed the Coach module. Training is the largest
player-facing domain and the engine behind every drill session,
progress chart, learning path, and certification.

| Module | Sprint | State |
|---|---|---|
| Knowledge | Sprint 1 | Shipped |
| Equipment | 2A | Shipped (PR #3) |
| Match | 2B | Shipped (PR #4) |
| Coach | 2C | Shipped (PR #9) |
| **Training** | **2D** | **<-- This sprint** |

Training is **larger than Coach by ~10x** (~6,641 LOC across 15
screens vs Coach's ~588 LOC across 7 files). The drill_session
recovery path is already Tier 1 (Sprint 1 baseline); the rest of
the Training domain is fragmented — many screens, few tests. The
risk this sprint: getting lost in surface area. Tier B + the
same discipline as 2A/2B/2C applies.

## 2. Scope decision (locked)

Per the same sign-off pattern as 2A/2B/2C:

- **Depth:** Drill-attempt persistence correctness + dead-code
  audit on the wider Training surface. UI redesign of any
  Training screen is out of scope. Real-time coach / drill
  recommendation tuning is out of scope (Coach owns that).
- **Tier 1:** Add `drill_attempt_repository_test.dart` to the
  Critical Suite if AC-1 ships. The existing
  `drill_session_recovery_test.dart` (Sprint 1 baseline at
  index 11) stays Tier 1.
- **Tier 2:** One widget smoke for `drill_session_screen`.
  Covers the screen that wires the most domain code (drill
  library + session + attempts + recovery).
- **Tier 3:** No Playwright. Training screens need real touch
  interaction (drag, timer); Playwright is not appropriate.
- **Tier 4:** Manual QA only.

## 3. Module inventory (V2 today)

### Models

| File | Lines | Status |
|---|---|---|
| `lib/data/models/drill.dart` | 120 | Complete (`DrillInfo`, `DrillCategory`) |
| `lib/data/models/drill_attempt.dart` | 44 | Per-attempt outcome (`made`, `timeMs`, `notes`) |
| `lib/data/models/drill_progress.dart` | 80 | Per-drill best / streak |
| `lib/data/models/drill_session.dart` | 214 | Session state + `attempts` list + pause/resume |
| `lib/data/models/training_session.dart` | 78 | Top-level training session |

### Repos

| File | Lines | Status |
|---|---|---|
| `lib/data/repositories/drill_repository.dart` | 81 | `DrillRepository` interface (drills + categories) |
| `lib/data/repositories/drill_session_repository.dart` | 111 | `IDrillSessionRepository` interface + Local impl (sessions + attempts) |
| `lib/data/impl/local_drill_repository.dart` | 136 | SharedPreferences-backed drill library |

### Services

| File | Lines | Status |
|---|---|---|
| `lib/domain/services/drill_library_service.dart` | 90 | Reads parsed drill library |
| `lib/domain/services/drill_recommendation_service.dart` | 66 | Heuristic recommendations |
| `lib/domain/services/drill_recommender_v2.dart` | 82 | Phase B recommender (knowledge-gap aware) |
| `lib/domain/services/drill_session_recovery_service.dart` | 92 | Pause/resume + attempt recording |

### UI (15 screens, 6,641 LOC)

| File | Lines | Purpose |
|---|---|---|
| `lib/presentation/screens/training/training_center_screen.dart` | 624 | Hub |
| `lib/presentation/screens/training/drill_list_screen.dart` | 628 | Catalog |
| `lib/presentation/screens/training/drill_detail_screen.dart` | 604 | Per-drill detail |
| `lib/presentation/screens/training/drill_session_screen.dart` | 389 | Active session UI |
| `lib/presentation/screens/training/drill_result_screen.dart` | 282 | Result summary |
| `lib/presentation/screens/training/progress_screen.dart` | 398 | Charts |
| `lib/presentation/screens/training/learning_path_screen.dart` | 520 | Curriculum |
| `lib/presentation/screens/training/knowledge_screen.dart` | 441 | In-Training knowledge |
| `lib/presentation/screens/training/knowledge_detail_screen.dart` | 526 | Article reader |
| `lib/presentation/screens/training/assessment_screen.dart` | 594 | Quiz |
| `lib/presentation/screens/training/certification_list_screen.dart` | 214 | Cert catalog |
| `lib/presentation/screens/training/certification_detail_screen.dart` | 285 | Cert detail |
| `lib/presentation/screens/training/recommended_screen.dart` | 571 | Recs |
| `lib/presentation/screens/training/training_history_screen.dart` | 565 | History |

### Tests

| File | Status |
|---|---|
| `test/drill_session_recovery_test.dart` | **Already exists** (Tier 1, Sprint 1 baseline index 11) |
| `test/presentation/screens/training/learning_path_screen_test.dart` | Tier 2 (Sprint 2A widget smoke) |
| `test/presentation/screens/training/knowledge_screen_test.dart` | Tier 2 |
| `test/presentation/screens/training/knowledge_detail_screen_test.dart` | Tier 2 |
| `test/personal_best_repository_test.dart` | Tier 1 (covers drill_progress sibling) |

## 4. Gap analysis — V1 to V2

### Already present in V2

- `DrillSession` with `attempts` list, pause/resume via
  `pausedAt` field.
- `DrillAttempt` per-attempt outcome (made, timeMs, notes).
- `DrillSessionRecoveryService` for in-flight session recovery.
- `DrillLibraryService` reads parsed asset via
  `cacheRepositoryProvider`.
- 3 widget smoke tests for Learning Path / Knowledge / Knowledge
  Detail screens (Tier 2).
- `personal_best_repository_test.dart` covers the
  personal-best / drill-progress atomicity invariant.

### Gaps to close during this sprint

| Gap | Severity | Action |
|---|---|---|
| **No test for `DrillAttempt` persistence** (`IDrillSessionRepository.addAttempt`) | High | AC-1 adds `drill_attempt_repository_test.dart` to Critical Suite. |
| **Dead code in Training screens** (`progress_screen.dart`, `learning_path_screen.dart`, `recommended_screen.dart` are likely candidates per Sprint 2C observations) | TBD | Audit at AC-3, same locked deletion policy. |
| **No widget smoke for `drill_session_screen`** (the screen that wires the most domain code) | Medium | AC-2 single smoke (3 assertions). |
| **Coaches' `training_plan_screen.dart` may overlap with `learning_path_screen.dart`** | Low | Audit at AC-3. |

### Out of scope this sprint

- Refactoring any Training screen beyond what AC-2 requires.
- UI redesign of `training_center_screen.dart` (largest screen).
- Wiring Coach recommender (`drill_recommender_v2.dart`) more
  tightly into Training — that is a Coach-side concern per
  Sprint 2C Dependency Boundary.
- Real-time collaboration / multiplayer drills.
- Certification certificate PDF generation.

## 5. Acceptance Criteria

Per Constitution Article 8 (Evidence over Artifacts), this sprint
has 4 ACs — same shape as 2A/2B/2C.

### AC-1: DrillAttempt critical-suite coverage

**GIVEN** `IDrillSessionRepository.addAttempt` persists
`DrillAttempt` records per session
**WHEN** sprint closes
**THEN** a new file `test/drill_attempt_repository_test.dart`
covers:

1. **CRUD round-trip** — `addAttempt` writes a `DrillAttempt`,
   `getAttemptsBySession` reads it back with all fields intact
   (`id`, `sessionId`, `drillCode`, `attemptNumber`, `made`,
   `timeMs`, `notes`, `createdAt`).
2. **Multiple attempts per session** — 5 attempts added in order
   are read back in insertion order with monotonically increasing
   `attemptNumber`.
3. **Attempt counter monotonic** — re-adding a session's
   `attemptNumber` does NOT overwrite the original; the
   repository appends or rejects (per LocalDrillSessionRepository
   behavior). Test asserts whichever behavior is implemented.
4. **Session isolation** — attempts for session A are not
   returned by `getAttemptsBySession('B')`.
5. **Empty-session case** — `getAttemptsBySession` on a session
   id with no attempts returns empty list, not null / throw.
6. **JSON round-trip** — `toJson` / `fromJson` of `DrillAttempt`
   preserves all fields including nullable `timeMs` and `notes`.

The file MUST be added to `test/CRITICAL_SUITE.md`, both runner
scripts, and the rationale updated to mention DrillAttempt.

### AC-2: drill_session_screen widget smoke

Per Article 8, one widget smoke is sufficient for Tier B.

`test/widget/drill_session_screen_test.dart` asserts exactly:

1. Drill session screen mounts without crash.
2. Attempt count or progress indicator renders (any of the
   session-state UI elements).
3. Pausing the session does not throw (calls the recovery
   service via the screen's pause action).

No score assertions, no timer simulation, no manual tap-through.
Manual QA on a real device covers the rest.

### AC-3: Dead-code audit + cleanup

Audit the Training screens for unused code paths. Candidates
surfaced during pre-sprint inventory:

- `recommended_screen.dart` (571 LOC) — may be superseded by
  `learning_path_screen.dart` (520 LOC) if Learning Paths are
  the canonical entry now.
- `progress_screen.dart` (398 LOC) — may have been replaced by
  the Training dashboard in `training_center_screen.dart`.
- Coaches-side `training_plan_screen.dart` (under
  `presentation/screens/coach/`) — verify ownership boundary
  between Coach domain and Training domain.
- Generated `.g.dart` companions that lost their source
- Any other dead code surfaced during the audit

**Deletion policy (locked):** Audit trước bằng grep + runtime
verification. Chỉ xóa khi xác nhận **0 importer** và
**0 runtime reference**. Không dùng trạng thái `@Deprecated`.

**Preconditions to verify before deletion:**

1. `grep -rn "" lib/ test/` returns only true consumers
   (not just the file itself).
2. `flutter analyze` 0 errors after removal.
3. `bash scripts/run_critical_suite.sh` still PASS.

**If grep is non-empty**, deletion BLOCKED. The file stays —
no deprecation stub, no soft-removal. Re-evaluate in Sprint 2E
or later.

### AC-4: Critical Suite manifest sync

`test/coach_profile_aggregator_test.dart` rationale was refreshed
in Sprint 2C. After Sprint 2D ships AC-1, the new
`drill_attempt_repository_test.dart` must be added to:

- `test/CRITICAL_SUITE.md` (the manifest).
- `scripts/run_critical_suite.sh` (bash runner).
- `scripts/run_critical_suite.ps1` (Windows runner, if it
  exists — verify).
- "Inventory at a glance" totals: 12 → 13 files.

If any of the runners or the manifest is already in sync,
AC-4 is verification-only.

### What is explicitly NOT in this sprint

- Real-time multiplayer drills.
- UI redesign of `training_center_screen.dart`.
- Cross-domain dashboards (Coach + Training integration).
- `SPRINT_2D_VERIFICATION.md` — gate output is the verification.
- Per-AC scorecard.
- New Tier 2 widget tests beyond the AC-2 single smoke.
- Refactoring `drill_session_recovery_service.dart` beyond what
  AC-1 requires.

## 6. Definition of Done

Sprint 2D is closed when all of the following are true:

- [ ] All 4 Acceptance Criteria verified.
- [ ] `bash scripts/run_critical_suite.sh` PASS (13 files).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.
- [ ] Commit history follows Constitution conventions.
- [ ] Branch ready for PR review.

## 7. Verification gate scope (locked per Constitution)

This sprint is a **Training-domain sprint** classified as **Tier B**.
Per Articles 5 and 8:

- **Tier 1 (Critical Suite):** expand `drill_attempt_repository_test.dart`
  to cover AC-1 invariants. Sprint 1 baseline
  `drill_session_recovery_test.dart` stays.
- **Tier 2 (widget tests):** exactly one smoke for
  `drill_session_screen` (3 assertions).
- **Tier 3 (Playwright):** not in this sprint.
- **Tier 4 (visual):** no Golden tests; manual QA only.

Other domains (Knowledge, Equipment, Match, Coach, Profile,
Session) **must not** be touched in this sprint except where a
shared provider requires a one-line update (with justification
in commit body).

## 8. Effort budget

Per Article 4 (10-20% test, 80-90% feature). Anticipated split:

| Phase | Effort | Notes |
|---|---|---|
| Spec & inventory | already done | this document |
| Repo test (Tier 1, AC-1) | ~35% | 6 cases, persistence correctness |
| Widget smoke (Tier 2, AC-2) | ~10% | 3 assertions |
| Dead-code cleanup (AC-3) | ~15% | audit + 0-2 deletions (most likely 0) |
| Manifest sync (AC-4) | ~10% | 13-file manifest, runner sync |
| Verification (gates) | ~30% | Critical Suite + analyze + builds |

This sprint's highest-value item is AC-1's `DrillAttempt`
persistence test — exactly the kind of latent bug Article 6 +
Article 8 anticipate catching with a Tier 1 test.

## 9. Out-of-scope reminders

- Refactoring `training_center_screen.dart`.
- Touching screens outside the Training domain.
- Adding a `training_plan_screen.dart` migration path.
- Creating `SPRINT_2D_VERIFICATION.md`.
- Adding Tier 2 widget tests beyond AC-2's single smoke.
- Wiring Coach recommender into Training (Coach-side concern
  per Sprint 2C Dependency Boundary).

## 10. Sprint Exit Criteria

Sprint 2D **exits** when **every checkbox below is true**.

### Engineering gate (the only automated gate)

- [ ] `bash scripts/run_critical_suite.sh` PASS (13 files).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.

### Functional smoke (manual)

- [ ] Drill session can be started, paused, resumed, completed.
- [ ] Drill attempts persist across app restart.
- [ ] Progress screen renders personal-best chart without crash.

### Hygiene

- [ ] PR opened with reference to this kickoff doc.
- [ ] Branch `feature/parity/training` ready to merge.
- [ ] No `SPRINT_2D_VERIFICATION.md` (Article 8).

### Decision: "Ready for Sprint 2E"

When ALL of the above are checked, sprint is closed. Sprint 2E
will be decided in retrospective based on what remains.

## 11. References

- `docs/engineering-constitution.md` — Articles 5-8.
- `docs/SPRINT_2C_KICKOFF.md` — preceding sprint spec.
- `lib/domain/services/drill_session_recovery_service.dart` — primary domain service.
- `lib/data/repositories/drill_session_repository.dart` — primary repository under test.
- `lib/data/models/drill_attempt.dart` — primary value object under test.
- `lib/presentation/screens/training/drill_session_screen.dart` — primary widget under smoke.

## 12. Commit conventions

1. First commit: `test(training): add drill_attempt critical-suite coverage`
   (AC-1, single atomic commit per Article 6).
2. Subsequent commits scoped to one AC each.
3. Tag final commit: `chore(sprint2d): close — sprint 2D verification`.

## 13. Decision log

- **2026-08-06** — Sprint 2D scope locked.
- **2026-08-06** — `feature/parity/training` branch created at `2b09adb`.
- **2026-08-06** — Article 8 carried forward from 2A/2B/2C; same 4-AC
  shape.
- **2026-08-06** — AC-1 `DrillAttempt` persistence flagged as the
  highest-value Tier 1 invariant for this sprint.
- **2026-08-06** — Dependency Boundary from Sprint 2C (§14 of
  Sprint 2C kickoff) carries forward: Training consumes
  derived signals from Coach, never raw Coach internals.
- **2026-08-06** — `progress_card.dart` ownership question (raised
  in Sprint 2C AC-3 audit, deletion BLOCKED) will be revisited
  in AC-3 of this sprint — Training domain is now in scope, so
  the file may legitimately belong here.
