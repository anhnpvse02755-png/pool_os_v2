// ============================================================================
// Coach Rules Engine V3 - Expert Billiards Coaching System
// ============================================================================
// Implements rule-based coaching with 10 core skills
// Data-driven recommendations based on player performance
// ============================================================================

import '../../core/utils/drills_library.dart';
import '../../data/models/drill_progress.dart';
import '../../data/models/match.dart';

/// ============================================================================
// PLAYER SKILL MODEL
// ============================================================================

/// 10 Core Skills that define a pool player's ability
enum CoachSkill {
  // POTTING Category
  aim('Aim', 'Ngắm', 'potting'),
  thinCut('Thin Cut', 'Cắt mỏng', 'potting'),
  thickCut('Thick Cut', 'Cắt dày', 'potting'),
  longPot('Long Pot', 'Đánh xa', 'potting'),
  pocketSpeed('Pocket Speed', 'Tốc độ vào lỗ', 'potting'),

  // CONTROL Category
  stopShot('Stop Shot', 'Dừng bi', 'control'),
  follow('Follow', 'Follow', 'control'),
  draw('Draw', 'Draw', 'control'),
  spin('Spin Control', 'Kiểm soát xoáy', 'control'),
  speedControl('Speed Control', 'Kiểm soát lực', 'control'),

  // POSITION Category
  oneRail('1-Rail Position', 'Position 1 băng', 'position'),
  twoRail('2-Rail Position', 'Position 2 băng', 'position'),
  naturalAngle('Natural Angle', 'Góc tự nhiên', 'position'),
  keyBall('Key Ball', 'Bi chủ chốt', 'position'),
  positionRecovery('Position Recovery', 'Phục hồi vị trí', 'position'),

  // SAFETY Category
  distanceSafety('Distance Safety', 'Safety khoảng cách', 'safety'),
  hookSafety('Hook Safety', 'Safety móc', 'safety'),
  containingSafety('Containing Safety', 'Safety nhốt', 'safety'),
  kickSafe('Kick Safe', 'Kick an toàn', 'safety'),
  twoWay('Two-Way Shot', 'Đánh hai hướng', 'safety'),

  // BANK/KICK Category
  shortBank('Short Bank', 'Bank ngắn', 'bank'),
  longBank('Long Bank', 'Bank dài', 'bank'),
  oneRailKick('1-Rail Kick', 'Kick 1 băng', 'kick'),
  twoRailKick('2-Rail Kick', 'Kick 2 băng', 'kick'),
  diamondSystem('Diamond System', 'Hệ thống kim cương', 'bank'),

  // BREAK Category
  powerBreak('Power Break', 'Phá lực mạnh', 'break'),
  controlBreak('Control Break', 'Phá kiểm soát', 'break'),
  spread('Break Spread', 'Phết bóng', 'break'),
  scratchPrevention('Scratch Prevention', 'Tránh scratch', 'break'),
  wingBall('Wing Ball', 'Bi cánh', 'break'),

  // MENTAL Category
  confidence('Confidence', 'Tự tin', 'mental'),
  focus('Focus', 'Tập trung', 'mental'),
  pressure('Pressure Play', 'Chơi áp lực', 'mental'),
  mentalRecovery('Recovery', 'Phục hồi tinh thần', 'mental'),
  tiltControl('Tilt Control', 'Kiểm soát tilt', 'mental'),

  // PATTERN Category
  tableRead('Table Read', 'Đọc bàn', 'pattern'),
  clusterPlay('Cluster Play', 'Chơi cụm bi', 'pattern'),
  runOut('Run Out', 'Đánh hết', 'pattern'),
  endGame('End Game', 'Kết thúc game', 'pattern'),
  multiRailPattern('Multi-Rail Pattern', 'Mẫu đa băng', 'pattern');

  final String name;
  final String nameVi;
  final String category;

  const CoachSkill(this.name, this.nameVi, this.category);
}

/// Skill score with evidence
class SkillScore {
  final CoachSkill skill;
  final double score; // 0.0 - 1.0
  final int attempts;
  final int successes;
  final DateTime? lastTested;

  SkillScore({
    required this.skill,
    required this.score,
    required this.attempts,
    required this.successes,
    this.lastTested,
  });

  String get grade {
    if (score >= 0.85) return 'A';
    if (score >= 0.70) return 'B';
    if (score >= 0.55) return 'C';
    if (score >= 0.40) return 'D';
    return 'F';
  }
}

