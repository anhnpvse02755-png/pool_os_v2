// ============================================================================
// COACH PROVIDER - Phase 7.x
// Integration Layer: Wires Coach Brain to Experience Layer
//
// This provider:
// - Initializes PlayerIntelligence from real data
// - Provides KnowledgeGraph for reasoning
// - Provides PriorityEngine for recommendations
// - Provides CoachService for conversation
// - Tracks PlayerIntelligence updates
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../knowledge/player_intelligence.dart';
import '../services/session_memory_service.dart';
import '../services/coach_types.dart';
import '../services/match_analysis_service.dart';
import '../services/local_storage_service.dart';
import '../models/match_stats.dart';
import '../../knowledge/knowledge_graph_service.dart';
import '../../knowledge/priority_engine.dart';
import '../../knowledge/coach_service.dart' hide CoachRecommendation;
import '../../knowledge/conversation_engine.dart';
import '../../presentation/widgets/coach/recommendation_card.dart';
import 'training_provider.dart';

// ========================================================================
// KNOWLEDGE GRAPH PROVIDER
// ========================================================================

final knowledgeGraphProvider = Provider<KnowledgeGraphService>((ref) {
  return KnowledgeGraphService.instance;
});

// ========================================================================
// PLAYER INTELLIGENCE PROVIDER
// ========================================================================

/// Main Coach State - Player's Intelligence + Coach Brain
class CoachState {
  final PlayerIntelligence playerIntelligence;
  final CoachingPlan? coachingPlan;
  final CoachRecommendation? currentRecommendation;
  final List<CoachRecommendation> recentRecommendations;
  final bool isLoading;
  final String? error;

  CoachState({
    required this.playerIntelligence,
    this.coachingPlan,
    this.currentRecommendation,
    this.recentRecommendations = const [],
    this.isLoading = false,
    this.error,
  });

