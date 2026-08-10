import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/training_session.dart';
import '../../data/models/match.dart';
import '../../data/models/drill_progress.dart';
import '../../domain/services/trend_engine.dart';
import '../../knowledge/knowledge_graph_service.dart';
import '../../knowledge/drill_node.dart';
import '../../knowledge/skill_node.dart';
import '../../knowledge/mistake_node.dart';
import 'repository_providers.dart';

/// Sprint 4C Task 21 — Coach AI Data Layer
///
/// Unified data provider for Coach AI.
/// Abstracts all data access for Phase 6-7 Coach AI implementation.
///
/// Coach AI reads from this provider to get:
/// - Training history
/// - Match history
/// - Drill progress
/// - Trend analysis
/// - Player performance signals

/// Combined player data for Coach AI consumption
class CoachPlayerData {
  final List<TrainingSession> trainingHistory;
  final List<Match> matchHistory;
  final List<DrillProgress> drillProgress;
  final TrendSummary? trendSummary;
  final DateTime fetchedAt;

  CoachPlayerData({
    required this.trainingHistory,
    required this.matchHistory,
    required this.drillProgress,
    this.trendSummary,
    required this.fetchedAt,
  });

  /// Summary for Coach AI quick access
  CoachPlayerSummary get summary => CoachPlayerSummary(
    totalSessions: trainingHistory.length,
    totalMatches: matchHistory.length,
    totalDrills: drillProgress.length,
    overallTrainingTrend: trendSummary?.trainingTrend ?? TrendResult.insufficient,
    overallMatchTrend: trendSummary?.matchTrend ?? TrendResult.insufficient,
    consistencyScore: trendSummary?.consistencyScore ?? 0,
    winRate: _computeWinRate(),
    avgTrainingScore: _computeAvgTrainingScore(),
  );

  int _computeWinRate() {
    if (matchHistory.isEmpty) return 0;
    final wins = matchHistory.where((m) => m.isWin).length;
    return (wins * 100 / matchHistory.length).round();
  }

  int _computeAvgTrainingScore() {
    if (trainingHistory.isEmpty) return 0;
    final total = trainingHistory.fold<int>(0, (sum, s) => sum + s.score);
    return total ~/ trainingHistory.length;
  }
}

class CoachPlayerSummary {
  final int totalSessions;
  final int totalMatches;
  final int totalDrills;
  final TrendResult overallTrainingTrend;
  final TrendResult overallMatchTrend;
  final int consistencyScore;
  final int winRate;
  final int avgTrainingScore;

  CoachPlayerSummary({
    required this.totalSessions,
    required this.totalMatches,
    required this.totalDrills,
    required this.overallTrainingTrend,
    required this.overallMatchTrend,
    required this.consistencyScore,
    required this.winRate,
    required this.avgTrainingScore,
  });
}

/// Coach AI data provider
final coachPlayerDataProvider = FutureProvider<CoachPlayerData>((ref) async {
  final drillRepo = ref.watch(drillRepositoryProvider);
  final matchRepo = ref.watch(matchRepositoryProvider);

  // Fetch all data in parallel
  final results = await Future.wait([
    drillRepo.getTrainingHistory(),
    drillRepo.getUserProgress(),
    matchRepo.getAllMatches(),
  ]);

  final trainingHistory = results[0] as List<TrainingSession>;
  final drillProgress = results[1] as List<DrillProgress>;
  final matchHistory = results[2] as List<Match>;

  // Compute trends
  TrendSummary? trendSummary;
  if (trainingHistory.isNotEmpty || matchHistory.isNotEmpty) {
    final trendEngine = TrendEngine(
      trainingHistory: trainingHistory,
      matchHistory: matchHistory,
    );
    trendSummary = trendEngine.summary;
  }

  return CoachPlayerData(
    trainingHistory: trainingHistory,
    matchHistory: matchHistory,
    drillProgress: drillProgress,
    trendSummary: trendSummary,
    fetchedAt: DateTime.now(),
  );
});

/// Provider for specific drill history (Coach AI)
final coachDrillHistoryProvider = FutureProvider.family<List<TrainingSession>, String>((ref, drillCode) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  return data.trainingHistory.where((s) => s.drillCode == drillCode).toList()
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
});

/// Provider for specific opponent history (Coach AI)
final coachOpponentHistoryProvider = FutureProvider.family<List<Match>, String>((ref, opponent) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  return data.matchHistory.where((m) =>
    m.opponentName == opponent || m.opponent == opponent
  ).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

/// Provider for recent sessions (Coach AI reads last N sessions)
final coachRecentSessionsProvider = FutureProvider.family<List<TrainingSession>, int>((ref, limit) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  final sorted = List<TrainingSession>.from(data.trainingHistory)
    ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return sorted.take(limit).toList();
});

/// Provider for recent matches (Coach AI reads last N matches)
final coachRecentMatchesProvider = FutureProvider.family<List<Match>, int>((ref, limit) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  final sorted = List<Match>.from(data.matchHistory)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted.take(limit).toList();
});

