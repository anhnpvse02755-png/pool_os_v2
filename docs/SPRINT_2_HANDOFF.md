# Sprint 2 — Handoff

> **From:** Sprint 1 (Knowledge Parity)
> **To:** Sprint 2 (next parity sprint)
> **Starting point:** `origin/main` at `22ed422`
> **Date:** 2026-08-04

## What Sprint 1 delivered

- 112 Knowledge articles (10 live + 102 migrated from V1).
- Knowledge feature parity on the new V2 architecture.
- Migration tool (`tools/knowledge_migration/`) — permanent, deterministic.
- Repository Completeness Gate defined and passing.

## What's safe to build on

- The `knowledge_provider` boundary is established. Use it for any
  Knowledge-related reads. Don't bypass it.
- The `drill_code_bridge` pattern. If Sprint 2 needs similar V1→V2
  cross-domain code translation, follow the same pattern.
- The migration tool pattern. If Sprint 2 needs to import data from
  another V1 source, use the tool's CLI options / validator pipeline.

## What's outstanding (Sprint 1 backlog)

These are intentionally deferred from Sprint 1. They became visible
during the recovery work and should be addressed in their respective
parity sprints:

### 1. Modified Dart screens (12 files)

The user's local working tree had these files modified before Sprint 1
began. They were not part of Sprint 1 scope.

| File | Likely parity domain |
|---|---|
| `lib/core/router/app_router.dart` | Routing |
| `lib/core/theme/app_theme.dart` | Theme (NB: this one was kept in R1) |
| `lib/presentation/screens/home/home_screen.dart` | Home |
| `lib/presentation/screens/play/friendly_match_screen.dart` | Play |
| `lib/presentation/screens/play/quick_match_screen.dart` | Play |
| `lib/presentation/screens/play/tournament_detail_screen.dart` | Play |
| `lib/presentation/screens/play/vision_recording_screen.dart` | Play |
| `lib/presentation/screens/profile/equipment_screen.dart` | Profile + Equipment |
| `lib/presentation/screens/profile/profile_screen.dart` | Profile |
| `lib/presentation/screens/profile/settings_screen.dart` | Profile |
| `lib/presentation/screens/session/create_session_screen.dart` | Session |
| `lib/presentation/screens/training/drill_list_screen.dart` | Training |
| `lib/presentation/screens/training/progress_screen.dart` | Training |

### 2. Pre-existing test failures (2)

- `test/coach_profile_aggregator_test.dart`
- `test/drill_session_recovery_test.dart`

These predate Sprint 1 and should be addressed in the Coach and
Training parity sprints respectively.

### 3. Dead-code files (10)

Files preserved in R1 but with zero importers. They are not build
blockers but exist in the codebase.

```
lib/data/datasources/demo/demo_seeder.dart
lib/data/models/knowledge.dart
lib/data/repositories/repositories.dart
lib/domain/services/drill_recommendation_service.dart
lib/domain/services/drill_recommender_v2.dart
lib/domain/services/match_recording_service.dart
lib/presentation/screens/match/environment_capture_screen.dart
lib/presentation/widgets/decision_quality_view.dart
lib/presentation/widgets/pocket_accuracy_view.dart
lib/presentation/widgets/voice_notes_panel.dart
```

Either delete in dev cycle, or wire up in the appropriate parity sprint.

### 4. Playwright specs

- 6 modified Playwright specs (Home/Play/Profile/Session/Training).
- 10 untracked Playwright specs (`tests/00-*.spec.ts`, `tests/05-match-summary.spec.ts`, etc.).

These are test coverage for parity domains, not Sprint 1 scope.

### 5. Untracked assets and scripts

- `assets/data/drills_data.json` — data file, not referenced by code.
- `generate_drills.py` — script.
- `server.js` — script.

### 6. Minor hygiene items

- `Thanh Cong Group/`, `Usersanhnpv*` folder-name artifacts.
- `Understand-Anything` typo file at root.
- `pubspec.lock` had a single `transitive` → `direct main` flag drift
  (reverted to match origin/main in R3).

## Sprint 2 starting checklist

1. **Read `REPOSITORY_HEALTH_CHECKLIST.md` first.** Run the gate on
   `origin/main` before starting work — it should PASS.
2. Pick the highest-priority parity domain from the backlog.
3. Open a feature branch from `main`.
4. Apply the same discipline as Sprint 1: scope control, small commits,
   empirical verification.
5. Use the migration tool pattern if you need to import data.
6. Run the Repository Completeness Gate on a fresh clone before opening
   your PR.

## Contact / context

- Migration tool: `tools/knowledge_migration/` — see `README.md`.
- Knowledge boundary: `lib/knowledge/knowledge_provider.dart`.
- Provider tree: `lib/core/providers/repository_providers.dart`.
- Recovery artifacts: `docs/RECOVERY_*.md` — useful if you discover
  similar source-of-truth issues.

## Out of scope for Sprint 2 (recommended)

- AI expansion / Knowledge Graph visualization — separate initiative.
- Equipment parity — separate initiative, but the equipment screens
  and repository are now in the codebase (R1).
- Coach / Reports / Match parity — separate initiatives.
- New features in main — keep working tree clean (R1's lesson).

## Final note

Sprint 1 ended with a hard-learned lesson: **Source of Truth is not
optional**. The Repository Completeness Gate enforces that. Apply it
before every RC/Beta cutoff, and before every PR that touches
production source.
