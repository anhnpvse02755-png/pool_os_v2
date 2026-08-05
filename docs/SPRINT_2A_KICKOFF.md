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
| Knowledge | Sprint 1 | ✅ Shipped (102 articles migrated) |
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
  manifest.
- **Images:** Defer upload — show placeholder only with TODO.
- **Stats + recommendation:** Keep in scope (model already supports
  both, screens already reference them).

## 3. Module inventory (V2 today)

### Models & repo

| File | Lines | Status |
|---|---|---|
| `lib/data/models/equipment.dart` | 415 | ✅ Complete (17+ fields, EquipmentStats, MaintenanceEntry) |
| `lib/data/repositories/equipment_repository.dart` | 49 | ✅ Contract complete |
| `lib/data/impl/local_equipment_repository.dart` | 418 | ✅ Implementation complete (CRUD + archive + active + stats + recommendation) |
| `lib/data/repositories/equipment_change_log_repository.dart` | 36 | ⚠ Contract only — `EquipmentChangeLog` model not used by any screen. **Status TBD** during sprint. |
| `lib/core/constants/equipment_constants.dart` | 214 | ✅ Brand/model catalog |

### UI

| File | Lines | Status |
|---|---|---|
| `lib/presentation/screens/profile/equipment_screen.dart` | 954 | ✅ List + search + filter + sort + compare-selection + recommended section |
| `lib/presentation/screens/profile/equipment_detail_screen.dart` | 563 | ✅ Full V1 field display |
| `lib/presentation/screens/profile/equipment_edit_screen.dart` | 692 | ✅ Add / edit form (all 17+ fields) |
| `lib/presentation/screens/profile/equipment_statistics_screen.dart` | 258 | ✅ Stats per cue |
| `lib/presentation/screens/profile/equipment_comparison_screen.dart` | 97 | ✅ Side-by-side compare |

### Providers

| File | Notes |
|---|---|
| `lib/core/providers/repository_providers.dart` | Exposes `equipmentRepositoryProvider` + 5 domain providers + `equipmentStatsProvider` |

### Tests

| File | Status |
|---|---|
| `test/**/*equipment*` | ❌ **None exist** — greenfield for Sprint 2A |

### E2E

| File | Status |
|---|---|
| `tests/07-equipment.spec.ts` | ⚠ Stub only — needs content |
| `tests/08-equipment-screenshots.spec.ts` | ⚠ Stub only — needs content |

## 4. Gap analysis — V1 ↔ V2

### Already present in V2 ✅

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

### Known gaps to close during sprint 🔧

| Gap | Severity | Action |
|---|---|---|
| **No unit tests for `EquipmentRepository`** | P0 | Add `test/equipment_repository_test.dart`. Add to Critical Suite. |
| **No widget test for equipment flow** | P1 | Add `test/widget/equipment_list_flow_test.dart` (search → tap → detail). |
| **No Playwright flow stub** | P2 | Fill `tests/07-equipment.spec.ts` with a smoke flow. |
| **`EquipmentChangeLogRepository` unused** | P2 | Decide: delete or wire. Likely delete unless audit need surfaces. |
| **Image upload deferred** | P2 | UI placeholder in edit screen with TODO; do not implement. |

### Out of scope this sprint 🚫

- Image upload (deferred to 2A+).
- Cloud sync of equipment (V1 was local-only too).
- Cross-player equipment sharing.

## 5. Acceptance Criteria

### AC-1: Add Critical-Suite coverage

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
`test/CRITICAL_SUITE.md` and both runner scripts.

**Note on Case 10 scope:** the Equipment model is intentionally flat
(no foreign keys between cues/shafts/tips — they are siblings under
the same `Equipment` entity). "Invalid reference" here therefore
means *operations on IDs that don't exist in storage*, not cross-
entity FK validation. If a future sprint adds relational refs (e.g.
`shaftId` on `Cue`), this case must be extended.

### AC-2: Widget test for main equipment flow

`test/widget/equipment_list_flow_test.dart` covers the canonical
"open list → search → tap → detail → back" path. Asserts:
- List renders without crash.
- Search input filters visible items.
- Tap on first non-archived item navigates to detail.
- Back returns to list.

### AC-3: Playwright flow fill

`tests/07-equipment.spec.ts` runs:

```
Open app
  → Profile tab
  → Equipment
  → Add cue (form smoke)
  → Back
PASS
```

The flow must crash-free. No pixel assertions.

### AC-4: Dead-code decision

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

### AC-5: Image placeholder

