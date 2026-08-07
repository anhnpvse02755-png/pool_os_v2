// ============================================================================
// CONVERSATION ENGINE - Phase 7
// Interaction Layer between Player and Coach Brain
//
// Phase 7 does NOT build Coach Brain.
// Phase 7 builds the CONVERSATION INTERFACE to Coach Brain.
// ============================================================================

import 'player_intelligence.dart';
import 'knowledge_graph_service.dart';
import 'priority_engine.dart';
import 'coach_service.dart';

/// Conversation Engine - Handles player conversations with Coach
class ConversationEngine {
  ConversationEngine({
    required PlayerIntelligence playerIntelligence,
    required KnowledgeGraphService knowledgeGraph,
    required CoachService coachService,
  })  : _player = playerIntelligence,
        _kg = knowledgeGraph,
        _coach = coachService,
        _sessionMemory = CoachSessionMemory.empty();

  final PlayerIntelligence _player;
  final KnowledgeGraphService _kg;
  final CoachService _coach;
  CoachSessionMemory _sessionMemory;

  /// Process a user message and generate Coach response
  Future<CoachResponse> processMessage(String message) async {
    // 1. Parse intent
    final intent = IntentParser.parse(message);

    // 2. Build context
    final context = await _buildContext(intent, message);

    // 3. Get reasoning from Coach Brain
    final reasoning = _coach.getReasoning(context);

    // 4. Generate response
    final response = CoachResponse(
      intent: intent,
      message: _coach.formatResponse(reasoning),
      suggestions: _coach.getSuggestions(intent),
      context: context,
      timestamp: DateTime.now(),
    );

    // 5. Update session memory
    _sessionMemory = _sessionMemory.addTurn(
      userMessage: message,
      coachMessage: response.message,
      intent: intent,
    );

    return response;
  }

  /// Build context for Coach Brain
  Future<ConversationContext> _buildContext(CoachIntent intent, String message) async {
    // Get relevant data from Player Intelligence
    final playerSummary = _player.toSummary();
    final recentSessions = _player.shortTermMemory.recentSessions;
    final currentGoal = _player.identity.primaryGoal;

    // Get Coach Brain output
    final coachingPlan = PriorityEngine(
      playerIntelligence: _player,
      knowledgeGraph: _kg,
    ).getCoachingPlan();

    // Build context
    return ConversationContext(
      intent: intent,
      userMessage: message,
      playerProfile: playerSummary,
      coachingPlan: coachingPlan,
      recentSessions: recentSessions,
      currentGoal: currentGoal,
      sessionHistory: _sessionMemory.turns,
      availableData: _getAvailableData(),
    );
  }

  /// Check what data is available for the intent
  AvailableData _getAvailableData() {
    return AvailableData(
      hasPracticeHistory: _player.practicePatterns.totalSessions > 0,
      hasMatchHistory: _player.matchPatterns.totalMatches > 0,
      hasSkillProfile: _player.skillProfile.skills.isNotEmpty,
      hasMistakePatterns: _player.mistakePatterns.patterns.isNotEmpty,
      hasProgressData: _player.progress.trendHistory.isNotEmpty,
      practiceSessionCount: _player.practicePatterns.totalSessions,
      matchCount: _player.matchPatterns.totalMatches,
      confidenceLevel: _player.toSummary().confidence,
    );
  }

  /// Get session memory
  CoachSessionMemory get sessionMemory => _sessionMemory;

  /// Clear session memory
  void clearSession() {
    _sessionMemory = CoachSessionMemory.empty();
  }
}

// ============================================================================
// INTENT PARSER
// ============================================================================

/// Intent types that Coach can handle
enum CoachIntent {
  // Before practice
  whatToPracticeToday,
  planSession,
  prepareForMatch,
  limitedTime,

  // During practice
  feedback,
  encouragement,
  adjustSession,
  takeBreak,

  // After practice
  summarizeSession,
  progressReview,
  nextSteps,

  // After match
  matchAnalysis,
  whatWentWrong,
  strengthsAnalysis,
  improvements,

  // General
  howAmIDoing,
  explainMistake,
  explainSkill,
  generalQuestion,

  // Unknown
  unclear,
  outOfScope;

