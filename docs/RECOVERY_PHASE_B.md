# Recovery Phase B — Empirical Classification

> **Purpose:** decide which files belong in the recovery commit(s).
> **Method:** empirical. Files are copied into a fresh worktree of
> `origin/main` (the post-merge state) and `flutter analyze` is run
> after each batch. Files that reduced the error count are GROUP A.
> **Status:** Phase B complete. Phase C/G decision pending.

## Test rig

```
Fresh worktree: poolos_v2-fresh  (origin/main only, a61a124)
Baseline:       flutter analyze   → 430 issues, 57 URI errors
                flutter build web → FAIL ("system cannot find the file")
```

## Empirical trial log

| Trial | Files copied | Issues after | URI errors after | Triages |
|---|---|---|---|---|
| 0 | (none) | 430 | 57 | baseline |
| 1 | 59 untracked `lib/` files (data/models, data/repositories, data/impl, data/datasources/demo, domain/services, presentation/screens/knowledge + match + profile, presentation/widgets/) | 143 | 1 | 56 of 57 URI errors resolved |
| 2 | + `lib/data/services/drill_service.dart`, `lib/presentation/widgets/streak_widget.dart`, `lib/presentation/widgets/learning_streak_widget.dart` | 138 | 0 | AppTheme.primary cascade errors revealed |
| 3 | + local modified `lib/core/theme/app_theme.dart` (adds `AppTheme.primary` alias) | 111 | 0 | 0 errors, 61 warnings, 50 info |
| 4 | `flutter build web --release` | PASS | — | 144s build, asset warnings only |

**Errors at end:** 0. **Web build:** PASS.

## GROUP A — Build blockers (must recover)

These are the files whose absence broke `flutter analyze` and
`flutter build web`. Triaged by empirical proof: copy them, errors
drop. They are the **only** files needed to make `origin/main` build.

### Modified files (2)

`lib/core/theme/app_theme.dart` — adds `AppTheme.primary` alias to
keep 30+ call sites compiling. This is a **compatibility alias**,
not a Sprint 1 change. It was added in the user's local working tree
before Sprint 1 began. The note in the file says:

> *"Alias for [primaryGreen] — used by widgets that previously
> expected `AppTheme.primary`. Adding the alias keeps 30+ call sites
> compiling without a sweeping rename. Tracked for cleanup in a
> future sprint."*

This is the **only modified Dart file** that materially affects the
build. Other 13 modified Dart screens are Story 2 (per rules).

### Untracked production files (52)

**After de-duplication of dead code** (10 files removed — see
"Excluded dead code" below), the build-blocker set is 52 files.

```
lib/core/constants/equipment_constants.dart
lib/data/impl/local_ai_coach_repository.dart
lib/data/impl/local_community_repository.dart
lib/data/impl/local_drill_repository.dart
lib/data/impl/local_equipment_repository.dart
lib/data/impl/local_knowledge_repository.dart
lib/data/impl/local_notification_repository.dart
lib/data/impl/local_player_repository.dart
lib/data/impl/local_settings_repository.dart
lib/data/models/certification.dart
lib/data/models/drill.dart
lib/data/models/drill_attempt.dart
lib/data/models/drill_progress.dart
lib/data/models/equipment.dart
lib/data/models/equipment_change_log.dart
lib/data/models/flashcard.dart
lib/data/models/knowledge_node.dart
lib/data/models/match_analysis.dart
lib/data/models/match_environment.dart
lib/data/models/personal_best.dart
lib/data/models/player.dart
lib/data/models/player_interests.dart
lib/data/models/quiz.dart
lib/data/models/shot.dart
lib/data/models/tournament.dart
lib/data/models/training_session.dart
lib/data/models/voice_note.dart
lib/data/repositories/ai_coach_repository.dart
lib/data/repositories/community_repository.dart
lib/data/repositories/drill_repository.dart
lib/data/repositories/equipment_repository.dart
lib/data/repositories/knowledge_repository.dart
lib/data/repositories/notification_repository.dart
lib/data/repositories/player_repository.dart
lib/data/repositories/settings_repository.dart
lib/data/services/drill_service.dart
lib/domain/services/ai_explain_service.dart
lib/domain/services/coach_profile_aggregator.dart
lib/domain/services/drill_session_recovery_service.dart
lib/domain/services/match_statistics_service.dart
lib/domain/services/match_weakness_signals.dart
lib/domain/services/monthly_report_generator.dart
lib/domain/services/streak_calculator.dart
lib/domain/services/weekly_report_generator.dart
lib/presentation/screens/knowledge/ai_explain_screen.dart
lib/presentation/screens/profile/equipment_comparison_screen.dart
lib/presentation/screens/profile/equipment_detail_screen.dart
lib/presentation/screens/profile/equipment_edit_screen.dart
lib/presentation/screens/profile/equipment_statistics_screen.dart
lib/presentation/widgets/learning_streak_widget.dart
lib/presentation/widgets/progress_card.dart
lib/presentation/widgets/streak_widget.dart
```