/// ============================================================================
// PROBLEM DETECTION
// ============================================================================

enum ProblemSeverity { critical, urgent, priority, maintenance }

class DetectedProblem {
  final CoachSkill skill;
  final String description;
  final String evidence;
  final double severity;
  final ProblemSeverity priority;
  final List<String> drillCodes;

  DetectedProblem({
    required this.skill,
    required this.description,
    required this.evidence,
    required this.severity,
    required this.priority,
    required this.drillCodes,
  });
}

/// ============================================================================
// RECOMMENDATION ENGINE
// ============================================================================

enum RecommendationPriority { urgent, priority, maintenance, exploration }

class CoachRecommendation {
  final String title;
  final String titleVi;
  final String reason;
  final String drillCode;
  final String drillName;
  final String drillNameVi;
  final String instructions;
  final int durationMinutes;
  final RecommendationPriority priority;
  final String expectedResult;
  final CoachSkill targetSkill;
  final DateTime createdAt;
  final DateTime? validUntil;

  CoachRecommendation({
    required this.title,
    required this.titleVi,
    required this.reason,
    required this.drillCode,
    required this.drillName,
    required this.drillNameVi,
    required this.instructions,
    required this.durationMinutes,
    required this.priority,
    required this.expectedResult,
    required this.targetSkill,
    required this.createdAt,
    this.validUntil,
  });

  bool get isExpired =>
      validUntil != null && DateTime.now().isAfter(validUntil!);
}

/// ============================================================================
// COACH RULES ENGINE V3
// ============================================================================

class CoachRulesEngine {
  // Singleton pattern
  static final CoachRulesEngine _instance = CoachRulesEngine._internal();
  factory CoachRulesEngine() => _instance;
  CoachRulesEngine._internal();

  // Recent recommendations (avoid repeating for 14 days)
  final List<CoachRecommendation> _recentRecommendations = [];
  static const int _recommendationCooldownDays = 14;

  // ==========================================================================
  // MAIN ANALYSIS METHODS
  // ==========================================================================

  /// Analyze player performance and return skill scores
  Map<CoachSkill, SkillScore> analyzePlayer({
    required List<DrillProgress> drillProgress,
    required List<Match> matchHistory,
  }) {
    final scores = <CoachSkill, SkillScore>{};

    // Map drill progress to skills
    for (final progress in drillProgress) {
      final skills = _mapDrillToSkills(progress.drillCode);
      final score = _calculateSkillScore(progress);

      for (final skill in skills) {
        if (scores.containsKey(skill)) {
          // Average with existing score
          final existing = scores[skill]!;
          final newAttempts = existing.attempts + progress.attempts;
          final newSuccesses = existing.successes + (progress.successRate * progress.attempts / 100).round();
          scores[skill] = SkillScore(
            skill: skill,
            score: newSuccesses / newAttempts,
            attempts: newAttempts,
            successes: newSuccesses.toInt(),
            lastTested: progress.completedAt,
          );
        } else {
          scores[skill] = SkillScore(
            skill: skill,
            score: score,
            attempts: progress.attempts,
            successes: (progress.successRate * progress.attempts / 100).round(),
            lastTested: progress.completedAt,
          );
        }
      }
    }

    // Add match-based analysis
    _analyzeMatchPerformance(matchHistory, scores);

    // Initialize missing skills with default score
    for (final skill in CoachSkill.values) {
      if (!scores.containsKey(skill)) {
        scores[skill] = SkillScore(
          skill: skill,
          score: 0.5, // Default average
          attempts: 0,
          successes: 0,
        );
      }
    }

    return scores;
  }

  /// Detect problems based on skill scores
  List<DetectedProblem> detectProblems(Map<CoachSkill, SkillScore> scores) {
    final problems = <DetectedProblem>[];

    for (final entry in scores.entries) {
      final skill = entry.key;
      final score = entry.value;

      // Critical: score < 40%
      if (score.score < 0.40 && score.attempts >= 5) {
        final drills = _getDrillsForSkill(skill);
        problems.add(DetectedProblem(
          skill: skill,
          description: '${skill.nameVi} cần cải thiện ngay',
          evidence: 'Tỷ lệ thành công: ${(score.score * 100).toInt()}% (${score.successes}/${score.attempts} lần)',
          severity: score.score < 0.25 ? 0.9 : 0.7,
          priority: score.score < 0.25
              ? ProblemSeverity.critical
              : ProblemSeverity.urgent,
          drillCodes: drills,
        ));
      }
      // Priority: score < 55%
      else if (score.score < 0.55 && score.attempts >= 3) {
        problems.add(DetectedProblem(
          skill: skill,
          description: '${skill.nameVi} có thể cải thiện',
          evidence: 'Tỷ lệ thành công: ${(score.score * 100).toInt()}%',
          severity: 0.5,
          priority: ProblemSeverity.priority,
          drillCodes: _getDrillsForSkill(skill),
        ));
      }
    }

    // Sort by severity
    problems.sort((a, b) => b.severity.compareTo(a.severity));
    return problems;
  }

