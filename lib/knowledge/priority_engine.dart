// ============================================================================
// PRIORITY ENGINE - Phase 6B
// Coach Priority-First Recommendation System
//
// Coach knows WHAT to prioritize, not just WHAT to recommend.
// Every recommendation includes: Priority, Confidence, Reasoning, Evidence,
// Expected Outcome, Time Horizon, Success Criteria.
// ============================================================================

import 'player_intelligence.dart';
import 'knowledge_graph_service.dart';
import 'drill_node.dart';
import 'mistake_node.dart';
import 'cause_node.dart';

/// Priority Engine - Determines what Coach should focus on
class PriorityEngine {
  PriorityEngine({
    required PlayerIntelligence playerIntelligence,
    required KnowledgeGraphService knowledgeGraph,
    PriorityConstraint? constraint,
  })  : _player = playerIntelligence,
        _kg = knowledgeGraph,
        constraint = constraint ?? PriorityConstraint.defaultConstraint();

  final PlayerIntelligence _player;
  final KnowledgeGraphService _kg;
  final PriorityConstraint constraint;

  /// Get prioritized coaching plan
  CoachingPlan getCoachingPlan() {
    // 1. Identify all potential focus areas
    final focusAreas = _identifyFocusAreas();

    // 2. Score and prioritize
    final prioritized = _prioritize(focusAreas);

    // 3. Generate recommendations
    final recommendations = _generateRecommendations(prioritized);

    // 4. Generate today's recommendation
    final todayRecommendation = _getTodayRecommendation(recommendations);

    // 5. Identify what NOT to do
    final avoidRecommendations = _getAvoidRecommendations(prioritized);

    return CoachingPlan(
      playerProfile: _player.toSummary(),
      prioritizedFocusAreas: prioritized,
      todayRecommendation: todayRecommendation,
      avoidRecommendations: avoidRecommendations,
      longTermPlan: _getLongTermPlan(prioritized),
      reasoning: _buildPlanReasoning(prioritized),
    );
  }

  /// Identify all potential focus areas
  List<FocusArea> _identifyFocusAreas() {
    final areas = <FocusArea>[];
    final graph = _kg.graph;

    // From mistake patterns
    for (final mistakeId in _player.mistakePatterns.topMistakes) {
      final mistake = graph.getMistake(mistakeId);
      if (mistake == null) continue;

      final causes = graph.getCausesForMistake(mistakeId);
      final drills = graph.getDrillsForMistake(mistakeId);

      areas.add(FocusArea(
        type: FocusAreaType.mistakeFix,
        id: mistakeId,
        name: mistake.nameVi,
        urgency: _calculateMistakeUrgency(mistake),
        impact: _calculateMistakeImpact(mistake),
        effort: _calculateDrillEffort(drills),
        drills: drills,
        causes: causes,
      ));
    }

    // From skill weaknesses
    for (final entry in _player.skillProfile.skills.entries) {
      if (entry.value.level < 50) {
        final skill = graph.getSkill(entry.key);
        if (skill == null) continue;

        final drills = graph.getDrillsBySkill(entry.key);

        areas.add(FocusArea(
          type: FocusAreaType.skillImprovement,
          id: entry.key,
          name: skill.nameVi,
          urgency: _calculateSkillUrgency(entry.value),
          impact: _calculateSkillImpact(entry.value),
          effort: _calculateDrillEffort(drills),
          drills: drills,
          causes: [],
        ));
      }
    }

    // From trend (if declining)
    if (_player.progress.currentTrend == TrendDirection.declining) {
      areas.add(FocusArea(
        type: FocusAreaType.trendReversal,
        id: 'trend_reversal',
        name: 'Cải thiện xu hướng',
        urgency: PriorityLevel.high,
        impact: PriorityImpact.veryHigh,
        effort: PriorityEffort.medium,
        drills: _getTrendReversalDrills(),
        causes: [],
      ));
    }

    // From practice frequency (if inconsistent)
    if (_player.practicePatterns.consistency.regularity < 50) {
      areas.add(FocusArea(
        type: FocusAreaType.consistencyBuild,
        id: 'consistency',
        name: 'Xây dựng thói quen',
        urgency: PriorityLevel.medium,
        impact: PriorityImpact.veryHigh,
        effort: PriorityEffort.low,
        drills: [],
        causes: [],
      ));
    }

    return areas;
  }

