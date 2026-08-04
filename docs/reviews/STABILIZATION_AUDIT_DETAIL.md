# Pool OS V2 — Stabilization Audit Detail

**Date:** 2026-08-03
**Audience:** Engineering
**Status:** pending — populated by 5 parallel audit agents

---

## How to read this

This document holds every finding from the parallel audit. Each finding
has:

```
- ID: STAB-NNN
- Severity: P0 | P1 | P2 | P3
- Layer: <which of 14>
- File: path:line
- Finding: one sentence
- Why it matters: one sentence
- Fix: concrete change
```

P0 = blocks release. P1 = ship-blocker for next minor. P2 = tracked.
P3 = nice-to-have.

---

## Findings index

(filled by agents 1–5; Agent 2 done, others in progress)

---

## Layer 1 — Data Integrity — Agent 1 (self-run; sub-agent context overflow)

**Score: 7/10** — package name mismatch in 5 test files (test imports `package:poolos_v2/...` but pubspec is `pool_os_v2`); missing `assets/knowledge/drill_mapping.json` and `assets/knowledge/` not in pubspec `assets:` list; otherwise data layer is clean.

## Layer 2 — Model — Agent 1

**Score: 8/10** — 35 model classes present and well-named. No P0/P1; minor gap: no enum versioning for axis names (`CoachProfile.skillScores` keys are unversioned strings).

## Layer 3 — Content — Agent 1

**Score: 8/10** — 300/300 drills complete (no placeholders, 100% knowledge-linked, 20 categories used). Knowledge has 10 articles of high quality (>=300 chars each, tags + linked knowledge + linked drills). Gaps: only 10 articles vs Phase B target of 500; 15 duplicate `nameEn` drill names; no `tier` or `tableSize` fields (uses `difficulty` 1-5).

### Agent 1 findings

#### P0

- **STAB-027 [P0]** Layer=1 file=`pubspec.yaml:1` + `test/*.dart` (5 files)
  Finding: pubspec declares `name: pool_os_v2` (underscores) but all 5 unit-test files import as `package:poolos_v2/...` (no underscores).
  Why: Dart analyzer reports `uri_does_not_exist` for every test import even though the underlying model/service files exist on disk.
  Fix: Either rename pubspec to `poolos_v2` (breaks CI), or rewrite all 5 test imports to `package:pool_os_v2/...`. Pick the rename — cheaper.

- **STAB-003 [P0]** Layer=14 file=`pubspec.yaml:54-58` (already filed by Agent 5; double-confirmed)
  Finding: `assets/knowledge/` referenced by `lib/knowledge/knowledge_service.dart:40,54,68,82` and `lib/domain/services/knowledge_graph_service.dart:18` but **NOT listed under `flutter.assets:`**. `assets/knowledge/drill_mapping.json` does NOT exist on disk (only `categories.json`, `knowledge.json`, `tags.json`).
  Why: `rootBundle.loadString('assets/knowledge/knowledge.json')` throws in release builds; `loadDrillMapping()` always throws at runtime.
  Fix: Add `- assets/knowledge/` to `flutter.assets:`; commit missing `drill_mapping.json` (or delete its call site).

#### P1

- **STAB-028 [P1]** Layer=1 file=`test/*.dart` (5 files)
  Finding: Tests do not run because imports don't resolve. `flutter analyze` reports ~50 errors in `test/` folder — every `import 'package:poolos_v2/...'` is `uri_does_not_exist`.
  Why: No coverage of any Phase-A service. Refactors break silently.
  Fix: rewrite imports to `package:pool_os_v2/...` (or rename pubspec).

#### P2

- **STAB-029 [P2]** Layer=3 file=`assets/data/drills_data.json` (300 drills)
  Finding: 15 drills share duplicate `nameEn` values (mostly same-name-different-category like "Stop Shot" exists in both fundamentals and stop_shot category).
  Why: Search UX shows two identical results.
  Fix: append category suffix to `nameEn` for affected drills; or use `(nameEn, code)` compound key in dedup logic.

- **STAB-030 [P2]** Layer=3 file=`assets/data/drills_data.json` (300 drills)
  Finding: Phase B roadmap promised `tier` (Foundation/Intermediate/Advanced/Master) and `tableSize` fields. Actual JSON has only `difficulty` (1-5) — tier and tableSize are absent.
  Why: Roadmap → implementation gap.
  Fix: add `tier` and `tableSize` to schema; backfill from `difficulty` (1-2 → Foundation, 3 → Intermediate, 4 → Advanced, 5 → Master) and a default 9ft table.

- **STAB-031 [P2]** Layer=3 file=`assets/knowledge/knowledge.json` (10 articles)
  Finding: Phase B roadmap promised 500 articles. Actual JSON has 10.
  Why: roadmap says "current → 500 articles" — 50× gap.
  Fix: content team to scale up; not a code-blocker but a delivery gap.

- **STAB-032 [P2]** Layer=2 file=`lib/domain/services/coach_profile_aggregator.dart:115-130`
  Finding: `skillScores` is unversioned `Map<String, double>` with no schema.
  Why: same finding as Agent 4 STAB-012; renaming any axis key breaks panel UI silently.
  Fix: introduce `SkillAxis` enum + version field in `CoachProfile`.

#### P3

- **STAB-033 [P3]** Layer=3 file=`assets/knowledge/knowledge.json` (10 articles)
  Finding: `prerequisites` field absent on all 10 articles (only `relatedKnowledgeIds` exists). Knowledge graph DFS in `knowledge_graph_service.dart:53-60` cannot resolve prerequisite chains.
  Why: learning-path "read X before Y" feature relies on this.
  Fix: add `prerequisites: string[]` field; backfill for the 10 existing articles.

- **STAB-034 [P3]** Layer=1 file=`assets/data/drills_data.json`
  Finding: `difficultyLevel` field exists alongside `difficulty` — both store int. Confusing duplicate.
  Fix: pick one (keep `difficulty`, drop `difficultyLevel`).

---

## Layer 4 — Repository — Agent 2

**Score: 4/10** — interfaces partially defined (Match/DrillSession/DrillProgress/Shot/PersonalBest/EquipmentChangeLog/VoiceNote have `I*` interfaces); 8 older repositories use concrete-name convention without `I*`. Zero Supabase implementations. Runtime selection of local-vs-remote is hard-coded.

## Layer 5 — Service — Agent 2

**Score: 5/10** — services receive repository interfaces correctly in newer code (weekly/monthly/aggregator/streak/recommender/progress-score); but `quiz_service`, `spaced_repetition_service`, `learning_streak_service` do read-modify-write on raw SharedPreferences; error contracts not defined; no transactional boundaries.