  String get label {
    switch (this) {
      case CoachIntent.whatToPracticeToday:
        return 'Hỏi nên tập gì hôm nay';
      case CoachIntent.planSession:
        return 'Lập kế hoạch tập';
      case CoachIntent.prepareForMatch:
        return 'Chuẩn bị thi đấu';
      case CoachIntent.limitedTime:
        return 'Tập với thời gian hạn chế';
      case CoachIntent.feedback:
        return 'Phản hồi về buổi tập';
      case CoachIntent.encouragement:
        return 'Động viên';
      case CoachIntent.adjustSession:
        return 'Điều chỉnh buổi tập';
      case CoachIntent.takeBreak:
        return 'Nghỉ ngơi';
      case CoachIntent.summarizeSession:
        return 'Tổng kết buổi tập';
      case CoachIntent.progressReview:
        return 'Xem tiến độ';
      case CoachIntent.nextSteps:
        return 'Bước tiếp theo';
      case CoachIntent.matchAnalysis:
        return 'Phân tích trận đấu';
      case CoachIntent.whatWentWrong:
        return 'Hỏi điều sai';
      case CoachIntent.strengthsAnalysis:
        return 'Phân tích điểm mạnh';
      case CoachIntent.improvements:
        return 'Điều cần cải thiện';
      case CoachIntent.howAmIDoing:
        return 'Hỏi thẳng';
      case CoachIntent.explainMistake:
        return 'Giải thích lỗi';
      case CoachIntent.explainSkill:
        return 'Giải thích kỹ năng';
      case CoachIntent.generalQuestion:
        return 'Câu hỏi chung';
      case CoachIntent.unclear:
        return 'Không rõ ý';
      case CoachIntent.outOfScope:
        return 'Ngoài phạm vi';
    }
  }
}

/// Intent parser - converts user message to intent
class IntentParser {
  static CoachIntent parse(String message) {
    final lower = message.toLowerCase();

    // Before practice
    if (_containsAny(lower, ['nên tập gì', 'hôm nay tập', 'tập gì', 'bài tập nào'])) {
      return CoachIntent.whatToPracticeToday;
    }
    if (_containsAny(lower, ['kế hoạch', 'lập kế hoạch', 'sắp xếp'])) {
      return CoachIntent.planSession;
    }
    if (_containsAny(lower, ['thi đấu', 'sắp đấu', 'chuẩn bị đấu', 'trận đấu'])) {
      return CoachIntent.prepareForMatch;
    }
    if (_containsAny(lower, ['30 phút', '15 phút', 'ít thời gian', 'gấp'])) {
      return CoachIntent.limitedTime;
    }

    // During practice
    if (_containsAny(lower, ['accuracy', 'tỷ lệ', 'đang giảm', 'kém'])) {
      return CoachIntent.feedback;
    }
    if (_containsAny(lower, ['động viên', 'khích lệ', 'tốt lắm', 'giỏi'])) {
      return CoachIntent.encouragement;
    }
    if (_containsAny(lower, ['điều chỉnh', 'thay đổi', 'khác'])) {
      return CoachIntent.adjustSession;
    }
    if (_containsAny(lower, ['nghỉ', 'dừng', 'pause'])) {
      return CoachIntent.takeBreak;
    }

    // After practice
    if (_containsAny(lower, ['tổng kết', 'kết thúc', 'xong'])) {
      return CoachIntent.summarizeSession;
    }
    if (_containsAny(lower, ['tiến bộ', 'đang làm', 'progress'])) {
      return CoachIntent.progressReview;
    }
    if (_containsAny(lower, ['tiếp theo', 'sau đó', 'bước'])) {
      return CoachIntent.nextSteps;
    }

    // After match
    if (_containsAny(lower, ['thua', 'win', 'trận đấu', 'match'])) {
      return CoachIntent.matchAnalysis;
    }
    if (_containsAny(lower, ['sai', 'lỗi', 'why'])) {
      return CoachIntent.whatWentWrong;
    }
    if (_containsAny(lower, ['điểm mạnh', 'giỏi', 'tốt nhất'])) {
      return CoachIntent.strengthsAnalysis;
    }
    if (_containsAny(lower, ['cải thiện', 'yếu', 'kém'])) {
      return CoachIntent.improvements;
    }

    // General
    if (_containsAny(lower, ['làm sao', 'như thế nào', 'how'])) {
      return CoachIntent.generalQuestion;
    }
    if (_containsAny(lower, ['đang làm sao', 'thế nào', 'how am i'])) {
      return CoachIntent.howAmIDoing;
    }

    return CoachIntent.unclear;
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}

// ============================================================================
// CONVERSATION CONTEXT
// ============================================================================

class ConversationContext {
  final CoachIntent intent;
  final String userMessage;
  final PlayerSummary playerProfile;
  final CoachingPlan? coachingPlan;
  final List<MemoryEntry> recentSessions;
  final String? currentGoal;
  final List<ConversationTurn> sessionHistory;
  final AvailableData availableData;

  const ConversationContext({
    required this.intent,
    required this.userMessage,
    required this.playerProfile,
    this.coachingPlan,
    required this.recentSessions,
    this.currentGoal,
    required this.sessionHistory,
    required this.availableData,
  });

