// ============================================================================
// COACH SERVICE - Phase 7 / Sprint-13
// Orchestrates Coach Brain for Conversation
//
// All responses go through Coach Brain first.
// LLM only generates natural language.
// Sprint-13: Now receives real PlayerIntelligence for streak-aware recommendations.
// ============================================================================

import 'player_intelligence.dart';
import 'knowledge_graph_service.dart';
import 'priority_engine.dart';
import 'conversation_engine.dart';

/// Coach Service - Orchestrates Coach Brain
class CoachService {
  CoachService({
    required KnowledgeGraphService knowledgeGraph,
    PlayerIntelligence? playerIntelligence,
  }) : _kg = knowledgeGraph,
       _playerIntelligence = playerIntelligence;

  final KnowledgeGraphService _kg;
  final PlayerIntelligence? _playerIntelligence;

  /// Get reasoning from Coach Brain based on context
  CoachReasoning getReasoning(ConversationContext context) {
    // Get Player Intelligence
    final player = _getPlayerIntelligence(context);

    // Get Priority Engine output
    final coachingPlan = PriorityEngine(
      playerIntelligence: player,
      knowledgeGraph: _kg,
    ).getCoachingPlan();

    // Generate reasoning based on intent
    return _generateReasoning(context, coachingPlan, player);
  }

  /// Get Player Intelligence - Sprint-13: Use injected PI or empty
  PlayerIntelligence _getPlayerIntelligence(ConversationContext context) {
    // Sprint-13: Use injected PlayerIntelligence if available
    return _playerIntelligence ?? PlayerIntelligence.empty('default');
  }

  /// Generate reasoning based on context
  CoachReasoning _generateReasoning(
    ConversationContext context,
    CoachingPlan coachingPlan,
    PlayerIntelligence player,
  ) {
    switch (context.intent) {
      // BEFORE PRACTICE
      case CoachIntent.whatToPracticeToday:
        return _reasoningWhatToPractice(context, coachingPlan);

      case CoachIntent.limitedTime:
        return _reasoningLimitedTime(context, coachingPlan);

      case CoachIntent.prepareForMatch:
        return _reasoningPrepareForMatch(context, coachingPlan);

      case CoachIntent.planSession:
        return _reasoningPlanSession(context, coachingPlan);

      // DURING PRACTICE
      case CoachIntent.feedback:
        return _reasoningFeedback(context, player);

      case CoachIntent.encouragement:
        return _reasoningEncouragement(context, player);

      case CoachIntent.takeBreak:
        return _reasoningTakeBreak(context, player);

      // AFTER PRACTICE
      case CoachIntent.summarizeSession:
        return _reasoningSummarizeSession(context, player);

      case CoachIntent.progressReview:
        return _reasoningProgressReview(context, player);

      case CoachIntent.nextSteps:
        return _reasoningNextSteps(context, coachingPlan);

      // AFTER MATCH
      case CoachIntent.matchAnalysis:
        return _reasoningMatchAnalysis(context, player);

      case CoachIntent.whatWentWrong:
        return _reasoningWhatWentWrong(context, player);

      case CoachIntent.strengthsAnalysis:
        return _reasoningStrengths(context, player);

      // GENERAL
      case CoachIntent.howAmIDoing:
        return _reasoningHowAmIDoing(context, coachingPlan);

      case CoachIntent.explainMistake:
        return _reasoningExplainMistake(context);

      case CoachIntent.explainSkill:
        return _reasoningExplainSkill(context);

      // FALLBACK
      case CoachIntent.unclear:
        return CoachReasoning(
          type: ReasoningType.clarification,
          mainPoint: 'Mình không hiểu ý bạn. Bạn có thể nói rõ hơn không?',
          supportingPoints: [],
          dataNeeded: null,
        );

      case CoachIntent.outOfScope:
        return CoachReasoning(
          type: ReasoningType.outOfScope,
          mainPoint: 'Xin lỗi, mình không thể hỗ trợ về chủ đề này.',
          supportingPoints: [],
          dataNeeded: null,
        );

      default:
        return CoachReasoning(
          type: ReasoningType.general,
          mainPoint: 'Mình có thể giúp bạn về: kế hoạch tập, phân tích trận đấu, hoặc tiến độ luyện tập.',
          supportingPoints: [],
          dataNeeded: null,
        );
    }
  }