## Layer 6 — Offline-first / Persistence — Agent 2

**Score: 3/10** — **two parallel storage classes** (`LocalStorageService` legacy static + new `LocalStorageDataSource`) initialized side-by-side in `main.dart`, split-brain persistence. `clearAllData()` does not clear `_keyDrills`/`_keyTournaments`/`_keySettings`/`_keyFirstLaunch`. Non-atomic list RMW across all repositories. Also see `ARCHITECTURE_VIOLATIONS.md`.

### Agent 2 findings

#### P0

- **STAB-001 [P0]** Layer=6 file=`lib/main.dart:12-15`
  Finding: Two independent static persistence stores initialized (`LocalStorageDataSource.init()` + legacy `LocalStorageService`) with overlapping keys and no migration.
  Why: reads/writes land in different stores; `clearAllData` doesn't clear both.
  Fix: consolidate on one injected datasource/repository stack + one-time migration for legacy keys.

- **STAB-002 [P0]** Layer=4 file=`lib/core/providers/repository_providers.dart:31-65`
  Finding: Every provider selects local impl unconditionally. No Supabase impl, no runtime selection.
  Why: declared `Local + Supabase` architecture is unimplemented.
  Fix: define contracts consistently, add Supabase impls, inject selection.

- **STAB-003 [P0]** Layer=4 file=`lib/core/providers/training_provider.dart:83-173`
  Finding: `TrainingNotifier` performs storage CRUD directly.
  Why: UI↔persistence coupling breaks sync/test/conflict-handling.
  Fix: inject `IDrillSessionRepository` and call from notifier.

- **STAB-004 [P0]** Layer=4 file=`lib/presentation/screens/profile/knowledge_progress_section.dart:15-29`
  Finding: Widget reads `LocalStorageService` directly.
  Why: persistence errors uncaught; cannot switch to Supabase.
  Fix: consume `knowledgeProgressProvider`.

#### P1

- **STAB-005 [P1]** Layer=4 file=8 repositories (player/drill/knowledge/notification/community/settings/ai_coach/equipment): interface naming inconsistent (no `I` prefix).
  Fix: rename to `I*Repository` or document convention.

- **STAB-006 [P1]** Layer=4 file=`lib/data/repositories/repositories.dart:1-9`: barrel export omits 6 newer contracts.
  Fix: export all repository interfaces.

- **STAB-007 [P1]** Layer=4 file=`lib/data/impl/local_equipment_repository.dart:143-167`: repository bypasses datasource methods, exposes `LocalStorageDataSource.prefs` static singleton.
  Fix: inject datasource interface.

- **STAB-008 [P1]** Layer=6 file=`lib/data/repositories/match_repository.dart:107-132`: `deleteMatch` writes match list + 5 related keys sequentially, non-transactional.
  Fix: Drift/transactional or single aggregate record.

- **STAB-009 [P1]** Layer=6 file=`lib/data/repositories/drill_session_repository.dart:68-83`: `save` writes session + active index separately.
  Fix: transactional storage or recoverable write.

- **STAB-010 [P1]** Layer=6 file=`lib/data/repositories/drill_progress_repository.dart:66-83`: `recordAttempt` RMW without lock/transaction.
  Fix: atomic update + idempotency key.

- **STAB-011 [P1]** Layer=6 file=`lib/data/repositories/voice_note_repository.dart:29-35`: `save` always appends, no ID uniqueness check.
  Fix: upsert by note ID.

- **STAB-012 [P1]** Layer=6 file=`lib/data/impl/.../equipment_change_log_repository.dart:29-36`: `record` always appends, not idempotent.
  Fix: dedupe by event ID.

- **STAB-013 [P1]** Layer=5 file=`lib/domain/services/quiz_service.dart:30-66`, `spaced_repetition_service.dart:22-30,66-97`, `learning_streak_service.dart:44-54`: RMW persistence directly, no repo/transaction.
  Fix: inject repositories with atomic update.

- **STAB-014 [P1]** Layer=5 file=`lib/domain/services/drill_library_service.dart:15-20`, `knowledge_graph_service.dart:15-20`: cache-loaders swallow all exceptions.
  Fix: structured logging + retained fallback.

#### P2

- **STAB-015 [P2]** Layer=5 file=`lib/domain/services/match_statistics_service.dart:28-34`: multi-repository reads without snapshot/transaction.
- **STAB-016 [P2]** Layer=5 file=`lib/domain/services/match_recording_service.dart:37,47,71`: start/rack/finish persist independently, no transaction/retry.
- **STAB-017 [P2]** Layer=5 file=`lib/domain/services/drill_session_recovery_service.dart:16-89`: no transaction/conflict checks.
- **STAB-018 [P2]** Layer=5 file=`weekly/monthly/coach_profile/streak/recommender/progress_score`: no error policy / failure contract.
- **STAB-019 [P2]** Layer=5 file=`lib/data/datasources/supabase_service.dart:5-20`: Supabase as static singleton, `late` client, implicit init order.
- **STAB-020 [P2]** Layer=4 file=`lib/core/services/player_service.dart:19-106`, `training_service.dart:13-287`: services call Supabase tables directly, bypass repository interfaces.

#### P3

- **STAB-021 [P3]** Layer=6 file=`lib/core/services/local_storage_service.dart:33-151`: legacy methods RMW list, no duplicate-ID protection.
- **STAB-022 [P3]** Layer=6 file=`lib/data/datasources/local/local_storage_datasource.dart:6-333`: live duplicate alongside legacy, split-brain.
- **STAB-023 [P3]** Layer=6 file=`lib/data/datasources/local/local_storage_datasource.dart:318-332`: `clearAllData()` omits 4 keys.
- **STAB-024 [P3]** Layer=6 file=`lib/data/impl/local_player_repository.dart:41-52`: not keyed for multi-player.
- **STAB-025 [P3]** Layer=6 file=`lib/data/impl/local_drill_repository.dart:80-88,106-109`: RMW, no idempotency.
- **STAB-026 [P3]** Layer=4 file=`lib/data/repositories/match_repository.dart:7-8`: `typedef LocalStorage = LocalStorageService` leaks infra from contract.

## Layer 7 — UI / Navigation — Agent 3

**Score: 4/10** — routes register OK but analyzer blocks compilation; orphan/dead routes; no tablet logic; no font scaling; dark mode disabled; hardcoded strings.

## Layer 8 — UX (a11y / states / scaling / dark / tablet) — Agent 3

**Score: 3/10** — AsyncValue error branches swallowed in 11+ screens; no offline indicator; demo/fake data in production paths; zero Semantics; 28% tooltip coverage; 4 contrast failures.

