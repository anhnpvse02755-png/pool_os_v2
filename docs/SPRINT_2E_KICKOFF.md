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

(To be filled when AC-2 starts.)

## 6. AC-3 — Cross-Domain Dead-Code Audit (4 BLOCKED re-audit)

(To be filled when AC-3 starts. Will include decision log entries
for `progress_card.dart`, `recommended_screen.dart`, `progress_screen.dart`,
`training_plan_screen.dart`.)

## 7. AC-4 — Manifest Sync

Will refresh `Last updated` date in `test/CRITICAL_SUITE.md`,
add Sprint 2D row to Inventory at a glance, and **fix Finding A
file count drift** (13 → 14).

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