  /// Calculate urgency for a mistake
  PriorityLevel _calculateMistakeUrgency(MistakeNode mistake) {
    final frequency = _player.mistakePatterns.patterns
        .where((p) => p.mistakeId == mistake.id)
        .fold(0, (sum, p) => sum + p.frequency);

    if (frequency > 10) return PriorityLevel.critical;
    if (frequency > 5) return PriorityLevel.high;
    if (frequency > 2) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  /// Calculate impact for a mistake
  PriorityImpact _calculateMistakeImpact(MistakeNode mistake) {
    switch (mistake.category) {
      case MistakeCategory.position:
        return PriorityImpact.high;
      case MistakeCategory.execution:
        return PriorityImpact.medium;
      case MistakeCategory.mental:
        return PriorityImpact.veryHigh;
      case MistakeCategory.strategy:
        return PriorityImpact.high;
      case MistakeCategory.safety:
        return PriorityImpact.medium;
    }
  }

  /// Calculate urgency for a skill
  PriorityLevel _calculateSkillUrgency(SkillLevel skill) {
    if (skill.level < 20) return PriorityLevel.high;
    if (skill.level < 40) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  /// Calculate impact for a skill
  PriorityImpact _calculateSkillImpact(SkillLevel skill) {
    if (skill.level < 20) return PriorityImpact.veryHigh;
    if (skill.level < 50) return PriorityImpact.high;
    return PriorityImpact.medium;
  }

  /// Calculate effort for drills
  PriorityEffort _calculateDrillEffort(List<DrillNode> drills) {
    if (drills.isEmpty) return PriorityEffort.low;
    if (drills.any((d) => d.difficulty == DrillDifficulty.expert)) {
      return PriorityEffort.high;
    }
    if (drills.any((d) => d.difficulty == DrillDifficulty.advanced)) {
      return PriorityEffort.medium;
    }
    return PriorityEffort.low;
  }

  /// Get drills for trend reversal
  List<DrillNode> _getTrendReversalDrills() {
    final graph = _kg.graph;
    return graph.getAllSkills()
        .take(3)
        .expand((s) => graph.getDrillsBySkill(s.id))
        .take(5)
        .toList();
  }

  /// Prioritize focus areas
  List<PrioritizedFocusArea> _prioritize(List<FocusArea> areas) {
    final prioritized = <PrioritizedFocusArea>[];

    for (final area in areas) {
      final score = _calculatePriorityScore(area);
      prioritized.add(PrioritizedFocusArea(
        focusArea: area,
        priorityScore: score,
        priority: _scoreToPriority(score),
        confidence: _calculateConfidence(area),
        reasoning: _buildReasoning(area),
        evidence: _buildEvidence(area),
      ));
    }

    // Sort by priority score
    prioritized.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    // Assign ranks
    for (var i = 0; i < prioritized.length; i++) {
      prioritized[i] = prioritized[i].copyWith(rank: i + 1);
    }

    return prioritized;
  }

  /// Calculate priority score (higher = more important)
  double _calculatePriorityScore(FocusArea area) {
    double score = 0;

    // Urgency weight: 40%
    score += _urgencyWeight(area.urgency) * 0.4;

    // Impact weight: 30%
    score += _impactWeight(area.impact) * 0.3;

    // Effort penalty: -20% (lower effort = higher score)
    score -= _effortWeight(area.effort) * 0.2;

    // Player level factor: 10%
    final playerLevel = _player.skillProfile.overallLevel;
    score += _levelFactor(playerLevel) * 0.1;

    return score;
  }

  double _urgencyWeight(PriorityLevel level) {
    switch (level) {
      case PriorityLevel.critical: return 1.0;
      case PriorityLevel.high: return 0.8;
      case PriorityLevel.medium: return 0.5;
      case PriorityLevel.low: return 0.2;
    }
  }

  double _impactWeight(PriorityImpact impact) {
    switch (impact) {
      case PriorityImpact.veryHigh: return 1.0;
      case PriorityImpact.high: return 0.7;
      case PriorityImpact.medium: return 0.4;
      case PriorityImpact.low: return 0.1;
    }
  }

  double _effortWeight(PriorityEffort effort) {
    switch (effort) {
      case PriorityEffort.low: return 0.0;
      case PriorityEffort.medium: return 0.3;
      case PriorityEffort.high: return 0.7;
    }
  }

  double _levelFactor(dynamic level) {
    // Beginners need more fundamentals
    return 0.5;
  }

  PriorityLevel _scoreToPriority(double score) {
    if (score > 0.7) return PriorityLevel.critical;
    if (score > 0.5) return PriorityLevel.high;
    if (score > 0.3) return PriorityLevel.medium;
    return PriorityLevel.low;
  }

  int _calculateConfidence(FocusArea area) {
    int confidence = 50;

    // More data = more confidence
    if (_player.practicePatterns.totalSessions > 10) confidence += 20;
    if (_player.practicePatterns.totalSessions > 20) confidence += 20;

    // Matching mistakes = more confidence
    if (area.type == FocusAreaType.mistakeFix) confidence += 30;

    return confidence.clamp(0, 100);
  }

  String _buildReasoning(FocusArea area) {
    switch (area.type) {
      case FocusAreaType.mistakeFix:
        return 'Lỗi này ảnh hưởng đến ${area.urgency.label} trận đấu của bạn. Cần sửa sớm.';
      case FocusAreaType.skillImprovement:
        return 'Kỹ năng này cần cải thiện để nâng level tổng thể.';
      case FocusAreaType.trendReversal:
        return 'Xu hướng đang giảm. Cần tập trung để ổn định.';
      case FocusAreaType.consistencyBuild:
        return 'Thói quen tập luyện chưa đều đặn. Cần xây dựng trước.';
    }
  }

  List<String> _buildEvidence(FocusArea area) {
    final evidence = <String>[];

    // Add frequency evidence
    if (area.type == FocusAreaType.mistakeFix) {
      final pattern = _player.mistakePatterns.patterns
          .where((p) => p.mistakeId == area.id)
          .firstOrNull;
      if (pattern != null) {
        evidence.add('Xuất hiện ${pattern.frequency} lần trong ${_player.practicePatterns.totalSessions} buổi');
        if (pattern.isImproving) {
          evidence.add('Đang có xu hướng cải thiện');
        } else {
          evidence.add('Cần tập trung sửa');
        }
      }
    }

    // Add trend evidence
    evidence.add('Xu hướng hiện tại: ${_player.progress.currentTrend.label}');
    evidence.add('Độ ổn định: ${_player.progress.consistencyScore}%');

    return evidence;
  }

  /// Generate recommendations from prioritized areas
  List<CoachingRecommendation> _generateRecommendations(
    List<PrioritizedFocusArea> prioritized,
  ) {
    final recommendations = <CoachingRecommendation>[];

    for (final area in prioritized.take(5)) {
      if (area.focusArea.drills.isEmpty) continue;

      final drill = area.focusArea.drills.first;

      recommendations.add(CoachingRecommendation(
        rank: area.rank,
        priority: area.priority,
        confidence: area.confidence,
        type: RecommendationType.focus,
        drillCode: drill.code,
        drillName: drill.nameVi,
        reason: area.reasoning,
        evidence: area.evidence,
        expectedImprovement: _getExpectedImprovement(area),
        timeHorizon: _getTimeHorizon(drill),
        successCriteria: _getSuccessCriteria(area, drill),
      ));
    }

    return recommendations;
  }

  /// Get today's recommendation (considering time constraint)
  CoachingRecommendation? _getTodayRecommendation(
    List<CoachingRecommendation> recommendations,
  ) {
    // Filter by time constraint
    final available = recommendations
        .where((r) => r.timeHorizon.inDays <= constraint.maxSessionDays)
        .toList();

    if (available.isEmpty && recommendations.isNotEmpty) {
      // Return highest priority anyway
      return recommendations.first.copyWith(
        type: RecommendationType.today,
      );
    }

    if (available.isNotEmpty) {
      return available.first.copyWith(
        type: RecommendationType.today,
      );
    }

    return null;
  }

  /// Get recommendations to AVOID
  List<AvoidRecommendation> _getAvoidRecommendations(
    List<PrioritizedFocusArea> prioritized,
  ) {
    final avoid = <AvoidRecommendation>[];

    // If player is declining, avoid hard drills
    if (_player.progress.currentTrend == TrendDirection.declining) {
      avoid.add(AvoidRecommendation(
        item: 'Drill khó',
        reason: 'Bạn đang trong giai đoạn sa sút. Tập drill dễ để lấy lại confidence.',
        alternative: 'Quay lại drill cơ bản đã thành thạo.',
      ));
    }

    // If inconsistent, avoid changing routine
    if (_player.practicePatterns.consistency.regularity < 50) {
      avoid.add(AvoidRecommendation(
        item: 'Thay đổi kế hoạch tập',
        reason: 'Bạn chưa có thói quen ổn định. Tập trung xây dựng routine trước.',
        alternative: 'Tập cùng drill, cùng thời gian mỗi ngày.',
      ));
    }

    // If fatigue (too many sessions), avoid intensity
    if (_player.practicePatterns.sessionsThisWeek > 5) {
      avoid.add(AvoidRecommendation(
        item: 'Tập quá sức',
        reason: 'Tuần này bạn đã tập ${_player.practicePatterns.sessionsThisWeek} buổi. Nghỉ ngơi cũng là luyện tập.',
        alternative: 'Tập nhẹ nhàng hoặc nghỉ 1 ngày.',
      ));
    }

    // If just did a drill, don't repeat immediately
    final lastSession = _player.shortTermMemory.getLastSession();
    if (lastSession != null) {
      final daysAgo = DateTime.now().difference(lastSession.timestamp).inDays;
      if (daysAgo == 0) {
        avoid.add(AvoidRecommendation(
          item: 'Tập lại drill hôm nay',
          reason: 'Bạn vừa tập rồi. Nghỉ để cơ bắp hồi phục.',
          alternative: 'Tập drill khác hoặc xem lại video.',
        ));
      }
    }

    return avoid;
  }

  /// Get long-term plan
  LongTermPlan _getLongTermPlan(List<PrioritizedFocusArea> prioritized) {
    final phases = <PlanPhase>[];

    // Phase 1: Immediate (1-2 weeks)
    if (prioritized.isNotEmpty) {
      phases.add(PlanPhase(
        name: 'Giai đoạn 1: Cải thiện cấp bách',
        durationWeeks: 2,
        focusAreas: prioritized.take(2).map((p) => p.focusArea.name).toList(),
        targetOutcomes: ['Giảm 50% lỗi', 'Accuracy > 75%'],
      ));
    }

    // Phase 2: Medium-term (2-4 weeks)
    if (prioritized.length > 2) {
      phases.add(PlanPhase(
        name: 'Giai đoạn 2: Xây dựng nền tảng',
        durationWeeks: 4,
        focusAreas: prioritized.skip(2).take(3).map((p) => p.focusArea.name).toList(),
        targetOutcomes: ['Xu hướng ổn định', 'Tăng consistency'],
      ));
    }

    // Phase 3: Long-term (1-3 months)
    phases.add(PlanPhase(
      name: 'Giai đoạn 3: Lên level',
      durationWeeks: 12,
      focusAreas: ['Tất cả kỹ năng cơ bản', 'Match practice'],
      targetOutcomes: ['Level tiếp theo', 'Win rate tăng'],
    ));

    return LongTermPlan(
      phases: phases,
      estimatedCompletionWeeks: phases.fold(0, (sum, p) => sum + p.durationWeeks),
    );
  }

  String _buildPlanReasoning(List<PrioritizedFocusArea> prioritized) {
    final parts = <String>[];

    if (prioritized.isEmpty) {
      return 'Bạn đang tiến bộ tốt. Tiếp tục duy trì!';
    }

    parts.add('Dựa trên ${_player.practicePatterns.totalSessions} buổi tập và ${_player.matchPatterns.totalMatches} trận đấu:');

    // Top priority
    if (prioritized.isNotEmpty) {
      final top = prioritized.first;
      parts.add('Ưu tiên #1: ${top.focusArea.name}');
      parts.add('Lý do: ${top.reasoning}');
    }

    // Trend
    if (_player.progress.currentTrend != TrendDirection.stable) {
      parts.add('Xu hướng: ${_player.progress.currentTrend.label} - cần chú ý.');
    }

    return parts.join('\n');
  }

  ExpectedImprovement _getExpectedImprovement(PrioritizedFocusArea area) {
    return ExpectedImprovement(
      metric: area.focusArea.type == FocusAreaType.mistakeFix
          ? 'Tỷ lệ lỗi'
          : 'Skill level',
      currentValue: area.focusArea.type == FocusAreaType.mistakeFix ? 'Cao' : '50%',
      expectedValue: area.focusArea.type == FocusAreaType.mistakeFix ? 'Thấp' : '70%',
      improvementPercent: 20,
    );
  }

  Duration _getTimeHorizon(DrillNode drill) {
    switch (drill.difficulty) {
      case DrillDifficulty.beginner:
        return const Duration(days: 7);
      case DrillDifficulty.intermediate:
        return const Duration(days: 14);
      case DrillDifficulty.advanced:
        return const Duration(days: 30);
      case DrillDifficulty.expert:
        return const Duration(days: 60);
    }
  }

  List<String> _getSuccessCriteria(PrioritizedFocusArea area, DrillNode drill) {
    return [
      'Accuracy ${drill.metrics.contains('accuracy') ? '> 80%' : ''}',
      'Consistency > 70%',
      'Hoàn thành 3 levels đầu tiên',
    ];
  }
}

// ============================================================================
// PRIORITY CONSTRAINTS
// ============================================================================

class PriorityConstraint {
  final int maxSessionMinutes;
  final int maxSessionDays;
  final int sessionsPerWeek;
  final bool allowRecoveryDays;

  const PriorityConstraint({
    required this.maxSessionMinutes,
    required this.maxSessionDays,
    required this.sessionsPerWeek,
    this.allowRecoveryDays = true,
  });

  factory PriorityConstraint.defaultConstraint() {
    return const PriorityConstraint(
      maxSessionMinutes: 30,
      maxSessionDays: 1,
      sessionsPerWeek: 3,
      allowRecoveryDays: true,
    );
  }

  factory PriorityConstraint.busyConstraint() {
    return const PriorityConstraint(
      maxSessionMinutes: 15,
      maxSessionDays: 3,
      sessionsPerWeek: 2,
      allowRecoveryDays: true,
    );
  }

  factory PriorityConstraint.competitiveConstraint() {
    return const PriorityConstraint(
      maxSessionMinutes: 60,
      maxSessionDays: 1,
      sessionsPerWeek: 5,
      allowRecoveryDays: false,
    );
  }
}

// ============================================================================
// PRIORITY ENUMS
// ============================================================================

enum PriorityLevel {
  critical,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case PriorityLevel.critical:
        return 'Ngay lập tức';
      case PriorityLevel.high:
        return 'Cao';
      case PriorityLevel.medium:
        return 'Trung bình';
      case PriorityLevel.low:
        return 'Thấp';
    }
  }
}