### Agent 3 findings

#### P0

- **STAB-007 [P0]** Layer=7 file=`lib/main.dart:32`
  Finding: `themeMode` hardcoded to `ThemeMode.light` → `AppTheme.darkTheme` is dead code.
  Fix: change to `themeMode: ThemeMode.system`; complete darkTheme (input/button/card + bottom nav).

- **STAB-008 [P0]** Layer=8 file=`lib/presentation/widgets/progress_card.dart:46,61` (+ ~30 more in lib/presentation)
  Finding: 54 `flutter analyze` errors — `AppTheme.primary` undefined (should be `primaryGreen`), `Rack.shots` undefined, `invalid_constant` in painters, `withOpacity` deprecated.
  Fix: add `static const Color primary = primaryGreen;` alias in `AppTheme`; add `final List<Shot> shots` field to `Rack`; replace `withOpacity` with `withValues(alpha:)`.

- **STAB-009 [P0]** Layer=8 file=`lib/presentation/screens/match/match_replay_screen.dart:22`
  Finding: `Rack(...)` ctor invokes removed/renamed fields (`matchId`, `number`, `winner`, `startedAt`, `endedAt`).
  Fix: rewrite using `Rack(id, rackNumber, result, createdAt)`.

- **STAB-010 [P0]** Layer=8 file=`lib/presentation/screens/home/home_screen.dart:269` + `coach/analysis_screen.dart:30/39/56` + `training/progress_screen.dart:29`
  Finding: `AsyncValue.when` error branch returns `const SizedBox()` — silently swallows AI coach failure.
  Fix: replace with `ErrorRetryWidget(onRetry: () => ref.invalidate(provider))`.

- **STAB-011 [P0]** Layer=8 file=`lib/presentation/screens/play/match_recording_screen.dart:696`
  Finding: `duration.inMinutes` invoked on `int` — analyzer undefined_getter.
  Fix: assert `duration is Duration` and access `.inMinutes`, or coerce `int → Duration(minutes: …)` upstream.

- **STAB-012 [P0]** Layer=7 file=`lib/core/router/app_router.dart:321-355`
  Finding: `/profile/equipment` parent has sub-route `:id` registered before `compare`/`stats`/`edit` literals; route shadows are fragile.
  Fix: keep static-segment routes before dynamic `:id`; add go_router tests for each.

#### P1

- **STAB-013 [P1]** Layer=8 file=`lib/presentation/screens/training/drill_list_screen.dart:540,194,33`
  Finding: `body: _categories.isEmpty ? CircularProgressIndicator() : …` — no error state; `_loadDrills()` calls `setState` after `await` without mounted guard.
  Fix: try/catch + `_error`; guard with `if (!mounted) return`.

- **STAB-014 [P1]** Layer=8 file=`lib/presentation/screens/knowledge/knowledge_graph_screen.dart:19-20,30`
  Finding: `_nodes/_edges` populated but `_build` never reads them — empty graph always; no loading/retry.
  Fix: render from `_nodes/_edges`; add loading/error states.

- **STAB-015 [P1]** Layer=8 file=`lib/presentation/screens/training/certification_detail_screen.dart:97`
  Finding: link `/training/test/:certId/:testId` has no registered route — CTA is dead (404).
  Fix: register route or remove CTA.

- **STAB-016 [P1]** Layer=8 file=`lib/presentation/screens/training/training_history_screen.dart:18`
  Finding: data is hard-coded `_demoHistory` (no repository, no async).
  Fix: replace with `ref.watch(trainingHistoryProvider)`; add empty/error branches.

- **STAB-017 [P1]** Layer=7 file=`lib/presentation/screens/training/training_center_screen.dart:39`
  Finding: `context.push('/training/paths')` — typo (real route is `/training/path`). 404 nav.
  Fix: change to `/training/path`.

- **STAB-018 [P1]** Layer=7 file=`lib/presentation/screens/session/create_session_screen.dart:30`
  Finding: `context.push('/sessions')` — orphan nav literal.
  Fix: register `/sessions` or replace with `/training/session/new`.

- **STAB-019 [P1]** Layer=7 file=`lib/presentation/screens/session/session_list_screen.dart`
  Finding: implemented file never imported by router — orphan screen.
  Fix: register route or delete file.

- **STAB-020 [P1]** Layer=8 file=`lib/presentation/screens/community/community_screen.dart`
  Finding: 712 lines, zero loading/error/empty handling; `go_router` import unused.
  Fix: introduce `communityFeedProvider`; add loading+empty+error.

- **STAB-021 [P1]** Layer=8 file=`lib/presentation/screens/knowledge/{ai_explain,quiz,flashcard,knowledge_graph}_screen.dart`
  Finding: FutureBuilder with `LinearProgressIndicator` but no error/empty branches.
  Fix: try/catch + branch.

- **STAB-022 [P1]** Layer=8 file=`lib/presentation/screens/profile/settings_screen.dart:462`
  Finding: "Hoạt động offline hoàn toàn" is a static label, not a real connectivity indicator. No `ConnectivityResult` listener, no online/offline banner anywhere.
  Fix: add `connectivity_plus` and banner in MainShell listening to `Connectivity().onConnectivityChanged`.

- **STAB-023 [P1]** Layer=8 file=`lib/presentation/screens/auth/login_screen.dart:49,289`
  Finding: hard navigation to `/home` regardless of onboarding — bypasses `InterestSelectionScreen`.
  Fix: gate `/home` behind interest-selection completion.

- **STAB-024 [P1]** Layer=8 file=`lib/presentation/screens/training/learning_path_screen.dart:226`
  Finding: `context.push('/onboarding/interests')` reachable mid-app; user loses state.
  Fix: gate behind onboarding flag or hide CTA.

- **STAB-025 [P1]** Layer=8 file=`lib/presentation/screens/training/{recommended_screen,assessment_screen}.dart`
  Finding: 571 / 594 lines with no loading/error/empty states; zero results handling.
  Fix: AsyncValue/FutureBuilder with all 3 branches.

#### P2

- **STAB-026 [P2]** Layer=7 file=`lib/presentation/screens/shell/main_shell.dart:162,146`
  Finding: Bottom-nav labels hardcoded `fontSize: 11`; badge text `fontSize: 10`; no scaling clamp.
  Fix: switch to `Theme.of(context).textTheme.labelSmall`; wrap in `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.4, …)`.

- **STAB-027 [P2]** Layer=7 file=`widgets/coach_profile_panel.dart:90`, `widgets/shot_map_painter.dart:102`, `widgets/skill_trend_chart.dart:107`
  Finding: 3× `withOpacity` (deprecated in Flutter 3.27+).
  Fix: `withValues(alpha: …)`.

