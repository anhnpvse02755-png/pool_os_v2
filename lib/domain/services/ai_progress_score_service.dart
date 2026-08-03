import '../../data/models/match.dart';
import '../../data/repositories/match_repository.dart';

/// Phase C: AI Progress Score — composite 0..100.
class AiProgressScoreService {
  AiProgressScoreService(this._repo);
  final IMatchRepository _repo;

  /// Returns a map with `totalScore`, `breakdown`, `trend`.
  Future<Map<String, dynamic>> compute({String? playerId}) async {
    final matches = playerId != null
        ? await _repo.getMatchesByPlayer(playerId)
        : await _repo.getAllMatches();
    if (matches.isEmpty) {
      return {
        'totalScore': 0,
        'breakdown': <String, double>{},
        'trend': 'no_data',
      };
    }

    // Last 30 days vs previous 30 days.
    final now = DateTime.now();
    final recent = matches
        .where((m) => m.createdAt.isAfter(now.subtract(const Duration(days: 30))))
        .toList();
    final previous = matches
        .where((m) =>
            m.createdAt.isAfter(now.subtract(const Duration(days: 60))) &&
            m.createdAt.isBefore(now.subtract(const Duration(days: 30))))
        .toList();

    final recentWinRate =
        recent.isEmpty ? 0 : recent.where((m) => m.isWin).length / recent.length;
    final prevWinRate =
        previous.isEmpty ? recentWinRate : previous.where((m) => m.isWin).length / previous.length;

    // V2 model: break-and-runs are computed per rack via `isBreakAndRun`
// (defined as: breakShot && breakSuccess == true && totalBallsPotted >= 7).
//
// ⚠️ COMPATIBILITY NOTE (added Day 1.1):
// V1's Match.breakAndRuns was a per-Match integer field that has been
// removed in V2. We compute the aggregate on demand from `match.racks`.
//
// AUDIT REQUIRED post-Stabilization-Sprint:
//   - Confirm that `r.isBreakAndRun` definition matches the V2 product spec.
//   - If "break-and-run" in V2 product scope means something different
//     (e.g. 9-ball golden break, 7-ball run-out), this computation is wrong.
//   - Consider denormalising back to a Match-level field if recomputation
//     becomes a hot path (currently O(racks) per match per score call).
// Tracked as: STAB-030 (post-Sprint audit).
final recentBreakRun = recent.fold(0,
        (a, m) => a + m.racks.where((r) => r.isBreakAndRun).length);
    final recentRacks = recent.fold(0, (a, m) => a + m.racks.length);

    // Sub-scores 0..100.
    final skillScore = (recentWinRate * 100).clamp(0, 100).toDouble();
    final consistency = ((recent.length / 12) * 100).clamp(0, 100).toDouble();
    final breakRunScore = (recentRacks == 0
            ? 0.0
            : (recentBreakRun / recentRacks * 100 * 2))
        .clamp(0, 100)
        .toDouble();
    final improvementDelta = ((recentWinRate - prevWinRate) * 100).clamp(-50, 50).toDouble();
    final total = ((skillScore * 0.4) +
            (consistency * 0.2) +
            (breakRunScore * 0.2) +
            ((improvementDelta + 50) * 0.2))
        .clamp(0, 100);

    final trend = improvementDelta >= 5
        ? 'rising'
        : improvementDelta <= -5
            ? 'declining'
            : 'steady';

    return {
      'totalScore': total.round(),
      'breakdown': {
        'Skill': skillScore,
        'Consistency': consistency,
        'Break & Run': breakRunScore,
        'Improvement': improvementDelta + 50,
      },
      'trend': trend,
    };
  }
}