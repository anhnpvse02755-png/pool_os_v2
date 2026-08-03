// ============================================================================
// Cache Repository — single entry-point for arbitrary string caches
// ============================================================================
//
// Used by domain services that need to cache parsed assets (drills,
// knowledge, etc.) without reaching into SharedPreferences directly.
//
// Boundary rule (Day 2A — Repository Dependency Enforcement):
//   * Services MUST go through this repository, NOT LocalStorageService.
//   * UI MUST go through providers (riverpod).
//
// This is intentionally thin — it does NOT enforce schema validation,
// versioning, or business rules. Cache callers are expected to handle
// decode failures and key collisions themselves.
// ============================================================================

import '../../core/services/local_storage_service.dart';

abstract class ICacheRepository {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Set<String> getKeys();

  /// Returns the persisted knowledge progress map (article slug → progress).
  /// Day 2A: previously read directly from `LocalStorageService.getKnowledgeProgress`.
  Future<Map<String, dynamic>> getKnowledgeProgress();
}

/// Local SharedPreferences-backed implementation. Delegates to the
/// existing [LocalStorageService] static layer without exposing it to
/// callers — keeps the boundary closed.
class LocalCacheRepository implements ICacheRepository {
  @override
  String? getString(String key) => LocalStorageService.prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      LocalStorageService.prefs.setString(key, value);

  @override
  Set<String> getKeys() => LocalStorageService.prefs.getKeys();

  @override
  Future<Map<String, dynamic>> getKnowledgeProgress() =>
      LocalStorageService.getKnowledgeProgress();
}