- **STAB-028 [P2]** Layer=7 file=`lib/presentation/screens/onboarding/interest_selection_screen.dart:177`
  Finding: `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)` — fixed grid on tablets.
  Fix: derive crossAxisCount from `MediaQuery.sizeOf(context).width` (≥900 → 4, ≥600 → 3, else 2).

- **STAB-029 [P2]** Layer=7 file=`knowledge_graph_screen.dart` + many `GridView.count(crossAxisCount: 2)`
  Finding: no breakpoint logic anywhere.
  Fix: introduce `Responsive` helper with `compact/medium/expanded` buckets.

- **STAB-030 [P2]** Layer=8 file=`lib/presentation/screens/play/match_history_screen.dart:138`
  Finding: `AppTheme.primary.withOpacity(0.4)` on white ≈ 2.18:1 — empty-state icon barely visible.
  Fix: opacity 0.6 or `primaryGreen.shade300`.

- **STAB-031 [P2]** Layer=8 file=`training_center_screen.dart`, etc.
  Finding: `Colors.grey.shade500` on white = 2.68:1 fails AA normal text.
  Fix: darken `textSecondary` to `#595959` (≈7:1) or split into primary/secondary tokens.

- **STAB-032 [P2]** Layer=8 file=`learning_streak_widget.dart`, `streak_widget.dart`, `progress_card.dart`
  Finding: composed widgets swallow `AppTheme.primary` compile errors.
  Fix: bundled in STAB-008.

- **STAB-033 [P2]** Layer=8 file=`home_screen.dart:24-25`
  Finding: `playerAsync` and `streakAsync` locals unused.
  Fix: remove or wire into UI.

- **STAB-034 [P2]** Layer=7 file=`app_router.dart:227`
  Finding: `drill` query param silently fallback to `'STRAIGHT_POT'`.
  Fix: validate against `DrillLibrary.codes`; redirect to `/training/drills` if invalid.

- **STAB-035 [P2]** Layer=8 file=`onboarding_screen.dart:148` + many
  Finding: all user-facing strings hard-coded; no `flutter_localizations`, `intl` only for DateFormat.
  Fix: add `flutter_localizations` dep, set `localizationsDelegates`, generate `app_en.arb`/`app_vi.arb`.

#### P3

- **STAB-036 [P3]** Layer=8 file=`home_screen.dart` (all)
  Finding: long magic fontSize numbers repeated 100+ times in inline TextStyle.
  Fix: define `AppTextStyles`; rely on `textTheme.displaySmall/titleMedium/bodyMedium/labelSmall`.

- **STAB-037 [P3]** Layer=7 file=`drill_result_screen.dart`
  Finding: orphan screen (no router entry).
  Fix: register `/training/drill/result/:drillCode` or delete.

- **STAB-038 [P3]** Layer=8 file=`knowledge_progress_section.dart`
  Finding: depends on `AppTheme.primary` (compile error).
  Fix: bundled in STAB-008.

- **STAB-039 [P3]** Layer=7 file=`widgets/voice_notes_panel.dart:37`
  Finding: `_recordStub` writes fake voice note (2000ms /tmp/voice_*.m4a).
  Fix: gate behind feature flag or use real `record` package.

- **STAB-040 [P3]** Layer=8 file=`vision_recording_screen.dart` (612 lines)
  Finding: zero `CameraException` handling.
  Fix: handle exception; show retry CTA + open-settings action.

- **STAB-041 [P3]** Layer=7 file=`community_screen.dart:425,430,594`, `environment_capture_screen.dart:176`
  Finding: `showSnackBar` with hard-coded strings.
  Fix: align with i18n plan in STAB-035.

## Layer 9 — Statistics Pipeline — Agent 4

**Score: 7/10** — services are real, well-tested for empty cases, but `MatchReviewEngine` ships English in a Vietnamese app (STAB-005) and `longestStreak` has dead code (STAB-002). No P0.

## Layer 10 — AI Integration — Agent 4

**Score: 5/10** — `AiExplainService` is a stub masquerading as a real LLM (STAB-007, P0), `DrillRecommendationV2` is dead code (STAB-010), and the `AiProgressScore` formula has a bias-corrected floor that masks decline (STAB-008).

## Layer 11 — Reports — Agent 4

**Score: 6/10** — generators exist and handle 0-data correctly, but report screens have empty-state bug (STAB-014), routes are unreachable from any UI surface (STAB-017), narratives are hardcoded Vietnamese with no i18n hook (STAB-019).

### Agent 4 findings

#### P0

- **STAB-007 [P0]** Layer=10 file=`lib/domain/services/ai_explain_service.dart:11-39`
  Finding: `AiExplainService` is hardcoded stub — summarize/explain/ask all return template strings; no LLM call, no Provider/DI swap-in.
  Why: Users see what looks like an AI response but is hardcoded text. Product-trust P0.
  Fix: (a) add visible "AI offline — coming soon" banner + rename to `AiExplainStub`, or (b) introduce abstract `AiExplainService` interface with real LLM impl behind a config flag.

#### P1

- **STAB-002 [P1]** Layer=9 file=`lib/domain/services/streak_calculator.dart:36-39`
  Finding: `longestStreak` has dead code — `..toList()` on a Set is a no-op, then `sorted` is re-sorted on line 39.
  Fix: Drop lines 36-38; keep `final sorted = dates.toList()..sort();`.

- **STAB-005 [P1]** Layer=9 file=`lib/domain/services/match_statistics_service.dart:260-340`
  Finding: `MatchReviewEngine` emits hardcoded English strings ("Win rate is strong", "No break-and-runs — extend run-out drills") while rest of AI surface (AiExplainService, CoachProfileAggregator, weekly/monthly) returns Vietnamese.
  Why: Localization regression in AI summary path.
  Fix: Centralize strings in `assets/i18n/vi.json` (`en.json`) and have engine call `AiExplainService.explain()`.

- **STAB-008 [P1]** Layer=10 file=`lib/domain/services/ai_progress_score_service.dart:42-54`
  Finding: Improvement axis is bias-corrected (`improvementDelta + 50`) before being multiplied by 0.2, so a -50 delta player still earns 10 points (50/100 × 0.2 = 0.1 → 10) on the floor.
  Why: AI Progress Score cannot fall below 10/100 for a declining player with 0 wins.
  Fix: Either weight raw delta (only when positive) or use `max(0, improvementDelta + 50) * 0.2`.

