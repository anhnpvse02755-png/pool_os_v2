import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/drill_progress.dart';
import '../services/training_service.dart';
import 'auth_provider.dart';

/// Training Service Provider
final trainingServiceProvider = Provider<TrainingService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TrainingService(client);
});

// ============================================
// TRAINING SESSION PROVIDERS
// ============================================

/// Current Training Session State
class TrainingSessionState {
  final TrainingSession? currentSession;
  final DrillRun? currentDrillRun;
  final int attempts;
  final int successes;
  final bool isActive;

  const TrainingSessionState({
    this.currentSession,
    this.currentDrillRun,
    this.attempts = 0,
    this.successes = 0,
    this.isActive = false,
  });

  double get successRate => attempts > 0 ? (successes / attempts) * 100 : 0;

  TrainingSessionState copyWith({
    TrainingSession? currentSession,
    DrillRun? currentDrillRun,
    int? attempts,
    int? successes,
    bool? isActive,
  }) {
    return TrainingSessionState(
      currentSession: currentSession ?? this.currentSession,
      currentDrillRun: currentDrillRun ?? this.currentDrillRun,
      attempts: attempts ?? this.attempts,
      successes: successes ?? this.successes,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TrainingSessionNotifier extends StateNotifier<TrainingSessionState> {
  final TrainingService _trainingService;
  final String? _playerId;

  TrainingSessionNotifier(this._trainingService, this._playerId)
      : super(const TrainingSessionState());

  /// Start a new training session
  Future<void> startSession() async {
    if (_playerId == null) return;

    try {
      final session = await _trainingService.startSession(_playerId!);
      state = TrainingSessionState(
        currentSession: session,
        isActive: true,
      );
    } catch (e) {
      // Handle error
    }
  }

  /// Start a drill within the session
  Future<void> startDrill({
    required String drillCode,
    required String drillName,
    String? category,
    int? targetReps,
  }) async {
    if (state.currentSession == null) {
      await startSession();
    }

    try {
      final drillRun = await _trainingService.addDrillRun(
        sessionId: state.currentSession!.id,
        drillCode: drillCode,
        drillName: drillName,
        category: category,
        targetReps: targetReps,
      );
      state = state.copyWith(
        currentDrillRun: drillRun,
        attempts: 0,
        successes: 0,
      );
    } catch (e) {
      // Handle error
    }
  }

  /// Record a shot result
  void recordShot(bool success) {
    state = state.copyWith(
      attempts: state.attempts + 1,
      successes: success ? state.successes + 1 : state.successes,
    );
  }

  /// Finish the current drill
  Future<DrillRun?> finishDrill({String? notes}) async {
    if (state.currentDrillRun == null) return null;

    try {
      final updatedRun = await _trainingService.updateDrillRun(
        runId: state.currentDrillRun!.id,
        attempts: state.attempts,
        successes: state.successes,
        notes: notes,
      );

      // Update drill progress
      if (_playerId != null) {
        await _trainingService.updateDrillProgress(
          playerId: _playerId!,
          drillCode: state.currentDrillRun!.drillCode,
          attempts: state.attempts,
          successes: state.successes,
          successRate: state.successRate,
        );
      }

      state = state.copyWith(
        currentDrillRun: null,
        attempts: 0,
        successes: 0,
      );

      return updatedRun;
    } catch (e) {
      return null;
    }
  }

  /// End the training session
  Future<void> endSession() async {
    if (state.currentSession == null) return;

    try {
      await _trainingService.completeSession(state.currentSession!.id);
      state = const TrainingSessionState();
    } catch (e) {
      // Handle error
    }
  }
}

final trainingSessionProvider =
    StateNotifierProvider<TrainingSessionNotifier, TrainingSessionState>((ref) {
  final trainingService = ref.watch(trainingServiceProvider);

  // Get playerId from auth
  final authState = ref.watch(authProvider);
  String? playerId;

  return TrainingSessionNotifier(trainingService, authState.userId);
});

/// Recent Training Sessions
final recentTrainingSessionsProvider = FutureProvider<List<TrainingSession>>((ref) async {
  final trainingService = ref.watch(trainingServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.userId == null) return [];

  return await trainingService.getRecentSessions(authState.userId!, limit: 10);
});

// ============================================
// DRILL PROGRESS PROVIDERS
// ============================================

/// Get drill progress for a specific drill
final drillProgressProvider = FutureProvider.family<DrillProgress?, String>((ref, drillCode) async {
  final trainingService = ref.watch(trainingServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.userId == null) return null;

  return await trainingService.getDrillProgress(authState.userId!, drillCode);
});

/// Get all drill progress
final allDrillProgressProvider = FutureProvider<List<DrillProgress>>((ref) async {
  final trainingService = ref.watch(trainingServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.userId == null) return [];

  return await trainingService.getAllDrillProgress(authState.userId!);
});

/// Get drill level attempts
final drillLevelAttemptsProvider = FutureProvider.family<List<DrillLevelAttempt>, String>((ref, drillCode) async {
  final trainingService = ref.watch(trainingServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.userId == null) return [];

  return await trainingService.getLevelAttempts(authState.userId!, drillCode);
});

/// Get drill run history
final drillRunHistoryProvider = FutureProvider.family<List<DrillRun>, String>((ref, drillCode) async {
  final trainingService = ref.watch(trainingServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.userId == null) return [];

  return await trainingService.getDrillRunHistory(authState.userId!, drillCode);
});
