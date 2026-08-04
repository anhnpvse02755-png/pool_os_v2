# Recovery Inventory — Pre-merge Local State

> **Status:** Phase A complete. Phases B/C/D pending decision.
> **Created during:** Sprint 1, Commit 6 preparation
> **Reason:** After merging PR #1 (`feature/parity/knowledge` → `main`), the
> merged tree on `origin/main` (`a61a124`) did not include the working tree
> state of the user, which contained 29 modified files and 141 untracked files.
> `flutter build web` and `test/widget_test.dart` both fail on `origin/main`
> because the source files referenced (e.g. `lib/data/models/match_analysis.dart`)
> exist only locally.

## Totals

| Bucket | Count |
|---|---|
| Modified (in `git diff`) | **29** |
| Untracked (in `git ls-files --others`) | **141** |
| **Total** | **170** |

`git diff` overcounts because the `.ua/intermediate/batch-*.json` and
`Understand-Anything` rows are listed as both "deleted" and as agent
working files. Below is the cleaned breakdown.

## By top-level directory

| Directory | Count | Notes |
|---|---|---|
| `lib/` | 73 | Dart source — split into modified + untracked |
| `docs/` | 37 | Review docs + reports + testing notes |
| `.ua/` | 30 | Agent scratch / transient — **ignore** |
| `tests/` | 16 | Playwright specs |
| `(root)` | 8 | `CLAUDE.md`, `MEMORY.md`, `debug-onboarding.png`, etc. |
| `Thanh Cong Group/` | 3 | Folder name artifact — **ignore** |
| `Usersanhnpv…` | 1 | Folder-name duplication artifact — **ignore** |
| `assets/` | 1 | `assets/data/drills_data.json` |
| `ocd-0.2.1-windows-amd64/` | 1 | Bundled CLI executable — **decide** |

## Modified (29)

### Production — Dart source (10)

```
lib/core/router/app_router.dart
lib/core/theme/app_theme.dart
lib/presentation/screens/home/home_screen.dart
lib/presentation/screens/play/friendly_match_screen.dart
lib/presentation/screens/play/quick_match_screen.dart
lib/presentation/screens/play/tournament_detail_screen.dart
lib/presentation/screens/play/vision_recording_screen.dart
lib/presentation/screens/profile/equipment_screen.dart
lib/presentation/screens/profile/profile_screen.dart
lib/presentation/screens/profile/settings_screen.dart
lib/presentation/screens/session/create_session_screen.dart
lib/presentation/screens/training/drill_list_screen.dart
lib/presentation/screens/training/progress_screen.dart
```

These files were modified during C5 to align with the new provider
boundaries. They must be reviewed — some changes were intentionally
deferred to a separate parity commit so C5 stayed scoped to Knowledge.

### Test — Playwright (6)

```
tests/01-welcome.spec.ts
tests/02-onboarding.spec.ts
tests/03-home.spec.ts
tests/04-training.spec.ts
tests/05-play.spec.ts
tests/06-knowledge.spec.ts
```

### Config / generated diff noise (8)

```
.ua/intermediate/batch-1.json (deleted in tree)
.ua/intermediate/batch-2.json (deleted in tree)
.ua/intermediate/batch-3.json (deleted in tree)
.ua/intermediate/batch-4.json (deleted in tree)
.ua/intermediate/batch-5.json (deleted in tree)
.ua/intermediate/batches.json (deleted in tree)
.ua/intermediate/scan-result.json (deleted in tree)
Understand-Anything (typo file at root)
playwright.config.ts (modified)
pubspec.lock (modified)
```

## Untracked (141)

### Production — Dart source (73)

```
lib/core/constants/equipment_constants.dart
lib/data/datasources/demo/demo_seeder.dart
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
lib/data/models/knowledge.dart
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
lib/data/repositories/repositories.dart
lib/data/repositories/settings_repository.dart
lib/data/services/{~12 files}
lib/domain/services/ai_explain_service.dart
lib/domain/services/coach_profile_aggregator.dart
lib/domain/services/drill_recommendation_service.dart
lib/domain/services/drill_recommender_v2.dart
lib/domain/services/drill_session_recovery_service.dart
lib/domain/services/match_recording_service.dart
lib/domain/services/match_statistics_service.dart
lib/domain/services/match_weakness_signals.dart
lib/domain/services/monthly_report_generator.dart
lib/domain/services/streak_calculator.dart
lib/domain/services/weekly_report_generator.dart
lib/presentation/screens/knowledge/ai_explain_screen.dart
lib/presentation/screens/match/environment_capture_screen.dart
lib/presentation/screens/profile/equipment_comparison_screen.dart
lib/presentation/screens/profile/equipment_detail_screen.dart
lib/presentation/screens/profile/equipment_edit_screen.dart
lib/presentation/screens/profile/equipment_statistics_screen.dart
lib/presentation/widgets/decision_quality_view.dart
lib/presentation/widgets/pocket_accuracy_view.dart
lib/presentation/widgets/progress_card.dart
lib/presentation/widgets/voice_notes_panel.dart
```

These look like they belong to **other parity work** (Equipment, Coach,
Match, Reports, Training, Profile) that exists locally but never made it
into a commit. They are referenced by `widget_test.dart` and the
`playwright` specs — which is why both fail on the merged tree.

### Production — Assets (1)

```
assets/data/drills_data.json
```

### Production — Tools / scripts (1)

```
generate_drills.py
server.js
```

### Test — Playwright (8 + fixtures)

