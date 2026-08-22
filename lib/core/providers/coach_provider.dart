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
import '../../data/repositories/match_repository.dart';
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
import 'repository_providers.dart';

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
  late final CoachService _coachService;
  final SessionMemoryService _sessionMemory = SessionMemoryService();

  CoachStateNotifier(this._ref, this._kg)
      : super(CoachState(
          playerIntelligence: PlayerIntelligence.empty('current_user'),
        )) {
    // Sprint-13: Initialize CoachService with initial PlayerIntelligence
    _coachService = CoachService(
      knowledgeGraph: _kg,
      playerIntelligence: state.playerIntelligence,
    );
    _initialize();
    _setupTrainingListener();
  }

  /// Sprint-13: Sync CoachService with updated PlayerIntelligence
  void _syncCoachService() {
    _coachService = CoachService(
      knowledgeGraph: _kg,
      playerIntelligence: state.playerIntelligence,
    );
  }

  /// Listen to training provider changes to update PlayerIntelligence
  /// Sprint-10C: Wire trainingNotifierProvider so Coach receives session updates.
  void _setupTrainingListener() {
    _ref.listen(
      trainingNotifierProvider,
      (previous, next) {
        // Update when new sessions are added
        if (previous != null && next.sessions.length > previous.sessions.length) {
          _updatePlayerIntelligenceFromTraining(next);
        }
      },
    );
  }

  /// Update PlayerIntelligence from training data
  /// Sprint-11: Extract real data including mistakes inference
  Future<void> _updatePlayerIntelligenceFromTraining(TrainingState trainingState) async {
    if (trainingState.sessions.isEmpty) return;

    var updatedPI = state.playerIntelligence;

    // Build from all sessions
    for (final session in trainingState.sessions) {
      // Sprint-11: Infer mistakes from accuracy
      final mistakes = <String>[];
      if (session.score < 50) {
        mistakes.add('aiming_issues');
      } else if (session.score < 70) {
        mistakes.add('accuracy_can_improve');
      }
      // Infer missed shots from shotsAttempted - shotsMade
      final missedShots = session.shotsAttempted - session.shotsMade;
      if (missedShots > session.shotsMade && missedShots > 5) {
        mistakes.add('technique_consistency');
      }

      // Sprint-14: Get drill skills for SkillProfile population
      final drill = _kg.getDrill(session.drillCode);
      final drillSkills = drill?.skillsTrained ?? [];

      final sessionData = TrainingSessionData(
        drillCode: session.drillCode,
        score: session.score,
        durationMinutes: session.duration,
        completedAt: session.date,
        mistakes: mistakes,
      );
      updatedPI = updatedPI.updateWithSession(sessionData, drillSkills: drillSkills);
    }

    // Only update if changed
    if (updatedPI != state.playerIntelligence) {
      state = state.copyWith(playerIntelligence: updatedPI);
      _syncCoachService(); // Sprint-13: Sync CoachService with updated PI
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
      // Sprint-8: Try to load from storage first
      final savedData = LocalStorageService.getPlayerIntelligence();
      if (savedData != null) {
        final playerIntelligence = PlayerIntelligence.fromJson(savedData);
        state = state.copyWith(playerIntelligence: playerIntelligence);
        _syncCoachService(); // Sprint-13: Sync CoachService with loaded PI
        return;
      }

      // Fallback: build from training data if no saved data
      final playerIntelligence = await _buildPlayerIntelligence();
      state = state.copyWith(playerIntelligence: playerIntelligence);
      _syncCoachService(); // Sprint-13: Sync CoachService with built PI
    } catch (e) {
      state = state.copyWith(error: 'Failed to load player data: $e');
    }
  }

  /// Build PlayerIntelligence from real training data (fallback)
  Future<PlayerIntelligence> _buildPlayerIntelligence() async {
    // Get training sessions from provider
    final trainingState = _ref.read(trainingNotifierProvider);

    // Build PlayerIntelligence from sessions
    var playerIntelligence = PlayerIntelligence.empty('current_user');

    // Update with each session
    for (final session in trainingState.sessions) {
      final sessionData = TrainingSessionData(
        drillCode: session.drillCode,
        score: session.score,
        durationMinutes: session.duration,
        completedAt: session.date,
        mistakes: [],
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
      PlayerIntelligence updatedPI = state.playerIntelligence;

      if (coachingPlan.todayRecommendation != null) {
        currentRec = _convertRecommendation(coachingPlan.todayRecommendation!);

        // Sprint-17: Record recommendation in history
        final updatedRecs = state.playerIntelligence.recommendations.addRecommendation(
          coachingPlan.todayRecommendation!.drillCode,
          coachingPlan.todayRecommendation!.reason,
        );
        updatedPI = state.playerIntelligence.copyWith(recommendations: updatedRecs);
      }

      state = state.copyWith(
        playerIntelligence: updatedPI,
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

  /// Sprint-12: Refresh Coach from match data
  /// Called when a manual match is logged
  Future<void> refreshFromMatch() async {
    // Load matches from repository
    final matchRepo = _ref.read(matchRepositoryProvider);
    final matches = await matchRepo.getAllMatches();

    if (matches.isEmpty) return;

    // Build PlayerIntelligence from matches
    var updatedPI = state.playerIntelligence;

    for (final match in matches) {
      // Only use most recent match for MVP
      final matchData = MatchData(
        opponentName: match.opponentName ?? match.opponent ?? 'Unknown',
        won: match.isWin,
        playerScore: match.playerScore,
        opponentScore: match.opponentScore,
        durationMinutes: match.duration ?? 0,
        playedAt: match.createdAt,
        mistakes: match.analysis?.biggestMistakes ?? [],
      );
      updatedPI = updatedPI.updateWithMatch(matchData);
    }

    // Update state and refresh plan
    if (updatedPI != state.playerIntelligence) {
      state = state.copyWith(playerIntelligence: updatedPI);
      _syncCoachService(); // Sprint-13: Sync CoachService with updated PI
      await refreshCoachPlan();
      // Sprint-12: Persist updated PlayerIntelligence
      await _savePlayerIntelligence();
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
      priority: rec.rank,
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
    // Sprint-14: Get drill skills for SkillProfile population
    final drill = _kg.getDrill(sessionData.drillCode);
    final drillSkills = drill?.skillsTrained ?? [];

    // Update PlayerIntelligence
    final updatedPI = state.playerIntelligence.updateWithSession(
      sessionData,
      drillSkills: drillSkills,
    );

    // Update recommendation history
    final updatedRecs = [
      ...state.recentRecommendations,
      if (state.currentRecommendation != null) state.currentRecommendation!,
    ].take(10).toList();

    state = state.copyWith(
      playerIntelligence: updatedPI,
      recentRecommendations: updatedRecs,
    );
    _syncCoachService(); // Sprint-13: Sync CoachService with updated PI

    // Refresh coaching plan
    await refreshCoachPlan();

    // Save updated state
    await _savePlayerIntelligence();
  }

  /// Update PlayerIntelligence with match
  Future<void> updateWithMatch(MatchData matchData) async {
    final updatedPI = state.playerIntelligence.updateWithMatch(matchData);

    state = state.copyWith(playerIntelligence: updatedPI);
    _syncCoachService(); // Sprint-13: Sync CoachService with updated PI
    await refreshCoachPlan();
    await _savePlayerIntelligence();
  }

  /// Update Coach with match analysis from Match Recording
  /// This is called after a match is completed to feed data into Coach AI
  Future<void> updateWithMatchAnalysis(MatchRackAnalysis analysis) async {
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
    _syncCoachService(); // Sprint-13: Sync CoachService with updated PI
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
    try {
      await LocalStorageService.savePlayerIntelligence(
        state.playerIntelligence.toJson(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to save player data: $e');
    }
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

/// Learning Path Provider (derived from CoachingPlan)
final learningPathProvider = FutureProvider<List<LearningPathItem>>((ref) async {
  // Watch coach state to get coaching plan
  final coachState = ref.watch(coachStateProvider);

  // Check if user has enough data for recommendations
  if (coachState.playerIntelligence.practicePatterns.totalSessions < 1) {
    return <LearningPathItem>[];
  }

  final coachingPlan = coachState.coachingPlan;
  if (coachingPlan == null) {
    return <LearningPathItem>[];
  }

  // Generate learning path from prioritized recommendations
  final items = <LearningPathItem>[];

  for (final area in coachingPlan.prioritizedFocusAreas.take(5)) {
    if (area.focusArea.drills.isEmpty) continue;

    final drill = area.focusArea.drills.first;

    items.add(LearningPathItem(
      drillCode: drill.code,
      drillName: drill.name,
      drillNameVi: drill.nameVi,
      description: area.focusArea.name,
      priority: area.rank,
      reason: area.reasoning,
      estimatedMinutes: drill.estimatedMinutes,
      category: area.focusArea.type.label,
      difficulty: drill.difficulty.name,
      currentProgress: 0.0, // TODO: Calculate from player intelligence
      knowledgeIds: drill.prerequisites, // prerequisite drills
    ));
  }

  return items;
});

/// Performance Summary Provider
/// Sprint-10C P0-4: Calculate from actual training sessions
final performanceSummaryProvider = FutureProvider<PerformanceSummary>((ref) async {
  final trainingState = ref.watch(trainingNotifierProvider);

  if (trainingState.sessions.isEmpty) {
    return PerformanceSummary.empty();
  }

  final sessions = trainingState.sessions;
  final totalSessions = sessions.length;
  final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.duration);
  final totalShots = sessions.fold<int>(0, (sum, s) => sum + s.shotsAttempted);
  final totalMade = sessions.fold<int>(0, (sum, s) => sum + s.shotsMade);
  final overallAccuracy = totalShots > 0 ? ((totalMade / totalShots) * 100).round() : 0;

  // Find weakest and strongest drills by accuracy
  final drillScores = <String, List<int>>{};
  for (final session in sessions) {
    final score = session.score;
    drillScores.putIfAbsent(session.drillCode, () => []).add(score);
  }

  WeakestDrillInfo? strongest;
  WeakestDrillInfo? weakest;

  if (drillScores.isNotEmpty) {
    final avgScores = drillScores.map((code, scores) {
      final avg = scores.fold<int>(0, (sum, s) => sum + s) ~/ scores.length;
      return MapEntry(code, avg);
    });

    final sorted = avgScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isNotEmpty) {
      weakest = WeakestDrillInfo(
        code: sorted.last.key,
        name: sessions.firstWhere((s) => s.drillCode == sorted.last.key).drillName,
        rate: sorted.last.value,
      );
      strongest = WeakestDrillInfo(
        code: sorted.first.key,
        name: sessions.firstWhere((s) => s.drillCode == sorted.first.key).drillName,
        rate: sorted.first.value,
      );
    }
  }

  // Determine trend (simple: improving if recent avg > older avg)
  String recentTrend = 'stable';
  if (sessions.length >= 3) {
    final recent = sessions.take(sessions.length ~/ 2);
    final older = sessions.skip(sessions.length ~/ 2);
    final recentAvg = recent.fold<int>(0, (sum, s) => sum + s.score) ~/ recent.length;
    final olderAvg = older.fold<int>(0, (sum, s) => sum + s.score) ~/ older.length;
    if (recentAvg > olderAvg + 5) {
      recentTrend = 'improving';
    } else if (recentAvg < olderAvg - 5) {
      recentTrend = 'declining';
    }
  }

  return PerformanceSummary(
    totalSessions: totalSessions,
    totalMinutes: totalMinutes,
    totalShots: totalShots,
    overallAccuracy: overallAccuracy,
    strongestDrill: strongest,
    weakestDrill: weakest,
    recentTrend: recentTrend,
  );
});

/// Weakness Analysis Provider
/// Sprint-10C P0-5: Analyze from actual training sessions
final weaknessAnalysisProvider = FutureProvider<List<WeaknessAnalysis>>((ref) async {
  final trainingState = ref.watch(trainingNotifierProvider);

  if (trainingState.sessions.isEmpty) {
    return <WeaknessAnalysis>[];
  }

  final sessions = trainingState.sessions;
  final weaknesses = <WeaknessAnalysis>[];

  // Group sessions by drill
  final drillScores = <String, List<int>>{};
  final drillNames = <String, String>{};
  for (final session in sessions) {
    drillScores.putIfAbsent(session.drillCode, () => []).add(session.score);
    drillNames[session.drillCode] = session.drillName;
  }

  // Find drills with low accuracy (weakness)
  for (final entry in drillScores.entries) {
    final avgScore = entry.value.fold<int>(0, (sum, s) => sum + s) ~/ entry.value.length;
    if (avgScore < 70 && entry.value.length >= 2) {
      weaknesses.add(WeaknessAnalysis(
        drillCode: entry.key,
        drillName: drillNames[entry.key] ?? entry.key,
        currentRate: avgScore,
        attempts: entry.value.length,
        suggestion: 'Cần luyện tập thêm để cải thiện',
        priority: avgScore < 50 ? 1 : 2, // 1=high, 2=medium
      ));
    }
  }

  // Sort by accuracy (lowest first)
  weaknesses.sort((a, b) => a.currentRate.compareTo(b.currentRate));

  return weaknesses.take(5).toList(); // Top 5 weaknesses
});

/// All Drill Progress Provider
/// Sprint-10C P0: Calculate from actual training sessions
final allDrillProgressProvider = Provider<Map<String, SimpleDrillProgress>>((ref) {
  final trainingState = ref.watch(trainingNotifierProvider);
  final sessions = trainingState.sessions;

  if (sessions.isEmpty) {
    return <String, SimpleDrillProgress>{};
  }

  // Group by drill and calculate progress
  final progressMap = <String, SimpleDrillProgress>{};
  for (final session in sessions) {
    final code = session.drillCode;
    final existing = progressMap[code];

    if (existing != null) {
      final totalAttempts = existing.totalAttempts + session.shotsAttempted;
      final successfulAttempts = existing.successfulAttempts + session.shotsMade;
      final avgAccuracy = totalAttempts > 0
          ? ((successfulAttempts / totalAttempts) * 100)
          : 0.0;
      final successRate = session.shotsAttempted > 0
          ? ((session.shotsMade / session.shotsAttempted) * 100)
          : 0.0;

      progressMap[code] = SimpleDrillProgress(
        drillCode: code,
        drillName: session.drillName,
        successRate: session.score > existing.successRate ? successRate : existing.successRate,
        totalAttempts: totalAttempts,
        successfulAttempts: successfulAttempts,
        averageAccuracy: avgAccuracy,
        lastAttemptedAt: session.date,
      );
    } else {
      final successRate = session.shotsAttempted > 0
          ? ((session.shotsMade / session.shotsAttempted) * 100)
          : 0.0;
      progressMap[code] = SimpleDrillProgress(
        drillCode: code,
        drillName: session.drillName,
        successRate: successRate,
        totalAttempts: session.shotsAttempted,
        successfulAttempts: session.shotsMade,
        averageAccuracy: session.score.toDouble(),
        lastAttemptedAt: session.date,
      );
    }
  }

  return progressMap;
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
/// Sprint-11: Renamed from MatchAnalysis to MatchRackAnalysis
final latestMatchAnalysisProvider = StateProvider<MatchRackAnalysis?>((ref) {
  // Load from storage on initialization (Sprint-8)
  final savedData = LocalStorageService.getLatestMatchAnalysis();
  if (savedData != null) {
    try {
      return MatchRackAnalysis.fromJson(savedData);
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
