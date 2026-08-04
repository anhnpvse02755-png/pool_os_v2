import '../../data/models/match.dart';
import '../../data/repositories/match_repository.dart';

/// Daily streak calculator — counts consecutive calendar days with at
/// least one match.
class StreakCalculator {
  StreakCalculator(this._repo);
  final IMatchRepository _repo;

  Future<int> currentStreak({String? playerId}) async {
    final matches = playerId != null
        ? await _repo.getMatchesByPlayer(playerId)
        : await _repo.getAllMatches();
    if (matches.isEmpty) return 0;

    final dates = matches
        .map((m) => DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day))
        .toSet();
    int streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (dates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> longestStreak({String? playerId}) async {
    final matches = playerId != null
        ? await _repo.getMatchesByPlayer(playerId)
        : await _repo.getAllMatches();
    if (matches.isEmpty) return 0;
    final dates = matches
        .map((m) => DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day))
        .toSet()
      ..toList()
        .sort();
    final sorted = dates.toList()..sort();
    int longest = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }
}