```
tests/00-deeplink.spec.ts
tests/00-navigation.spec.ts
tests/00-regression.spec.ts
tests/00-responsive.spec.ts
tests/00-smoke.spec.ts
tests/00-validation.spec.ts
tests/05-match-summary.spec.ts
tests/07-equipment.spec.ts
tests/08-equipment-screenshots.spec.ts
tests/fixtures/
```

### Docs (37)

```
CLAUDE.md
MEMORY.md
docs/reviews/ARCHITECTURE_VIOLATIONS.md
docs/reviews/COACH_GAP_ANALYSIS.md
docs/reviews/CONTENT_QUALITY_REPORT.md
docs/reviews/EQUIPMENT_GAP_ANALYSIS.md
docs/reviews/EQUIPMENT_RESTORATION_REPORT.md
docs/reviews/EXECUTIVE_SUMMARY.md
docs/reviews/KNOWLEDGE_GAP_ANALYSIS.md
docs/reviews/KNOWLEDGE_VISION_GAP.md
docs/reviews/MATCH_SUMMARY_GAP_ANALYSIS.md
docs/reviews/MATCH_SUMMARY_RESTORATION_REPORT.md
docs/reviews/MATCH_VISION_GAP.md
docs/reviews/PHASE_A_CLOSE_OUT.md
docs/reviews/PHASE_B_CLOSE_OUT.md
docs/reviews/PHASE_CONVENTIONS.md
docs/reviews/PHASE_C_CLOSE_OUT.md
docs/reviews/PLAY_GAP_ANALYSIS.md
docs/reviews/POOL_OS_V2_STABILIZATION_SCORECARD.md
docs/reviews/PROFILE_GAP_ANALYSIS.md
docs/reviews/REGRESSION_SUMMARY.md
docs/reviews/REPORTS_GAP_ANALYSIS.md
docs/reviews/REPORTS_VISION_GAP.md
docs/reviews/ROADMAP.md
docs/reviews/STABILIZATION_AUDIT_DETAIL.md
docs/reviews/STATISTICS_GAP_ANALYSIS.md
docs/reviews/STATISTICS_VISION_GAP.md
docs/reviews/TRAINING_CONTENT_EXPANSION.md
docs/reviews/TRAINING_GAP_ANALYSIS.md
docs/reviews/VISION.md
docs/reviews/VISION_GAP.md
docs/screenshots/  (directory)
docs/testing/BUG_REPORT_001.md
docs/testing/BUG_REPORT_002.md
docs/testing/E2E_EXECUTION_REPORT.md
```

### Unknown / ignore (29)

```
.ua/  (entire directory — agent scratch, ~30 files)
Thanh Cong Group/  (typo folder-name artifact)
UsersanhnpvOneDrive - Thanh Cong GroupDesktoppoolos_v2/  (typo folder-name artifact)
ocd-0.2.1-windows-amd64/  (standalone CLI executable — likely a third-party tool not built into the app)
debug-onboarding.png  (debug screenshot — may be used by docs/testing)
```

### Modified-but-internal (8, all in `.ua/` and root)

These are agent working files. They are not part of source control.

```
.ua/intermediate/{batch-1..5,batches,scan-result}.json  (deleted in working tree)
Understand-Anything  (typo file)
```

## Classification (Phase B input)

| Class | Files | Decision |
|---|---|---|
| **Production Dart source** | 73 | MUST commit (parity work belongs in repo) |
| **Production assets / data** | 1 | MUST commit (`drills_data.json`) |
| **Production scripts** | 2 | MUST commit (`generate_drills.py`, `server.js`) |
| **Test Dart + Playwright + fixtures** | 16 | MUST commit |
| **Modified Dart screens (13)** | 13 | Review: were these intentional in C5 or pre-C5 drift? |
| **Modified Playwright specs (6)** | 6 | Likely relate to other parity work — must commit |
| **Docs** | 37 | MUST commit (the project's primary doc surface) |
| **`ocd-0.2.1-windows-amd64/`** | 1 | DECIDE — third-party CLI binary, not Flutter |
| **`.ua/`** | 30 | IGNORE (agent scratch) |
| **`Thanh Cong Group/`, `Usersanhnpv…`** | 4 | IGNORE (folder-name artifacts from external copy) |
| **`debug-onboarding.png`** | 1 | DECIDE — referenced by `docs/testing/` or transient? |
| **`pubspec.lock` modified** | 1 | REVIEW — could be regeneration after C5 deps |
| **`playwright.config.ts` modified** | 1 | MUST commit if modified alongside other Playwright work |
| **`Understand-Anything`** | 1 | IGNORE (typo file) |

## Open questions for Phase B

1. **Are the 13 modified Dart screens changes that were intended to be
   part of C5 but weren't committed?** If yes, they belong in a separate
   "screens refresh" commit on top of C5. If no, they need to be split
   back into their respective parity commits.

2. **`pubspec.lock` modified — why?** Could be (a) `flutter pub get`
   after C5 added the asset bundle, or (b) drift from a different
   branch. The diff will tell us.

3. **`ocd-0.2.1-windows-amd64/` — keep or delete?** It's a CLI binary
   in the repo root. If it's used by tests/docs, keep it. Otherwise
   add to `.gitignore`.

4. **`debug-onboarding.png` — keep or delete?** A 1280×720 PNG at root.

5. **The 73 untracked `lib/` files — these constitute most of the
   non-Knowledge parity work.** Recovery Plan 1.5 calls for inventory +
   classify. Should they become a single "restoration" commit (because
   they're pre-existing code that never landed in git), or split into
   one commit per parity domain (Equipment, Coach, Match, Reports,
   Training, Profile)?

## Next step

Phase B — human review of this inventory, then classify each entry.
Phase C — single recovery commit with the chosen files.
Phase D — full verification.