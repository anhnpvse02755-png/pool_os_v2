import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/coach_service.dart';
import 'auth_provider.dart';
import 'player_provider.dart';
import 'training_provider.dart';

/// Learning Path Item
class LearningPathItem {
  final String drillCode;
  final String drillName;
  final String drillNameVi;
  final String description;
  final int priority;
  final String reason;
  final int estimatedMinutes;
  final String category;
  final String difficulty;
  final double currentProgress;

  LearningPathItem({
    required this.drillCode,
    required this.drillName,
    required this.drillNameVi,
    required this.description,
    required this.priority,
    required this.reason,
    required this.estimatedMinutes,
    required this.category,
    required this.difficulty,
    this.currentProgress = 0,
  });
}

/// Weakness Analysis
class WeaknessAnalysis {
  final String drillCode;
  final String drillName;
  final int currentRate;
  final int attempts;
  final String suggestion;
  final int priority;

  WeaknessAnalysis({
    required this.drillCode,
    required this.drillName,
    required this.currentRate,
    required this.attempts,
    required this.suggestion,
    required this.priority,
  });
}

/// Performance Summary
class PerformanceSummary {
  final int totalSessions;
  final int totalMinutes;
  final int totalShots;
  final int overallAccuracy;
  final WeakestDrillInfo? strongestDrill;
  final WeakestDrillInfo? weakestDrill;
  final String recentTrend;

  PerformanceSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalShots,
    required this.overallAccuracy,
    this.strongestDrill,
    this.weakestDrill,
    required this.recentTrend,
  });
}

/// Weakest/Strongest Drill Info
class WeakestDrillInfo {
  final String code;
  final String name;
  final int rate;

  WeakestDrillInfo({
    required this.code,
    required this.name,
    required this.rate,
  });
}

/// Simple Drill Progress for local storage
class SimpleDrillProgress {
  final String drillCode;
  final String drillName;
  final int totalAttempts;
  final int successfulAttempts;
  final int averageAccuracy;
  final DateTime? lastAttemptedAt;
  final int bestScore;

  SimpleDrillProgress({
    required this.drillCode,
    required this.drillName,
    this.totalAttempts = 0,
    this.successfulAttempts = 0,
    this.averageAccuracy = 0,
    this.lastAttemptedAt,
    this.bestScore = 0,
  });

  double get successRate {
    if (totalAttempts == 0) return 0;
    return (successfulAttempts / totalAttempts) * 100;
  }
}

/// All Drill Progress Provider - từ training sessions
final allDrillProgressProvider = Provider<Map<String, SimpleDrillProgress>>((ref) {
  final trainingState = ref.watch(trainingProvider);
  final progressMap = <String, SimpleDrillProgress>{};

  for (final session in trainingState.sessions) {
    final existing = progressMap[session.drillCode];
    if (existing != null) {
      final newAttempts = existing.totalAttempts + 1;
      final newAccuracy = session.shotsAttempted > 0
          ? (session.shotsMade / session.shotsAttempted * 100).round()
          : 0;
      progressMap[session.drillCode] = SimpleDrillProgress(
        drillCode: session.drillCode,
        drillName: session.drillName,
        totalAttempts: newAttempts,
        successfulAttempts: session.shotsMade > session.shotsAttempted ~/ 2
            ? existing.successfulAttempts + 1
            : existing.successfulAttempts,
        averageAccuracy: ((existing.averageAccuracy + newAccuracy) / 2).round(),
        lastAttemptedAt: session.date,
        bestScore: session.score > existing.bestScore ? session.score : existing.bestScore,
      );
    } else {
      progressMap[session.drillCode] = SimpleDrillProgress(
        drillCode: session.drillCode,
        drillName: session.drillName,
        totalAttempts: 1,
        successfulAttempts: session.shotsMade > session.shotsAttempted ~/ 2 ? 1 : 0,
        averageAccuracy: session.shotsAttempted > 0
            ? (session.shotsMade / session.shotsAttempted * 100).round()
            : 0,
        lastAttemptedAt: session.date,
        bestScore: session.score,
      );
    }
  }

  return progressMap;
});

/// Coach Service Provider
final coachServiceProvider = Provider<CoachService>((ref) {
  return CoachService();
});

/// Learning Path Provider
final learningPathProvider = FutureProvider<List<LearningPathItem>>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final authState = ref.watch(authProvider);
  final interestsAsync = ref.watch(playerInterestsProvider);
  final progressMap = ref.watch(allDrillProgressProvider);

  if (authState.userId == null) {
    return [];
  }

  // Get user interests
  List<String> interests = [];
  interestsAsync.whenData((interestsData) {
    if (interestsData != null) {
      interests = interestsData.interests;
    }
  });

  // Default interests if not set
  if (interests.isEmpty) {
    interests = ['draw', 'position', 'bank'];
  }

  // Get user rank (placeholder)
  final userRank = 'beginner';

  return coachService.generateLearningPath(
    userInterests: interests,
    drillProgress: progressMap,
    userRank: userRank,
  );
});

/// Weakness Analysis Provider
final weaknessAnalysisProvider = FutureProvider<List<WeaknessAnalysis>>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final progressMap = ref.watch(allDrillProgressProvider);

  return coachService.analyzeWeaknesses(progressMap);
});

/// Performance Summary Provider
final performanceSummaryProvider = FutureProvider<PerformanceSummary>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final progressMap = ref.watch(allDrillProgressProvider);

  return coachService.getPerformanceSummary(progressMap);
});
