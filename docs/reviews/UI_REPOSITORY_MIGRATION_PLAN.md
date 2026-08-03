# UI → Repository Migration Plan (Day 2A.5)

**Created:** Day 2A (deferred scope)
**Status:** Pending — gated by widget tests
**Tracked as:** STAB-031, STAB-032

---

## Purpose

Day 2A (Repository Boundary) closed Service → LocalStorageService bypasses
through the new `ICacheRepository` boundary. The remaining P0 architecture
bypass is **UI → Repository instance** — UI files call `LocalMatchRepository()`
directly instead of `ref.read(matchRepositoryProvider)`.

This document tracks that pending migration. It is intentionally not
acted on in Day 2A because:

1. 10 files × 15 call sites = 30–50 edits.
2. No widget tests cover these screens.
3. Refactoring without tests risks breaking subtle UI behavior.

---

## Migration rules

**Before** (P0 bypass):
```dart
final repo = LocalMatchRepository();
await repo.getAllMatches();
```

**After** (provider injection):
```dart
final repo = ProviderScope.containerOf(context, listen: false)
    .read(matchRepositoryProvider);
await repo.getAllMatches();
```

For `StatefulWidget` with local `_repo` field, convert to `ConsumerStatefulWidget`:
```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  // _repo is gone; use `ref.read(matchRepositoryProvider)` directly.
}
```

---

## Migration inventory (10 files × 15 sites)

| # | File | Sites | Service | Widget Test |
|---|------|------:|---------|-------------|
| 1 | `lib/presentation/screens/play/match_history_screen.dart` | 2 | LocalMatchRepository | ❌ Missing |
| 2 | `lib/presentation/screens/play/match_recording_screen.dart` | 4 | LocalMatchRepository | ❌ Missing |
| 3 | `lib/presentation/screens/play/match_summary_screen.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 4 | `lib/presentation/screens/profile/player_state_screen.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 5 | `lib/presentation/screens/reports/monthly_report_screen.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 6 | `lib/presentation/screens/reports/weekly_report_screen.dart` | 2 | LocalMatchRepository | ❌ Missing |
| 7 | `lib/presentation/widgets/ai_progress_score_card.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 8 | `lib/presentation/widgets/coach_profile_panel.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 9 | `lib/presentation/widgets/skill_trend_chart.dart` | 1 | LocalMatchRepository | ❌ Missing |
| 10 | `lib/presentation/widgets/streak_widget.dart` | 1 | LocalMatchRepository | ❌ Missing |

**Total:** 15 sites across 10 files.

---

## Widget test coverage gap

The current `test/widget_test.dart` is a smoke test of the root app.
No widget-level tests cover these 10 screens. Day 2A.5 must write
tests BEFORE the migration to provide a safety net:

### Required widget tests (10 tests minimum)

For each of the 10 files above, write at minimum:
1. `pumpWidget(MyScreen(...))` with `ProviderScope` overriding
   `matchRepositoryProvider` with a fake/mock.
2. Verify the screen renders without throwing.
3. Verify load button / init action triggers provider read.
4. Verify navigation (if applicable).

A simple shared mock repository can live in
`test/helpers/fake_match_repository.dart`.

---

## Day 2A.5 workflow

Per user agreement:

1. **Write widget tests** for all 10 screens.
   - Run tests; confirm they fail or pass as baseline.
2. **Refactor** `LocalMatchRepository()` → `ProviderScope...read(...)`.
   - One file at a time; run widget test after each.
3. **Regression**:
   - `flutter analyze` = 0 errors.
   - `flutter test` = all pass.
   - Playwright smoke (web only).
4. **Commit**:
   ```
   stabilization(day2a.5): migrate UI to repository providers
   ```

---

## Acceptance criteria for Day 2A.5

- ✅ Widget tests written for all 10 screens (≥ 10 test cases).
- ✅ Zero `LocalMatchRepository()` instances remaining in `lib/presentation/`.
- ✅ Zero `LocalKnowledgeRepository()`, `LocalDrillRepository()`, etc.
  directly instantiated in UI (audit grep).
- ✅ `flutter analyze` = 0 errors.
- ✅ `flutter test` = 7 pass (Day 1 baseline) + ≥ 10 widget tests = ≥ 17 pass.
- ✅ Existing 2 logic regressions still open (deferred to Day 2C).

---

## Completion tracking

When all acceptance criteria pass, this document is deleted in the
commit that closes Day 2A.5. The final commit message should reference
"closes UI_REPOSITORY_MIGRATION_PLAN.md".

---

## See also

- `POOL_OS_V2_STABILIZATION_SCORECARD.md` — overall status.
- `EXECUTIVE_SUMMARY.md` — PO rollup.
- `ARCHITECTURE_VIOLATIONS.md` — full bypass catalog.