  /// Generate recommendations based on problems and player context
  List<CoachRecommendation> generateRecommendations({
    required List<DetectedProblem> problems,
    required Map<CoachSkill, SkillScore> scores,
    String playerLevel = 'intermediate', // beginner, intermediate, advanced
  }) {
    final recommendations = <CoachRecommendation>[];

    // VN players context: Strong natural position, Weak spin control
    final vnContext = _analyzeVNContext(scores);

    for (final problem in problems) {
      // Skip if recently recommended
      if (_wasRecentlyRecommended(problem.skill)) continue;

      // Get drill for this skill
      final drillCode = _selectBestDrill(problem.drillCodes, scores, playerLevel);
      final drill = DrillLibrary.getDrill(drillCode);

      if (drill == null) continue;

      // Determine priority based on problem severity and VN context
      final priority = _determinePriority(problem, vnContext);

      recommendations.add(CoachRecommendation(
        title: 'Tập ${drill.name}',
        titleVi: 'Tập ${drill.nameVi}',
        reason: problem.evidence,
        drillCode: drillCode,
        drillName: drill.name,
        drillNameVi: drill.nameVi,
        instructions: _generateInstructions(drill, problem.skill),
        durationMinutes: 15 + (drill.levels.length * 5),
        priority: priority,
        expectedResult: _getExpectedResult(problem.skill),
        targetSkill: problem.skill,
        createdAt: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 7)),
      ));