Equipment edit screen shows a placeholder widget ("Image upload
coming soon") where V1 had a photo picker. Mark with TODO comment
linking to a future sprint.

### AC-6: Gate artifacts

- `scripts/run_critical_suite.sh` PASS with new test included.
- `flutter analyze` 0 errors on changed files.
- `flutter build web --release` PASS.
- `flutter build apk --debug` PASS.
- `test/CRITICAL_SUITE.md` updated with new entry and rationale.

## 6. Definition of Done

Sprint 2A is closed when **all** of the following are true:

- [ ] All 6 Acceptance Criteria verified.
- [ ] Critical Suite is 11 files (10 prior + 1 new), all green.
- [ ] `flutter analyze` 0 errors on the branch.
- [ ] Both web and APK builds pass.
- [ ] Commit history follows Constitution conventions.
- [ ] `docs/SPRINT_2A_VERIFICATION.md` records gate results.
- [ ] Branch ready for PR review.

## 7. Verification gate scope (locked per Constitution)

This sprint is an **Equipment-domain sprint**. Per
`docs/engineering-constitution.md` Article 5:

- **Tier 1 (Critical Suite):** `equipment_repository_test.dart`
  added to manifest. **No other Tier 1 promotion without explicit
  reason.**
- **Tier 2 (widget tests):** exactly one — the list-search-detail
  flow. **No per-screen widget tests.**
- **Tier 3 (Playwright):** smoke flow in
  `tests/07-equipment.spec.ts`. Runs **on every PR** per current
  CI config.
- **Tier 4 (visual):** no Golden tests; manual QA only.

Other domains (Match, Coach, Knowledge, Training, Profile, Session)
**must not** be touched in this sprint except where a shared
provider requires a one-line update (with justification in commit
body). Drift into other domains = scope creep.

## 8. Effort budget

Constitution Article 4 sets 10–20% test/QA and 80–90% feature work.
Anticipated split:

| Phase | Effort | Notes |
|---|---|---|
| Spec & inventory | already done | this document |
| Repo test (Tier 1) | ~30% of total | 10 cases, ~180 lines of test code (incl. Case 9 fix if needed) |
| Widget test (Tier 2) | ~15% | One end-to-end flow |
| Playwright (Tier 3) | ~10% | One smoke flow |
| Image placeholder UI | ~10% | Cosmetic |
| Dead-code decision + cleanup | ~10% | Single PR |
| Verification + docs | ~15% | Gates, scoring, PR |

Feature code (`equipment_repository_test.dart` + `equipment_list_flow_test.dart`
+ Playwright spec + UI placeholder) is the 80%; the rest is
verification + docs.

## 9. Out-of-scope reminders

- ❌ Touching 11 other modified Dart screens (saved for Match / Coach
  sprints per P2 priority).
- ❌ Fixing the 2 pre-existing test failures (`critical_suite` ran
  clean post-Constitution baseline — those regressions are gone).
- ❌ Refactoring `local_equipment_repository.dart` beyond what tests
  require. Small surgical fixes only; flag bigger refactors for
  future sprint.
- ❌ Adding equipment-related features V1 didn't have (e.g. "share
  cue with teammate"). If a wish surfaces, file it in backlog — do
  not absorb into 2A.

## 10. Sprint Exit Criteria

Sprint 2A **exits** (and we move to Sprint 2B — Match Parity) when
**every checkbox below is true**. Reviewer walks this list top-to-
bottom at PR review.

### Functional checklist (player-visible)

- [ ] Equipment list opens and renders all non-archived items.
- [ ] Search filters the list (case-insensitive, by name + brand).
- [ ] Category filter (`all` / `cue` / `shaft` / `tip` / `case` /
  `chalk` / `glove` / `extension` / `accessory`) works.
- [ ] Sort options (`updated` / `name` / `value` / `usage`) work.
- [ ] Tap an item → detail screen renders all 17+ fields.
- [ ] "Add equipment" opens edit screen with all fields empty.
- [ ] "Edit equipment" prefills with current values, save persists.
- [ ] "Set as active cue" toggle updates the active cue indicator.
- [ ] Maintenance log: append + remove + history render correctly.
- [ ] Stats screen renders per-cue match count, win rate, accuracy,
  break speed, usage hours.
- [ ] Compare (N) flow: select 2+ items → comparison screen renders.
- [ ] Recommended section shows top-3 by usage.
- [ ] Image area shows placeholder with TODO (no crash if image
      upload deferred).

### Engineering gate (automated)

- [ ] `bash scripts/run_critical_suite.sh` PASS with **11 files**
       (10 prior + 1 new `equipment_repository_test.dart`).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] `flutter build web --release` PASS.
- [ ] `flutter build apk --debug` PASS.
- [ ] `flutter test test/widget/equipment_list_flow_test.dart` PASS
       (Tier 2 widget flow).
- [ ] `npx playwright test tests/07-equipment.spec.ts` PASS (Tier 3
       smoke flow).

### Regression gate (no other domain broken)

- [ ] Constitution baseline still PASS (no changes outside Equipment
       except Case 9 fix if needed).
- [ ] Other Critical Suite tests still green (8 unchanged tests).
- [ ] Knowledge runtime still loads 112 articles
       (`test/knowledge_runtime_loading_test.dart`).
- [ ] No new `flutter analyze` warnings introduced beyond prior
       baseline (57 warnings / 47 info).

### Documentation & hygiene

- [ ] `test/CRITICAL_SUITE.md` updated with new entry + rationale.
- [ ] `docs/SPRINT_2A_VERIFICATION.md` records final gate results.
- [ ] If `EquipmentChangeLogRepository` deleted: deletion commit has
       one-line rationale in commit body.
- [ ] Branch `feature/parity/equipment` ready to merge, no force-push,
       linear history since branch base.
- [ ] PR opened with reference to this kickoff doc.

### Decision: "Ready for Sprint 2B"

When ALL of the above are checked, sprint is closed. The Product
Owner signs the PR. The next sprint (Match Parity) opens with a new
`feature/parity/match` branch cut from the merge of 2A.

## 11. References

- `docs/engineering-constitution.md` — Articles 1-7.
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
