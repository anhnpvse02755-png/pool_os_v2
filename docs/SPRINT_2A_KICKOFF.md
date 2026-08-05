# Sprint 2A — Equipment Parity Kickoff

> **Branch:** `feature/parity/equipment`
> **Base:** `origin/main` at `b582eaf` (Constitution baseline)
> **Owner:** TBD
> **Started:** 2026-08-05
> **Status:** SPEC — awaiting approval before coding
> **Constitution:** `docs/engineering-constitution.md`

---

## 1. Why this sprint

After Stabilization (R1-R3) and Sprint 1 (Knowledge + Repository
Health), Pool OS reaches **internal-beta ready** when its three
player-facing modules feel complete:

| Module | Sprint | State |
|---|---|---|
| Knowledge | Sprint 1 | Shipped (102 articles migrated) |
| **Equipment** | **2A** | **<-- This sprint** |
| Match      | 2B | Queued |
| Coach      | 2C | Queued |

Equipment is chosen first because:

1. **Highest-touch surface** — pool players log a cue before every
   match; broken or stubbed equipment UX breaks the recording flow.
2. **V1 reference is concrete** — `docs/screenshots/equipment-*.png`
   exists; we can diff V1 vs V2 visually.
3. **Model already exists** — `lib/data/models/equipment.dart` has
   all 17+ V1 fields. The work is wiring, not invention.

## 2. Scope decision (locked)

Per stakeholder sign-off 2026-08-05:

- **Depth:** Full V1 parity (17+ fields, 5 screens).
- **Tier 1:** Add `equipment_repository_test.dart` to Critical Suite
  manifest if and only if AC-1 ships.
- **Images:** Defer upload (no UI risk, no user demand today).
- **Stats + recommendation:** Keep in scope (model already supports
  both, screens already reference them).

## 3. Module inventory (V2 today)

### Models & repo

| File | Lines | Status |
|---|---|---|
| `lib/data/models/equipment.dart` | 415 | Complete (17+ fields, EquipmentStats, MaintenanceEntry) |
| `lib/data/repositories/equipment_repository.dart` | 49 | Contract complete |
| `lib/data/impl/local_equipment_repository.dart` | 418 | Implementation complete (CRUD + archive + active + stats + recommendation) |
| `lib/data/repositories/equipment_change_log_repository.dart` | 36 | Targeted for deletion in AC-3 |
| `lib/core/constants/equipment_constants.dart` | 214 | Brand/model catalog |

### UI

| File | Lines | Status |
|---|---|---|
| `lib/presentation/screens/profile/equipment_screen.dart` | 954 | List + search + filter + sort + compare + recommended |
| `lib/presentation/screens/profile/equipment_detail_screen.dart` | 563 | Full V1 field display |
| `lib/presentation/screens/profile/equipment_edit_screen.dart` | 692 | Add / edit form (all 17+ fields) |
| `lib/presentation/screens/profile/equipment_statistics_screen.dart` | 258 | Stats per cue |
| `lib/presentation/screens/profile/equipment_comparison_screen.dart` | 97 | Side-by-side compare |

### Providers

| File | Notes |
|---|---|
| `lib/core/providers/repository_providers.dart` | Exposes `equipmentRepositoryProvider` + 5 domain providers + `equipmentStatsProvider` |

### Tests

| File | Status |
|---|---|
| `test/**/*equipment*` | None exist — greenfield for Sprint 2A |

## 4. Gap analysis — V1 to V2

### Already present in V2

- All 17+ V1 fields in `Equipment` model.
- Full CRUD repository implementation.
- Active-role resolution (`playing` / `break` / `jump`, with
  `break_jump` fallback).
- Maintenance history (append-only log per equipment).
- Purchase + current value tracking.
- Stats per cue (match count, wins, accuracy, break speed, hours).
- Top-3 recommendation by usage.
- Compare (N) multi-select flow.
- Search + filter + sort.

### Gaps to close during this sprint

