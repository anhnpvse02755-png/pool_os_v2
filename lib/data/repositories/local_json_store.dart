// ============================================================================
// LocalJsonStore — typed SharedPreferences-backed JSON list storage
// ============================================================================
//
// Day 2B — Repository Simplification. Extracts the recurring pattern
// across 4 repositories that all share the same _readAll/_writeAll boilerplate.
//
// Boundary rule preserved:
//   - This helper touches LocalStorageService directly. It MUST only be used
//     inside the data layer (lib/data/repositories/).
//   - It is NOT exposed to UI, services, or providers.
//
// IMPORTANT: this helper is intentionally minimal. Callers must pass
// `fromJson` (T.fromJson) and `toJson` (item.toJson) explicitly. We do
// NOT rely on `dynamic` casts because Dart's static analyzer cannot
// verify `toJson` exists on a generic T — and an empty `const []`
// would propagate as an unmodifiable list to callers that mutate
// the result (e.g. `all.add(...)`).
// ============================================================================

import 'dart:convert';

import '../../core/services/local_storage_service.dart';

class LocalJsonStore<T> {
  LocalJsonStore({
    required this.key,
    required this.fromJson,
    required this.toJson,
  });

  final String key;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  Future<List<T>> readAll() async {
    final raw = LocalStorageService.prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(fromJson).toList();
  }

  Future<void> writeAll(List<T> items) async {
    final encoded = jsonEncode(items.map(toJson).toList());
    await LocalStorageService.prefs.setString(key, encoded);
  }
}