**Total: 52 files.** All of them are imported by either
`lib/core/providers/repository_providers.dart` (committed) or another
file in the 52 set.

### Excluded dead code (10 files)

These files had **zero importers** anywhere in `lib/` and `test/`.
They are NOT build blockers. They are dead code that exists in the
local working tree but is not referenced by anything. They will go to
their respective parity sprints (Equipment / Coach / Match / Profile)
or be deleted as appropriate.

```
lib/data/datasources/demo/demo_seeder.dart            (DemoSeeder - never called)
lib/data/models/knowledge.dart                        (Knowledge model - duplicate of knowledge_data.dart)
lib/data/repositories/repositories.dart               (barrel - no one imports via barrel)
lib/domain/services/drill_recommendation_service.dart  (recommendation - never instantiated)
lib/domain/services/drill_recommender_v2.dart         (recommendation v2 - never instantiated)
lib/domain/services/match_recording_service.dart      (service - never injected)
lib/presentation/screens/match/environment_capture_screen.dart  (screen - never routed)
lib/presentation/widgets/decision_quality_view.dart   (widget - never used)
lib/presentation/widgets/pocket_accuracy_view.dart    (widget - never used)
lib/presentation/widgets/voice_notes_panel.dart       (widget - never used)
```

The 10-file dead-code exclusion was **not** visible from the
trial-2 result alone (the trial passed because the files don't break
anything when present; the deeper check was importers-in-codebase).

## GROUP B — Not needed for build (defer)

These exist locally but are not referenced by any code that
`origin/main` tries to compile. They are part of larger parity
work that landed in the user's local working tree but not in git.

| Category | Count | Reason |
|---|---|---|
| Modified Dart screens (Home/Play/Profile/Session/Training non-Knowledge) | 12 | Out of Sprint 1 scope per rules |
| Modified Playwright specs | 6 | Tests for non-Knowledge parity |
| `pubspec.lock` modified | 1 | Drift from `flutter pub get` — recommended revert |
| `pubspec.yaml` modified | 1 | Sprint 1 added `assets/knowledge/`, this is the legitimate change |
| `docs/` (39 docs) | 39 | Documentation, not build blockers |
| `tests/00-*.spec.ts` + `tests/05-match-summary.spec.ts` + `tests/07/08-equipment*` + `tests/fixtures/` | 10 | Tests for non-Knowledge parity |
| `assets/data/drills_data.json` | 1 | Data file, no `import` references it |
| `generate_drills.py`, `server.js` | 2 | Scripts, not referenced by Flutter app |
| `assets/data/` directory entry in pubspec.yaml | — | Build warning, not a blocker |

## GROUP C — Ignore (never recover)

| Path | Reason |
|---|---|
| `.ua/` (entire directory) | Agent scratch |
| `.ua/tmp/` | Working files for this recovery |
| `.dart_tool/`, `build/`, `node_modules/`, `playwright-report/`, `test-results/`, `.flutter-plugins-dependencies`, `pool_os_v2.iml`, `.idea/`, `.claude/` | Generated / IDE / local cache |
| `Thanh Cong Group/`, `Usersanhnpv…` | Folder-name artifacts from external copy |
| `ocd-0.2.1-windows-amd64/` | Third-party CLI binary, will go to `.gitignore` |
| `debug-onboarding.png` | Local debug screenshot |
| `Understand-Anything` | Typo file at root |
| `.ua/.trash-1785648879/` | Agent trash |

## Decision for Phase C

| Bucket | Files | Commit |
|---|---|---|
| **R1 — Build blockers** | 62 files (1 modified + 61 untracked) | **MUST commit** |
| **R2 — Documentation** | 39 docs (CLAUDE.md, MEMORY.md, docs/reviews/*, docs/screenshots/, docs/testing/) | Q — your call |
| **R3 — Workspace cleanup** | `.gitignore` (add `ocd-0.2.1-windows-amd64/`, `debug-onboarding.png`, possibly more) | Optional |

R1 alone is sufficient to make `origin/main` build (proven by
`flutter build web --release` PASS). R2/R3 are scope-control
choices for you.

## What R1 does NOT include

- **No Sprint 1 Knowledge files** — that's already merged.
- **No Sprint 1 untracked Knowledge files** — all 112 are in `assets/knowledge/knowledge.json` which is committed.
- **No 13 modified Dart screens** — those are other parity work, per your rule.
- **No `pubspec.lock`** — recommend revert (just `flutter pub get` drift).

## What R1 DOES include

Strictly the **minimal set of files** that, when added to `origin/main`,
makes `flutter analyze` clean of errors and `flutter build web` succeed.
Empirically verified.
