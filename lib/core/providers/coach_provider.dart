import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/coach_service.dart';
import '../models/drill_progress.dart';
import '../models/player_interests.dart';
import 'auth_provider.dart';
import 'player_provider.dart';
import 'training_provider.dart';

/// Coach Service Provider
final coachServiceProvider = Provider<CoachService>((ref) {
  return CoachService();
});

/// Learning Path Provider
final learningPathProvider = FutureProvider<List<LearningPathItem>>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final authState = ref.watch(authProvider);
  final interestsAsync = ref.watch(playerInterestsProvider);
  final progressAsync = ref.watch(allDrillProgressProvider);

  if (authState.userId == null) {
    return [];
  }

  // Get user interests
  List<String> interests = [];
  interestsAsync.whenData((interestsData) {
    if (interestsData != null) {
      interests = interestsData.interests;
    }
  });

  // Get drill progress
  List<DrillProgress> progress = [];
  progressAsync.whenData((progressData) {
    progress = progressData;
  });

  // Default interests if not set
  if (interests.isEmpty) {
    interests = ['draw', 'position', 'bank'];
  }

  // Get user rank (placeholder)
  final userRank = 'beginner';

  return coachService.generateLearningPath(
    userInterests: interests,
    drillProgress: progress,
    userRank: userRank,
  );
});

/// Weakness Analysis Provider
final weaknessAnalysisProvider = FutureProvider<List<WeaknessAnalysis>>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final progressAsync = ref.watch(allDrillProgressProvider);

  List<DrillProgress> progress = [];
  progressAsync.whenData((data) {
    progress = data;
  });

  return coachService.analyzeWeaknesses(progress);
});

/// Performance Summary Provider
final performanceSummaryProvider = FutureProvider<PerformanceSummary>((ref) async {
  final coachService = ref.watch(coachServiceProvider);
  final progressAsync = ref.watch(allDrillProgressProvider);

  List<DrillProgress> progress = [];
  progressAsync.whenData((data) {
    progress = data;
  });

  return coachService.getPerformanceSummary(progress);
});