enum PriorityImpact {
  veryHigh,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case PriorityImpact.veryHigh:
        return 'Rất cao';
      case PriorityImpact.high:
        return 'Cao';
      case PriorityImpact.medium:
        return 'Trung bình';
      case PriorityImpact.low:
        return 'Thấp';
    }
  }
}

enum PriorityEffort {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case PriorityEffort.low:
        return 'Dễ';
      case PriorityEffort.medium:
        return 'Trung bình';
      case PriorityEffort.high:
        return 'Khó';
    }
  }
}

enum FocusAreaType {
  mistakeFix,
  skillImprovement,
  trendReversal,
  consistencyBuild;

  String get label {
    switch (this) {
      case FocusAreaType.mistakeFix:
        return 'Sửa lỗi';
      case FocusAreaType.skillImprovement:
        return 'Cải thiện kỹ năng';
      case FocusAreaType.trendReversal:
        return 'Đảo chiều xu hướng';
      case FocusAreaType.consistencyBuild:
        return 'Xây dựng thói quen';
    }
  }
}

// ============================================================================
// FOCUS AREA
// ============================================================================

class FocusArea {
  final FocusAreaType type;
  final String id;
  final String name;
  final PriorityLevel urgency;
  final PriorityImpact impact;
  final PriorityEffort effort;
  final List<DrillNode> drills;
  final List<CauseNode> causes;