      _recentRecommendations.add(recommendations.last);
    }

    // Sort by priority
    recommendations.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return recommendations.take(5).toList();
  }

  /// Generate Vietnamese coach message
  String generateCoachMessage(List<CoachRecommendation> recommendations) {
    if (recommendations.isEmpty) {
      return '🎉 Bạn đang làm rất tốt!\n\n'
          'Tiếp tục luyện tập để duy trì phong độ.\n'
          'Hãy thử các bài tập nâng cao nhé!';
    }

    final buffer = StringBuffer();
    buffer.writeln('🎯 HÔM NAY BẠN NÊN TẬP:\n');

    for (var i = 0; i < recommendations.length && i < 3; i++) {
      final rec = recommendations[i];
      buffer.writeln('${i + 1}. ${rec.titleVi} - ${rec.durationMinutes} phút');
      buffer.writeln('   Tại sao: ${rec.reason}');
      buffer.writeln('   Cách tập: ${rec.instructions}');
      buffer.writeln();
    }

    return buffer.toString();
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Map drill code to related skills
  List<CoachSkill> _mapDrillToSkills(String drillCode) {
    final upper = drillCode.toUpperCase();

    // Aiming drills
    if (upper.contains('STRAIGHT')) return [CoachSkill.aim, CoachSkill.longPot];
    if (upper.contains('THIN_CUT')) return [CoachSkill.thinCut, CoachSkill.aim];
    if (upper.contains('THICK_CUT')) return [CoachSkill.thickCut, CoachSkill.aim];
    if (upper.contains('HALF_BALL')) return [CoachSkill.aim, CoachSkill.pocketSpeed];
    if (upper.contains('LONG_POT')) return [CoachSkill.longPot, CoachSkill.aim];

    // Cue ball control drills
    if (upper.contains('STOP')) return [CoachSkill.stopShot, CoachSkill.speedControl];
    if (upper.contains('FOLLOW')) return [CoachSkill.follow, CoachSkill.spin];
    if (upper.contains('DRAW')) return [CoachSkill.draw, CoachSkill.spin];
    if (upper.contains('STUN')) return [CoachSkill.speedControl, CoachSkill.aim];

    // Position drills
    if (upper.contains('POSITION')) return [CoachSkill.oneRail, CoachSkill.twoRail];
    if (upper.contains('3_BALL') || upper.contains('5_BALL')) {
      return [CoachSkill.keyBall, CoachSkill.naturalAngle];
    }

    // Spin drills
    if (upper.contains('ENGLISH') || upper.contains('SPIN')) {
      return [CoachSkill.spin, CoachSkill.positionRecovery];
    }

    // Safety drills
    if (upper.contains('SAFETY')) return [CoachSkill.distanceSafety, CoachSkill.containingSafety];
    if (upper.contains('KICK')) return [CoachSkill.kickSafe, CoachSkill.oneRailKick];

    // Bank drills
    if (upper.contains('BANK')) return [CoachSkill.shortBank, CoachSkill.longBank];
    if (upper.contains('DIAMOND')) return [CoachSkill.diamondSystem, CoachSkill.longBank];

    // Break drills
    if (upper.contains('BREAK_POWER')) return [CoachSkill.powerBreak, CoachSkill.spread];
    if (upper.contains('BREAK_CONTROL')) return [CoachSkill.controlBreak, CoachSkill.scratchPrevention];

    // Pattern drills
    if (upper.contains('PATTERN')) return [CoachSkill.tableRead, CoachSkill.runOut];
    if (upper.contains('CLUSTER')) return [CoachSkill.clusterPlay, CoachSkill.endGame];

    // Default: fundamental skill
    return [CoachSkill.focus, CoachSkill.confidence];
  }

  double _calculateSkillScore(DrillProgress progress) {
    if (progress.attempts == 0) return 0.5;
    // Use successRate which is bestScore / attempts * 100
    return progress.successRate / 100.0;
  }

  void _analyzeMatchPerformance(List<Match> matches, Map<CoachSkill, SkillScore> scores) {
    if (matches.isEmpty) return;

    // Calculate win rate
    final wins = matches.where((m) => m.isWin).length;
    final winRate = wins / matches.length;

    // High win rate = good mental game
    scores[CoachSkill.confidence] = SkillScore(
      skill: CoachSkill.confidence,
      score: winRate,
      attempts: matches.length,
      successes: wins,
    );

    // Analyze racks for specific skills
    int totalPocketed = 0;
    int totalAttempted = 0;
    int totalBreaks = 0;
    int successfulBreaks = 0;

    for (final match in matches) {
      for (final rack in match.racks) {
        totalPocketed += rack.totalBallsPotted;
        totalAttempted += 15; // Standard balls per rack
        if (rack.breakShot) {
          totalBreaks++;
          if (rack.isWin) successfulBreaks++;
        }
      }
    }

    if (totalAttempted > 0) {
      scores[CoachSkill.pocketSpeed] = SkillScore(
        skill: CoachSkill.pocketSpeed,
        score: totalPocketed / totalAttempted,
        attempts: totalAttempted,
        successes: totalPocketed,
      );
    }

    if (totalBreaks > 0) {
      scores[CoachSkill.powerBreak] = SkillScore(
        skill: CoachSkill.powerBreak,
        score: successfulBreaks / totalBreaks,
        attempts: totalBreaks,
        successes: successfulBreaks,
      );
    }
  }

  List<String> _getDrillsForSkill(CoachSkill skill) {
    final drills = <String>[];

    switch (skill) {
      case CoachSkill.aim:
      case CoachSkill.longPot:
        drills.addAll(['STRAIGHT_NEAR', 'STRAIGHT_MID', 'STRAIGHT_FAR', 'LONG_POT_1M']);
        break;
      case CoachSkill.thinCut:
        drills.addAll(['THIN_CUT_30', 'THIN_CUT_45']);
        break;
      case CoachSkill.thickCut:
        drills.addAll(['THICK_CUT_30', 'THICK_CUT_45', 'THICK_CUT_60']);
        break;
      case CoachSkill.stopShot:
        drills.addAll(['STOP_BALL']);
        break;
      case CoachSkill.follow:
        drills.addAll(['FOLLOW_SHOT', 'FOLLOW_FAR']);
        break;
      case CoachSkill.draw:
        drills.addAll(['DRAW_SHOT', 'DRAW_BACK_FAR']);
        break;
      case CoachSkill.spin:
        drills.addAll(['LEFT_ENGLISH_NEAR', 'RIGHT_ENGLISH_NEAR', 'TOP_SPIN_CONTROL']);
        break;
      case CoachSkill.oneRail:
      case CoachSkill.twoRail:
        drills.addAll(['POSITION_BASIC', 'POSITION_3BALL']);
        break;
      case CoachSkill.shortBank:
      case CoachSkill.longBank:
        drills.add('BANK_SHOT');
        break;
      case CoachSkill.kickSafe:
        drills.add('KICK_SHOT');
        break;
      case CoachSkill.powerBreak:
      case CoachSkill.controlBreak:
        drills.addAll(['BREAK_POWER', 'BREAK_CONTROL']);
        break;
      default:
        drills.add('STROKE_STRAIGHT');
    }

    return drills;
  }

  String _selectBestDrill(List<String> drillCodes, Map<CoachSkill, SkillScore> scores, String level) {
    if (drillCodes.isEmpty) return 'STROKE_STRAIGHT';

    // Find drill with lowest average score
    String bestDrill = drillCodes.first;
    double lowestScore = 1.0;

    for (final code in drillCodes) {
      final skills = _mapDrillToSkills(code);
      double totalScore = 0;
      int count = 0;

      for (final skill in skills) {
        if (scores.containsKey(skill)) {
          totalScore += scores[skill]!.score;
          count++;
        }
      }

      if (count > 0) {
        final avgScore = totalScore / count;
        if (avgScore < lowestScore) {
          lowestScore = avgScore;
          bestDrill = code;
        }
      }
    }

    return bestDrill;
  }

  RecommendationPriority _determinePriority(DetectedProblem problem, bool isVNContext) {
    // VN players: Spin control is more critical
    if (isVNContext && problem.skill == CoachSkill.spin) {
      return RecommendationPriority.urgent;
    }

    switch (problem.priority) {
      case ProblemSeverity.critical:
        return RecommendationPriority.urgent;
      case ProblemSeverity.urgent:
        return RecommendationPriority.priority;
      case ProblemSeverity.priority:
        return RecommendationPriority.maintenance;
      case ProblemSeverity.maintenance:
        return RecommendationPriority.exploration;
    }
  }

  bool _analyzeVNContext(Map<CoachSkill, SkillScore> scores) {
    // VN players typically strong in position, weak in spin
    final spinScore = scores[CoachSkill.spin]?.score ?? 0.5;
    final positionScore = scores[CoachSkill.oneRail]?.score ?? 0.5;
    return positionScore > spinScore;
  }

  bool _wasRecentlyRecommended(CoachSkill skill) {
    final cutoff = DateTime.now().subtract(const Duration(days: _recommendationCooldownDays));
    return _recentRecommendations.any(
      (rec) => rec.targetSkill == skill && rec.createdAt.isAfter(cutoff),
    );
  }

  String _generateInstructions(Drill drill, CoachSkill skill) {
    final level = drill.levels.isNotEmpty ? drill.levels.first : null;

    switch (skill) {
      case CoachSkill.stopShot:
        return 'Điểm đánh dưới tâm bi cái, đánh vừa phải, dừng bi tại vị trí chỉ định';
      case CoachSkill.follow:
        return 'Điểm đánh trên tâm bi cái, đánh mạnh hơn bình thường 20%';
      case CoachSkill.draw:
        return 'Điểm đánh dưới tâm bi cái, đánh mạnh, bi quay về sau khi chạm';
      case CoachSkill.thinCut:
        return 'Xác định góc cắt, ngắm điểm chính xác, kiểm soát lực';
      case CoachSkill.longPot:
        return 'Ngắm chuẩn, kiểm soát lực đầy đủ, follow through';
      default:
        return drill.steps.isNotEmpty
            ? drill.steps.take(3).join(', ')
            : 'Thực hiện bài tập theo hướng dẫn';
    }
  }

  String _getExpectedResult(CoachSkill skill) {
    switch (skill) {
      case CoachSkill.stopShot:
        return 'Cải thiện khả năng dừng bi chính xác';
      case CoachSkill.follow:
        return 'Tăng khoảng cách follow với kiểm soát';
      case CoachSkill.draw:
        return 'Cải thiện draw với độ chính xác cao';
      case CoachSkill.spin:
        return 'Kiểm soát xoáy tốt hơn trong mọi tình huống';
      case CoachSkill.thinCut:
        return 'Đánh cắt mỏng chính xác hơn';
      case CoachSkill.longPot:
        return 'Tăng tỷ lệ đánh xa thành công';
      default:
        return 'Cải thiện kỹ năng ${skill.nameVi}';
    }
  }
}
