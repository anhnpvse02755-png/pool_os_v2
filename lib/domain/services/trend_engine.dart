import '../../data/models/training_session.dart';
import '../../data/models/match.dart';

/// Sprint 4C Task 20 — Trend Engine
///
/// Computes trends from training and match history.
/// Used by Coach AI to detect patterns (improvement/decline).
class TrendEngine {
  TrendEngine({
    required List<TrainingSession> trainingHistory,
    required List<Match> matchHistory,
  }) : _training = trainingHistory,
       _matches = matchHistory;

  final List<TrainingSession> _training;
  final List<Match> _matches;

  /// Overall training trend: improving, stable, or declining.
  TrendResult get trainingTrend {
    if (_training.length < 2) return TrendResult.insufficient;

    final recent = _training.take(5).toList();
    final older = _training.skip(5).take(5).toList();

    if (older.isEmpty) return TrendResult.insufficient;

    final recentAvg = recent.fold<double>(0, (sum, s) => sum + s.score) / recent.length;
    final olderAvg = older.fold<double>(0, (sum, s) => sum + s.score) / older.length;

    final delta = recentAvg - olderAvg;
    if (delta > 5) return TrendResult.improving;
    if (delta < -5) return TrendResult.declining;
    return TrendResult.stable;
  }

  /// Overall match trend: improving, stable, or declining.
  TrendResult get matchTrend {
    if (_matches.length < 2) return TrendResult.insufficient;

    final recent = _matches.take(5).toList();
    final older = _matches.skip(5).take(5).toList();

    if (older.isEmpty) return TrendResult.insufficient;

    final recentWins = recent.where((m) => m.isWin).length;
    final olderWins = older.where((m) => m.isWin).length;

    final recentRate = recentWins / recent.length;
    final olderRate = olderWins / older.length;

    final delta = recentRate - olderRate;
    if (delta > 0.15) return TrendResult.improving;
    if (delta < -0.15) return TrendResult.declining;
    return TrendResult.stable;
  }

  /// Drill-specific trends: which drills are improving/declining.
  Map<String, DrillTrend> get drillTrends {
    final byDrill = <String, List<TrainingSession>>{};

    for (final session in _training) {
      byDrill.putIfAbsent(session.drillCode, () => []).add(session);
    }

    final trends = <String, DrillTrend>{};

    for (final entry in byDrill.entries) {
      final sessions = entry.value;
      if (sessions.length < 2) continue;

      // Sort by date ascending
      final sorted = List<TrainingSession>.from(sessions)
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

      final recent = sorted.take(3).toList();
      final older = sorted.skip(3).take(3).toList();

      if (older.isEmpty) {
        trends[entry.key] = DrillTrend(
          drillCode: entry.key,
          drillName: sessions.first.drillName,
          trend: TrendResult.insufficient,
          delta: 0,
          sessionCount: sessions.length,
        );
        continue;
      }

      final recentAvg = recent.fold<double>(0, (sum, s) => sum + s.score) / recent.length;
      final olderAvg = older.fold<double>(0, (sum, s) => sum + s.score) / older.length;
      final delta = recentAvg - olderAvg;

      TrendResult trend;
      if (delta > 5) {
        trend = TrendResult.improving;
      } else if (delta < -5) {
        trend = TrendResult.declining;
      } else {
        trend = TrendResult.stable;
      }

      trends[entry.key] = DrillTrend(
        drillCode: entry.key,
        drillName: sessions.first.drillName,
        trend: trend,
        delta: delta,
        sessionCount: sessions.length,
      );
    }

    return trends;
  }

  /// Consistency score: how consistent is performance (0-100).
  int get consistencyScore {
    if (_training.isEmpty) return 0;

    final scores = _training.map((s) => s.score.toDouble()).toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) / scores.length;
    final stdDev = variance > 0 ? variance / (mean * mean) : 0;

    // Lower variance = higher consistency
    // Map stdDev to 0-100 (inverse relationship)
    final score = (100 - (stdDev * 100)).clamp(0, 100).round();
    return score;
  }

  /// Win streak calculation.
  int get currentWinStreak {
    final sorted = List<Match>.from(_matches)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    for (final m in sorted) {
      if (m.isWin) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Loss streak calculation.
  int get currentLossStreak {
    final sorted = List<Match>.from(_matches)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    for (final m in sorted) {
      if (m.isLoss) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Overall summary for Coach AI.
  TrendSummary get summary {
    return TrendSummary(
      trainingTrend: trainingTrend,
      matchTrend: matchTrend,
      consistencyScore: consistencyScore,
      currentWinStreak: currentWinStreak,
      currentLossStreak: currentLossStreak,
      drillTrends: drillTrends,
      totalSessions: _training.length,
      totalMatches: _matches.length,
    );
  }
}

enum TrendResult { improving, stable, declining, insufficient }

class DrillTrend {
  final String drillCode;
  final String drillName;
  final TrendResult trend;
  final double delta;
  final int sessionCount;

  DrillTrend({
    required this.drillCode,
    required this.drillName,
    required this.trend,
    required this.delta,
    required this.sessionCount,
  });
}

class TrendSummary {
  final TrendResult trainingTrend;
  final TrendResult matchTrend;
  final int consistencyScore;
  final int currentWinStreak;
  final int currentLossStreak;
  final Map<String, DrillTrend> drillTrends;
  final int totalSessions;
  final int totalMatches;

  TrendSummary({
    required this.trainingTrend,
    required this.matchTrend,
    required this.consistencyScore,
    required this.currentWinStreak,
    required this.currentLossStreak,
    required this.drillTrends,
    required this.totalSessions,
    required this.totalMatches,
  });
}