  const FocusArea({
    required this.type,
    required this.id,
    required this.name,
    required this.urgency,
    required this.impact,
    required this.effort,
    required this.drills,
    required this.causes,
  });
}

class PrioritizedFocusArea {
  final FocusArea focusArea;
  final double priorityScore;
  final PriorityLevel priority;
  final int confidence;
  final String reasoning;
  final List<String> evidence;
  final int rank;

  const PrioritizedFocusArea({
    required this.focusArea,
    required this.priorityScore,
    required this.priority,
    required this.confidence,
    required this.reasoning,
    required this.evidence,
    this.rank = 0,
  });

  PrioritizedFocusArea copyWith({
    int? rank,
  }) {
    return PrioritizedFocusArea(
      focusArea: focusArea,
      priorityScore: priorityScore,
      priority: priority,
      confidence: confidence,
      reasoning: reasoning,
      evidence: evidence,
      rank: rank ?? this.rank,
    );
  }
}

// ============================================================================
// COACHING PLAN OUTPUT
// ============================================================================

class CoachingPlan {
  final PlayerSummary playerProfile;
  final List<PrioritizedFocusArea> prioritizedFocusAreas;
  final CoachingRecommendation? todayRecommendation;
  final List<AvoidRecommendation> avoidRecommendations;
  final LongTermPlan longTermPlan;
  final String reasoning;

