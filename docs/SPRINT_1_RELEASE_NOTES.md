# Sprint 1 — Release Notes

> **Sprint:** 1 — Knowledge Parity
> **Release:** v2.0-knowledge
> **Tag:** `v2.0-knowledge` (recommended)
> **Date:** 2026-08-04

## Headline

The Pool OS V2 app now ships a complete, validated Knowledge surface
backed by 112 articles (10 live + 102 migrated from V1).

## What users see

- A **Knowledge** screen with 112 articles, browsable by category.
- A **search** bar with 300ms debounce — type to filter live.
- A **difficulty filter** (Cơ bản / Trung bình / Nâng cao / Chuyên gia).
- **Article detail** with related drills and "Đọc trước khi tập" callouts.
- **Learning Path** entries now surface prerequisite knowledge as
  tappable chips that navigate to the article detail.

## What changed under the hood

- `assets/knowledge/knowledge.json` now ships 112 articles.
- `KnowledgeNotifier._loadData` reads the bundled asset via `rootBundle`
  with a 10-article const fallback on parse failure.
- `drill_code_bridge` translates V1 `_LV`-suffixed drill codes to V2
  `DrillLibrary` codes at navigation time, so article payloads stay
  V1-clean.
- `coach_provider` and `coach_service` accept `LearningPathItem.knowledgeIds`.
- A new `learningKnowledgeProvider` resolves related knowledge with a
  3-tier strategy: 1) explicit `knowledgeIds`, 2) `drillCode` map,
  3) difficulty fallback.

## Architecture

The Knowledge feature respects the boundary established by the
Stabilization Sprint:

- UI talks to a `Provider` (Riverpod) — never to JSON directly.
- All knowledge resolving goes through `knowledge_provider` or its
  derivatives (`knowledgeSearchProvider`, `learningKnowledgeProvider`).
- V1 drill codes are translated at navigation time via
  `lib/knowledge/drill_code_bridge.dart`.

## Data integrity

- 112 articles, 0 duplicate IDs, 0 duplicate slugs.
- Sorted by id, UTF-8 valid, JSON well-formed.
- SHA-256: `c1c1906b17fa315ae6726d900585b865a21c970728125ab3c7e7df318dd8545e`.
- All 12 validators passed at import time (see `docs/PROMOTION_REPORT.md`).

## Verification

| Gate | Result |
|---|---|
| `flutter analyze` | 0 errors |
| `flutter test` (Sprint 1) | 88/88 PASS |
| `flutter build web --release` | PASS |
| `flutter build apk --debug` | PASS |
| Knowledge runtime loading | PASS |
| Deterministic migration | PASS |
| SHA-256 stability | PASS |

## Known limitations

- 12 modified Dart screens (Home/Play/Profile/Session/Training
  non-Knowledge) and 6 Playwright specs are intentionally deferred
  to their respective parity sprints.
- 10 untracked dead-code files (DemoSeeder, drill_recommender_v2,
  decision_quality_view, etc.) are deferred to dev cycle.
- `pubspec.lock` had a single dependency flag drift reset to match
  origin/main in R3.
- Pre-existing test failures (coach_profile_aggregator_test,
  drill_session_recovery_test) are unchanged.

## What's next

Sprint 2 will build on this surface. See `SPRINT_2_HANDOFF.md`.

## Sprint 1 commit history

```
22ed422 chore(repository): minimal .gitignore cleanup (R3)
267648e docs(sprint1): recovery — project documentation surface
93d404d Merge origin/main: bring in PR #1 (Sprint 1) and PR #2 (R1 Repository Recovery)
8b1c1a5 Merge pull request #2 from anhnpvse02755-png/recovery
74ae5ef chore(repository): restore missing production sources required for clean build
a61a124 Merge pull request #1 from anhnpvse02755-png/feature/parity/knowledge
2858d81 feat(parity/knowledge): Commit 5 - UI Integration & Knowledge Promotion
edd8e0a feat(parity/knowledge): Commit 4 - Import 102 verified articles
230d832 feat(parity/knowledge): Commit 3 - 12 Validators + Reports (quality gate)
2be55de feat(parity/knowledge): Commit 2 - Schema Mapper (real V1->V2 mapping)
6ef3c74 feat(parity/knowledge): Commit 1 - Migration Tool Skeleton
```

## Migration tool

The `tools/knowledge_migration/` directory is a permanent, deterministic
migration tool. It can be re-run to re-import V1 articles with the
same SHA-256 output. See `tools/knowledge_migration/README.md`.

## Artifacts

- `docs/SPRINT_1_FINAL_VERIFICATION.md` — final verification gates.
- `docs/SPRINT_1_SCORECARD.md` — per-commit scorecard.
- `docs/SPRINT_2_HANDOFF.md` — Sprint 2 starting point.
- `docs/REPOSITORY_HEALTH_CHECKLIST.md` — mandatory pre-RC/Beta gate.
- `docs/PROMOTION_REPORT.md` — Knowledge promotion audit.
- `docs/RECOVERY_*.md` — Sprint 1 recovery trail.
- `assets/knowledge/knowledge.json` — the 112-article dataset.
- `tools/knowledge_migration/` — the migration tool.
