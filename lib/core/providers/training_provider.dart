// ============================================================================
// TRAINING PROVIDER
// ============================================================================
// Buoi tap di qua DrillRepository, KHONG cham storage truc tiep.
// Nho vay Sprint 3 (noi Directus) chi phai doi mot dong o
// repository_providers.dart.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/training_session.dart';
import 'repository_providers.dart';

class TrainingState {
  final List<TrainingSession> sessions;
  final bool isLoading;
  final String? error;

  const TrainingState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  TrainingState copyWith({
    List<TrainingSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return TrainingState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrainingNotifier extends StateNotifier<TrainingState> {
  /// [autoStart] va [initialState] la khe cho test. Mac dinh giu nguyen
  /// hanh vi cu nen ma chay that khong doi. Cung khuon voi
  /// CoachStateNotifier — xem .claude/memory/poolos.md muc 9.
  TrainingNotifier(
    this._ref, {
    bool autoStart = true,
    TrainingState? initialState,
  }) : super(initialState ?? const TrainingState()) {
    if (autoStart) _loadData();
  }

  final Ref _ref;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final sessions =
          await _ref.read(drillRepositoryProvider).getTrainingHistory();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addSession(TrainingSession session) async {
    try {
      await _ref.read(drillRepositoryProvider).saveTrainingSession(session);
      state = state.copyWith(sessions: [session, ...state.sessions]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  Map<String, dynamic> getStats() {
    final sessions = state.sessions;
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'avgScore': 0,
        'totalShots': 0,
      };
    }

    final totalSessions = sessions.length;
    final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final avgScore =
        sessions.fold<int>(0, (sum, s) => sum + s.score) ~/ totalSessions;
    final totalShots = sessions.fold<int>(0, (sum, s) => sum + s.shotsMade);

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'avgScore': avgScore,
      'totalShots': totalShots,
    };
  }

  List<TrainingSession> getSessionsByDrill(String drillCode) {
    return state.sessions.where((s) => s.drillCode == drillCode).toList();
  }

  List<TrainingSession> getSessionsInRange(DateTime start, DateTime end) {
    return state.sessions.where((s) {
      return s.completedAt.isAfter(start) && s.completedAt.isBefore(end);
    }).toList();
  }
}

final trainingNotifierProvider =
    StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier(ref);
});

final trainingStatsProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(trainingNotifierProvider);
  return ref.read(trainingNotifierProvider.notifier).getStats();
});
