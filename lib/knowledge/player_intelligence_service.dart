// ============================================================================
// PLAYER INTELLIGENCE SERVICE - Phase 6
// Manages Player Intelligence Model lifecycle
//
// Updates from: training sessions, matches, reflections, recommendations
// Used by: Coach AI for personalized coaching
// ============================================================================

import '../data/models/training_session.dart';
import '../data/models/match.dart';
import 'player_intelligence.dart';
import 'knowledge_graph_service.dart';
import 'drill_node.dart';

/// Service for managing Player Intelligence Model
class PlayerIntelligenceService {
  PlayerIntelligenceService._(this._playerIntelligence);
  static PlayerIntelligenceService? _instance;
  static PlayerIntelligenceService get instance => _instance ??= _create();

  final PlayerIntelligence _playerIntelligence;

  static PlayerIntelligenceService _create() {
    // In production, this would load from persistent storage
    return PlayerIntelligenceService._(PlayerIntelligence.empty('default_user'));
  }

  /// Get current player intelligence
  PlayerIntelligence get current => _playerIntelligence;

  /// Get player summary for Coach
  PlayerSummary get summary => _playerIntelligence.toSummary();

  /// Update from training session
  /// Sprint-11: Extract real data from available fields
  Future<PlayerIntelligence> updateFromSession(TrainingSession session) async {
    // Infer mistakes from accuracy
    // Low accuracy (< 50%) suggests aiming issues
    // High misses relative to shots suggests technique issues
    final mistakes = <String>[];
    if (session.score < 50) {
      mistakes.add('aiming_issues');
    } else if (session.score < 70) {
      mistakes.add('accuracy_can_improve');
    }
    if (session.shotsMissed > session.shotsMade && session.shotsMissed > 5) {
      mistakes.add('technique_consistency');
    }

    final data = TrainingSessionData(
      drillCode: session.drillCode,
      score: session.score,
      durationMinutes: session.duration,
      completedAt: session.completedAt,
      mistakes: mistakes,
      metrics: {
        'accuracy': session.score,
        'shotsMade': session.shotsMade,
        'shotsMissed': session.shotsMissed,
        'totalShots': session.shotsMade + session.shotsMissed,
      },
    );

    return _playerIntelligence.updateWithSession(data);
  }

  /// Update from match
  /// Sprint-11: Extract real data where available
  Future<PlayerIntelligence> updateFromMatch(Match match) async {
    // Extract mistakes from AI analysis if available
    final mistakes = match.analysis?.biggestMistakes ?? [];

    final data = MatchData(
      opponentName: match.opponentName ?? match.opponent ?? 'Unknown',
      won: match.isWin,
      playerScore: match.playerScore,
      opponentScore: match.opponentScore,
      durationMinutes: 0, // Duration not tracked in current model
      playedAt: match.createdAt,
      mistakes: mistakes,
    );

    return _playerIntelligence.updateWithMatch(data);
  }

  /// Get Coach explanation for recommendation
  String getCoachExplanationForDrill(String drillCode) {
    final kg = KnowledgeGraphService.instance;
    final drill = kg.getDrill(drillCode);

    if (drill == null) {
      return 'Drill không tìm thấy trong hệ thống.';
    }

    final parts = <String>[];

    // Context from player intelligence
    final player = _playerIntelligence;

    // Why this drill now?
    parts.add(_buildWhyNowContext(player, drill));

    // What skills does it train?
    if (drill.skillsTrained.isNotEmpty) {
      final skills = drill.skillsTrained
          .map((s) => kg.getSkill(s)?.nameVi ?? s)
          .join(', ');
      parts.add('Drill này giúp cải thiện: $skills.');
    }

    // What mistakes does it fix?
    if (drill.fixesMistakes.isNotEmpty) {
      parts.add('Đồng thời giúp sửa các lỗi: ${drill.fixesMistakes.map((m) => kg.getMistake(m)?.nameVi ?? m).join(', ')}.');
    }

    // Prerequisites met?
    if (drill.prerequisites.isNotEmpty) {
      final prereqs = drill.prerequisites
          .map((code) => kg.getDrill(code)?.nameVi ?? code)
          .join(', ');
      parts.add('Bạn đã có nền tảng từ: $prereqs.');
    }

    // Tips
    if (drill.tips.isNotEmpty) {
      parts.add('Lưu ý: ${drill.tips.first}');
    }

    return parts.join(' ');
  }

  String _buildWhyNowContext(PlayerIntelligence player, DrillNode drill) {
    final parts = <String>[];

    // Recent trend
    if (player.progress.currentTrend != TrendDirection.stable) {
      parts.add('Trong thời gian gần đây, bạn đang ${player.progress.currentTrend.label}.');
    }

    // Recent sessions
    final lastSession = player.shortTermMemory.getLastSession();
    if (lastSession != null) {
      final daysAgo = DateTime.now().difference(lastSession.timestamp).inDays;
      if (daysAgo == 0) {
        parts.add('Hôm nay bạn vừa tập ${lastSession.data['drillCode']}.');
      } else if (daysAgo == 1) {
        parts.add('Hôm qua bạn tập ${lastSession.data['drillCode']}.');
      } else {
        parts.add('Lần cuối tập là ${daysAgo} ngày trước.');
      }
    }

    // Top mistakes
    if (player.mistakePatterns.topMistakes.isNotEmpty) {
      final topMistake = player.mistakePatterns.topMistakes.first;
      parts.add('Lỗi bạn thường mắc là: $topMistake.');
    }

    // Overall confidence statement
    final confidence = player.toSummary().confidence;
    if (confidence > 70) {
      parts.add('Dựa trên ${player.practicePatterns.totalSessions} buổi tập, mình hiểu rõ phong cách của bạn.');
    } else if (confidence > 40) {
      parts.add('Sau ${player.practicePatterns.totalSessions} buổi tập, mình bắt đầu hiểu điểm mạnh và yếu của bạn.');
    } else {
      parts.add('Bạn mới bắt đầu, chúng ta sẽ cùng nhau xây dựng lộ trình phù hợp.');
    }

    return parts.join(' ');
  }

  /// Generate Coach statement about player
  String getCoachPlayerStatement() {
    return _playerIntelligence.toSummary().toCoachStatement();
  }

  /// Check if player is ready for advanced drills
  bool canAttemptDrill(String drillCode) {
    final kg = KnowledgeGraphService.instance;
    final graph = kg.graph;
    final drill = kg.getDrill(drillCode);

    if (drill == null) return false;
    if (drill.prerequisites.isEmpty) return true;

    // Check if prerequisites are met
    for (final prereqCode in drill.prerequisites) {
      // Simplified: check if skill level is high enough
      final prereqSkill = graph.getSkill(prereqCode);
      if (prereqSkill == null) continue;

      // TODO: Implement actual skill level check
    }

    return true;
  }

  /// Get recommended drills based on player profile
  List<DrillNode> getRecommendedDrills() {
    final kg = KnowledgeGraphService.instance;
    final player = _playerIntelligence;

    // Get drills for top weaknesses
    final recommendations = <DrillNode>{};

    for (final mistakeId in player.mistakePatterns.topMistakes) {
      final drills = kg.getDrillsForMistake(mistakeId);
      recommendations.addAll(drills.take(2));
    }

    // Filter by player level
    final playerLevel = player.skillProfile.overallLevel;

    return recommendations
        .where((d) => d.difficulty.index <= playerLevel.index + 1)
        .take(5)
        .toList();
  }
}