  // =========================================================================
  // REASONING GENERATORS
  // =========================================================================

  CoachReasoning _reasoningWhatToPractice(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    if (plan.todayRecommendation == null) {
      return CoachReasoning(
        type: ReasoningType.noRecommendation,
        mainPoint: 'Mình chưa có đủ dữ liệu để đưa ra kế hoạch cụ thể.',
        supportingPoints: ['Hãy bắt đầu tập để mình hiểu bạn hơn.'],
        dataNeeded: 'Ít nhất 1-2 buổi tập',
      );
    }

    final rec = plan.todayRecommendation!;
    final avoid = plan.avoidRecommendations;
    final player = _getPlayerIntelligence(context);

    // Sprint-15: Build supporting points with specific evidence
    final supportingPoints = <String>[];

    // Sprint-15: Add specific drill evidence if available
    final lastDrillSession = player.shortTermMemory.getLastSessionForDrill(rec.drillCode);
    if (lastDrillSession != null) {
      final daysAgo = DateTime.now().difference(lastDrillSession.timestamp).inDays;
      final score = lastDrillSession.data['score'] as int? ?? 0;
      final daysText = daysAgo == 0 ? 'hôm nay' : (daysAgo == 1 ? 'hôm qua' : '$daysAgo ngày trước');
      supportingPoints.add('Lần gần nhất bạn tập bài này $daysText được $score%.');
    } else {
      // No history - use generic reason
      supportingPoints.add('Lý do: ${rec.reason}');
    }

    // Sprint-13: Add streak context with opponent names
    if (player.matchPatterns.totalMatches > 0) {
      final streak = player.matchPatterns.currentStreak;
      if (streak.type == StreakType.loss && streak.count >= 3) {
        // Sprint-15: Get opponent names from ShortTermMemory
        final recentMatches = player.shortTermMemory.getRecentMatches(limit: streak.count);
        final opponents = recentMatches
            .where((m) => m.data['won'] == false)
            .map((m) => m.data['opponent'] as String? ?? 'đối thủ')
            .take(streak.count)
            .toList();

        if (opponents.isNotEmpty) {
          final opponentText = opponents.take(3).join(', ');
          supportingPoints.add('Chuỗi ${streak.count} trận thua gần nhất trước $opponentText.');
        } else {
          supportingPoints.add('Bạn đang có chuỗi ${streak.count} trận thua - ưu tiên củng cố thay vì tăng độ khó.');
        }
      } else if (streak.type == StreakType.win && streak.count >= 5) {
        supportingPoints.add('Bạn đang có chuỗi ${streak.count} trận thắng - đang tự tin, có thể thử drill khó hơn.');
      }
    }

    if (rec.expectedImprovement != null) supportingPoints.add('Dự kiến cải thiện: ${rec.expectedImprovement!.improvementPercent}%');

    return CoachReasoning(
      type: ReasoningType.recommendation,
      mainPoint: 'Hôm nay mình khuyên bạn tập: ${rec.drillName}',
      supportingPoints: supportingPoints,
      recommendations: [
        CoachRecommendation(
          type: RecommendationType.today,
          drillCode: rec.drillCode,
          drillName: rec.drillName,
          reason: rec.reason,
          confidence: rec.confidence,
        ),
      ],
      avoidRecommendations: avoid.map((a) => CoachAvoidRecommendation(
        item: a.item,
        reason: a.reason,
        alternative: a.alternative,
      )).toList(),
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningLimitedTime(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    final rec = plan.todayRecommendation;
    if (rec == null) {
      return CoachReasoning(
        type: ReasoningType.noRecommendation,
        mainPoint: 'Với thời gian hạn chế, hãy tập trung vào drill cơ bản.',
        supportingPoints: ['Mình chưa có đủ dữ liệu để đưa ra gợi ý cụ thể.'],
        dataNeeded: '1-2 buổi tập',
      );
    }

    return CoachReasoning(
      type: ReasoningType.shortSession,
      mainPoint: 'Với thời gian có hạn, hãy tập ${rec.drillName}',
      supportingPoints: [
        'Drill này ngắn nhưng hiệu quả.',
        'Ưu tiên chất lượng, không phải số lượng.',
        'Nghỉ giải lao giữa các set.',
      ],
      recommendations: [
        CoachRecommendation(
          type: RecommendationType.today,
          drillCode: rec.drillCode,
          drillName: rec.drillName,
          reason: 'Phù hợp với thời gian ngắn',
          confidence: rec.confidence,
        ),
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningPrepareForMatch(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    final player = context.playerProfile;

    return CoachReasoning(
      type: ReasoningType.matchPreparation,
      mainPoint: 'Để chuẩn bị cho trận đấu, hãy tập trung vào:',
      supportingPoints: [
        'Warm-up: ${plan.todayRecommendation?.drillName ?? "Straight Shot"}',
        'Tập trung vào điểm mạnh: ${player.primaryStrength ?? "Tự đánh giá"}',
        'Không tập drill mới 1-2 ngày trước trận.',
        'Nghỉ ngơi đầy đủ.',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningPlanSession(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    return CoachReasoning(
      type: ReasoningType.sessionPlan,
      mainPoint: 'Kế hoạch hôm nay:',
      supportingPoints: plan.prioritizedFocusAreas
          .take(3)
          .map((p) => '${p.rank}. ${p.focusArea.name} - ${p.reasoning}')
          .toList(),
      recommendations: plan.prioritizedFocusAreas
          .take(3)
          .map((p) => CoachRecommendation(
            type: RecommendationType.focus,
            drillCode: p.focusArea.drills.isNotEmpty ? p.focusArea.drills.first.code : '',
            drillName: p.focusArea.drills.isNotEmpty ? p.focusArea.drills.first.nameVi : p.focusArea.name,
            reason: p.reasoning,
            confidence: p.confidence,
          ))
          .toList(),
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningFeedback(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final lastSession = player.shortTermMemory.getLastSession();
    final trend = player.progress.currentTrend;

    String mainPoint;
    if (trend == TrendDirection.declining) {
      mainPoint = 'Mình nhận thấy xu hướng đang giảm. Hãy cẩn thận!';
    } else if (trend == TrendDirection.improving) {
      mainPoint = 'Tốt lắm! Bạn đang tiến bộ.';
    } else {
      mainPoint = 'Xu hướng ổn định. Tiếp tục duy trì!';
    }

    return CoachReasoning(
      type: ReasoningType.feedback,
      mainPoint: mainPoint,
      supportingPoints: [
        'Độ ổn định: ${player.progress.consistencyScore}%',
        if (lastSession != null) 'Lần tập gần nhất: ${lastSession.data['drillCode'] ?? "N/A"}',
        'Số buổi tập: ${player.practicePatterns.totalSessions}',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningEncouragement(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final progress = player.progress;

    // Sprint-13: Build supporting points with streak awareness
    final supportingPoints = <String>[
      'Bạn đã tập ${player.practicePatterns.totalSessions} buổi.',
      'Độ ổn định: ${progress.consistencyScore}%.',
      if (progress.personalBest != null) 'PB: ${progress.personalBest!.score}%.',
    ];

    // Sprint-13: Add streak context for encouragement
    if (player.matchPatterns.totalMatches > 0) {
      final streak = player.matchPatterns.currentStreak;
      if (streak.type == StreakType.loss && streak.count >= 3) {
        supportingPoints.add('Chuỗi thua: ${streak.count} trận - đừng nản, mỗi trận là bài học!');
      } else if (streak.type == StreakType.win && streak.count >= 5) {
        supportingPoints.add('Chuỗi thắng: ${streak.count} trận - giữ phong độ!');
      }
    }

    return CoachReasoning(
      type: ReasoningType.encouragement,
      mainPoint: _getEncouragementMessage(player),
      supportingPoints: supportingPoints,
      dataNeeded: null,
    );
  }

  String _getEncouragementMessage(PlayerIntelligence player) {
    // Sprint-13: Consider match streak in encouragement
    if (player.matchPatterns.totalMatches > 0) {
      final streak = player.matchPatterns.currentStreak;
      if (streak.type == StreakType.loss && streak.count >= 3) {
        return 'Chuỗi thua gần đây không định nghĩa bạn. Mỗi trận là cơ hội học hỏi!';
      }
    }

    if (player.progress.currentTrend == TrendDirection.improving) {
      return 'Xuất sắc! Bạn đang tiến bộ rõ rệt!';
    }
    if (player.progress.currentTrend == TrendDirection.declining) {
      return 'Đừng nản lòng! Mỗi người đều có giai đoạn khó khăn.';
    }
    if (player.practicePatterns.sessionsThisWeek >= 3) {
      return 'Tuyệt vời! Bạn đang tập đều đặn!';
    }
    return 'Giỏi lắm! Cố gắng lên!';
  }

  CoachReasoning _reasoningTakeBreak(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    return CoachReasoning(
      type: ReasoningType.breakRecommendation,
      mainPoint: 'Nghỉ ngơi là quan trọng!',
      supportingPoints: [
        'Tuần này bạn đã tập ${player.practicePatterns.sessionsThisWeek} buổi.',
        'Nghỉ 1-2 ngày giúp cơ bắp hồi phục.',
        'Khi quay lại, bạn sẽ tập hiệu quả hơn.',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningSummarizeSession(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final trend = player.progress.currentTrend;
    final mistakes = player.mistakePatterns.topMistakes;

    return CoachReasoning(
      type: ReasoningType.sessionSummary,
      mainPoint: 'Tổng kết:',
      supportingPoints: [
        'Xu hướng: ${trend.label}',
        'Độ ổn định: ${player.progress.consistencyScore}%',
        if (mistakes.isNotEmpty) 'Lỗi cần chú ý: ${mistakes.first}',
        'Tiếp theo: ${_getNextStepRecommendation(player)}',
      ],
      dataNeeded: null,
    );
  }

  String _getNextStepRecommendation(PlayerIntelligence player) {
    if (player.progress.currentTrend == TrendDirection.declining) {
      return 'Nghỉ ngơi và quay lại với drill cơ bản';
    }
    if (player.mistakePatterns.topMistakes.isNotEmpty) {
      return 'Tập trung sửa lỗi: ${player.mistakePatterns.topMistakes.first}';
    }
    return 'Tiếp tục duy trì thói quen tốt';
  }

  CoachReasoning _reasoningProgressReview(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final progress = player.progress;

    return CoachReasoning(
      type: ReasoningType.progressReview,
      mainPoint: 'Tiến độ của bạn:',
      supportingPoints: [
        'Xu hướng: ${progress.currentTrend.label}',
        'Độ ổn định: ${progress.consistencyScore}%',
        'Tổng buổi tập: ${player.practicePatterns.totalSessions}',
        'Buổi tuần này: ${player.practicePatterns.sessionsThisWeek}',
        if (progress.personalBest != null) 'Personal best: ${progress.personalBest!.score}%',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningNextSteps(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    if (plan.prioritizedFocusAreas.isEmpty) {
      return CoachReasoning(
        type: ReasoningType.noRecommendation,
        mainPoint: 'Bạn đang tiến bộ tốt! Tiếp tục duy trì.',
        supportingPoints: [],
        dataNeeded: null,
      );
    }

    final next = plan.prioritizedFocusAreas.first;

    return CoachReasoning(
      type: ReasoningType.nextSteps,
      mainPoint: 'Bước tiếp theo: ${next.focusArea.name}',
      supportingPoints: [
        'Lý do: ${next.reasoning}',
        if (next.focusArea.drills.isNotEmpty) 'Drill đề xuất: ${next.focusArea.drills.first.nameVi}',
        'Ưu tiên: ${next.priority.label}',
      ],
      recommendations: next.focusArea.drills.isNotEmpty
          ? [
              CoachRecommendation(
                type: RecommendationType.focus,
                drillCode: next.focusArea.drills.first.code,
                drillName: next.focusArea.drills.first.nameVi,
                reason: next.reasoning,
                confidence: next.confidence,
              ),
            ]
          : [],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningMatchAnalysis(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final matchPatterns = player.matchPatterns;

    return CoachReasoning(
      type: ReasoningType.matchAnalysis,
      mainPoint: 'Phân tích trận đấu:',
      supportingPoints: [
        'Tổng trận: ${matchPatterns.totalMatches}',
        'Thắng: ${matchPatterns.wins} | Thua: ${matchPatterns.losses}',
        'Tỷ lệ thắng: ${matchPatterns.winRate.toStringAsFixed(1)}%',
        if (matchPatterns.currentStreak.count > 0)
          'Chuỗi: ${matchPatterns.currentStreak.count} ${matchPatterns.currentStreak.type == StreakType.win ? "thắng" : "thua"} liên tiếp',
      ],
      dataNeeded: matchPatterns.totalMatches > 0 ? null : 'Ít nhất 1 trận đấu',
    );
  }

  CoachReasoning _reasoningWhatWentWrong(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final mistakes = player.mistakePatterns.topMistakes;

    if (mistakes.isEmpty) {
      return CoachReasoning(
        type: ReasoningType.insufficientData,
        mainPoint: 'Mình chưa có đủ dữ liệu để phân tích.',
        supportingPoints: ['Hãy tiếp tục tập để mình hiểu bạn hơn.'],
        dataNeeded: '1-2 trận đấu hoặc buổi tập',
      );
    }

    return CoachReasoning(
      type: ReasoningType.mistakeAnalysis,
      mainPoint: 'Lỗi quyết định lớn nhất: ${mistakes.first}',
      supportingPoints: [
        'Đây là lỗi bạn mắc thường xuyên nhất.',
        'Cần tập trung cải thiện.',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningStrengths(
    ConversationContext context,
    PlayerIntelligence player,
  ) {
    final strength = player.skillProfile.primaryStrength;

    if (strength == null) {
      return CoachReasoning(
        type: ReasoningType.insufficientData,
        mainPoint: 'Mình chưa xác định được điểm mạnh của bạn.',
        supportingPoints: ['Hãy tiếp tục tập để mình đánh giá.'],
        dataNeeded: '3-5 buổi tập',
      );
    }

    return CoachReasoning(
      type: ReasoningType.strengthsAnalysis,
      mainPoint: 'Điểm mạnh của bạn: $strength',
      supportingPoints: [
        'Đây là kỹ năng bạn thể hiện tốt nhất.',
        'Hãy tận dụng điểm mạnh này trong thi đấu.',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningHowAmIDoing(
    ConversationContext context,
    CoachingPlan plan,
  ) {
    final profile = context.playerProfile;

    return CoachReasoning(
      type: ReasoningType.generalStatus,
      mainPoint: '${profile.name} là người chơi ${profile.overallLevel.label}.',
      supportingPoints: [
        'Xu hướng: ${profile.currentTrend.label}',
        'Điểm mạnh: ${profile.primaryStrength ?? "Chưa xác định"}',
        'Cần cải thiện: ${profile.primaryWeakness ?? "Chưa xác định"}',
        'Ưu tiên tiếp theo: ${plan.todayRecommendation?.drillName ?? "Tự do"}',
      ],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningExplainMistake(ConversationContext context) {
    // Extract mistake name from message if possible
    return CoachReasoning(
      type: ReasoningType.explanation,
      mainPoint: 'Mình sẽ giải thích về lỗi này.',
      supportingPoints: [],
      dataNeeded: null,
    );
  }

  CoachReasoning _reasoningExplainSkill(ConversationContext context) {
    // Extract skill name from message if possible
    return CoachReasoning(
      type: ReasoningType.explanation,
      mainPoint: 'Mình sẽ giải thích về kỹ năng này.',
      supportingPoints: [],
      dataNeeded: null,
    );
  }

  // =========================================================================
  // RESPONSE FORMATTER
  // =========================================================================

  /// Format reasoning into natural language response
  String formatResponse(CoachReasoning reasoning) {
    final parts = <String>[];

    // Main point
    parts.add(reasoning.mainPoint);

    // Supporting points
    for (final point in reasoning.supportingPoints) {
      parts.add('• $point');
    }

    // Avoid recommendations
    if (reasoning.avoidRecommendations.isNotEmpty) {
      parts.add('\n🚫 HÔM NAY KHÔNG NÊN:');
      for (final avoid in reasoning.avoidRecommendations) {
        parts.add('• ${avoid.item}: ${avoid.reason}');
      }
    }

    // Next steps
    if (reasoning.recommendations.isNotEmpty) {
      parts.add('\n📌 KẾT LUẬN:');
      for (final rec in reasoning.recommendations.take(2)) {
        parts.add('• ${rec.drillName} - ${rec.reason}');
      }
    }

    // Data needed disclaimer
    if (reasoning.dataNeeded != null) {
      parts.add('\n⚠️ Lưu ý: ${reasoning.dataNeeded}');
    }

    return parts.join('\n');
  }

  /// Get suggestions based on intent
  List<String> getSuggestions(CoachIntent intent) {
    return intent.getSuggestions();
  }
}

// ============================================================================
// COACH REASONING OUTPUT
// ============================================================================

enum ReasoningType {
  recommendation,
  feedback,
  encouragement,
  sessionSummary,
  progressReview,
  matchAnalysis,
  explanation,
  clarification,
  outOfScope,
  noRecommendation,
  insufficientData,
  general,
  shortSession,
  matchPreparation,
  sessionPlan,
  breakRecommendation,
  mistakeAnalysis,
  strengthsAnalysis,
  generalStatus,
  nextSteps;

  String get label {
    switch (this) {
      case ReasoningType.recommendation:
        return 'Đề xuất';
      case ReasoningType.feedback:
        return 'Phản hồi';
      case ReasoningType.encouragement:
        return 'Động viên';
      case ReasoningType.sessionSummary:
        return 'Tổng kết';
      case ReasoningType.progressReview:
        return 'Xem tiến độ';
      case ReasoningType.matchAnalysis:
        return 'Phân tích trận';
      case ReasoningType.explanation:
        return 'Giải thích';
      case ReasoningType.clarification:
        return 'Làm rõ';
      case ReasoningType.outOfScope:
        return 'Ngoài phạm vi';
      case ReasoningType.noRecommendation:
        return 'Không có đề xuất';
      case ReasoningType.insufficientData:
        return 'Thiếu dữ liệu';
      default:
        return 'Tư vấn';
    }
  }
}

class CoachReasoning {
  final ReasoningType type;
  final String mainPoint;
  final List<String> supportingPoints;
  final List<CoachRecommendation> recommendations;
  final List<CoachAvoidRecommendation> avoidRecommendations;
  final String? dataNeeded;

  const CoachReasoning({
    required this.type,
    required this.mainPoint,
    this.supportingPoints = const [],
    this.recommendations = const [],
    this.avoidRecommendations = const [],
    this.dataNeeded,
  });
}

class CoachRecommendation {
  final RecommendationType type;
  final String drillCode;
  final String drillName;
  final String reason;
  final int confidence;

  const CoachRecommendation({
    required this.type,
    required this.drillCode,
    required this.drillName,
    required this.reason,
    required this.confidence,
  });
}

class CoachAvoidRecommendation {
  final String item;
  final String reason;
  final String alternative;

  const CoachAvoidRecommendation({
    required this.item,
    required this.reason,
    required this.alternative,
  });
}
