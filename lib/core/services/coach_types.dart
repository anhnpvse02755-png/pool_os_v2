// ============================================================================
// Coach Service Types — Stub definitions for coach_service.dart
// ============================================================================

import 'package:flutter/foundation.dart';

/// Simple drill progress data
@immutable
class SimpleDrillProgress {
  final String drillCode;
  final String drillName;
  final double successRate;
  final int totalAttempts;
  final int successfulAttempts;
  final double averageAccuracy;
  final DateTime? lastAttemptedAt;

  const SimpleDrillProgress({
    required this.drillCode,
    this.drillName = '',
    required this.successRate,
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.averageAccuracy,
    this.lastAttemptedAt,
  });

  /// Create from JSON
  factory SimpleDrillProgress.fromJson(Map<String, dynamic> json) {
    return SimpleDrillProgress(
      drillCode: json['drillCode'] as String? ?? json['drill_code'] as String? ?? '',
      drillName: json['drillName'] as String? ?? json['drill_name'] as String? ?? '',
      successRate: (json['successRate'] as num?)?.toDouble() ??
                   (json['success_rate'] as num?)?.toDouble() ??
                   0.0,
      totalAttempts: json['totalAttempts'] as int? ??
                    json['total_attempts'] as int? ??
                    0,
      successfulAttempts: json['successfulAttempts'] as int? ??
                         json['successful_attempts'] as int? ??
                         0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ??
                      (json['average_accuracy'] as num?)?.toDouble() ??
                      0.0,
      lastAttemptedAt: json['lastAttemptedAt'] != null || json['last_attempted_at'] != null
          ? DateTime.tryParse(json['lastAttemptedAt'] as String? ??
                              json['last_attempted_at'] as String? ??
                              '')
          : null,
    );
  }
}

/// Learning path item
@immutable
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
  final List<String> knowledgeIds;

  const LearningPathItem({
    required this.drillCode,
    this.drillName = '',
    this.drillNameVi = '',
    this.description = '',
    this.priority = 0,
    this.reason = '',
    this.estimatedMinutes = 10,
    this.category = '',
    this.difficulty = 'medium',
    this.currentProgress = 0.0,
    this.knowledgeIds = const [],
  });
}

/// Weakness analysis result
@immutable
class WeaknessAnalysis {
  final String drillCode;
  final String drillName;
  final int currentRate;
  final int attempts;
  final String suggestion;
  final int priority;

  const WeaknessAnalysis({
    required this.drillCode,
    required this.drillName,
    required this.currentRate,
    required this.attempts,
    required this.suggestion,
    required this.priority,
  });
}

/// Performance summary
@immutable
class PerformanceSummary {
  final int totalSessions;
  final int totalMinutes;
  final int totalShots;
  final int overallAccuracy;
  final WeakestDrillInfo? strongestDrill;
  final WeakestDrillInfo? weakestDrill;
  final String recentTrend;

  const PerformanceSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.totalShots,
    required this.overallAccuracy,
    required this.strongestDrill,
    required this.weakestDrill,
    required this.recentTrend,
  });

  /// Empty summary
  factory PerformanceSummary.empty() {
    return const PerformanceSummary(
      totalSessions: 0,
      totalMinutes: 0,
      totalShots: 0,
      overallAccuracy: 0,
      strongestDrill: null,
      weakestDrill: null,
      recentTrend: 'no_data',
    );
  }
}

/// Drill info for performance summary
@immutable
class WeakestDrillInfo {
  final String code;
  final String name;
  final int rate;

  const WeakestDrillInfo({
    required this.code,
    required this.name,
    required this.rate,
  });
}
