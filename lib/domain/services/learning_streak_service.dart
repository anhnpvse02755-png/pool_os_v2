import 'dart:convert';

import '../../data/repositories/cache_repository.dart';

/// Phase B: Daily learning service — picks one article per day, tracks
/// learning streak.
class LearningStreakService {
  LearningStreakService(this._cache);
  final ICacheRepository _cache;
  static const _kKey = 'poolos_v2.learning_streak';
  static const _kLastArticleKey = 'poolos_v2.learning_last_article';
  static const _kLastDateKey = 'poolos_v2.learning_last_date';

  int currentStreak() {
    final raw = _cache.getString(_kKey);
    if (raw == null || raw.isEmpty) return 0;
    return jsonDecode(raw)['streak'] as int? ?? 0;
  }

  int longestStreak() {
    final raw = _cache.getString(_kKey);
    if (raw == null || raw.isEmpty) return 0;
    return jsonDecode(raw)['longest'] as int? ?? 0;
  }

  /// Mark "I read today". Returns (newStreak, longestStreak).
  List<int> markTodayRead() {
    final today = _today();
    final lastDateStr = _cache.getString(_kLastDateKey);
    final existing = jsonDecode(
            _cache.getString(_kKey) ?? '{}') as Map;

    int current = (existing['streak'] as int?) ?? 0;
    int longest = (existing['longest'] as int?) ?? current;

    if (lastDateStr == _fmt(today)) {
      // Already counted today.
      return [current, longest];
    }
    if (lastDateStr == _fmt(today.subtract(const Duration(days: 1)))) {
      current += 1;
    } else {
      current = 1;
    }
    if (current > longest) longest = current;
    _cache.setString(
        _kKey, jsonEncode({'streak': current, 'longest': longest}));
    _cache.setString(_kLastDateKey, _fmt(today));
    return [current, longest];
  }

  String? lastArticleSlug() =>
      _cache.getString(_kLastArticleKey);

  void rememberArticle(String slug) {
    _cache.setString(_kLastArticleKey, slug);
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}