- **STAB-009 [P1]** Layer=10 file=`lib/domain/services/ai_progress_score_service.dart:14-20` + `ai_progress_score_card.dart:44`
  Finding: When matches empty, service returns trend='no_data' but widget falls back to 'steady' via `_data?['trend'] as String? ?? 'steady'`, masking empty state.
  Fix: Surface 'no_data' trend in widget with distinct chip color + "Chưa có dữ liệu".

- **STAB-010 [P1]** Layer=10 file=`lib/domain/services/drill_recommender_v2.dart:1-82`
  Finding: `DrillRecommendationV2` (rich signals + knowledge + PB recommender) has zero call sites in `lib/`. App uses older text-matching `DrillRecommendationService`.
  Why: Better recommender is dead code.
  Fix: Either delete (YAGNI) or wire into drill home screen.

- **STAB-014 [P1]** Layer=11 file=`lib/presentation/screens/reports/monthly_report_screen.dart:39-89`
  Finding: `MonthlyReportScreen` only differentiates loading from non-null report — never branches on `matchesPlayed == 0`. Empty-month users land in render block with all-zero KPIs.
  Fix: Mirror weekly screen's `_empty()` widget when `_report!.matchesPlayed == 0`.

- **STAB-016 [P1]** Layer=11 file=`lib/domain/services/weekly_report_generator.dart:48-58`
  Finding: Week window is `[start, end + 1 day)` with no timezone handling. DST or local clock shifts cause off-by-one boundary around midnight.
  Fix: Persist player's timezone and compute end-of-day in that zone.

- **STAB-017 [P1]** Layer=11 file=`lib/core/router/app_router.dart:366-373`
  Finding: `/reports/weekly` and `/reports/monthly` are defined but no UI surface in the app actually navigates to them (zero `weeklyReport` / `monthlyReport` references outside router).
  Why: Unreachable screens.
  Fix: Add Reports tile in `profile_screen.dart` or `home_screen.dart`.

- **STAB-019 [P1]** Layer=11 file=`lib/domain/services/monthly_report_generator.dart:127-128`
  Finding: Hardcoded Vietnamese narrative ("Tháng này bạn đã chơi...").
  Fix: Move narrative strings to `assets/i18n/vi.json`.

#### P2

- **STAB-001 [P2]** Layer=9 file=`lib/domain/services/streak_calculator.dart:20-27`
  Finding: `currentStreak()` uses `DateTime.now()` (local) with no TZ normalization; two devices in different TZs compute different streaks.
  Fix: Persist tz and compute day cursor in that zone.

- **STAB-003 [P2]** Layer=9 file=`lib/domain/services/learning_streak_service.dart:28-29`
  Finding: `markTodayRead` reads streak JSON via `jsonDecode` without try/catch; corrupt blob throws uncaught `FormatException`.
  Fix: Wrap `jsonDecode` in try/catch with fallback to `{}`.

- **STAB-004 [P2]** Layer=9 file=`lib/domain/services/match_statistics_service.dart:46-49`
  Finding: 0-rack match returns flat map (no state discriminator), so finished 0-rack match is indistinguishable from in-progress one.
  Fix: Add `state: 'in_progress' | 'completed' | 'empty'` field to returned map.

- **STAB-011 [P2]** Layer=10 file=`lib/domain/services/coach_profile_aggregator.dart:40-42`
  Finding: `recent` list uses only lower bound (no upper cap); name is misleading because matches older than `now - 30d` would have been included if `getMatchesByPlayer` ever returned archived items.
  Fix: Add explicit upper bound or rename to `inWindow`.

- **STAB-012 [P2]** Layer=10 file=`lib/domain/services/coach_profile_aggregator.dart:115-130`
  Finding: `skillScores` is unversioned `Map<String, double>` with no schema.
  Why: Renaming any axis key silently breaks panel UI.
  Fix: Introduce `SkillAxis` enum + version field in `CoachProfile`.

- **STAB-015 [P2]** Layer=11 file=`lib/domain/services/monthly_report_generator.dart:99-129`
  Finding: `monthLabel` uses `DateFormat.MMMM('vi')` but narrative string is hardcoded Vietnamese — no i18n switch.
  Fix: Extract narrative to localized resource bundle.

#### P3

- **STAB-013 [P3]** Layer=10 file=`lib/presentation/screens/knowledge/ai_explain_screen.dart:39`
  Finding: 600 ms `Future.delayed` fake latency before stubbed response.
  Fix: Remove delay or surface real "AI offline" badge.

- **STAB-006 [P3]** Layer=9 file=`lib/domain/services/decision_quality_service.dart:52`
  Finding: `s.shotType.contains('easy')` is brittle substring match.
  Fix: Use `Set<String> easyShotTypes` constant or typed enum.

- **STAB-018 [P3]** Layer=11 file=`lib/presentation/screens/reports/weekly_report_screen.dart:172-176`
  Finding: Share button is a SnackBar stub.
  Fix: Wire to `share_plus` with report summary text.

- ID: STAB-001
- Severity: P2
- Layer: 9
- File: `lib/domain/services/streak_calculator.dart:20-27`
- Finding: `currentStreak()` uses `DateTime.now()` directly (local time) with
  no timezone normalization. Two devices in different TZs will compute
  different streaks for the same `createdAt` timestamps.
- Why it matters: A user playing at 23:55 UTC vs a viewer in UTC-8 will see
  the streak roll over on a different calendar day, creating inconsistency
  between analytics and notifications.
- Fix: Pass `DateTime.now().toUtc()` then convert back to player's `TZ`
  preference (if known), or persist a `tz` setting and compute the day
  cursor in that zone.

- ID: STAB-002
- Severity: P1
- Layer: 9
- File: `lib/domain/services/streak_calculator.dart:29-52`
- Finding: `longestStreak()` does not handle duplicate dates or
  "today-in-future" timestamps; line 36 `..toList()` is dead code
  (mutation on a `Set`), and `sorted` is then re-sorted on line 39.
- Why it matters: Dead code masks intent; the `Set.toList()` cast and
  re-sort is wasted work and signals the dev was uncertain about the
  semantics. Future maintainers will not know which is canonical.
- Fix: Drop line 36-38; keep only `final sorted = dates.toList()..sort();`.

- ID: STAB-003
- Severity: P2
- Layer: 9
- File: `lib/domain/services/learning_streak_service.dart:25-48`
- Finding: `markTodayRead()` reads the existing streak via
  `LocalStorageService.prefs.getString(_kKey) ?? '{}'` and decodes it,
  but if the on-disk blob is corrupt JSON this throws an uncaught
  `FormatException`. There is no `try/catch`.
- Why it matters: One bad write from an earlier version corrupts the
  streak permanently for every subsequent call.