| Gap | Severity | Action |
|---|---|---|
| **No unit tests for `EquipmentRepository`** | High | AC-1 adds `test/equipment_repository_test.dart` and promotes it to Critical Suite. |
| **No widget test at all** | Low | AC-2 adds a single 3-assertion smoke. |
| **`EquipmentChangeLogRepository` unused** | Low | AC-3 deletes it after grep proves zero importers. |

### Out of scope this sprint

- Image upload (deferred, no user demand).
- Cloud sync of equipment (V1 was local-only too).
- Cross-player equipment sharing.

## 5. Acceptance Criteria

Per Constitution Article 8 (Evidence over Artifacts), this sprint
has 4 ACs — the minimum needed to ship Equipment Parity without
process overhead. Anything outside this list is either already
covered by other gates or deferred to a future sprint with
explicit justification.

### AC-1: Repository critical-suite coverage

**GIVEN** the Critical Suite today has no equipment coverage
**WHEN** sprint closes
**THEN** `test/equipment_repository_test.dart` exists and covers:

1. CRUD round-trip (create → read-by-id → update → list → delete).
2. Archive / unarchive correctly toggles visibility.
3. Maintenance log append + remove are atomic.
4. Active-role resolution: `setActiveCue` unsets previous; only one
   cue has `isActive=true` at any time across the playing role.
5. `getActiveCueByType('break')` falls back to `break_jump` when no
   dedicated break cue exists.
6. `getStatsForCue` returns zero-state when cue missing.
7. `getRecommendedEquipment` ranks by `(matches + hours)` desc and
   honors `topN` and `playerId` filter.
8. `getTotalEquipmentValue` sums `currentValue` across non-archived.
9. **Duplicate ID guard:** `createEquipment` with an id that already
   exists does NOT create a duplicate row. **Implementation note:**
   this case may require a code fix in
   `LocalEquipmentRepository.createEquipment` (current impl blindly
   appends — needs `indexWhere` check before add). If code change
   is needed, it is part of this AC and tracked in the same commit.
10. **Invalid reference safety:** operations on non-existent
    equipment IDs are safe no-ops, never throw. Specifically:
    - `updateEquipment(id_not_exists)` → silent return, no throw.
    - `deleteEquipment(id_not_exists)` → silent return, no throw.
    - `archiveEquipment(id_not_exists)` → silent return.
    - `setActiveCue(id_not_exists)` → leaves existing active cue
      state untouched.
    - `addMaintenanceEntry(id_not_exists, ...)` → silent return.

All 10 cases must pass. The file MUST be added to
`test/CRITICAL_SUITE.md` and both runner scripts (since this is a
real Tier 1 promotion with rationale per Constitution Article 5).

**Note on Case 10 scope:** the Equipment model is intentionally flat
(no foreign keys between cues/shafts/tips — they are siblings under
the same `Equipment` entity). "Invalid reference" here therefore
means *operations on IDs that don't exist in storage*, not cross-
entity FK validation. If a future sprint adds relational refs (e.g.
`shaftId` on `Cue`), this case must be extended.

### AC-2: Widget smoke

Per Constitution Article 8, widget tests are not a per-flow
exercise. One smoke test verifying the screen is reachable and
renders is sufficient for a Tier B business-logic sprint.

`test/widget/equipment_list_flow_test.dart` asserts exactly:

1. Equipment screen opens without crash.
2. Equipment list renders (≥ 1 item from seed).
3. Search box is present and accepts input.

No navigation simulation, no detail screen tap-through, no
back-button behavior. The full search → tap → detail flow is
**out of scope** for this sprint and is the responsibility of
manual QA on a real device.

### AC-3: Delete dead repository

`EquipmentChangeLogRepository` (and its `EquipmentChangeLog` model)
— record a decision in the PR.

**Decision (locked 2026-08-05):** **delete**.

**Preconditions to verify before deletion** (no surprise importers
downstream):

