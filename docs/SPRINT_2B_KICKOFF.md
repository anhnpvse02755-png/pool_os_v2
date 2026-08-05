# Sprint 2B — Match Parity Kickoff

> **Branch:** `feature/parity/match`
> **Base:** `origin/main` at `dbe357d` (post-Sprint 2A merge)
> **Owner:** TBD
> **Started:** 2026-08-05
> **Status:** SPEC — awaiting approval before coding
> **Constitution:** `docs/engineering-constitution.md` (8 Articles)
> **Predecessor:** Sprint 2A — Equipment Parity (PR #3, merged)
> **Retrospective:** `docs/SPRINT_2A_RETRO.md`

---

## 1. Why this sprint

Sprint 2A closed the Equipment module. Match is the next
player-facing domain and the bridge to recording/reporting flows.

| Module | Sprint | State |
|---|---|---|
| Knowledge | Sprint 1 | Shipped |
| Equipment | 2A | Shipped (PR #3) |
| **Match** | **2B** | **<-- This sprint** |
| Coach   | 2C | Queued |

Match is the most complex business domain in Pool OS: 30+ model
fields, 3 services, 3 screens, and cross-references to Equipment
snapshot, Player state, and AI analysis. Choosing Tier B with
the same discipline as Sprint 2A is critical.

## 2. Scope decision (locked)

Per stakeholder sign-off 2026-08-05:

- **Depth:** Core match CRUD + summary screen + basic statistics.
  Racks/timeline/equipment-snapshot/AI-analysis deferred.
- **Tier 1:** Add `match_repository_test.dart` to Critical Suite
  if AC-1 ships.
- **Stats:** Win/loss ratio, average score, match count. AI
  recommendation deferred (Sprint 2C).
- **Equipment snapshot:** Read-only consumption from existing
  snapshot stored in Match. No dual-write logic in this sprint.

## 3. Module inventory (V2 today)

### Models

| File | Lines | Status |
|---|---|---|
| `lib/data/models/match.dart` | 653 | Complete (30+ fields, `isWin/isLoss/isDraw` getters, copyWith, `MatchStats` aggregate) |
| `lib/data/models/match_analysis.dart` | 281 | Complete (AI analysis payload) |
| `lib/data/models/match_environment.dart` | 47 | Complete (light/table/venue metadata) |
| `lib/data/models/match_model.dart` | 47 | **Legacy** — referenced only by `supabase_service.dart` |
| `lib/data/models/match_model.g.dart` | 50 | Generated companion to `match_model.dart` |

### Repo

| File | Lines | Status |
|---|---|---|
| `lib/data/repositories/match_repository.dart` | 297 | Contract + Local impl with 30+ methods (CRUD, racks, player state, equipment snapshot, timeline, analysis, aggregates) |

### Services

| File | Lines | Status |
|---|---|---|
| `lib/domain/services/match_recording_service.dart` | 81 | Recording orchestrator |
| `lib/domain/services/match_statistics_service.dart` | 367 | Aggregation service |
| `lib/domain/services/match_weakness_signals.dart` | 66 | Weakness detector (Coach-related) |

### UI

| File | Lines | Status |
|---|---|---|
| `lib/presentation/screens/play/match_history_screen.dart` | 269 | List of matches |
| `lib/presentation/screens/play/match_recording_screen.dart` | 740 | Live recording UI |
| `lib/presentation/screens/play/match_summary_screen.dart` | 521 | Post-match summary |
| `lib/presentation/screens/play/friendly_match_screen.dart` | n/a | Setup flow |
| `lib/presentation/screens/play/quick_match_screen.dart` | n/a | Setup flow |

### Dead code

| File | Lines | Status |
|---|---|---|
| `lib/data/datasources/supabase_service.dart` | 310 | 0 importer in `lib/` or `test/` — orphan |
| `lib/data/models/match_model.dart` | 47 | Only referenced by `supabase_service.dart` |
| `lib/data/models/match_model.g.dart` | 50 | Generated companion |

### Tests

| File | Status |
|---|---|
| `test/*match*` | None at the repo level — only `test/widget/match_history_screen_test.dart` (smoke) |

## 4. Gap analysis — V1 to V2

### Already present in V2

- 30+ V1 Match fields preserved in `match.dart`.
- Full CRUD + cascade delete (racks/timeline/analysis wipes).
- Player aggregates computation.
- `isWin` / `isLoss` / `isDraw` getters.
- Match recording screen, summary screen, history screen.
- Match statistics service (match_count, win rate, etc.).
- Weakness signals serving (Coach-readiness).

### Gaps to close during this sprint

| Gap | Severity | Action |
|---|---|---|
| **No repository test coverage** | High | AC-1 adds `match_repository_test.dart` with 8 cases. |
| **Match summary statistical surface untested** | Medium | Same AC-1 covers `getPlayerAggregates` correctness. |
| **No widget test for match summary** | Low | AC-2 adds a 3-assertion smoke. |
| **`SupabaseService` (310 lines) + legacy `MatchModel` chain** | Low | AC-3 deletes after grep proves zero importers. |

### Out of scope this sprint

- Rack / shot / timeline full lifecycle (data model exists; UI
  surface deferred — most players log lifetime, not shot-by-shot).
- AI analysis writing (model exists; writing path is in 2C).
- Live recording flow robustness (screen exists; deferred).
- Cross-device sync (V1 was local-only; Supabase code is dead).

## 5. Acceptance Criteria

Per Constitution Article 8 (Evidence over Artifacts), this sprint
has 4 ACs — same shape as 2A. Anything outside this list is
deferred or already covered.

### AC-1: Match repository critical-suite coverage

**GIVEN** today there is no `match_repository_test.dart`
**WHEN** sprint closes
**THEN** `test/match_repository_test.dart` exists and covers 8 cases:

1. **CRUD round-trip** — create, read-by-id, update, list, delete.
2. **Cascade delete** — deleting a match removes its racks, player
   state, equipment snapshot, timeline, and analysis keys.
3. **getMatchesBySession** — returns only matches with the given
   session id, in newest-first order.
4. **getPlayerAggregates** — for a player with N wins + M losses,
   returns `matchCount = N+M`, `winRate = N/(N+M)`.
5. **Statistics compute** — `MatchStats` exposes total matches,
   wins, losses, win rate, average opponent score relative to
   player score; arithmetic is correct on a known seed.
6. **Duplicate ID guard** — saving a match with an id that already
   exists updates in place rather than appending (parallel to
   Equipment Case 9).
7. **Invalid reference safety** — `getMatchById`, `deleteMatch`,
   `updateMatch`, `saveRack`, `saveAnalysis` on unknown match ids
   are silent no-ops, never throw.
8. **Score progression invariants** — `playerScore` and
   `opponentScore` are non-negative; the sum cannot exceed `raceTo`
   if `raceTo` is set; `resultSummary` updates reflect the score.

The file MUST be added to `test/CRITICAL_SUITE.md` and both
runner scripts if AC-1 ships.

### AC-2: Widget smoke

Per Article 8, one widget smoke is sufficient for Tier B.

`test/widget/match_summary_flow_test.dart` asserts exactly:

1. Match summary screen opens without crash.
2. Summary shows player score and opponent score.
3. Result label ("Win" / "Loss" / "Draw") renders.

No rack interactions, no timeline scroll, no equipment snapshot
preview. Full flow is manual QA on a real device.

### AC-3: Delete dead Supabase/MatchModel chain

`lib/data/datasources/supabase_service.dart` (310 lines),
`lib/data/models/match_model.dart` (47 lines), and
`lib/data/models/match_model.g.dart` (50 lines) are dead code.

**Preconditions to verify before deletion:**

1. `grep -rn "SupabaseService\|supabase_service" lib/ test/`
   returns **only the file itself**.
2. `grep -rn "MatchModel\|match_model.dart" lib/ test/`
   returns **only the legacy files and the now-deleted service**.
3. `flutter analyze` 0 errors after removal.
4. `bash scripts/run_critical_suite.sh` still PASS.

**If any grep is non-empty**, the deletion is BLOCKED. Instead:
mark the files `@Deprecated` with TODO pointing to this AC. Do
not delete in 2B.

**Order of removal** (single commit):

1. Delete `lib/data/datasources/supabase_service.dart`.
2. Delete `lib/data/models/match_model.dart` and
   `lib/data/models/match_model.g.dart`.
3. Remove any barrel exports (none expected).
4. Re-run gates.

**Justification:** 0 importer in `lib/` and `test/`; legacy V1
JSON model never migrated; supabase_service was a planned V3
feature that never connected.

### AC-4: Critical Suite manifest sync

Only invoked if AC-1 ships. Updates `test/CRITICAL_SUITE.md`,
`scripts/run_critical_suite.sh`, and `scripts/run_critical_suite.ps1`
to include `test/match_repository_test.dart`.

If AC-1 does not actually add a new file, this AC collapses to
nothing (Article 8 forbids updating "just because a sprint
opened").

### What is explicitly NOT in this sprint

Per Article 8 and Tier B classification:

- Rack / shot / timeline full lifecycle testing.
- AI analysis writing path (Sprint 2C).
- Multi-flow widget test.
- `SPRINT_2B_VERIFICATION.md` — gate output is the verification.
- Real recording flow robustness UI work.

## 6. Definition of Done

Sprint 2B is closed when all of the following are true:

- [ ] All 4 Acceptance Criteria verified.
- [ ] `bash scripts/run_critical_suite.sh` PASS (12 files after
       AC-1 ships, or 11 if AC-1 decides against promotion).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.
- [ ] Commit history follows Constitution conventions.
- [ ] Branch ready for PR review.

## 7. Verification gate scope (locked per Constitution)

This sprint is a **Match-domain sprint** classified as **Tier B**.
Per Articles 5 and 8:

- **Tier 1 (Critical Suite):** `match_repository_test.dart` added
  if AC-1 ships. **No other Tier 1 promotion without explicit
  reason.**
- **Tier 2 (widget tests):** exactly one smoke (3 assertions).
- **Tier 3 (Playwright):** not in this sprint. Deferred to the
  next Regression Sprint.
- **Tier 4 (visual):** no Golden tests; manual QA only.

Other domains (Coach, Knowledge, Training, Profile, Session)
**must not** be touched in this sprint except where a shared
provider requires a one-line update (with justification in commit
body).

## 8. Effort budget

Per Article 4 (10-20% test, 80-90% feature). Anticipated split:

| Phase | Effort | Notes |
|---|---|---|
| Spec & inventory | already done | this document |
| Repo test (Tier 1, AC-1) | ~45% | 8 cases, ~220 lines |
| Widget smoke (Tier 2, AC-2) | ~10% | 3 assertions |
| Dead-code cleanup (AC-3) | ~10% | 3 deletions, one commit |
| Manifest sync (AC-4, if AC-1) | ~5% | 3 line edits |
| Verification (gates) | ~30% | Critical Suite + analyze + builds |

Feature + test work is the bulk; reports and scorecards are not
generated because the gate output is the verification (Article 8).

## 9. Out-of-scope reminders

- Touching screens outside the Match domain (Coach, Knowledge, etc.)
  even if they import match types.
- Refactoring the recording screen beyond what AC-2 requires.
- Adding V1 features V2 doesn't have (e.g. deep shot-by-shot
  annotation). If a wish surfaces, file it in backlog.
- Creating `SPRINT_2B_VERIFICATION.md`. Per Article 8, gate output
  is the verification.

## 10. Sprint Exit Criteria

Sprint 2B **exits** when **every checkbox below is true**. Kept
short by design (Article 8).

### Engineering gate (the only automated gate)

- [ ] `bash scripts/run_critical_suite.sh` PASS (12 or 11 files
       depending on AC-1 outcome).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.

### Functional smoke (manual)

- [ ] Match summary screen opens and shows score + result.
- [ ] Match history screen lists matches.
- [ ] Recording screen → save → summary flow works on a real device.

### Hygiene

- [ ] PR opened with reference to this kickoff doc.
- [ ] Branch `feature/parity/match` ready to merge, no force-push,
       linear history since branch base.
- [ ] No `SPRINT_2B_VERIFICATION.md` created (Article 8).

### Decision: "Ready for Sprint 2C"

When ALL of the above are checked, sprint is closed. Product Owner
signs the PR. Sprint 2C (Coach Parity) opens with a new
`feature/parity/coach` branch from the merge of 2B.

## 11. References

- `docs/engineering-constitution.md` — Articles 5-8.
- `docs/SPRINT_2A_KICKOFF.md` — preceding sprint spec.
- `docs/SPRINT_2A_RETRO.md` — retro (note Article 8 worked).
- `lib/data/models/match.dart` — domain model.
- `lib/data/repositories/match_repository.dart` — repo contract.
- `lib/domain/services/match_statistics_service.dart` — stats.

## 12. Commit conventions

1. First commit: `test(match): repository critical-suite coverage`.
2. Subsequent commits scoped to one AC each.
3. Tag final commit: `chore(sprint2b): close — sprint 2B verification`.
4. Open PR referencing this doc.

## 13. Decision log

- **2026-08-05** — Sprint 2B scope locked (core CRUD + summary,
  8 test cases, dead Supabase code to be deleted).
- **2026-08-05** — `feature/parity/match` branch created at
  `dbe357d`.
- **2026-08-05** — Article 8 carried forward from 2A; same 4-AC
  shape.
- **2026-08-05** — Audit confirmed `SupabaseService` and the
  legacy `MatchModel` chain are 0-importer dead code and can be
  deleted in AC-3.