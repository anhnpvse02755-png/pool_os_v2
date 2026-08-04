/// Flashcard associated with an article.
class Flashcard {
  final String id;
  final String articleSlug;
  final String front;
  final String back;
  final DateTime createdAt;
  final int difficulty; // 1..5 — affects spaced repetition step

  const Flashcard({
    required this.id,
    required this.articleSlug,
    required this.front,
    required this.back,
    required this.createdAt,
    this.difficulty = 3,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'articleSlug': articleSlug,
        'front': front,
        'back': back,
        'createdAt': createdAt.toIso8601String(),
        'difficulty': difficulty,
      };

  factory Flashcard.fromJson(Map<String, dynamic> j) => Flashcard(
        id: j['id'] as String,
        articleSlug: j['articleSlug'] as String,
        front: j['front'] as String,
        back: j['back'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        difficulty: j['difficulty'] as int? ?? 3,
      );
}

/// Per-card spaced repetition state.
class FlashcardProgress {
  final String cardId;
  final int easeLevel; // 0..5 (0 = brand new, 5 = mastered)
  final DateTime dueAt;
  final DateTime? lastSeenAt;
  final int reviews;

  const FlashcardProgress({
    required this.cardId,
    required this.easeLevel,
    required this.dueAt,
    this.lastSeenAt,
    this.reviews = 0,
  });

  /// SuperMemo-style ease step in days. Cards repeat with exponential
  /// growth once mastered.
  Duration nextInterval() {
    final level = easeLevel.clamp(0, 5);
    switch (level) {
      case 0:
        return const Duration(days: 0);
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

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'easeLevel': easeLevel,
        'dueAt': dueAt.toIso8601String(),
        'lastSeenAt': lastSeenAt?.toIso8601String(),
        'reviews': reviews,
      };

  factory FlashcardProgress.fromJson(Map<String, dynamic> j) =>
      FlashcardProgress(
        cardId: j['cardId'] as String,
        easeLevel: j['easeLevel'] as int? ?? 0,
        dueAt: DateTime.parse(j['dueAt'] as String),
        lastSeenAt: j['lastSeenAt'] != null
            ? DateTime.parse(j['lastSeenAt'] as String)
            : null,
        reviews: j['reviews'] as int? ?? 0,
      );
}