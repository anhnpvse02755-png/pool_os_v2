// ============================================================================
// COACH CHAT SCREEN - Phase 7B.2
// Natural Language Conversation with Coach
//
// Coach Voice:
// - Short (2-3 sentences)
// - Natural (no "dựa trên", "AI")
// - Leads (doesn't ask when has data)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../knowledge/conversation_engine.dart';
import '../../../knowledge/coach_service.dart' show ReasoningType;
import '../../widgets/coach/explain_bottom_sheet.dart';
import '../../widgets/coach/coach_chat_bubble.dart';
import '../../widgets/coach/coach_suggestion_chips.dart';
import '../../widgets/coach/recommendation_card.dart';
import '../training/drill_detail_screen.dart';

/// Chat Message
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatIntent? intent;
  final CoachRecommendation? recommendation;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.recommendation,
  });
}

/// Chat State
class CoachChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? contextDrillCode;

  CoachChatState({
    this.messages = const [],
    this.isTyping = false,
    this.contextDrillCode,
  });

  CoachChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? contextDrillCode,
  }) {
    return CoachChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      contextDrillCode: contextDrillCode ?? this.contextDrillCode,
    );
  }
}

/// Chat Intent
enum ChatIntent {
  whatToPractice,
  whyAccuracyDropped,
  whatWentWrong,
  strengths,
  improvement,
  howAmIDoing,
  general,
  unclear,
}

/// Coach Chat Screen
class CoachChatScreen extends ConsumerStatefulWidget {
  final String? initialDrillCode;
  final String? initialQuestion;

  const CoachChatScreen({
    super.key,
    this.initialDrillCode,
    this.initialQuestion,
  });

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  CoachChatState _state = CoachChatState();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final messages = <ChatMessage>[];

    // Initial Coach message
    messages.add(ChatMessage(
      content: 'Chào bạn! Mình có thể giúp gì?',
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _state = _state.copyWith(messages: messages);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _state.messages.length,
              itemBuilder: (context, index) {
                final message = _state.messages[index];
                return CoachChatBubble(
                  message: message,
                  onTapRecommendation: () => _navigateToDrill(message.recommendation?.drillCode),
                  onTapWhy: () => _showExplain(context, message.recommendation?.drillCode),
                );
              },
            ),
          ),

          // Suggestion Chips
          if (_state.messages.length == 1)
            CoachSuggestionChips(
              onSuggestionTap: _handleSuggestion,
            ).animate().fadeIn(delay: 500.ms),