1. `grep -r "EquipmentChangeLog" lib/ test/ tools/` returns
   **only the file itself and its model**.
2. `grep -r "equipmentChangeLogRepositoryProvider" lib/ test/`
   returns **zero matches**.
3. `flutter analyze` 0 errors after removal.
4. `bash scripts/run_critical_suite.sh` still PASS.

**If any grep above is non-empty**, the deletion is BLOCKED.
Instead:

- Mark the class `@Deprecated('use Equipment.maintenanceHistory')`
  with a TODO pointing to this AC.
- File a follow-up issue to remove in next sprint.
- Do NOT remove in 2A.

**Order of removal** (all in one commit, single AC):

1. Delete `lib/data/models/equipment_change_log.dart`.
2. Delete `lib/data/repositories/equipment_change_log_repository.dart`.
3. Remove any provider wiring (none expected after grep check).
4. Re-run gates.

**Justification** (for commit body): no UI consumer; `Equipment.maintenanceHistory`
already provides append-only audit; no retention policy requires
a separate change log. Audit trail can be reconstructed from
`updatedAt` deltas if ever needed.

### AC-4: Critical Suite manifest sync

Only invoked if a new Tier 1 file is actually added in this sprint
(see AC-1). If AC-1 ships, then:

- `test/CRITICAL_SUITE.md` updated with new entry and one-line
  rationale.
- `scripts/run_critical_suite.sh` and `scripts/run_critical_suite.ps1`
  include the new file path.

If AC-1 does NOT actually add a new file (e.g. if it's decided to
keep Equipment at Tier 2 after discussion), this AC collapses to
nothing and there is no manifest work to do. The Constitution
explicitly forbids updating the manifest "just because a sprint
opened" (Article 8).

### What is explicitly NOT in this sprint

Per Article 8 and the Tier B classification of Equipment:

- **Playwright flow** — Equipment CRUD does not benefit from
  browser-level E2E. Deferred to the next Regression Sprint, where
  all domains get checked together.
- **Image upload UI** — V1 had photo picking; V2 currently uses
  `imageUrls = const []`. No user-visible regression. Defer until
  a player actually needs it (file a backlog ticket).
- **`SPRINT_2A_VERIFICATION.md`** — Per Article 8, the gate
  output is the verification. Do not create a separate document.
- **Multi-flow widget test** — Per Article 8, smoke is enough
  for Tier B at this stage.

## 6. Definition of Done

Sprint 2A is closed when **all** of the following are true. The
list is short by design — anything that the gates already verify
is not re-listed here (Article 8).

- [ ] All 4 Acceptance Criteria verified.
- [ ] `bash scripts/run_critical_suite.sh` PASS (will be 11 files
       after AC-1 ships, or 10 if AC-1 decides against promotion).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.
- [ ] Commit history follows Constitution conventions.
- [ ] Branch ready for PR review.

## 7. Verification gate scope (locked per Constitution)

This sprint is an **Equipment-domain sprint** classified as
**Tier B** (business logic). Per
`docs/engineering-constitution.md` Articles 5 and 8:

- **Tier 1 (Critical Suite):** `equipment_repository_test.dart`
  added to manifest if AC-1 ships. **No other Tier 1 promotion
  without explicit reason.**
- **Tier 2 (widget tests):** exactly one smoke (3 assertions).
  **No per-screen widget tests in this sprint.**
- **Tier 3 (Playwright):** not in this sprint. Deferred to the
  Regression Sprint.
- **Tier 4 (visual):** no Golden tests; manual QA only.

Other domains (Match, Coach, Knowledge, Training, Profile, Session)
**must not** be touched in this sprint except where a shared
provider requires a one-line update (with justification in commit
body). Drift into other domains = scope creep.

## 8. Effort budget

Constitution Article 4 sets 10–20% test/QA and 80–90% feature work.
Anticipated split for a 4-AC sprint:

