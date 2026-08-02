import '../utils/drills_library.dart';
import '../providers/coach_provider.dart';

/// AI Coach Service - Generates recommendations based on:
/// 1. User's interests (from onboarding)
/// 2. Performance data (weaknesses)
/// 3. Rank/level
class CoachService {
  /// Generate personalized learning path
  List<LearningPathItem> generateLearningPath({
    required List<String> userInterests,
    required Map<String, SimpleDrillProgress> drillProgress,
    required String userRank,
  }) {
    final List<LearningPathItem> path = [];

    // Get all drills
    final allDrills = DrillLibrary.getAllDrills();

    // 1. Prioritize drills matching user interests
    final interestDrills = allDrills
        .where((d) => _matchesInterest(d.category, userInterests))
        .toList();

    // 2. Get drills user is weak at (low success rate)
    final weakDrills = drillProgress.entries
        .where((e) => e.value.successRate < 60)
        .map((e) => DrillLibrary.getDrill(e.key))
        .whereType<Drill>()
        .toList();

    // Sort by interest match first, then by difficulty (easy first)
    interestDrills.sort((a, b) {
      final aProgress = drillProgress[a.code];
      final bProgress = drillProgress[b.code];

      final aLevel = aProgress?.totalAttempts ?? 0;
      final bLevel = bProgress?.totalAttempts ?? 0;

      // Prioritize drills not yet started
      if (aLevel == 0 && bLevel > 0) return -1;
      if (bLevel == 0 && aLevel > 0) return 1;

      // Then by current level progress
      return aLevel.compareTo(bLevel);
    });

    // Add top 3 from interest drills
    for (var i = 0; i < interestDrills.take(3).length; i++) {
      final drill = interestDrills[i];
      final progress = drillProgress[drill.code];

      path.add(LearningPathItem(
        drillCode: drill.code,
        drillName: drill.name,
        drillNameVi: drill.nameVi,
        description: drill.description,
        priority: i + 1,
        reason: _getRecommendationReason(drill.category, userInterests),
        estimatedMinutes: 15,
        category: drill.category,
        difficulty: drill.difficulty,
        currentProgress: progress?.successRate ?? 0.0,
      ));
    }

    // Add weak drills if not already in path
    for (final drill in weakDrills.take(2)) {
      if (!path.any((p) => p.drillCode == drill.code)) {
        final progress = drillProgress[drill.code];
        path.add(LearningPathItem(
          drillCode: drill.code,
          drillName: drill.name,
          drillNameVi: drill.nameVi,
          description: drill.description,
          priority: path.length + 1,
          reason: 'Cần cải thiện - Tỷ lệ thành công thấp',
          estimatedMinutes: 15,
          category: drill.category,
          difficulty: drill.difficulty,
          currentProgress: progress?.successRate ?? 0.0,
        ));
      }
    }

    return path;
  }

  /// Analyze weaknesses
  List<WeaknessAnalysis> analyzeWeaknesses(Map<String, SimpleDrillProgress> progress) {
    final List<WeaknessAnalysis> weaknesses = [];

    // Get all drills
    final allDrills = DrillLibrary.getAllDrills();

    for (final drill in allDrills) {
      final p = progress[drill.code];
      if (p != null && p.successRate < 70) {
        weaknesses.add(WeaknessAnalysis(
          drillCode: drill.code,
          drillName: drill.name,
          currentRate: p.successRate.toInt(),
          attempts: p.totalAttempts,
          suggestion: _getSuggestion(drill.category, p.successRate.toInt()),
          priority: _getPriority(p.successRate.toInt(), p.totalAttempts),
        ));
      }
    }

    // Sort by priority (lower rate first)
    weaknesses.sort((a, b) => a.currentRate.compareTo(b.currentRate));

    return weaknesses;
  }

  /// Get performance summary
  PerformanceSummary getPerformanceSummary(Map<String, SimpleDrillProgress> progress) {
    if (progress.isEmpty) {
      return PerformanceSummary(
        totalSessions: 0,
        totalMinutes: 0,
        totalShots: 0,
        overallAccuracy: 0,
        strongestDrill: null,
        weakestDrill: null,
        recentTrend: 'no_data',
      );
    }

    final sessions = progress.values.fold<int>(0, (sum, p) => sum + p.totalAttempts);
    final totalAccuracy = progress.values.fold<int>(0, (sum, p) => sum + p.averageAccuracy);
    final avgAccuracy = progress.isNotEmpty ? totalAccuracy ~/ progress.length : 0;

    // Find strongest and weakest
    String? strongestCode;
    String? strongestName;
    int strongestRate = 0;
    String? weakestCode;
    String? weakestName;
    int weakestRate = 100;

    for (final entry in progress.entries) {
      final rate = entry.value.successRate.toInt();
      if (rate > strongestRate) {
        strongestRate = rate;
        strongestCode = entry.key;
        final drill = DrillLibrary.getDrill(entry.key);
        strongestName = drill?.name;
      }
      if (rate < weakestRate) {
        weakestRate = rate;
        weakestCode = entry.key;
        final drill = DrillLibrary.getDrill(entry.key);
        weakestName = drill?.name;
      }
    }

    return PerformanceSummary(
      totalSessions: sessions,
      totalMinutes: 0, // Would need to track this separately
      totalShots: progress.values.fold<int>(0, (sum, p) => sum + p.successfulAttempts),
      overallAccuracy: avgAccuracy,
      strongestDrill: strongestCode != null
          ? WeakestDrillInfo(code: strongestCode, name: strongestName ?? '', rate: strongestRate)
          : null,
      weakestDrill: weakestCode != null
          ? WeakestDrillInfo(code: weakestCode, name: weakestName ?? '', rate: weakestRate)
          : null,
      recentTrend: 'stable',
    );
  }

  bool _matchesInterest(String category, List<String> interests) {
    return interests.any((i) => category.toLowerCase().contains(i.toLowerCase()));
  }

  String _getRecommendationReason(String category, List<String> interests) {
    if (interests.contains(category)) {
      return 'Phù hợp với sở thích của bạn';
    }
    return 'Kỹ năng nền tảng quan trọng';
  }

  String _getSuggestion(String category, int rate) {
    if (rate < 40) {
      return 'Nên bắt đầu lại từ đầu với tốc độ chậm';
    } else if (rate < 60) {
      return 'Tập trung vào độ chính xác trước';
    } else {
      return 'Tiếp tục luyện tập để cải thiện';
    }
  }

  int _getPriority(int rate, int attempts) {
    if (rate < 40) return 1; // High priority
    if (rate < 60) return 2; // Medium priority
    return 3; // Low priority
  }
}
