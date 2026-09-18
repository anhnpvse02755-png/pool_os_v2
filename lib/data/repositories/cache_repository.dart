// ============================================================================
// Cache Repository — single entry-point for arbitrary string caches
// ============================================================================
//
// Used by domain services that need to cache parsed assets (drills,
// knowledge, etc.) without reaching into SharedPreferences directly.
//
// Boundary rule (Day 2A — Repository Dependency Enforcement):
//   * Services MUST go through this repository, NOT LocalStorageDataSource.
//   * UI MUST go through providers (riverpod).
//
// This is intentionally thin — it does NOT enforce schema validation,
// versioning, or business rules. Cache callers are expected to handle
// decode failures and key collisions themselves.
// ============================================================================

import '../datasources/local/local_storage_datasource.dart';

abstract class ICacheRepository {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Set<String> getKeys();

  /// Returns the persisted knowledge progress map (article slug → progress).
  /// Day 2A: previously read directly from `LocalStorageService.getKnowledgeProgress`.
  Future<Map<String, dynamic>> getKnowledgeProgress();

  /// Đánh dấu một bài kiến thức là đã đọc. `title` để màn Profile hiện được
  /// tên bài thay vì id thô.
  Future<void> markKnowledgeAsRead(String id, {String? title});
}

/// Local SharedPreferences-backed implementation. Delegates to the
/// [LocalStorageDataSource] static layer without exposing it to
/// callers — keeps the boundary closed.
class LocalCacheRepository implements ICacheRepository {
  @override
  String? getString(String key) => LocalStorageDataSource.prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      LocalStorageDataSource.prefs.setString(key, value);

  @override
  Set<String> getKeys() => LocalStorageDataSource.prefs.getKeys();

  @override
  Future<Map<String, dynamic>> getKnowledgeProgress() =>
      LocalStorageDataSource.getKnowledgeProgress();

  @override
  Future<void> markKnowledgeAsRead(String id, {String? title}) =>
      LocalStorageDataSource.markKnowledgeAsRead(id, title: title);
}