  /// Check if Coach has enough data to answer
  bool get hasEnoughData {
    if (availableData.confidenceLevel >= 70) return true;
    if (availableData.hasPracticeHistory && availableData.hasProgressData) return true;
    return false;
  }
}

class AvailableData {
  final bool hasPracticeHistory;
  final bool hasMatchHistory;
  final bool hasSkillProfile;
  final bool hasMistakePatterns;
  final bool hasProgressData;
  final int practiceSessionCount;
  final int matchCount;
  final int confidenceLevel;

  const AvailableData({
    required this.hasPracticeHistory,
    required this.hasMatchHistory,
    required this.hasSkillProfile,
    required this.hasMistakePatterns,
    required this.hasProgressData,
    required this.practiceSessionCount,
    required this.matchCount,
    required this.confidenceLevel,
  });

  String get summary {
    if (confidenceLevel >= 80) return 'Mình có đủ dữ liệu để đánh giá.';
    if (confidenceLevel >= 50) return 'Mình có một số dữ liệu để tham khảo.';
    return 'Mình chưa có đủ dữ liệu để đưa ra đánh giá chính xác.';
  }
}

// ============================================================================
// COACH SESSION MEMORY
// ============================================================================

class CoachSessionMemory {
  final List<ConversationTurn> turns;
  final DateTime sessionStart;
  final List<String> discussedTopics;
  final Map<String, int> intentFrequency;

  const CoachSessionMemory({
    required this.turns,
    required this.sessionStart,
    required this.discussedTopics,
    required this.intentFrequency,
  });

  factory CoachSessionMemory.empty() {
    return CoachSessionMemory(
      turns: [],
      sessionStart: DateTime.now(),
      discussedTopics: [],
      intentFrequency: {},
    );
  }

  CoachSessionMemory addTurn({
    required String userMessage,
    required String coachMessage,
    required CoachIntent intent,
  }) {
    final turn = ConversationTurn(
      timestamp: DateTime.now(),
      userMessage: userMessage,
      coachMessage: coachMessage,
      intent: intent,
    );

    final updatedTopics = [...discussedTopics];
    if (!updatedTopics.contains(intent.label)) {
      updatedTopics.add(intent.label);
    }

    final updatedFrequency = Map<String, int>.from(intentFrequency);
    updatedFrequency[intent.label] = (updatedFrequency[intent.label] ?? 0) + 1;

    return CoachSessionMemory(
      turns: [...turns, turn],
      sessionStart: sessionStart,
      discussedTopics: updatedTopics,
      intentFrequency: updatedFrequency,
    );
  }

  /// Get context summary for follow-up
  String getContextSummary() {
    if (turns.isEmpty) return '';
    final lastTurn = turns.last;
    return 'Cuộc trò chuyện vừa rồi về: ${lastTurn.intent.label}';
  }
}

class ConversationTurn {
  final DateTime timestamp;
  final String userMessage;
  final String coachMessage;
  final CoachIntent intent;

  const ConversationTurn({
    required this.timestamp,
    required this.userMessage,
    required this.coachMessage,
    required this.intent,
  });
}

// ============================================================================
// COACH RESPONSE
// ============================================================================

class CoachResponse {
  final CoachIntent intent;
  final String message;
  final List<String> suggestions;
  final ConversationContext context;
  final DateTime timestamp;

  const CoachResponse({
    required this.intent,
    required this.message,
    required this.suggestions,
    required this.context,
    required this.timestamp,
  });

  /// Check if Coach is confident about this response
  bool get isConfident => context.availableData.confidenceLevel >= 60;

  /// Get response with data disclaimer if needed
  String getSafeMessage() {
    if (context.hasEnoughData) {
      return message;
    }
    return '${message}\n\n⚠️ ${context.availableData.summary}';
  }
}

// ============================================================================
// SUGGESTIONS
// ============================================================================

extension CoachIntentSuggestions on CoachIntent {
  List<String> getSuggestions() {
    switch (this) {
      case CoachIntent.whatToPracticeToday:
        return [
          'Mình có thể giúp bạn xem kế hoạch dài hạn',
          'Bạn muốn tập với thời gian bao lâu?',
        ];
      case CoachIntent.summarizeSession:
        return [
          'Xem tiến độ 1 tuần qua',
          'So sánh với tuần trước',
        ];
      case CoachIntent.matchAnalysis:
        return [
          'Phân tích chi tiết lỗi quyết định',
          'Xem điểm mạnh trong trận',
        ];
      case CoachIntent.howAmIDoing:
        return [
          'Xem chi tiết skill profile',
          'Xem kế hoạch ưu tiên',
        ];
      default:
        return [
          'Hỏi về bài tập cụ thể',
          'Xem kế hoạch dài hạn',
        ];
    }
  }
}