- Fix: Wrap the `jsonDecode` in try/catch and fall back to `{}`.

- ID: STAB-004
- Severity: P2
- Layer: 9
- File: `lib/domain/services/match_statistics_service.dart:46-49`
- Finding: `winPercent` divides by `totalRacks` (good) but if
  `getRacksByMatch()` returns an empty list for a brand-new match
  the function still proceeds and emits all-zero stats with no
  warning — `computeMatchStatistics` returns the flat map but
  the screen may render "win rate 0%" without a "no data" state.
- Why it matters: A finished 0-rack match looks identical to a fresh
  in-progress one. Downstream reports and AI review engines can't
  distinguish.
- Fix: Add a `state: 'in_progress' | 'completed' | 'empty'` discriminator
  to the returned map and have the UI render an empty state when state
  is `empty`.

- ID: STAB-005
- Severity: P1
- Layer: 9
- File: `lib/domain/services/match_statistics_service.dart:239-367` (`MatchReviewEngine`)
- Finding: `MatchReviewEngine.generateAnalysis()` has hardcoded English
  threshold strings ('Win rate is strong...', 'No break-and-runs...')
  embedded in the logic that returns to the Vietnamese-locale UI.
- Why it matters: The `AiExplainService`, `CoachProfileAggregator`, and
  both report generators all return Vietnamese narrative. Mixing English
  in `MatchReviewEngine` is a localization regression.
- Fix: Either centralize all strings into `assets/i18n/vi.json` or have
  the engine call `AiExplainService.explain()` for consistency.

- ID: STAB-006
- Severity: P3
- Layer: 9
- File: `lib/domain/services/decision_quality_service.dart:40-63`
- Finding: `s.shotType.contains('easy')` is a brittle string match; if
  shotType is `'easy_miss'` or `'easy-cut'` it fires, but `'not-easy'`
  or `'easyBank'` would also fire.
- Why it matters: Future drill taxonomy changes silently degrade grading.
- Fix: Use a `Set<String> easyShotTypes` constant or a typed enum.

## Layer 10 — AI Integration

(Agent 4)

- ID: STAB-007
- Severity: P0
- Layer: 10
- File: `lib/domain/services/ai_explain_service.dart:11-39`
- Finding: `AiExplainService` is a hardcoded stub. `summarize()` returns
  `'${title}. ${_tone}'`, `explain()` returns `'Giải thích: $title — $passage'`,
  `ask()` returns a hardcoded 'Trả lời (stub): Hãy tham khảo...' string.
  No LLM call, no swap-in interface, no `Provider` pattern, no DI hook.
- Why it matters: The AI Explain screen (`ai_explain_screen.dart`) ships
  this string to the user with a 600 ms fake delay, masquerading as a
  real AI. Users will assume the responses are generated. This is a
  product-trust P0.
- Fix: Either (a) ship with an obvious "AI is offline, coming soon"
  banner in the UI and rename to `AiExplainStub`, or (b) define a
  `abstract class AiExplainService` interface with `SummarizeProvider`,
  `LlmExplainProvider` impls, and a config flag that swaps them.

- ID: STAB-008
- Severity: P1
- Layer: 10
- File: `lib/domain/services/ai_progress_score_service.dart:42-54`
- Finding: The composite formula is hardcoded — 0.4 / 0.2 / 0.2 / 0.2 —
  and the `improvementDelta` term is pre-bias-corrected
  (`(improvementDelta + 50)`) so it ranges 0..100. The `total` is then
  `.clamp(0, 100)` which means a player with negative trend still scores
  the bias-corrected floor of 50/100 * 0.2 = 10 points.
- Why it matters: A player whose recent win rate = 0 (skillScore=0) and
  has -50% delta still earns 10 points from Improvement, masking
  decline. The "trend" string then says `'declining'` but the total
  doesn't reflect it.
- Fix: Either weight Improvement on raw delta sign (only count when
  positive), or use `(max(0, improvementDelta) + 50) * 0.2`.

- ID: STAB-009
- Severity: P1
- Layer: 10
- File: `lib/domain/services/ai_progress_score_service.dart:11-32`
- Finding: When `matches.isEmpty`, the function returns
  `{'totalScore': 0, 'breakdown': <empty>, 'trend': 'no_data'}` but
  the consumer widget (`ai_progress_score_card.dart:43`) does
  `_data?['totalScore'] as int? ?? 0` and renders a flat "0 / 100"
  card with a "steady" trend chip (because `?? 'steady'` fallback
  masks `'no_data'`).
- Why it matters: First-time users see "AI Progress Score 0/100, steady"
  which is misleading; should be "no data" copy.
- Fix: Surface the `'no_data'` trend in the widget (different chip color
  and "Chưa có dữ liệu" copy).

- ID: STAB-010
- Severity: P1
- Layer: 10
- File: `lib/domain/services/drill_recommender_v2.dart:14-77`
- Finding: `DrillRecommendationV2` is implemented but **never instantiated**
  anywhere in `lib/` (no usages found outside the file itself). The
  codebase uses the older `DrillRecommendationService` (legacy heuristic
  text-matching on weakness strings).
- Why it matters: The richer, signals+knowledge+PB-aware recommender is
  dead code; users get the dumber version.
- Fix: Either delete `DrillRecommendationV2` (YAGNI) or wire it into the
  drill home screen.

- ID: STAB-011
- Severity: P2
- Layer: 10
- File: `lib/domain/services/coach_profile_aggregator.dart:37-100`
- Finding: `generate()` uses the default 30-day window but the
  `recent` list is computed from `matches.where((m) =>
  m.createdAt.isAfter(cutoff))` — there is no upper bound, so if the
  user has matches 10 years old they'll be included since
  `isAfter(10-years-ago)` is true. Actually OK on close read but the
  variable name `recent` is misleading.
- Why it matters: Cosmetic — but if a future change swaps `getMatchesByPlayer`
  to include archived matches, the aggregator silently includes them.
- Fix: Add an explicit upper bound or rename `recent` to `inWindow`.

- ID: STAB-012
- Severity: P2
- Layer: 10
- File: `lib/domain/services/coach_profile_aggregator.dart:115-130`
- Finding: `_score()` returns a `Map<String, double>` with five keys
  (`Cutting`, `Break & Run`, `Safety`, `Specialty`, `Discipline`)
  but `skillScores` are written to JSON later by the panel widget
  using `entries.map` — there's no schema/version field, so renaming
  any key breaks UI silently.
- Why it matters: No contract = silent breakage.
- Fix: Introduce `enum SkillAxis { cutting, breakAndRun, ... }` and a
  `version: 1` field in `CoachProfile`.

