# Sprint 1 — Scorecard

> **Sprint:** 1 — Knowledge Parity
> **Method:** per-commit scorecard with scope, gates, rollback, and risks

## Commit C1 — Migration Tool Skeleton

| Field | Value |
|---|---|
| Hash | `6ef3c74` |
| Subject | feat(parity/knowledge): Commit 1 - Migration Tool Skeleton |
| Scope | `tools/knowledge_migration/` |
| Goals | Establish permanent, deterministic migration tool. Skeleton only. |
| Gates | Tool parses CLI options, produces pipeline skeleton. |
| Tests | n/a (skeleton) |
| Risk | Low — tool is isolated, no app code touched. |
| Rollback | `git revert 6ef3c74` — removes tool, no app impact. |

## Commit C2 — Schema Mapper

| Field | Value |
|---|---|
| Hash | `2be55de` |
| Subject | feat(parity/knowledge): Commit 2 - Schema Mapper (real V1->V2 mapping) |
| Scope | `tools/knowledge_migration/schema_mapper.dart` |
| Goals | Real V1→V2 mapping for all 10 fields. |
| Gates | All 92 source articles map without errors. |
| Tests | 17 migration tests added. |
| Risk | Medium — schema correctness depends on V1 sample. |
| Rollback | `git revert 2be55de` — reverts mapper. |
| Status | PASS |

## Commit C3 — Validators + Reports

| Field | Value |
|---|---|
| Hash | `230d832` |
| Subject | feat(parity/knowledge): Commit 3 - 12 Validators + Reports (quality gate) |
| Scope | `tools/knowledge_migration/validators.dart`, `report_generator.dart` |
| Goals | 12-rule validator suite + Markdown / JSON report emission. |
| Gates | All 92 articles pass 12 validators. |
| Tests | 17 migration tests. |
| Risk | Low — validators are pure. |
| Rollback | `git revert 230d832` — reverts validators. |
| Status | PASS |

## Commit C4 — Import 102 verified articles

| Field | Value |
|---|---|
| Hash | `edd8e0a` |
| Subject | feat(parity/knowledge): Commit 4 - Import 102 verified articles |
| Scope | `tools/knowledge_migration/` orchestration + `assets/knowledge/knowledge.json` |
| Goals | 102 V1 articles imported into V2 staging. |
| Gates | All 12 validators pass. 0 failures. |
| Tests | 64 migration tests pass. |
| Risk | High — production data is being added. SHA-stable. |
| Rollback | `git revert edd8e0a` — removes 102 articles. App falls back to 10 live. |
| Status | PASS |

## Commit C5 — UI Integration & Knowledge Promotion

| Field | Value |
|---|---|
| Hash | `2858d81` |
| Subject | feat(parity/knowledge): Commit 5 - UI Integration & Knowledge Promotion |
| Scope | runtime + UI + tests |
| Goals | Knowledge feature parity, runtime asset loading, search+filter, learning path integration. |
| Gates | `flutter analyze` 0 errors. 88/88 Sprint 1 tests pass. |
| Tests | 17 widget tests + 5 runtime tests + 64 migration tests. |
| Risk | Medium — UI changes touch multiple screens. |
| Rollback | `git revert 2858d81` — reverts UI integration. App stays on 10-article fallback. |
| Status | PASS |
| PR | #1 (merged) |

## Commit R1 — Repository Build Recovery

| Field | Value |
|---|---|
| Hash | `74ae5ef` |
| Subject | chore(repository): restore missing production sources required for clean build |
| Scope | 51 files (1 modified + 50 untracked) |
| Goals | Restore `main` as a buildable Source of Truth. |
| Gates | Clean clone → `flutter pub get` PASS, `flutter analyze` 0 errors, 88/88 tests pass, `flutter build web` PASS, `flutter build apk --debug` PASS. |
| Risk | Low — empirically proven minimum set. |
| Rollback | `git revert 74ae5ef` — restores the broken state. |
| Status | PASS |
| PR | #2 (merged) |

## Commit R2 — Documentation Recovery

| Field | Value |
|---|---|
| Hash | `267648e` |
| Subject | docs(sprint1): recovery — project documentation surface |
| Scope | 42 files (39 docs + 3 recovery artifacts) |
| Goals | Restore canonical project documentation. |
| Gates | No code change. Repository Completeness Gate still green. |
| Risk | None — docs only. |
| Rollback | `git revert 267648e` — removes docs. |
| Status | PASS |

## Commit R3 — Minimal `.gitignore` Cleanup

| Field | Value |
|---|---|
| Hash | `22ed422` |
| Subject | chore(repository): minimal .gitignore cleanup (R3) |
| Scope | 1 file (`.gitignore`) |
| Goals | Ignore verified local-only artifacts. |
| Gates | Repository Completeness Gate still green. |
| Risk | None — additive ignore rules. |
| Rollback | `git revert 22ed422` — restores previous `.gitignore`. |
| Status | PASS |

## Sprint 1 totals

| Metric | Value |
|---|---|
| Total commits | 10 (5 sprint + 3 recovery + 2 merge) |
| Files added | 157 (51 R1 + 42 R2 + 64 Sprint 1 Knowledge) |
| Tests added | 88 (5 runtime + 17 widget + 64 migration + 2 article count) |
| Knowledge articles | 112 (10 live + 102 migrated) |
| Build gate | PASS |
| Test gate | PASS |
| Analyze gate | 0 errors |
| Source of Truth gate | PASS |

## Risks carried forward

| Risk | Severity | Mitigation |
|---|---|---|
| 12 modified Dart screens deferred | Medium | Tracked for next parity sprint. |
| 10 dead-code files preserved but unused | Low | Pending dev cycle cleanup. |
| Pre-existing test failures (2) | Low | Tracked in Sprint 1 backlog. |
| Repository Completeness Gate not yet enforced in CI | Medium | `REPOSITORY_HEALTH_CHECKLIST.md` documents the gate for manual application. |
