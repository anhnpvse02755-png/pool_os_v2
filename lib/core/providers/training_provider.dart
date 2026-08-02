// ============================================================================
// TRAINING PROVIDER - Với Local Storage
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/local_storage_service.dart';

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

class TrainingSession {
  final String id;
  final String drillCode;
  final String drillName;
  final int score;
  final int shotsAttempted;
  final int shotsMade;
  final int duration;
  final DateTime date;
  final int? improvement;

  TrainingSession({
    required this.id,
    required this.drillCode,
    required this.drillName,
    required this.score,
    required this.shotsAttempted,
    required this.shotsMade,
    required this.duration,
    required this.date,
    this.improvement,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] ?? const Uuid().v4(),
      drillCode: json['drillCode'] ?? '',
      drillName: json['drillName'] ?? '',
      score: json['score'] ?? 0,
      shotsAttempted: json['shotsAttempted'] ?? 0,
      shotsMade: json['shotsMade'] ?? 0,
      duration: json['duration'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      improvement: json['improvement'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'drillCode': drillCode,
    'drillName': drillName,
    'score': score,
    'shotsAttempted': shotsAttempted,
    'shotsMade': shotsMade,
    'duration': duration,
    'date': date.toIso8601String(),
    'improvement': improvement,
  };
}

class TrainingNotifier extends StateNotifier<TrainingState> {
  TrainingNotifier() : super(const TrainingState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await LocalStorageService.getDrillSessions();
      final sessions = data.map((json) => TrainingSession.fromJson(json)).toList();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addSession(TrainingSession session) async {
    try {
      await LocalStorageService.saveDrillSession(session.toJson());
      state = state.copyWith(sessions: [session, ...state.sessions]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSession(TrainingSession session) async {
    try {
      await LocalStorageService.updateDrillSession(session.id, session.toJson());
      final sessions = state.sessions.map((s) {
        return s.id == session.id ? session : s;
      }).toList();
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await LocalStorageService.deleteDrillSession(id);
      final sessions = state.sessions.where((s) => s.id != id).toList();
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }

  // Stats
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
    final avgScore = sessions.fold<int>(0, (sum, s) => sum + s.score) ~/ totalSessions;
    final totalShots = sessions.fold<int>(0, (sum, s) => sum + s.shotsMade);

    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'avgScore': avgScore,
      'totalShots': totalShots,
    };
  }

  // Filter
  List<TrainingSession> getSessionsByDrill(String drillCode) {
    return state.sessions.where((s) => s.drillCode == drillCode).toList();
  }

  List<TrainingSession> getSessionsInRange(DateTime start, DateTime end) {
    return state.sessions.where((s) {
      return s.date.isAfter(start) && s.date.isBefore(end);
    }).toList();
  }
}

final trainingProvider = StateNotifierProvider<TrainingNotifier, TrainingState>((ref) {
  return TrainingNotifier();
});

// Stats provider
final trainingStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(trainingProvider.notifier);
  return notifier.getStats();
});