          // Input Area
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Hỏi Coach...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _handleSend,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSend(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _state = _state.copyWith(
        messages: [..._state.messages, userMessage],
        isTyping: true,
      );
    });

    _textController.clear();
    _scrollToBottom();

    // Generate Coach response through Brain
    Future.delayed(const Duration(milliseconds: 500), () {
      _generateCoachResponse(userMessage);
    });
  }

  void _generateCoachResponse(ChatMessage userMessage) async {
    // Parse intent using ConversationEngine's IntentParser
    final intent = IntentParser.parse(userMessage.content);

    // Build context from Coach State
    final context = _buildContext(intent, userMessage.content);

    // Get reasoning from Coach Brain via CoachService
    final coachNotifier = ref.read(coachStateProvider.notifier);
    final reasoning = coachNotifier.getReasoning(context);

    // Format response with Coach Voice
    String content;
    CoachRecommendation? recommendation;

    if (reasoning.type == ReasoningType.noRecommendation ||
        reasoning.type == ReasoningType.insufficientData) {
      // No data response
      content = coachNotifier.formatResponse(reasoning);
    } else if (reasoning.recommendations.isNotEmpty) {
      // Has recommendations - use Coach Brain response
      content = coachNotifier.formatResponse(reasoning);

      // Convert first recommendation to UI format
      final rec = reasoning.recommendations.first;
      recommendation = CoachRecommendation.fromBrain(
        drillCode: rec.drillCode,
        drillName: rec.drillName,
        reason: rec.reason,
        expectedOutcome: 'Cải thiện kỹ năng',
        estimatedMinutes: 10,
        confidence: rec.confidence,
      );
    } else {
      // General response
      content = coachNotifier.formatResponse(reasoning);
    }

    // Also include supporting points if available
    if (reasoning.supportingPoints.isNotEmpty &&
        !reasoning.supportingPoints.first.contains(content)) {
      content = '$content\n\n${reasoning.supportingPoints.map((p) => '• $p').join('\n')}';
    }

    // Add data disclaimer if needed
    if (reasoning.dataNeeded != null) {
      content = '$content\n\n⚠️ ${reasoning.dataNeeded}';
    }

    final coachMessage = ChatMessage(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      intent: _mapReasoningType(intent),
      recommendation: recommendation,
    );

    if (mounted) {
      setState(() {
        _state = _state.copyWith(
          messages: [..._state.messages, coachMessage],
          isTyping: false,
        );
      });
      _scrollToBottom();
    }
  }

  /// Build ConversationContext from Coach State
  ConversationContext _buildContext(CoachIntent intent, String message) {
    final coachState = ref.read(coachStateProvider);
    final pi = coachState.playerIntelligence;

    // Get coaching plan or create empty one
    final coachingPlan = coachState.coachingPlan;

    return ConversationContext(
      intent: intent,
      userMessage: message,
      playerProfile: pi.toSummary(),
      coachingPlan: coachingPlan,
      recentSessions: pi.shortTermMemory.recentSessions,
      currentGoal: pi.identity.primaryGoal,
      sessionHistory: [],
      availableData: AvailableData(
        hasPracticeHistory: pi.practicePatterns.totalSessions > 0,
        hasMatchHistory: pi.matchPatterns.totalMatches > 0,
        hasSkillProfile: pi.skillProfile.skills.isNotEmpty,
        hasMistakePatterns: pi.mistakePatterns.patterns.isNotEmpty,
        hasProgressData: pi.progress.trendHistory.isNotEmpty,
        practiceSessionCount: pi.practicePatterns.totalSessions,
        matchCount: pi.matchPatterns.totalMatches,
        confidenceLevel: pi.toSummary().confidence,
      ),
    );
  }

  /// Map ConversationEngine's CoachIntent to ChatIntent
  ChatIntent _mapReasoningType(CoachIntent intent) {
    switch (intent) {
      case CoachIntent.whatToPracticeToday:
      case CoachIntent.planSession:
        return ChatIntent.whatToPractice;
      case CoachIntent.matchAnalysis:
      case CoachIntent.whatWentWrong:
        return ChatIntent.whatWentWrong;
      case CoachIntent.strengthsAnalysis:
        return ChatIntent.strengths;
      case CoachIntent.howAmIDoing:
        return ChatIntent.howAmIDoing;
      case CoachIntent.feedback:
        return ChatIntent.whyAccuracyDropped;
      case CoachIntent.improvements:
        return ChatIntent.improvement;
      default:
        return ChatIntent.general;
    }
  }

  void _handleSuggestion(String suggestion) {
    _handleSend(suggestion);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Get explanation from Coach Brain
  String _getExplanationFromBrain(String drillCode, CoachState coachState) {
    // Get drill knowledge from Knowledge Graph
    final kg = ref.read(knowledgeGraphProvider);
    final drill = kg.getDrill(drillCode);

    if (drill != null) {
      // Use drill's explanation from Knowledge Graph
      final skills = drill.skillsTrained
          .map((s) => kg.graph.getSkill(s)?.nameVi ?? s)
          .join(', ');
      return 'Drill này giúp cải thiện: $skills.\n\n'
          'Đây là bài tập ${drill.difficulty.label} giúp bạn phát triển kỹ năng.';
    }

    // Fallback
    return 'Drill này giúp bạn cải thiện kỹ năng cơ bản.';
  }

  void _showExplain(BuildContext context, String? drillCode) {
    if (drillCode == null) return;

    // Get explanation from Coach Brain
    final coachState = ref.read(coachStateProvider);
    final explanation = _getExplanationFromBrain(drillCode, coachState);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExplainBottomSheet(
        drillCode: drillCode,
        explanation: explanation,
        onStartDrill: () {
          Navigator.pop(context);
          _navigateToDrill(drillCode);
        },
      ),
    );
  }

  void _navigateToDrill(String? drillCode) {
    if (drillCode == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrillDetailScreen(drillCode: drillCode),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hỏi Coach gì?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• "Hôm nay nên tập gì?"'),
            SizedBox(height: 8),
            Text('• "Tại sao tôi đánh kém?"'),
            SizedBox(height: 8),
            Text('• "Tôi nên cải thiện gì?"'),
            SizedBox(height: 8),
            Text('• "Điểm mạnh của tôi là gì?"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