/// Provider for drill trends (Coach AI reads improvement/decline per drill)
final coachDrillTrendsProvider = FutureProvider<Map<String, DrillTrend>>((ref) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  if (data.trendSummary == null) return {};
  return data.trendSummary!.drillTrends;
});

/// Provider for weakest drills (Coach AI prioritizes improvement areas)
final coachWeakestDrillsProvider = FutureProvider<List<DrillProgress>>((ref) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  // Sort by score ascending (lowest = weakest)
  return List<DrillProgress>.from(data.drillProgress)
    ..sort((a, b) => a.bestScore.compareTo(b.bestScore));
});

/// Provider for strongest drills (Coach AI builds on strengths)
final coachStrongestDrillsProvider = FutureProvider<List<DrillProgress>>((ref) async {
  final data = await ref.watch(coachPlayerDataProvider.future);
  // Sort by score descending (highest = strongest)
  return List<DrillProgress>.from(data.drillProgress)
    ..sort((a, b) => b.bestScore.compareTo(a.bestScore));
});

// ========================================================================
// KNOWLEDGE GRAPH PROVIDERS - Phase 5
// Coach AI Brain queries
// ========================================================================

/// Knowledge Graph Service provider
final knowledgeGraphProvider = Provider<KnowledgeGraphService>((ref) {
  return KnowledgeGraphService.instance;
});

/// Get drill knowledge (Coach AI query)
final coachDrillKnowledgeProvider = Provider.family<DrillNode?, String>((ref, drillCode) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getDrill(drillCode);
});

/// Get drills that train a specific skill (Coach AI query)
final coachDrillsBySkillProvider = Provider.family<List<DrillNode>, String>((ref, skillId) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getDrillsBySkill(skillId);
});

/// Get drills that fix a specific mistake (Coach AI query)
final coachDrillsForMistakeProvider = Provider.family<List<DrillNode>, String>((ref, mistakeId) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getDrillsForMistake(mistakeId);
});

/// Get prerequisites for a drill (Coach AI query)
final coachPrerequisitesProvider = Provider.family<List<DrillNode>, String>((ref, drillCode) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getPrerequisites(drillCode);
});

/// Get progression drills (Coach AI query)
final coachProgressionDrillsProvider = Provider.family<List<DrillNode>, String>((ref, drillCode) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getProgressionDrills(drillCode);
});

/// Get recommended drills for weakest skills (Coach AI reasoning)
/// Combines player weakness → skill → recommended drills
final coachRecommendedDrillsProvider = FutureProvider<List<DrillNode>>((ref) async {
  final kg = ref.watch(knowledgeGraphProvider);
  final weakestDrills = await ref.watch(coachWeakestDrillsProvider.future);

  if (weakestDrills.isEmpty) {
    // Return beginner drills if no history
    return kg.getDrillsByLevel(DrillDifficulty.beginner);
  }

  // Get drills for the weakest areas
  final recommendations = <DrillNode>[];
  final addedCodes = <String>{};

  for (final progress in weakestDrills.take(3)) {
    final drills = kg.getDrillsBySkill(_skillForDrill(progress.drillCode));
    for (final drill in drills) {
      if (!addedCodes.contains(drill.code) && drill.difficulty.index <= DrillDifficulty.intermediate.index) {
        recommendations.add(drill);
        addedCodes.add(drill.code);
      }
    }
  }

  return recommendations.take(5).toList();
});

/// Get explanation for why a drill is recommended (Coach AI reasoning)
final coachDrillExplanationProvider = Provider.family<String, String>((ref, drillCode) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.explainDrillPurpose(drillCode);
});

/// Get all drill nodes
final coachAllDrillsProvider = Provider<List<DrillNode>>((ref) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getAllDrills();
});

/// Get all skill nodes
final coachAllSkillsProvider = Provider<List<SkillNode>>((ref) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getAllSkills();
});

/// Get all mistake nodes
final coachAllMistakesProvider = Provider<List<MistakeNode>>((ref) {
  final kg = ref.watch(knowledgeGraphProvider);
  return kg.getAllMistakes();
});

/// Helper: Map drill code to primary skill
String _skillForDrill(String drillCode) {
  // This would ideally come from DrillNode, but for now use common mappings
  final drill = KnowledgeGraphService.instance.getDrill(drillCode);
  if (drill != null && drill.skillsTrained.isNotEmpty) {
    return drill.skillsTrained.first;
  }

  // Fallback mappings
  if (drillCode.contains('STOP')) return PoolSkills.cueBallControl;
  if (drillCode.contains('FOLLOW')) return PoolSkills.cueBallControl;
  if (drillCode.contains('DRAW')) return PoolSkills.cueBallControl;
  if (drillCode.contains('CUT')) return PoolSkills.aiming;
  if (drillCode.contains('BANK') || drillCode.contains('KICK')) return PoolSkills.bankShot;
  if (drillCode.contains('SAFETY')) return PoolSkills.safetyPlay;
  if (drillCode.contains('POSITION')) return PoolSkills.positionPlay;
  if (drillCode.contains('SPEED')) return PoolSkills.speedControl;
  return PoolSkills.stroke;
}
