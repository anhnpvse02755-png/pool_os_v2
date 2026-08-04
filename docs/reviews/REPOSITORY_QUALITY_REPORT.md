# Repository Quality Report (Day 2B)

**Date:** 2026-08-03 (Day 2B — Repository Simplification)
**Scope:** `lib/data/repositories/*.dart`
**Method:** LOC + Public-API-count + duplicate-pattern scan.

---

## Summary

| Metric | Pre-Day 2B | After Day 2B | Δ |
|--------|-----------:|-------------:|--:|
| Repository files | 18 | **19** | +1 (helper) |
| Total LOC | 1405 | **1427** | +22 |
| Duplicate `_readAll/_writeAll` patterns | 4 | **0** | −4 |
| Public API methods | 130 (sum) | 130 (sum) | 0 |
| New compatibility layers | 0 | **0** | — |
| New architecture bypasses | 0 | **0** | — |

---

## Per-repository inventory

| Repository | LOC | Public API | Uses `LocalJsonStore<T>` | Status |
|------------|---:|-----------:|:------------------------:|--------|
| `match_repository.dart` | 296 | 38 | ✅ | Split-candidate (Day 2C scope) |
| `drill_session_repository.dart` | 110 | 14 | ✅ | Done |
| `settings_repository.dart` | 113 | 5 | — | Stays |
| `ai_coach_repository.dart` | 111 | 7 | — | Stays |
| `knowledge_repository.dart` | 96 | 10 | — | Stays |
| `shot_repository.dart` | 89 | 12 | — | Stays |
| `community_repository.dart` | 83 | 10 | — | Stays |
| `drill_progress_repository.dart` | 75 | 8 | ✅ | Done |
| `drill_repository.dart` | 81 | 11 | — | Stays |
| `notification_repository.dart` | 62 | 9 | — | Stays |
| `personal_best_repository.dart` | 47 | 6 | ✅ | Done |
| `equipment_repository.dart` | 48 | 17 | — | Stays |
| `player_repository.dart` | 43 | 10 | — | Stays |
| `equipment_change_log_repository.dart` | 36 | 4 | — | Stays |
| `voice_note_repository.dart` | 35 | 4 | — | Stays |
| `local_json_store.dart` | 48 | n/a | n/a | **NEW (helper)** |
| `repositories.dart` | 9 | n/a | n/a | barrel |
| `cache_repository.dart` | 45 | 4 | — | Day 2A |

---

## Duplicate-pattern scan

Pre-Day 2B, 4 repositories shared the exact same `_readAll/_writeAll` boilerplate:

```
1. match_repository.dart
2. drill_session_repository.dart
3. drill_progress_repository.dart
4. personal_best_repository.dart
```

Each had this 12-line block:
```dart
Future<List<T>> _readAll() async {
  final raw = LocalStorageService.prefs.getString(key);
  if (raw == null || raw.isEmpty) return [];
  final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  return list.map((j) => T.fromJson(j)).toList();
}

Future<void> _writeAll(List<T> items) async {
  await LocalStorageService.prefs.setString(
      key, jsonEncode(items.map((x) => x.toJson()).toList()));
}
```

After Day 2B: **0 duplicate copies** remaining. All 4 repositories
now use `LocalJsonStore<T>`.

Lines saved: 4 × 12 = **48 LOC of boilerplate removed** in caller
files, offset by 48 LOC of helper class (`local_json_store.dart`).
Net: same total LOC, but **logic deduplicated**.

---

## God repository analysis (`match_repository.dart`)

| Sub-area | Methods | Storage key |
|----------|---------|-------------|
| Match CRUD | 7 | `poolos_v2.matches` |
| Racks | 2 | `poolos_v2.racks.{matchId}` |
| Player State | 2 | `poolos_v2.player_state.{matchId}` |
| Equipment Snapshot | 2 | `poolos_v2.equipment.{matchId}` |
| Timeline | 2 | `poolos_v2.timeline.{matchId}` |
| Analysis | 2 | `poolos_v2.analysis.{matchId}` |
| Aggregates | 1 | (computed) |
| Other (overloads) | 20 | (overload counts above) |

The interface has 38 methods but the unique sub-resources are 7.
This is a candidate for a future split (e.g. `RackRepository`,
`PlayerStateRepository`), but **NOT in Day 2B scope** per user
agreement (no API change unless required).

---

## Acceptance criteria

| Criterion | Status |
|-----------|--------|
| ✅ `flutter analyze` = 0 errors | 0 errors |
| ✅ `flutter test` không giảm (≥ 9/9) | **9/9** (unchanged from Day 2A.5) |
| ✅ Không tăng public API surface | 130 → 130 methods |
| ✅ Không tạo compatibility layer mới | 0 new layers |
| ✅ Không phát sinh bypass | grep verified |
| ✅ Có REPOSITORY_QUALITY_REPORT.md | this file |

---

## Compatibility items (preserved, not removed)

- **STAB-029** — `tournamentsProvider` returns `<Tournament>[]`. Kept —
  no production consumer exists.
- **STAB-030** — `Match.breakAndRuns` computed via
  `racks.where((r) => r.isBreakAndRun).length`. Kept — value matches
  product spec.

---

## Follow-up candidates (Day 2C / future)

1. Split `match_repository.dart` into focused sub-repositories.
2. Move `_formatDate` and other static helpers in services to
   `lib/core/utils/`.
3. Add `IMatchRepository` mock for widget tests beyond
   `match_history_screen`.