  const CoachingPlan({
    required this.playerProfile,
    required this.prioritizedFocusAreas,
    this.todayRecommendation,
    required this.avoidRecommendations,
    required this.longTermPlan,
    required this.reasoning,
  });

  String toCoachStatement() {
    final parts = <String>[];

    // Header
    parts.add('Xin chào ${playerProfile.name}!');

    // Today's focus
    if (todayRecommendation != null) {
      parts.add('\n📌 HÔM NAY: ${todayRecommendation!.drillName}');
      parts.add('Lý do: ${todayRecommendation!.reason}');
      if (todayRecommendation!.evidence.isNotEmpty) {
        parts.add('Bằng chứng: ${todayRecommendation!.evidence.first}');
      }
    }

    // Avoid
    if (avoidRecommendations.isNotEmpty) {
      parts.add('\n🚫 HÔM NAY KHÔNG NÊN:');
      for (final avoid in avoidRecommendations) {
        parts.add('- ${avoid.item}: ${avoid.reason}');
      }
    }

    // Long-term
    if (longTermPlan.phases.isNotEmpty) {
      parts.add('\n📅 KẾ HOẠCH:');
      for (final phase in longTermPlan.phases) {
        parts.add('${phase.name} (${phase.durationWeeks} tuần)');
        parts.add('  Tập trung: ${phase.focusAreas.join(', ')}');
      }
    }

    // Closing
    parts.add('\nChúc bạn tập vui! 💪');

    return parts.join('\n');
  }
}

