import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../data/repositories/cache_repository.dart';
import '../../data/models/drill.dart';

/// Phase B: in-app drill library with offline-first caching.
///
/// Day 2A: now depends on [ICacheRepository] (injected by callers via
/// `ref.read(cacheRepositoryProvider)`). Does NOT import LocalStorageService.
class DrillLibraryService {
  DrillLibraryService(this._cache);
  final ICacheRepository _cache;
  static const _kCacheKey = 'poolos_v2.drill_library_cache';
  static const _kIndexKey = 'poolos_v2.drill_library_index';

  Future<void> load() async {
    final cached = _cache.getString(_kCacheKey);
    if (cached != null && cached.isNotEmpty) return;
    try {
      final raw = await rootBundle.loadString('assets/data/drills_data.json');
      await _cache.setString(_kCacheKey, raw);
    } catch (_) {
      // Asset may be unavailable in some test contexts; tolerate.
    }
  }

  Future<List<DrillAxes>> all() async {
    final raw = _cache.getString(_kCacheKey);
    if (raw == null || raw.isEmpty) {
      await load();
    }
    final s = _cache.getString(_kCacheKey);
    if (s == null || s.isEmpty) return [];
    final json = jsonDecode(s) as Map<String, dynamic>;
    final list = (json['drills'] as List).cast<Map<String, dynamic>>();
    return list.map(DrillAxes.fromJson).toList();
  }

  Future<DrillAxes?> byCode(String code) async {
    final drills = await all();
    try {
      return drills.firstWhere((d) => d.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<List<DrillAxes>> byTier(DrillTier tier) async {
    final drills = await all();
    return drills.where((d) => d.tier == tier).toList();
  }

  Future<List<DrillAxes>> byTag(String tag) async {
    final drills = await all();
    return drills.where((d) => d.tags.contains(tag)).toList();
  }

  Future<List<DrillAxes>> search(String query) async {
    final drills = await all();
    final q = query.toLowerCase();
    return drills
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.nameVi.toLowerCase().contains(q) ||
            d.code.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q))
        .toList();
  }

  /// One drill per day, deterministic by date so the user sees the same
  /// drill for the whole day.
  Future<DrillAxes> daily() async {
    final drills = await all();
    if (drills.isEmpty) {
      throw StateError('Drill library is empty.');
    }
    final today = DateTime.now();
    final seed = today.year * 1000 + today.month * 50 + today.day;
    final idx = seed % drills.length;
    return drills[idx];
  }

  int count() {
    final raw = _cache.getString(_kCacheKey);
    if (raw == null || raw.isEmpty) return 0;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['drills'] as List).length;
  }
}