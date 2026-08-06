# Sprint 2E — Cross-Domain Consolidation Kickoff

> **Branch:** `feature/parity/consolidation-ac1` (AC-1) — others cut from main as needed
> **Base:** `origin/main` at `8f462f7` (post-Sprint 2D merge)
> **Owner:** TBD
> **Started:** 2026-08-06
> **Status:** SPEC — awaiting approval before coding
> **Constitution:** `docs/engineering-constitution.md` (8 Articles)
> **Predecessor:** Sprint 2D — Training Parity (PR #14, merged `8f462f7`)

---

## 1. Why this sprint

Sprint 2A→2D đã hoàn thành Feature Parity cho 4 domain:
Equipment (2A), Match (2B), Coach (2C), Training (2D). Critical Suite
hiện ổn định. Cả 4 sprint đều theo đúng template 4 ACs, mỗi AC = 1 PR
nhỏ, scope discipline chặt.

| Module | Sprint | State |
|---|---|---|
| Knowledge | Sprint 1 | Shipped |
| Equipment | 2A | Shipped (PR #3) |
| Match | 2B | Shipped (PR #4) |
| Coach | 2C | Shipped (PR #9) |
| Training | 2D | Shipped (PR #14) |
| **Cross-Domain Consolidation** | **2E** | **<-- This sprint** |

Sprint 2E là sprint **ổn định nền tảng**, không phải thêm feature.
Mục tiêu:
- Verify Critical Suite hiện tại còn aligned với code state.
- Re-audit các deletion candidates đã bị BLOCKED ở 2A→2D.
- Không tăng Critical Suite (không thêm Tier 1 mới — tránh "mỗi
  sprint phải tăng"). Quyết định chốt từ Sprint 2E planning.

## 2. Scope decision (locked)

- **AC-1:** Re-audit 13 Tier 1 tests hiện có (verify rationale,
  redundancy, business-critical assumption, code health).
  **Không thêm Tier 1 mới. Không remove Tier 1.**
- **AC-2:** Widget smoke cho `CreateSessionScreen` (3 assertions).
- **AC-3:** Cross-domain dead-code audit — re-audit 4 BLOCKED
  candidates từ 2A→2D. Audit-only, **không xóa** theo quyết
  định của user. Ghi findings vào decision log.
- **AC-4:** Manifest sync — nếu AC-1 phát hiện rationale thay
  đổi thì sync; nếu không, refresh metadata only.
- **Out of scope:** Promote `ai_coach_repository.dart` hoặc bất
  kỳ repo nào lên Tier 1. Scan 15 dead-code screens
  (Knowledge sub-features, Reports, Equipment sub-screens,
  PlayerStateScreen, SessionListScreen, DrillResultScreen,
  MatchReplayScreen). `pubspec.lock` modifications. Stash
  cleanup.

## 3. Engineering gate baseline

- **Critical Suite:** 14 files, 108 test cases (run on
  `8f462f7` confirms PASS — see AC-1 audit §13.1 below).
- **flutter analyze:** 9 pre-existing issues, none related to
  AC-1 scope. No new issues introduced.
- **flutter build web --release:** PASS (per Sprint 2D baseline).

## 4. AC-1 — Tier 1 Re-Audit

### 4.1 Audit method

For each of 14 Tier 1 tests (corrected count — see §13.1):
1. Read top-of-file comment + manifest rationale line.
2. Verify underlying repo/model file exists on disk.
3. Run Critical Suite baseline (`powershell scripts/run_critical_suite.ps1`).
4. Check for redundancy with other Tier 1 tests.
5. Note any code smell or stale rationale.

### 4.2 Findings

#### Finding A (HIGH) — Manifest/runner file count drift

`test/CRITICAL_SUITE.md` line 103 reads:
```
- **Total files in Critical Suite:** 13
```

Actual count:
- `test/CRITICAL_SUITE.md` table sections: 14 (knowledge
  migration × 4 + knowledge runtime × 2 + personal bests +
  streak + weekly + coach + session recovery + equipment +
  match + drill attempt = 14)
- `scripts/run_critical_suite.sh` array entries: 14
- `scripts/run_critical_suite.ps1` array entries: 14
- `scripts/run_critical_suite.sh` final echo: "Running 14
  critical test files..."

**Root cause:** Sprint 2D AC-4 added `Drill attempt (1 file)`
section to manifest, both runners, but missed updating the
"Total files" summary line.

**Decision:** **AC-4 of Sprint 2E will fix this.** Update
manifest summary line to 14. Runners already correct. No
business rule affected — purely a docs/metadata sync.

#### Finding B (LOW) — Minimal coverage on Tests 7 and 9

Two Tier 1 tests have only 1 test case each:
- `test/personal_best_repository_test.dart`: 1 case
  ("personal best only updated when better")
- `test/weekly_report_generator_test.dart`: 1 case
  ("empty week generates zero matches report")

Rationale còn đúng:
- Test 7 protects atomic transactions on personal best — the
  single case catches the "old best kept when new value is
  worse" invariant.
- Test 9 protects weekly aggregation correctness on the empty
  path — this is the easiest invariant to break with a
  refactor.

**Decision:** **No action in Sprint 2E.** Adding more cases sẽ
vượt scope Article 8 (process work competing with feature
work). Rationale is locked, code health is acceptable.

#### Finding C (LOW) — pre-existing pubspec warning

When running `flutter test`, a warning appears at suite start:

```
Error: unable to find directory entry in pubspec.yaml:
C:\Users\anhnpv\OneDrive - Thanh Cong Group\Desktop\poolos_v2\assets\data\
```

This is a pre-existing warning about `assets/data/` directory
missing from pubspec.yaml asset declarations. **Not introduced
by AC-1. Not in scope.** Note for future sprint.

### 4.3 Per-test audit

| # | Test | Underlying code | Cases | Rationale alignment | Verdict |
|---|---|---|---|---|---|
| 1 | `knowledge_migration/pipeline_test.dart` | `tools/knowledge_migration/src/migration_pipeline.dart` | 2 | ✅ end-to-end migration runs, determinism | KEPT |
| 2 | `knowledge_migration/validators_test.dart` | `tools/knowledge_migration/validators.dart` | 33 | ✅ 12 validators + ReportGenerator | KEPT |
| 3 | `knowledge_migration/mappers_test.dart` | `tools/knowledge_migration/{id,category,tag,schema}_mapper.dart` | 18 | ✅ V1→V2 schema mappers | KEPT |
| 4 | `knowledge_migration/cli_options_test.dart` | `tools/knowledge_migration/src/cli_options.dart` | 9 | ✅ CLI flag parsing | KEPT |
| 5 | `knowledge_runtime_loading_test.dart` | `assets/knowledge/knowledge.json` + `lib/knowledge/knowledge_provider.dart` | 5 | ✅ 112-article runtime load | KEPT |
| 6 | `knowledge_article_count_test.dart` | `assets/knowledge/knowledge.json` | 2 | ✅ ≥110-article invariant + required fields | KEPT |
| 7 | `personal_best_repository_test.dart` | `lib/data/repositories/personal_best_repository.dart` | 1 | ✅ Atomic update-on-better | KEPT (minimal) |
| 8 | `streak_calculator_test.dart` | `lib/domain/services/streak_calculator.dart` + match repo | 2 | ✅ streak math | KEPT |
| 9 | `weekly_report_generator_test.dart` | `lib/domain/services/weekly_report_generator.dart` | 1 | ✅ empty-week zero-state | KEPT (minimal) |
| 10 | `coach_profile_aggregator_test.dart` | `lib/domain/services/coach_profile_aggregator.dart` | 6 | ✅ 6 cases from Sprint 2C | KEPT |
| 11 | `drill_session_recovery_test.dart` | `lib/domain/services/drill_session_recovery_service.dart` + `lib/data/repositories/drill_session_repository.dart` | 3 | ✅ pause/resume/complete | KEPT |
| 12 | `equipment_repository_test.dart` | `lib/data/impl/local_equipment_repository.dart` | 10 | ✅ 10 cases from Sprint 2A | KEPT |
| 13 | `match_repository_test.dart` | `lib/data/repositories/match_repository.dart` | 8 | ✅ 8 cases from Sprint 2B | KEPT |
| 14 | `drill_attempt_repository_test.dart` | `lib/data/models/drill_attempt.dart` + `test/helpers/fake_drill_session_repository.dart` | 6 | ✅ 6 cases from Sprint 2D | KEPT |

**No redundancy found.** Tests 5 and 6 cover different layers
(runtime loading path vs. asset bundle integrity) — complementary,
not redundant.

**No stale rationale found.** All 14 rationales remain aligned
with the business rules they protect.

**No deprecated underlying code found.** Every repo/model
referenced by a test exists on disk.

**Test code health:** All tests pass on baseline. No assertions
have stale comments or broken expectations.

### 4.4 Sprint 2E AC-1 deliverable

This document IS the AC-1 deliverable. No code changes
required in AC-1 PR. AC-4 of Sprint 2E will sync Finding A
(manifest count drift).

## 5. AC-2 — CreateSessionScreen Widget Smoke

**Branch:** `feature/parity/consolidation-ac2`
**Deliverable:** `test/widget/create_session_screen_test.dart` (new file, 65 insertions)
**Status:** PR #16 merged at `f6bca69`.

### 3 assertions (Article 8)
1. **Mount** — `expect(find.byType(CreateSessionScreen), findsOneWidget)` — screen is reachable.
2. **Key UI renders** — `expect(find.widgetWithText(ElevatedButton, 'Bắt đầu buổi chơi'), findsOneWidget)` — start-session CTA present.
3. **Type-card tap safe** — tap on 'Luyện tập' type card; `expect(tester.takeException(), isNull)`.

### Pattern reuse
- `MaterialApp(home: CreateSessionScreen())` — no Riverpod, no GoRouter needed (screen holds state locally).
- `pump() + pump(100ms) × 2` — avoids `pumpAndSettle()` (flutter_animate indefinite tweens).
- Tap on type card, NOT on start button (which calls `context.go('/sessions')` and would fail without a router).

Same pattern as `drill_session_screen_test.dart` (Sprint 2D AC-2).

### Engineering gates
- `flutter analyze` on new file: 0 issues
- Widget test: 1/1 PASS
- Critical Suite: 14/14 files, 108/108 test cases PASS (no regression)

## 6. AC-3 — Cross-Domain Dead-Code Audit (4 BLOCKED re-audit)

**Branch:** `feature/parity/consolidation-ac3`
**Status:** Audit complete. PR #17 opened (docs only).

### 6.1 Audit method
For each candidate file:
1. `Grep` for class name + file name in `lib/`. Count matches outside the file itself.
2. `Grep` for string-based route references (camelCase route name) in `lib/core/router/app_router.dart`.
3. `Grep` for class name references in `test/`.
4. If 0 external references, file qualifies for deletion (report, không delete).

Per locked deletion policy (Sprint 2C): chỉ xóa khi importer absent. Per user decision for Sprint 2E AC-3 (audit-only): **không xóa**, chỉ report.

### 6.2 Findings

#### Candidate 1 — `lib/presentation/widgets/progress_card.dart`

**History:** BLOCKED 2C AC-3 (record: 1 importer via `home_screen.dart`); BLOCKED 2D AC-3 (revisited because Training domain now in scope; finding reaffirmed).

**Current state on `f6bca69`:**
- `lib/` grep for `progress_card|ProgressCard`: matches in
  - `lib/presentation/widgets/progress_card.dart:12-13,17,20` (self: class declaration + State class)
  - `lib/presentation/screens/training/training_center_screen.dart:96,447,450` (private inner class `_ProgressCard` defined in this file at line 447)
  - `lib/presentation/screens/training/progress_screen.dart:75,255,258` (private inner class `_ProgressCard` defined in this file at line 255)

**Important distinction:** The 2 matches in `training_center_screen.dart` and `progress_screen.dart` are **NOT** imports of the public `ProgressCard` widget — they are **private inner classes** named `_ProgressCard` defined inside those files themselves. These are unrelated to `progress_card.dart`.

**Public widget importer count: 0.**

**`test/` grep:** no matches.

**Verdict:** **STALE.** Public `ProgressCard` widget có 0 importers. The 2C/2D audit conclusions ("1 importer via home_screen.dart" / "active route bindings") appear stale — current grep shows the home_screen reference no longer exists. The 2 inner `_ProgressCard` classes are local definitions, not external imports.

**Decision:** **Audit-only, không xóa** (per user). Re-evaluate trong Sprint 2F nếu Product/Platform cho phép cleanup. Đây là finding quan trọng để track — 3 sprint liên tiếp đã block progress_card, và vẫn không có importer. Recommend cho sprint cleanup tương lai.

#### Candidate 2 — `lib/presentation/screens/training/recommended_screen.dart`

**History:** BLOCKED 2D AC-3.

**Current state on `f6bca69`:**
- `lib/` grep for `recommended_screen|RecommendedScreen`:
  - `lib/core/router/app_router.dart:22` (import statement)
  - `lib/core/router/app_router.dart:108` (route builder: `builder: (context, state) => const RecommendedScreen(),`)
  - `lib/presentation/screens/training/recommended_screen.dart:7-14` (self)

**Imported by router.** Active route binding `/training/recommended`.

**`test/` grep:** no matches.

**Verdict:** **KEPT.** Active route binding present.

#### Candidate 3 — `lib/presentation/screens/training/progress_screen.dart`

**History:** BLOCKED 2D AC-3.

**Current state on `f6bca69`:**
- `lib/` grep for `progress_screen|ProgressScreen`:
  - `lib/core/router/app_router.dart:23` (import statement)
  - `lib/core/router/app_router.dart:196` (route builder)
  - `lib/presentation/screens/training/progress_screen.dart:9-10` (self)

**Imported by router.** Active route binding `/training/progress`.

**`test/` grep:** no matches.

**Verdict:** **KEPT.** Active route binding present. (Note: this screen also contains a private inner `_ProgressCard` class — separate from Candidate 1, not an external reference.)

#### Candidate 4 — `lib/presentation/screens/coach/training_plan_screen.dart`

**History:** BLOCKED 2D AC-3 (Coach-side ownership retained per Dependency Boundary from Sprint 2C).

**Current state on `f6bca69`:**
- `lib/` grep for `training_plan_screen|TrainingPlanScreen`:
  - `lib/core/router/app_router.dart:34` (import statement)
  - `lib/core/router/app_router.dart:206` (route builder)
  - `lib/presentation/screens/coach/training_plan_screen.dart:11-12` (self)

**Imported by router.** Active route binding `/coach/plan`.

**`test/` grep:** no matches.

**Verdict:** **KEPT.** Active route binding present. Coach-side ownership acknowledged.

### 6.3 Summary table

| # | File | Sprint first flagged | lib refs (excl. self) | Router binding | Test refs | Verdict |
|---|---|---|---|---|---|---|
| 1 | `progress_card.dart` | 2C | 0 (public widget) | none | 0 | **STALE** (audit-only) |
| 2 | `recommended_screen.dart` | 2D | 1 (router) | `/training/recommended` | 0 | **KEPT** |
| 3 | `progress_screen.dart` | 2D | 1 (router) | `/training/progress` | 0 | **KEPT** |
| 4 | `training_plan_screen.dart` | 2D | 1 (router) | `/coach/plan` | 0 | **KEPT** |

### 6.4 Notable finding

**Candidate 1 `progress_card.dart`** is the only BLOCKED candidate whose status has materially changed since prior audits. The 2C and 2D conclusions referenced "1 importer" but the current grep on `f6bca69` shows **0 importers of the public widget**. The grep matches in `training_center_screen.dart` and `progress_screen.dart` are **private inner classes** (`_ProgressCard`), not external references. This is a stale finding worth tracking for a future cleanup sprint.

No deletion performed. Per user decision: AC-3 is audit-only, deletion is out of scope for parity sprint.

## 7. AC-4 — Manifest Sync

**Branch:** `feature/parity/consolidation-ac4`
**Status:** PR #18 opened.

### 7.1 Changes (metadata only)

Per user direction (received before AC-3 review): "AC-4 chỉ sửa manifest/runner, **không** nhân cơ hội thay đổi rationale hay cơ cấu Critical Suite."

Applied edits to `test/CRITICAL_SUITE.md`:
1. **Finding A fixed:** `Total files in Critical Suite: 13` → `14` (line 103).
2. **Last reviewed** updated: `Sprint 2D training parity` → `Sprint 2E cross-domain consolidation` (line 104).
3. **Sprint 2E row added** to Inventory at a glance (line 110): `Sprint 2E: 14/14 PASS (AC-1 re-audit; count drift 13 → 14 fixed)`.
4. **Tier 2 inventory** updated to enumerate current widget smokes (6 in `test/widget/` + `test/presentation/**`).

No changes to:
- Test file roster (14 entries remain identical).
- Rationale strings.
- Runner scripts (both already correct from Sprint 2D AC-4).

### 7.2 Engineering gate

- Critical Suite: 14/14 files, 108/108 test cases PASS (no test count change).
- Manifest/runner parity: all three list 14 entries consistently.

## 8. Out of scope (deferred)

- Promote `ai_coach_repository.dart` to Tier 1 — Sprint 2F+
  khi có framing rõ ràng cho production usage.
- Scan 15 dead-code screens (Knowledge sub-features, Reports,
  Equipment sub-screens, PlayerStateScreen, SessionListScreen,
  DrillResultScreen, MatchReplayScreen) — Sprint 2F+ khi đã
  có framing riêng cho deletion.
- `pubspec.lock` modifications — sprint sau tự xử lý nếu
  reproduce.
- Stash `Sprint 2D AC-3 cleanup` — chờ công việc liên quan
  thực sự bắt đầu.

## 9. Sprint Exit Criteria

Sprint 2E **exits** when:

- [ ] All 4 PRs opened, reviewed, merged.
- [ ] `bash scripts/run_critical_suite.sh` PASS (14 files, 108
      test cases).
- [ ] `flutter analyze` 0 errors on changed files.
- [ ] No `SPRINT_2E_VERIFICATION.md` (Article 8).

## 10. References

- `docs/engineering-constitution.md` — Articles 1, 5, 6, 8.
- `docs/SPRINT_2D_KICKOFF.md` — preceding sprint spec.
- `docs/SPRINT_2C_KICKOFF.md` — earlier spec.
- `test/CRITICAL_SUITE.md` — manifest under audit.
- `scripts/run_critical_suite.sh` + `.ps1` — runners.

## 11. Commit conventions

1. First commit: `docs(sprint2e): AC-1 Tier 1 re-audit complete`.
2. Subsequent commits scoped to one AC each.
3. No final tag commit (Article 8 — sprint close happens via PR
   merge, not a marker tag).

## 12. Decision log

- **2026-08-06** — Sprint 2E scope locked: re-audit + dead-code
  re-audit only, no new Tier 1 promotion.
- **2026-08-06** — AC-1 audit complete on `feature/parity/consolidation-ac1`
  at `8f462f7`. Baseline: 14 files / 108 test cases PASS.
  Findings: A (manifest count drift), B (low coverage Tests 7/9 —
  accepted), C (pre-existing pubspec warning — out of scope).
  No code changes needed in AC-1 PR.
- **2026-08-06** — AC-1 verdict: 14/14 Tier 1 tests pass,
  rationale aligned, no redundancy, no deprecated code. Sprint
  2E AC-4 will sync manifest count from 13 → 14.
- **2026-08-06** — AC-2 widget smoke for CreateSessionScreen
  merged at `f6bca69`. 1/1 test PASS, 3 assertions (mount, CTA
  renders, type-card tap safe). Critical Suite 14/14 PASS, no
  regression.
- **2026-08-06** — AC-3 audit complete on `feature/parity/consolidation-ac3`
  at `f6bca69`. 4 BLOCKED candidates re-audited:
  - `progress_card.dart` — **STALE** (public widget has 0
    importers; 2D/2C "1 importer" finding was conflating with
    private inner classes). Audit-only, no deletion.
  - `recommended_screen.dart` — **KEPT** (router binding
    `/training/recommended`).
  - `progress_screen.dart` — **KEPT** (router binding
    `/training/progress`).
  - `training_plan_screen.dart` — **KEPT** (router binding
    `/coach/plan`, Coach-side ownership).
- **2026-08-06** — AC-3 verdict: 3 of 4 BLOCKED candidates remain
  KEPT (their references are real). 1 (`progress_card.dart`) is
  STALE — recommend a Cleanup Sprint in Phase 3+ for review and
  deletion. Do not embed in parity sprint.
- **2026-08-06** — AC-4 manifest sync complete on `feature/parity/consolidation-ac4`
  at `18dafdc`. Finding A (count drift) fixed: manifest updated
  13 → 14. Last reviewed refreshed. Sprint 2E row added. Tier 2
  widget smoke inventory updated. **Metadata-only changes**, no
  rationale or structural changes per user direction.