class CoachingRecommendation {
  final int rank;
  final PriorityLevel priority;
  final int confidence;
  final RecommendationType type;
  final String drillCode;
  final String drillName;
  final String reason;
  final List<String> evidence;
  final ExpectedImprovement expectedImprovement;
  final Duration timeHorizon;
  final List<String> successCriteria;

  const CoachingRecommendation({
    required this.rank,
    required this.priority,
    required this.confidence,
    required this.type,
    required this.drillCode,
    required this.drillName,
    required this.reason,
    required this.evidence,
    required this.expectedImprovement,
    required this.timeHorizon,
    required this.successCriteria,
  });

  CoachingRecommendation copyWith({
    RecommendationType? type,
  }) {
    return CoachingRecommendation(
      rank: rank,
      priority: priority,
      confidence: confidence,
      type: type ?? this.type,
      drillCode: drillCode,
      drillName: drillName,
      reason: reason,
      evidence: evidence,
      expectedImprovement: expectedImprovement,
      timeHorizon: timeHorizon,
      successCriteria: successCriteria,
    );
  }
}

enum RecommendationType {
  today,
  focus,
  maintain,
  delay,
  review;

  String get label {
    switch (this) {
      case RecommendationType.today:
        return 'Hôm nay';
      case RecommendationType.focus:
        return 'Tập trung';
      case RecommendationType.maintain:
        return 'Duy trì';
      case RecommendationType.delay:
        return 'Tạm hoãn';
      case RecommendationType.review:
        return 'Xem lại';
    }
  }
}

class AvoidRecommendation {
  final String item;
  final String reason;
  final String alternative;

  const AvoidRecommendation({
    required this.item,
    required this.reason,
    required this.alternative,
  });
}

class ExpectedImprovement {
  final String metric;
  final String currentValue;
  final String expectedValue;
  final int improvementPercent;

  const ExpectedImprovement({
    required this.metric,
    required this.currentValue,
    required this.expectedValue,
    required this.improvementPercent,
  });
}

class LongTermPlan {
  final List<PlanPhase> phases;
  final int estimatedCompletionWeeks;

  const LongTermPlan({
    required this.phases,
    required this.estimatedCompletionWeeks,
  });
}

class PlanPhase {
  final String name;
  final int durationWeeks;
  final List<String> focusAreas;
  final List<String> targetOutcomes;

  const PlanPhase({
    required this.name,
    required this.durationWeeks,
    required this.focusAreas,
    required this.targetOutcomes,
  });
}
