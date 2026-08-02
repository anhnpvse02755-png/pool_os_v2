import '../models/drill_progress.dart';
import '../models/player_interests.dart';
import '../utils/drills_library.dart';

/// AI Coach Service - Generates recommendations based on:
/// 1. User's interests (from onboarding)
/// 2. Performance data (weaknesses)
/// 3. Rank/level
class CoachService {
  /// Generate personalized learning path
  List<LearningPathItem> generateLearningPath({
    required List<String> userInterests,
    required List<DrillProgress> drillProgress,
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
    final weakDrills = drillProgress
        .where((p) => p.overallSuccessRate < 60)
        .map((p) => DrillLibrary.getDrill(p.drillCode))
        .whereType<Drill>()
        .toList();

    // 3. Get drills not yet started
    final notStartedDrills = allDrills
        .where((d) => !drillProgress.any((p) => p.drillCode == d.code))
        .toList();

    // Sort by interest match first, then by difficulty (easy first)
    interestDrills.sort((a, b) {
      final aProgress = drillProgress.firstWhere(
        (p) => p.drillCode == a.code,
        orElse: () => DrillProgress(
          id: '',
          playerId: '',
          drillCode: a.code,
          currentLevel: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      final bProgress = drillProgress.firstWhere(
        (p) => p.drillCode == b.code,
        orElse: () => DrillProgress(
          id: '',
          playerId: '',
          drillCode: b.code,
          currentLevel: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Prioritize drills not yet started
      if (aProgress.currentLevel == 0 && bProgress.currentLevel > 0) return -1;
      if (bProgress.currentLevel == 0 && aProgress.currentLevel > 0) return 1;

      // Then by current level progress
      return aProgress.currentLevel.compareTo(bProgress.currentLevel);
    });

    // Add top 5 from interest drills
    for (var i = 0; i < interestDrills.take(3).length; i++) {
      final drill = interestDrills[i];
      final progress = drillProgress.firstWhere(
        (p) => p.drillCode == drill.code,
        orElse: () => DrillProgress(
          id: '',
          playerId: '',
          drillCode: drill.code,
          currentLevel: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      path.add(LearningPathItem(
        drill: drill,
        priority: i == 0 ? PathPriority.high : PathPriority.medium,
        reason: _getRecommendationReason(drill, userInterests, progress),
        suggestedLevel: progress.currentLevel + 1,
      ));
    }

    // Add weak drills
    for (var i = 0; i < weakDrills.take(2).length; i++) {
      final drill = weakDrills[i];
      final progress = drillProgress.firstWhere(
        (p) => p.drillCode == drill.code,
        orElse: () => DrillProgress(
          id: '',
          playerId: '',
          drillCode: drill.code,
          currentLevel: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Check if already in path
      if (!path.any((item) => item.drill.code == drill.code)) {
        path.add(LearningPathItem(
          drill: drill,
          priority: PathPriority.medium,
          reason: 'Cần cải thiện - ${progress.overallSuccessRate.toStringAsFixed(0)}% thành công',
          suggestedLevel: progress.currentLevel + 1,
        ));
      }
    }

    return path.take(5).toList();
  }

  /// Analyze player weaknesses
  List<WeaknessAnalysis> analyzeWeaknesses(List<DrillProgress> progress) {
    final List<WeaknessAnalysis> weaknesses = [];

    for (final p in progress) {
      if (p.overallSuccessRate < 50) {
        final drill = DrillLibrary.getDrill(p.drillCode);
        if (drill != null) {
          weaknesses.add(WeaknessAnalysis(
            drillCode: p.drillCode,
            drillName: drill.nameVi,
            category: drill.category,
            successRate: p.overallSuccessRate,
            totalAttempts: p.totalAttempts,
            suggestion: _getWeaknessSuggestion(drill, p.overallSuccessRate),
          ));
        }
      }
    }

    // Sort by lowest success rate first
    weaknesses.sort((a, b) => a.successRate.compareTo(b.successRate));
    return weaknesses;
  }

  /// Get overall performance summary
  PerformanceSummary getPerformanceSummary(List<DrillProgress> progress) {
    if (progress.isEmpty) {
      return PerformanceSummary(
        totalDrillsStarted: 0,
        totalDrillsCompleted: 0,
        averageSuccessRate: 0,
        strongestCategory: null,
        weakestCategory: null,
        totalPracticeTime: 0,
      );
    }

    // Calculate stats
    final totalAttempts = progress.fold<int>(
      0,
      (sum, p) => sum + p.totalAttempts,
    );
    final totalSuccesses = progress.fold<int>(
      0,
      (sum, p) => sum + p.totalSuccesses,
    );
    final avgSuccessRate = totalAttempts > 0
        ? (totalSuccesses / totalAttempts) * 100
        : 0.0;

    // Find strongest and weakest categories
    final categoryRates = <String, List<double>>{};
    for (final p in progress) {
      final drill = DrillLibrary.getDrill(p.drillCode);
      if (drill != null) {
        categoryRates.putIfAbsent(drill.category, () => []);
        categoryRates[drill.category]!.add(p.overallSuccessRate);
      }
    }

    String? strongest;
    String? weakest;
    double strongestRate = 0;
    double weakestRate = 100;

    categoryRates.forEach((category, rates) {
      final avg = rates.reduce((a, b) => a + b) / rates.length;
      if (avg > strongestRate) {
        strongestRate = avg;
        strongest = category;
      }
      if (avg < weakestRate) {
        weakestRate = avg;
        weakest = category;
      }
    });

    return PerformanceSummary(
      totalDrillsStarted: progress.where((p) => p.totalAttempts > 0).length,
      totalDrillsCompleted: progress.where((p) => p.currentLevel >= 5).length,
      averageSuccessRate: avgSuccessRate,
      strongestCategory: strongest,
      weakestCategory: weakest,
      totalPracticeTime: totalAttempts * 30, // Estimate 30 seconds per attempt
    );
  }

  /// Check if drill category matches user interests
  bool _matchesInterest(String category, List<String> interests) {
    final categoryToInterest = {
      'potting': 'potting',
      'cueball': 'position',
      'position': 'position',
      'safety': 'safety',
      'special': ['bank', 'kick', 'jump', 'masse'],
      'break': 'break',
    };

    final mappedInterest = categoryToInterest[category];
    if (mappedInterest == null) return false;

    if (mappedInterest is String) {
      return interests.contains(mappedInterest);
    } else if (mappedInterest is List) {
      return mappedInterest.any((i) => interests.contains(i));
    }
    return false;
  }

  String _getRecommendationReason(
    Drill drill,
    List<String> interests,
    DrillProgress progress,
  ) {
    if (progress.currentLevel == 0) {
      return 'Phù hợp với sở thích của bạn';
    } else if (progress.currentLevel < 5) {
      return 'Tiếp tục luyện tập - đang ở Lv${progress.currentLevel}';
    } else {
      return 'Đã hoàn thành tất cả các cấp';
    }
  }

  String _getWeaknessSuggestion(Drill drill, double successRate) {
    if (drill.category == 'cueball') {
      if (successRate < 30) {
        return 'Hãy bắt đầu với khoảng cách gần hơn và tập trung vào kỹ thuật cơ bản';
      }
      return 'Tập trung vào điểm đánh và kiểm soát lực';
    } else if (drill.category == 'potting') {
      return 'Luyện tập ngắm và kiểm soát lực đánh';
    } else if (drill.category == 'safety') {
      return 'Học các góc cơ bản và cách đọc bàn';
    } else if (drill.category == 'special') {
      return 'Đây là kỹ thuật nâng cao, hãy luyện tập kiên nhẫn';
    }
    return 'Tiếp tục luyện tập để cải thiện';
  }
}

/// Learning Path Item
class LearningPathItem {
  final Drill drill;
  final PathPriority priority;
  final String reason;
  final int suggestedLevel;

  LearningPathItem({
    required this.drill,
    required this.priority,
    required this.reason,
    required this.suggestedLevel,
  });
}

enum PathPriority { high, medium, low }

/// Weakness Analysis
class WeaknessAnalysis {
  final String drillCode;
  final String drillName;
  final String category;
  final double successRate;
  final int totalAttempts;
  final String suggestion;

  WeaknessAnalysis({
    required this.drillCode,
    required this.drillName,
    required this.category,
    required this.successRate,
    required this.totalAttempts,
    required this.suggestion,
  });
}

/// Performance Summary
class PerformanceSummary {
  final int totalDrillsStarted;
  final int totalDrillsCompleted;
  final double averageSuccessRate;
  final String? strongestCategory;
  final String? weakestCategory;
  final int totalPracticeTime; // in seconds

  PerformanceSummary({
    required this.totalDrillsStarted,
    required this.totalDrillsCompleted,
    required this.averageSuccessRate,
    required this.strongestCategory,
    required this.weakestCategory,
    required this.totalPracticeTime,
  });

  String get practiceTimeFormatted {
    final hours = totalPracticeTime ~/ 3600;
    final minutes = (totalPracticeTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}p';
    }
    return '${minutes}p';
  }
}
