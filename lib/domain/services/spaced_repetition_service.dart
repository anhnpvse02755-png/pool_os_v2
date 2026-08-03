import 'dart:convert';

import '../../data/repositories/cache_repository.dart';
import '../../data/models/flashcard.dart';

/// Phase B: simple SM-2 style spaced repetition.
///
/// Day 2A: depends on [ICacheRepository].
class SpacedRepetitionService {
  SpacedRepetitionService(this._cache);
  final ICacheRepository _cache;

  static const _kProgressKey = 'poolos_v2.flashcard_progress';
  static const _kCardKey = 'poolos_v2.flashcard_cards';

  Future<List<Flashcard>> allCards() async {
    final raw = _cache.getString(_kCardKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(Flashcard.fromJson)
        .toList();
  }

  Future<void> saveCard(Flashcard card) async {
    final cards = await allCards();
    final idx = cards.indexWhere((c) => c.id == card.id);
    if (idx >= 0) {
      cards[idx] = card;
    } else {
      cards.add(card);
    }
    await _cache.setString(
        _kCardKey, jsonEncode(cards.map((c) => c.toJson()).toList()));
  }

  Future<List<Flashcard>> byArticle(String articleSlug) async {
    final cards = await allCards();
    return cards.where((c) => c.articleSlug == articleSlug).toList();
  }

  Future<Map<String, FlashcardProgress>> _readAll() async {
    final raw = _cache.getString(_kProgressKey);
    if (raw == null || raw.isEmpty) return {};
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return {
      for (final j in list) j['cardId'] as String: FlashcardProgress.fromJson(j),
    };
  }

  Future<void> _writeAll(Map<String, FlashcardProgress> m) async {
    final list = m.values.map((p) => p.toJson()).toList();
    await _cache.setString(_kProgressKey, jsonEncode(list));
  }

  /// Return due cards (now >= dueAt) for an article.
  Future<List<Flashcard>> dueFor(String articleSlug) async {
    final cards = await byArticle(articleSlug);
    final progress = await _readAll();
    final now = DateTime.now();
    return cards.where((c) {
      final p = progress[c.id];
      if (p == null) return true; // new cards are always due
      return !p.dueAt.isAfter(now);
    }).toList();
  }

  /// Mark review outcome. `grade` is 0..5 (e.g. 0 = wrong, 5 = easy).
  Future<FlashcardProgress> review({
    required String cardId,
    required int grade,
  }) async {
    final progress = await _readAll();
    final existing = progress[cardId] ??
        FlashcardProgress(
          cardId: cardId,
          easeLevel: 0,
          dueAt: DateTime.now(),
        );

    int newLevel;
    if (grade <= 2) {
      newLevel = 0;
    } else {
      newLevel = (existing.easeLevel + 1).clamp(0, 5);
    }

    final next = FlashcardProgress(
      cardId: cardId,
      easeLevel: newLevel,
      dueAt: DateTime.now().add(
        newLevel == 0
            ? const Duration(minutes: 5)
            : _intervalForLevel(newLevel),
      ),
      lastSeenAt: DateTime.now(),
      reviews: existing.reviews + 1,
    );
    progress[cardId] = next;
    await _writeAll(progress);
    return next;
  }

  Duration _intervalForLevel(int level) {
    switch (level) {
      case 1:
        return const Duration(days: 1);
      case 2:
        return const Duration(days: 2);
      case 3:
        return const Duration(days: 4);
      case 4:
        return const Duration(days: 7);
      default:
        return const Duration(days: 14);
    }
  }
}