- ID: STAB-013
- Severity: P3
- Layer: 10
- File: `lib/presentation/screens/knowledge/ai_explain_screen.dart:39-46`
- Finding: The "AI response" is preceded by a 600 ms `Future.delayed`
  to mimic latency — the user sees a fake spinner / progress bar.
- Why it matters: Misleading UX; combined with STAB-007 this is a
  product-trust issue.
- Fix: Remove the fake delay or surface a real "AI offline" badge.

## Layer 11 — Reports

(Agent 4)

- ID: STAB-014
- Severity: P1
- Layer: 11
- File: `lib/presentation/screens/reports/monthly_report_screen.dart:39-89`
- Finding: The monthly screen only differentiates loading from a
  non-null report — it never checks `matchesPlayed == 0` or
  `narrative.isEmpty`, so a fresh user lands on a "No data." text and
  then the report rendering block runs with all-zero KPIs. The empty
  state branch is wrong: line 45 shows `Center(Text('No data.'))`
  but only when `_report == null`, not when matches is 0.
- Why it matters: Empty-month experience is "report" with 0/0/0
  numbers, not the friendly "Chưa có trận đấu" empty state used in
  weekly.
- Fix: Mirror the weekly screen's `_empty()` widget when
  `_report!.matchesPlayed == 0`.

- ID: STAB-015
- Severity: P2
- Layer: 11
- File: `lib/domain/services/monthly_report_generator.dart:99-129`
- Finding: `monthLabel()` uses `DateFormat.MMMM('vi')` (Vietnamese)
  for the calendar label, but the inline narrative returned by
  `_composeNarrative()` is also Vietnamese — yet the file mixes
  English identifiers (`matches`, `wins`, `breakAndRun`, `runOuts`)
  for the numeric fields and Vietnamese narrative for prose. There is
  no i18n switch.
- Why it matters: Hardcoded to one locale; future i18n will require
  touching every narrative.
- Fix: Extract narrative to a `Map<String, String>` keyed by locale
  in the assets.

- ID: STAB-016
- Severity: P2
- Layer: 11
- File: `lib/domain/services/weekly_report_generator.dart:48-58`
- Finding: The week window is computed as `[start, end + 1 day)`. On a
  long-running app where the user's local clock shifts (DST, travel,
  manual time change) the "end + 1 day" is computed against
  `DateTime.now()` which means yesterday's matches may bleed into the
  current week at the boundary. No timezone handling.
- Why it matters: Off-by-one boundary around midnight UTC.
- Fix: Use the player's stored `tz` and compute end-of-day locally.

- ID: STAB-017
- Severity: P1
- Layer: 11
- File: `lib/core/router/app_router.dart:366-373` and `lib/presentation/screens/`
- Finding: Both `/reports/weekly` and `/reports/monthly` routes are
  defined but no UI surface in the app actually navigates to them
  (verified: zero `weeklyReport` / `monthlyReport` references outside
  the router). They are unreachable from the user flow.
- Why it matters: Dead routes — the work to build them is invisible
  to users.
- Fix: Add a tile in `profile_screen.dart` or `home_screen.dart` that
  pushes to `/reports/weekly` and `/reports/monthly`.

- ID: STAB-018
- Severity: P3
- Layer: 11
- File: `lib/presentation/screens/reports/weekly_report_screen.dart:172-176`
- Finding: Share button is a stub (`SnackBar('Share sheet opened (stub)')`).
- Why it matters: Minor — but if a P0 ships a sharing flow, this needs
  the same impl.
- Fix: Wire to `share_plus` with the report summary text.

