# Pool OS V2 — Architecture Violations

**Date:** 2026-08-03
**Source:** Agent 2 audit (Repository + Services + Persistence layers)
**Status:** populated for Layers 4/5/6

---

## What counts as a violation

A violation is **any code path that bypasses the repository layer**
to talk to persistence / network / external state directly. The
architecture rule is:

```
UI  →  Provider (Riverpod)  →  Service  →  Repository (interface)
                                              ↓
                                          Local impl  +  Supabase impl
                                              ↓
                                          SharedPreferences / Drift / Supabase
```

Any code that goes **UI → SharedPreferences** directly (no repository
in between) is a violation. Same for `UI → supabase.from(...)`.

---

## Catalog

### V1 — direct SharedPreferences access from UI / Provider

| File:line | Call | Notes |
|-----------|------|-------|
| `lib/presentation/screens/profile/knowledge_progress_section.dart:26` | `LocalStorageService.getKnowledgeProgress()` | Stateful UI widget reads persistence directly. |
| `lib/core/providers/training_provider.dart:91` | `LocalStorageService.getDrillSessions()` | Provider owns persistence instead of consuming repo. |
| `lib/core/providers/training_provider.dart:101` | `LocalStorageService.saveDrillSession(...)` | Provider writes persistence directly. |
| `lib/core/providers/training_provider.dart:110` | `LocalStorageService.updateDrillSession(...)` | Same. |
| `lib/core/providers/training_provider.dart:122` | `LocalStorageService.deleteDrillSession(...)` | Same. |

No raw `SharedPreferences.getInstance()` calls from presentation code.
All direct access goes through the static `LocalStorageService` /
`LocalStorageDataSource`.

---

### V2 — direct LocalStorageService (static) from domain services

Domain services also bypass repository and use the static helper
directly. This violates the architecture even though it's not "UI".

| File:line | Call | Notes |
|-----------|------|-------|
| `lib/domain/services/drill_library_service.dart:15,19,26,30,82` | `LocalStorageService.prefs.getString/setString(...)` | Drill cache persisted directly. |
| `lib/domain/services/knowledge_graph_service.dart:15,19,25` | `LocalStorageService.prefs.getString/setString(...)` | Knowledge graph cache. |
| `lib/domain/services/learning_streak_service.dart:13,19,27,29,44,46,51,54` | `LocalStorageService.prefs.getString/setString(...)` | Streak persistence, individual writes. |
| `lib/domain/services/spaced_repetition_service.dart:14,30,40,50` | `LocalStorageService.prefs.getString/setString(...)` | Flashcard + review state. |
| `lib/domain/services/quiz_service.dart:13,38,61,66,71` | `LocalStorageService.prefs.getString/setString(...)` | Quiz + attempt persistence. |

---

### V2b — legacy repository implementations using the old `LocalStorageService`

These are technically *behind* the repository abstraction, but they
still bind to the legacy static helper instead of the new datasource.

| File:line |
|-----------|
| `lib/data/repositories/match_repository.dart:3,8,54,66,74,127-131,146,151,161,169,179,187,206,219,227` |
| `lib/data/repositories/drill_session_repository.dart:3,21,28,35,41,46,78-81,90,95,100` |
| `lib/data/repositories/drill_progress_repository.dart:3,20,25,32,71` |
| `lib/data/repositories/shot_repository.dart:3,19,24,32,44,69-76` |
| `lib/data/repositories/personal_best_repository.dart:3,14,18,25` |
| `lib/data/impl/.../equipment_change_log_repository.dart:3,14,19,31,36` |
| `lib/data/repositories/voice_note_repository.dart:3,13,18,30` |

---

### V3 — direct Supabase client from Providers / core services

| File:line | Call | Notes |
|-----------|------|-------|
| `lib/core/providers/auth_provider.dart:8` | `Supabase.instance.client` | Provider obtains global singleton directly. |
| `lib/data/datasources/supabase_service.dart:19,48-52,74-78,84-87,95-100,128-132,162-166,172-175,195-199,205-208,233-237,249-254,267-270,275-283` | Supabase table access in general-purpose service | Should be repository implementations. |
| `lib/core/services/training_service.dart:13,29,44,56,67,88,112,130,141,169,182,194,240,267,287` | Direct table ops | Service layer bypasses repo. |
| `lib/core/services/player_service.dart:19,34,47,59,71,87,95,106` | Direct table ops | Same. |

No presentation screen directly calls `Supabase.instance.client` or `.from(...)`.

---

### V4 — Riverpod providers holding static helpers

| File:line | Notes |
|-----------|-------|
| `lib/core/providers/training_provider.dart:7,84,91-122` | `TrainingNotifier` imports and uses static `LocalStorageService`; no repository injected. |
| `lib/core/providers/auth_provider.dart:8` | Uses global `Supabase.instance.client` rather than injected auth repo/service. |
| `lib/core/providers/repository_providers.dart:31-65` | Providers instantiate only local repos directly; no env-based local/Supabase selection. Repository abstraction is local-only at runtime. |

---

## Why this matters

- Every bypass is a place where offline-first is silently broken.
- Every bypass is a place where Phase D (cloud sync) becomes
  impossible without a rewrite.
- Every bypass is a place where Supabase-row-level-security can't
  be enforced.

---

## Fix pattern

```dart
// BEFORE (violation)
final prefs = await SharedPreferences.getInstance();
prefs.setString('foo', 'bar');

// AFTER
class FooRepository {
  Future<void> save(String value) => _local.save(key: 'foo', value: value);
}
```

Add an `IFooRepository` interface, a `LocalFooRepository` impl, and a
`RemoteFooRepository` impl. Riverpod provider chooses between them.

---

## See also

- `STABILIZATION_AUDIT_DETAIL.md` — Layer 4 / 5 / 6 findings.
- `POOL_OS_V2_STABILIZATION_SCORECARD.md` — overall scoring.