  CoachState copyWith({
    PlayerIntelligence? playerIntelligence,
    CoachingPlan? coachingPlan,
    CoachRecommendation? currentRecommendation,
    List<CoachRecommendation>? recentRecommendations,
    bool? isLoading,
    String? error,
  }) {
    return CoachState(
      playerIntelligence: playerIntelligence ?? this.playerIntelligence,
      coachingPlan: coachingPlan ?? this.coachingPlan,
      currentRecommendation: currentRecommendation ?? this.currentRecommendation,
      recentRecommendations: recentRecommendations ?? this.recentRecommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Coach State Notifier - Manages Coach Brain state
class CoachStateNotifier extends StateNotifier<CoachState> {
  final Ref _ref;
  final KnowledgeGraphService _kg;
  final CoachService _coachService;
  final SessionMemoryService _sessionMemory = SessionMemoryService();

  CoachStateNotifier(this._ref, this._kg)
      : _coachService = CoachService(knowledgeGraph: _kg),
        super(CoachState(
          playerIntelligence: PlayerIntelligence.empty('current_user'),
        )) {
    _initialize();
    _setupTrainingListener();
  }

  /// Listen to training provider changes to update PlayerIntelligence
  void _setupTrainingListener() {
    _ref.listen(
      trainingProvider,
      (previous, next) {
        // Update when new sessions are added
        if (previous != null && next.sessions.length > previous.sessions.length) {
          _updatePlayerIntelligenceFromTraining(next);
        }
      },
    );
  }

  /// Update PlayerIntelligence from training data
  Future<void> _updatePlayerIntelligenceFromTraining(TrainingState trainingState) async {
    if (trainingState.sessions.isEmpty) return;

    var updatedPI = state.playerIntelligence;

    // Build from all sessions
    for (final session in trainingState.sessions) {
      final sessionData = TrainingSessionData(
        drillCode: session.drillCode,
        score: session.score,
        durationMinutes: session.duration,
        completedAt: session.date,
        mistakes: [],
      );
      updatedPI = updatedPI.updateWithSession(sessionData);
    }

    // Only update if changed
    if (updatedPI != state.playerIntelligence) {
      state = state.copyWith(playerIntelligence: updatedPI);
      await refreshCoachPlan();
    }
  }

  Future<void> _initialize() async {
    // Load session memory
    await _sessionMemory.load();

    // Load saved PlayerIntelligence
    await _loadPlayerIntelligence();

    // Generate coaching plan
    await refreshCoachPlan();

    // Track recommendation if exists
    _trackCurrentRecommendation();
  }

  /// Track current recommendation in session memory
  void _trackCurrentRecommendation() {
    final rec = state.currentRecommendation;
    if (rec != null) {
      _sessionMemory.setRecommendation(
        drillCode: rec.drillCode,
        drillName: rec.drillName,
      );
    }
  }

  /// Load PlayerIntelligence from storage
  Future<void> _loadPlayerIntelligence() async {
    try {
      // Build from training data (MatchAnalysis persistence is Sprint-8 main focus)
      final playerIntelligence = await _buildPlayerIntelligence();
      state = state.copyWith(playerIntelligence: playerIntelligence);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load player data: $e');
    }
  }

  /// Build PlayerIntelligence from real training data
  Future<PlayerIntelligence> _buildPlayerIntelligence() async {
    // Get training sessions from provider
    final trainingState = _ref.read(trainingProvider);

    // Build PlayerIntelligence from sessions
    var playerIntelligence = PlayerIntelligence.empty('current_user');

    // Update with each session
    for (final session in trainingState.sessions) {
      final sessionData = TrainingSessionData(
        drillCode: session.drillCode,
        score: session.score,
        durationMinutes: session.duration,
        completedAt: session.date,
        mistakes: [], // TODO: Extract from session if available
      );
      playerIntelligence = playerIntelligence.updateWithSession(sessionData);
    }

    return playerIntelligence;
  }

  /// Refresh coaching plan from PriorityEngine
  Future<void> refreshCoachPlan() async {
    state = state.copyWith(isLoading: true);

    try {
      final priorityEngine = PriorityEngine(
        playerIntelligence: state.playerIntelligence,
        knowledgeGraph: _kg,
      );

      final coachingPlan = priorityEngine.getCoachingPlan();

      // Extract current recommendation
      CoachRecommendation? currentRec;
      if (coachingPlan.todayRecommendation != null) {
        currentRec = _convertRecommendation(coachingPlan.todayRecommendation!);
      }

      state = state.copyWith(
        coachingPlan: coachingPlan,
        currentRecommendation: currentRec,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate plan: $e',
      );
    }
  }

  /// Convert CoachingRecommendation to CoachRecommendation (UI layer)
  CoachRecommendation _convertRecommendation(CoachingRecommendation rec) {
    return CoachRecommendation.fromBrain(
      drillCode: rec.drillCode,
      drillName: rec.drillName,
      reason: rec.reason,
      expectedOutcome: 'Cải thiện ${rec.expectedImprovement.improvementPercent}%',
      outcomes: rec.evidence,
      estimatedMinutes: _getEstimatedMinutes(rec.drillCode),
      confidence: rec.confidence,
    );
  }

  int _getEstimatedMinutes(String drillCode) {
    final drill = _kg.getDrill(drillCode);
    if (drill != null) {
      // Use drill's estimated time or default
      return 10; // Default 10 minutes
    }
    return 10;
  }

  /// Update PlayerIntelligence with new session
  Future<void> updateWithSession(TrainingSessionData sessionData) async {
    // Update PlayerIntelligence
    final updatedPI = state.playerIntelligence.updateWithSession(sessionData);

    // Update recommendation history
    final updatedRecs = [
      ...state.recentRecommendations,
      if (state.currentRecommendation != null) state.currentRecommendation!,
    ].take(10).toList();

    state = state.copyWith(
      playerIntelligence: updatedPI,
      recentRecommendations: updatedRecs,
    );

    // Refresh coaching plan
    await refreshCoachPlan();

    // Save updated state
    await _savePlayerIntelligence();
  }

  /// Update PlayerIntelligence with match
  Future<void> updateWithMatch(MatchData matchData) async {
    final updatedPI = state.playerIntelligence.updateWithMatch(matchData);

    state = state.copyWith(playerIntelligence: updatedPI);
    await refreshCoachPlan();
    await _savePlayerIntelligence();
  }

  /// Update Coach with match analysis from Match Recording
  /// This is called after a match is completed to feed data into Coach AI
  Future<void> updateWithMatchAnalysis(MatchAnalysis analysis) async {
    // Update PlayerIntelligence with match data
    final matchData = MatchData(
      opponentName: 'Unknown',
      won: analysis.wins > analysis.losses,
      playerScore: analysis.wins,
      opponentScore: analysis.losses,
      durationMinutes: 0,
      playedAt: analysis.analyzedAt,
      mistakes: analysis.commonMistakes,
    );

    final updatedPI = state.playerIntelligence.updateWithMatch(matchData);

    state = state.copyWith(playerIntelligence: updatedPI);
    await refreshCoachPlan();
    await _savePlayerIntelligence();

    // Persist MatchAnalysis for app restart (Sprint-8)
    await LocalStorageService.saveLatestMatchAnalysis(analysis.toJson());
  }

  /// Clear MatchAnalysis when starting new match (Sprint-8)
  Future<void> clearMatchAnalysis() async {
    await LocalStorageService.clearLatestMatchAnalysis();
  }

  /// Save PlayerIntelligence to storage
  Future<void> _savePlayerIntelligence() async {
    // Sprint-8: Save PlayerIntelligence to local storage
    // TODO: Implement full PlayerIntelligence serialization for persistence
    // For now, MatchAnalysis is persisted which is the main Sprint-8 requirement
  }

  /// Get Coach response through CoachService
  CoachReasoning getReasoning(ConversationContext context) {
    return _coachService.getReasoning(context);
  }

  /// Format response with Coach Voice
  String formatResponse(CoachReasoning reasoning) {
    return _coachService.formatResponse(reasoning);
  }

  /// Get coaching plan
  CoachingPlan? get coachingPlan => state.coachingPlan;

  /// Get current recommendation
  CoachRecommendation? get currentRecommendation => state.currentRecommendation;

  /// Get player intelligence
  PlayerIntelligence get playerIntelligence => state.playerIntelligence;

  /// Get session memory
  SessionMemory get sessionMemory => _sessionMemory.memory;

  /// Check if there's an interrupted session
  bool get hasInterruptedSession => _sessionMemory.memory.hasInterruptedSession;

  /// Check if there's a recent recommendation
  bool get hasRecentRecommendation => _sessionMemory.memory.hasRecommendation;

  /// Start a new practice session
  void startPracticeSession(String drillCode, String drillName) {
    _sessionMemory.startSession(
      drillCode: drillCode,
      drillName: drillName,
    );
  }

  /// Update session progress
  void updatePracticeProgress(int progress, int? score) {
    _sessionMemory.updateProgress(progress, score);
  }

  /// Complete practice session
  void completePracticeSession(int score) {
    _sessionMemory.completeSession(score);
  }

  /// Pause practice session (interrupt)
  void pausePracticeSession(int progress, int? score) {
    _sessionMemory.pauseSession(progress, score);
  }

  /// Check recommendation consistency
  /// Returns true if new recommendation is different from previous without new evidence
  bool checkRecommendationConsistency(CoachRecommendation newRec) {
    final memory = _sessionMemory.memory;

    // If no previous recommendation, it's consistent
    if (!memory.hasRecommendation) return true;

    // If previous recommendation was completed, it's consistent
    if (memory.progress == 100) return true;

    // If more than 3 days since recommendation, it's consistent
    if (memory.recommendedDate != null &&
        DateTime.now().difference(memory.recommendedDate!).inDays > 3) {
      return true;
    }

    // If same drill, it's consistent
    if (memory.recommendedDrillCode == newRec.drillCode) return true;

    // Different drill without completion = inconsistency
    return false;
  }

  /// Get consistency warning message if any
  String? getConsistencyWarning() {
    final memory = _sessionMemory.memory;

    if (!memory.hasRecommendation) return null;
    if (memory.progress == 100) return null;

    // User didn't complete the previous recommendation
    if (memory.recommendedDrillName != null) {
      return 'Bạn chưa hoàn thành "${memory.recommendedDrillName}" từ lần trước.';
    }

    return null;
  }
}

// ========================================================================
// COACH STATE PROVIDER
// ========================================================================

final coachStateProvider = StateNotifierProvider<CoachStateNotifier, CoachState>((ref) {
  final kg = ref.watch(knowledgeGraphProvider);
  return CoachStateNotifier(ref, kg);
});

// ========================================================================
// CONVENIENCE PROVIDERS
// ========================================================================

/// Current Coaching Plan
final coachingPlanProvider = Provider<CoachingPlan?>((ref) {
  return ref.watch(coachStateProvider).coachingPlan;
});

/// Today's Recommendation
final todayRecommendationProvider = Provider<CoachRecommendation?>((ref) {
  return ref.watch(coachStateProvider).currentRecommendation;
});

/// Is Coach Loading
final coachLoadingProvider = Provider<bool>((ref) {
  return ref.watch(coachStateProvider).isLoading;
});

/// Coach Error
final coachErrorProvider = Provider<String?>((ref) {
  return ref.watch(coachStateProvider).error;
});

/// Learning Path Provider (derived from CoachService)
final learningPathProvider = FutureProvider<List<LearningPathItem>>((ref) async {
  // Return empty list for now - Coach AI will populate this when user has data
  // This prevents showing fake "Hoàn thành onboarding" message
  return <LearningPathItem>[];
});

/// Performance Summary Provider
final performanceSummaryProvider = FutureProvider<PerformanceSummary>((ref) async {
  return PerformanceSummary.empty();
});

/// Weakness Analysis Provider
final weaknessAnalysisProvider = FutureProvider<List<WeaknessAnalysis>>((ref) async {
  return <WeaknessAnalysis>[];
});

/// All Drill Progress Provider
final allDrillProgressProvider = Provider<Map<String, SimpleDrillProgress>>((ref) {
  return <String, SimpleDrillProgress>{};
});

// ========================================================================
// MATCH ANALYSIS PROVIDER - Phase 8
// ========================================================================

/// Match Analysis Service Provider
final matchAnalysisServiceProvider = Provider<MatchAnalysisService>((ref) {
  return MatchAnalysisService();
});

/// Latest Match Analysis Provider
/// Stores the most recent match analysis for Coach Home display
final latestMatchAnalysisProvider = StateProvider<MatchAnalysis?>((ref) {
  // Load from storage on initialization (Sprint-8)
  final savedData = LocalStorageService.getLatestMatchAnalysis();
  if (savedData != null) {
    try {
      return MatchAnalysis.fromJson(savedData);
    } catch (_) {
      return null;
    }
  }
  return null;
});

/// Latest Match Analysis Summary Provider
final latestMatchAnalysisSummaryProvider = Provider<MatchAnalysisSummary?>((ref) {
  final analysis = ref.watch(latestMatchAnalysisProvider);
  if (analysis == null) return null;

  final service = ref.read(matchAnalysisServiceProvider);
  return service.getSummary(analysis);
});

/// Match Analysis Recommendations Provider
final matchAnalysisRecommendationsProvider = Provider<List<DrillRecommendation>>((ref) {
  final analysis = ref.watch(latestMatchAnalysisProvider);
  if (analysis == null) return [];

  final service = ref.read(matchAnalysisServiceProvider);
  return service.getRecommendations(analysis);
});

/// Coach Insight from Match Provider
final coachMatchInsightProvider = Provider<String?>((ref) {
  final analysis = ref.watch(latestMatchAnalysisProvider);
  if (analysis == null) return null;

  final service = ref.read(matchAnalysisServiceProvider);
  return service.generateCoachInsight(analysis);
});

// Note: CoachRecommendation is defined in recommendation_card.dart
// and imported via the coach_home_widgets export