- ID: STAB-019
- Severity: P1
- Layer: 11
- File: `lib/domain/services/monthly_report_generator.dart:78-80`
- Finding: `_composeNarrative()` is hardcoded Vietnamese ("Chưa có trận
  đấu nào trong tháng.", "Tháng này bạn đã chơi..."). When the player
  is on English locale (no current toggle, but planned) this is
  silently wrong.
- Why it matters: i18n blocker.
- Fix: Move narrative strings to a localized resource bundle.

## Layer 12 — Security (×2)

(Agent 5)

## Layer 12 — Security (weighted ×2) — Agent 5

**Score: 5/10** — no secrets in `.gitignore`, no hardcoded real keys (only placeholder strings); BUT two parallel Supabase config files, RLS policies partial, no secure storage, TODO comment left in source.

### Agent 5 findings

#### P0

- **STAB-001 [P0]** Layer=12 file=`lib/core/constants/supabase_config.dart:6-7`
  Finding: Hardcoded placeholder Supabase URL `https://your-project.supabase.co` + anon key as `static const`.
  Why: Sets the pattern of credentials-in-source tree; URL is environment-specific and must not ship baked.
  Fix: Replace with `String.fromEnvironment('SUPABASE_URL', defaultValue: '')` + `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` in CI.

- **STAB-002 [P0]** Layer=12 file=`lib/main.dart:14-15`
  Finding: `LocalStorageDataSource.clearAllData()` runs unconditionally on every cold start.
  Why: Wipes returning users' state on every launch. Forces re-onboarding even for signed-in users.
  Fix: Gate via `if (await LocalStorageDataSource.isFirstLaunch()) { await LocalStorageDataSource.clearAllData(); }`.

- **STAB-003 [P0]** Layer=14 file=`pubspec.yaml:54-58`
  Finding: `assets/knowledge/` referenced by `lib/knowledge/knowledge_service.dart:40,54,68,82` and `lib/domain/services/knowledge_graph_service.dart:18` but **NOT listed under `flutter.assets:`**. `assets/knowledge/drill_mapping.json` does NOT exist on disk.
  Why: `rootBundle.loadString('assets/knowledge/knowledge.json')` throws in release builds; try/catch swallows, every knowledge search returns empty.
  Fix: Add `- assets/knowledge/` to `flutter.assets:`; commit missing `drill_mapping.json` (or delete call site). Rebuild + `flutter pub get`.

- **STAB-004 [P0]** Layer=12 file=`lib/supabase.dart:1-16`
  Finding: Two competing Supabase config files (`lib/supabase.dart` and `lib/core/constants/supabase_config.dart`) with placeholder creds and different `initialize()` implementations. `lib/main.dart` never calls `SupabaseConfig.initialize()`.
  Why: Drift between 3 config points. `Supabase.instance.client` calls will hit `AssertionError: Supabase not initialized`.
  Fix: Delete `lib/supabase.dart` and `lib/core/constants/supabase_config.dart`. Keep one file reading from `--dart-define`. Call `SupabaseConfig.initialize()` between `ensureInitialized()` and `runApp()`.

#### P1

- **STAB-005 [P1]** Layer=13 file=`lib/presentation/screens/profile/equipment_detail_screen.dart:460-461`
  Finding: 2 `TextEditingController`s inside `_showAddMaintenanceDialog` never disposed.
  Why: Each dialog open leaks 2 controllers; accumulates over a long session.
  Fix: Wrap dialog body in `StatefulWidget` with proper `dispose()`.

- **STAB-006 [P1]** Layer=13 file=`lib/domain/services/drill_library_service.dart:25-35,56-66`
  Finding: `all()` decodes entire `assets/data/drills_data.json` on every call; `search()` does 4-field linear scan. `byCode/byTier/byTag` each call `all()` first → JSON decoded 3-4× per filter screen.
  Fix: Build `Map<String, DrillAxes>` index by code at first `load()`. Pre-compute tokenized lowercase haystacks.

- **STAB-007 [P1]** Layer=12 file=`pubspec.yaml:31-33` + `lib/data/datasources/local/local_storage_datasource.dart:1-333`
  Finding: All persistence uses `shared_preferences` (plaintext XML/NSUserDefaults), including Supabase auth tokens and player PII. No `flutter_secure_storage`.
  Fix: Add `flutter_secure_storage: ^9.x`. Create `lib/core/security/secure_storage.dart`. Use for `_keyPlayer`, `_keySettings`, JWT. Keep SharedPreferences for non-sensitive caches.

- **STAB-008 [P1]** Layer=12 file=`supabase/migrations/001_initial_schema.sql:494-619`
  Finding: 13 tables (`player_events`, `matches`, `racks`, `shots`, etc.) have only `SELECT` or `FOR ALL` policies — no dedicated `INSERT`/`UPDATE`/`DELETE` for owning user. `racks`/`shots` define `SELECT` + `INSERT` only — no `UPDATE`/`DELETE`.
  Why: `updateMatch`, `updateRack`, `deleteShot` will silently get zero rows-affected.
  Fix: Add explicit `INSERT WITH CHECK`, `UPDATE USING WITH CHECK`, `DELETE USING` policies mirroring SELECT clause.

#### P2

- **STAB-009 [P2]** Layer=13 file=`lib/main.dart:11-15`
  Finding: `init()` + `clearAllData()` awaited sequentially before `runApp`. No `Future.wait`. Long-term: switch to `IsolateNameServer` for asset parsing.
  Fix: Move `clearAllData()` to `addPostFrameCallback`.

- **STAB-010 [P2]** Layer=14 file=`lib/data/repositories/match_repository.dart:21-249`
  Finding: 19-method abstract + 19-method concrete in same file = 38 signatures. "God repository" does matches/racks/player state/equipment/timeline/analysis.
  Fix: Split into `MatchRepository`, `RackRepository`, `MatchTimelineRepository`, `MatchAnalysisRepository`.

- **STAB-011 [P2]** Layer=14 file=`lib/presentation/screens/home/home_screen.dart:1-1268`
  Finding: Single 1268-line home file.
  Fix: Extract into `home_dashboard_widget.dart`, `home_quick_actions.dart`, `home_recommendations_panel.dart`, `home_progress_summary.dart`. Target < 400 lines.

- **STAB-012 [P2]** Layer=14 file=`lib/data/repositories/{drill_progress_repository, drill_session_repository, match_repository, personal_best_repository}.dart`
  Finding: `_readAll/_writeAll()` SharedPreferences JSON-encode/decode duplicated across 4 repositories (16 occurrences).
  Fix: Extract `lib/data/repositories/local_json_store.dart` with generic `readAll<T>(String key, T fromJson)` / `writeAll<T>(String key, List<T>, Map Function(T))`.

- **STAB-013 [P2]** Layer=14 file=`equipment_detail_screen.dart:453`, `tournament_detail_screen.dart:257`, `tournament_list_screen.dart:293`, `equipment_edit_screen.dart:593`
  Finding: `_formatDate(DateTime?)` reimplemented 4 times.
  Fix: Move to `lib/core/utils/date_formatter.dart`.

#### P3

- **STAB-014 [P3]** Layer=14 file=`lib/supabase.dart:5`: `// TODO: Replace with your actual Supabase credentials` left in source.

- **STAB-015 [P3]** Layer=14 file=`assets/icons/`, `assets/images/`: only `.gitkeep` placeholders, declared in pubspec.

- **STAB-016 [P3]** Layer=14 file=`knowledge_screen.dart:117`, `quiz_screen.dart`, `match_history_screen.dart`
  Finding: Per-item `.animate().fadeIn(delay: (index * 50).ms)` causes staggered entrance. Long delays (~50 items → 2.5 s) drop frames during scroll.
  Fix: Apply single fade-in to list container; use `flutter_animate` only on first 6 items.

---

## Layer 13 — Performance — Agent 5

**Score: 6/10** — lists use `.builder` (good), zero raw Streams, zero `print` leaks. BUT 2 undisposed controllers, sequential init chain, linear drill/knowledge search, per-item staggered animations.

### Headline KPIs (all currently unmeasured)

| KPI | Target | Measured |
|-----|--------|----------|
| Cold start | < 2 s | tbd |
| Warm start | < 1 s | tbd |
| Search 300 drills | < 100 ms | tbd (linear scan today) |
| Search 900 knowledge | < 150 ms | tbd (linear scan + asset path bug) |
| Memory after 30 min | < 250 MB | tbd (2 controller leaks per dialog open) |
| Frame drops on long lists | 0 | tbd (per-item stagger likely culprit) |

---

## Layer 14 — Maintainability — Agent 5

**Score: 5/10** — 24 files > 500 lines (top: home 1268, equipment 954), 33 screens > 300 lines, 1 god repository, 16 duplicate `_readAll/_writeAll`, 4 duplicate `_formatDate`, 4 TODO comments, 2 unused asset dirs, 1 missing asset dir.

| Threshold | Count |
|-----------|-------|
| Files > 500 lines | 24 (top 5: home 1268, equipment 954, onboarding 835, match_recording 736, community 712) |
| Screens > 300 lines | 33 |
| Services > 20 public methods | 1 (`match_repository.dart`) |
| TODO/FIXME | 4 (3 in code, 1 in `lib/supabase.dart`) |
| Unused assets | 2 dirs (`assets/icons/`, `assets/images/` — only `.gitkeep`) |
| Missing referenced assets | 1 (`assets/knowledge/drill_mapping.json` + `assets/knowledge/` not in pubspec) |
| Duplicate code clusters | 3 (`_readAll/_writeAll` × 16, `_formatDate` × 4, `_buildEmptyState` × 4) |