| Phase | Effort | Notes |
|---|---|---|
| Spec & inventory | already done | this document |
| Repo test (Tier 1, AC-1) | ~50% of total | 10 cases, ~180 lines of test code (incl. Case 9 fix if needed) |
| Widget smoke (Tier 2, AC-2) | ~10% | 3-assertion smoke |
| Dead-code decision + cleanup (AC-3) | ~10% | Single PR |
| Manifest sync (AC-4, if AC-1 ships) | ~5% | 3-line edits |
| Verification (gates) | ~25% | Critical Suite + analyze + builds |

Feature + test work is the bulk; reports, scorecards, and
verification docs are not generated because the gate output is
the verification (Article 8).

## 9. Out-of-scope reminders

- Touching 11 other modified Dart screens (saved for Match / Coach
  sprints per P2 priority).
- Fixing the 2 pre-existing test failures that the Constitution
  baseline already fixed (`critical_suite` runs clean post-baseline).
- Refactoring `local_equipment_repository.dart` beyond what AC-1
  requires. Small surgical fixes only; flag bigger refactors for
  future sprint.
- Adding equipment-related features V1 didn't have (e.g. "share
  cue with teammate"). If a wish surfaces, file it in backlog — do
  not absorb into 2A.
- Creating `SPRINT_2A_VERIFICATION.md`. Per Article 8, gate output
  is the verification.

## 10. Sprint Exit Criteria

Sprint 2A **exits** (and we move to Sprint 2B — Match Parity) when
**every checkbox below is true**. Kept short by design (Article 8).

### Engineering gate (the only automated gate)

- [ ] `bash scripts/run_critical_suite.sh` PASS (10 or 11 files
       depending on AC-1 outcome).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.

### Functional smoke (manual)

- [ ] Equipment list opens and renders non-archived items.
- [ ] Search input filters the list.
- [ ] "Add equipment" → edit screen opens with empty fields.

(No further functional checks — Article 8. Full functional pass is
manual QA on a real device, not a sprint-blocker.)

### Hygiene

- [ ] PR opened with reference to this kickoff doc.
- [ ] Branch `feature/parity/equipment` ready to merge, no
       force-push, linear history since branch base.
- [ ] No `SPRINT_2A_VERIFICATION.md` or similar artifact created
       (gate output is enough — Article 8).

### Decision: "Ready for Sprint 2B"

When ALL of the above are checked, sprint is closed. The Product
Owner signs the PR. The next sprint (Match Parity) opens with a
new `feature/parity/match` branch cut from the merge of 2A.

## 11. References

- `docs/engineering-constitution.md` — Articles 5, 6, 7, 8.
- `docs/REPOSITORY_HEALTH_CHECKLIST.md` — pre-RC/Beta gate.
- `docs/SPRINT_2_HANDOFF.md` — originating scope discussion.
- `docs/screenshots/equipment-*.png` — V1 reference visuals.
- `lib/data/models/equipment.dart` — field inventory.
- `lib/data/impl/local_equipment_repository.dart` — current impl.

## 12. Commit conventions

When work begins:

1. Branch is `feature/parity/equipment`.
2. First commit: `chore(sprint2a): equipment repo critical-suite coverage`.
3. Subsequent commits scoped to one AC each.
4. Tag final commit: `chore(sprint2a): close — sprint 2A verification`.
5. Open PR referencing this doc. Request review.

## 13. Decision log

- **2026-08-05** — Sprint 2A scope locked (full V1 parity, image
  deferred, stats + recommendation included).
- **2026-08-05** — `feature/parity/equipment` branch created at
  `b582eaf`.
- **2026-08-05** — Constitution baseline accepted as gate authority
  for this sprint.
- **2026-08-05** — Kickoff refactored from 6-AC to 4-AC per
  Constitution Article 8 (Evidence over Artifacts). Playwright
  AC-3 and Image-placeholder AC-5 removed; widget test reduced
  to 3-assertion smoke; verification report removed. Sprint still
  ships the same user-facing parity; only the process surface
  shrinks.