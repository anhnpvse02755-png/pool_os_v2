// ============================================================================
// Snapshot Builder Service — Phase B.3
// Builds player, coach, and session snapshots for Black Box
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Builds complete player snapshot for Black Box
class SnapshotBuilderService {
  /// Build complete player identity snapshot
  Map<String, dynamic> buildPlayerIdentity({
    required String playerId,
    required String displayName,
    required DateTime createdAt,
    required int daysActive,
    required String testerId,
    String level = 'intermediate',
    int levelScore = 0,
  }) {
    return {
      'schemaVersion': '2.0',
      'player': {
        'id': playerId,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
        'daysActive': daysActive,
        'testerId': testerId,
      },
      'level': {
        'current': level,
        'score': levelScore,
      },
    };
  }

  /// Build skill profile snapshot (simplified)
  Map<String, dynamic> buildSkillProfile({
    required int overallScore,
    String trend = 'stable',
    int confidence = 50,
    List<String> weakestSkills = const [],
    List<String> strongestSkills = const [],
    List<Map<String, dynamic>>? skills,
  }) {
    return {
      'schemaVersion': '2.0',
      'snapshotAt': DateTime.now().toIso8601String(),
      'overall': {
        'score': overallScore,
        'trend': trend,
        'confidence': confidence,
      },
      'skills': skills ?? [],
      'weakestSkills': weakestSkills,
      'strongestSkills': strongestSkills,
    };
  }

  /// Build progress/trend snapshot (simplified)
  Map<String, dynamic> buildProgress({
    String trend = 'stable',
    int confidence = 50,
    int currentStreak = 0,
    int longestStreak = 0,
    int totalSessions = 0,
    List<Map<String, dynamic>>? weeklyData,
  }) {
    return {
      'schemaVersion': '2.0',
      'trend': {
        'direction': trend,
        'confidence': confidence,
      },
      'weeklyProgress': weeklyData ?? [],
      'personalBests': {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      },
    };
  }

  /// Build mental indicators snapshot (simplified)
  Map<String, dynamic> buildMental({
    String confidence = 'medium',
    String motivation = 'medium',
    String frustration = 'low',
    bool burnoutRisk = false,
    double acceptRate = 0.0,
    double completionRate = 0.0,
  }) {
    return {
      'schemaVersion': '2.0',
      'indicators': {
        'confidence': confidence,
        'motivation': motivation,
        'frustration': frustration,
        'burnoutRisk': burnoutRisk,
      },
      'recommendationAdherence': {
        'acceptRate': acceptRate,
        'completionRate': completionRate,
      },
    };
  }

  /// Build Coach current state snapshot (simplified)
  Map<String, dynamic> buildCoachState({
    Map<String, dynamic>? currentPriority,
    List<Map<String, dynamic>>? priorityQueue,
    Map<String, dynamic>? shortTermPlan,
    List<Map<String, dynamic>>? longTermPhases,
    Map<String, dynamic>? sessionMemory,
    Map<String, dynamic>? recommendationMemory,
    String priorityEngineVersion = '7',
  }) {
    return {
      'schemaVersion': '2.0',
      'snapshotAt': DateTime.now().toIso8601String(),
      'priorityEngine': {
        'version': priorityEngineVersion,
        'currentPriority': currentPriority,
        'priorityQueue': priorityQueue ?? [],
      },
      'coachingPlan': {
        'shortTerm': shortTermPlan,
        'longTerm': {
          'phases': longTermPhases ?? [],
        },
      },
      'memory': {
        'sessionMemory': sessionMemory ?? {},
        'recommendationMemory': recommendationMemory ?? {},
      },
    };
  }

  /// Build session snapshot
  Map<String, dynamic> buildSessionSnapshot({
    required bool hasInterrupted,
    Map<String, dynamic>? interruptedSession,
    int totalSessions = 0,
    int completedSessions = 0,
    int interruptedSessions = 0,
    List<Map<String, dynamic>>? recentSessions,
  }) {
    return {
      'schemaVersion': '2.0',
      'hasInterrupted': hasInterrupted,
      'interruptedSession': interruptedSession,
      'summary': {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'interruptedSessions': interruptedSessions,
      },
      'recentSessions': recentSessions ?? [],
    };
  }

  /// Build complete system snapshot
  Map<String, dynamic> buildSystemSnapshot({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String os,
    required String deviceModel,
    required int screenWidth,
    required int screenHeight,
    String locale = 'vi-VN',
  }) {
    return {
      'schemaVersion': '2.0',
      'app': {
        'name': 'PoolOS',
        'version': appVersion,
        'build': buildNumber,
        'channel': 'beta',
      },
      'device': {
        'platform': platform,
        'model': deviceModel,
        'os': os,
      },
      'screen': {
        'width': screenWidth,
        'height': screenHeight,
      },
      'locale': {
        'language': locale.split('-').first,
        'country': locale.split('-').last,
      },
    };
  }

  /// Build versions snapshot
  Map<String, dynamic> buildVersionsSnapshot({
    required String appVersion,
    required String buildNumber,
    String schemaVersion = '2.0',
    String knowledgeGraphVersion = '18',
    String priorityEngineVersion = '7',
    String coachServiceVersion = '7',
    String conversationEngineVersion = '7',
  }) {
    return {
      'schemaVersion': schemaVersion,
      'app': {
        'name': 'PoolOS',
        'version': appVersion,
        'build': buildNumber,
        'channel': 'beta',
      },
      'components': {
        'schema': schemaVersion,
        'knowledgeGraph': {
          'version': knowledgeGraphVersion,
        },
        'coachBrain': {
          'priorityEngine': priorityEngineVersion,
          'coachService': coachServiceVersion,
          'conversationEngine': conversationEngineVersion,
        },
      },
    };
  }
}
