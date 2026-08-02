import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard Context - Trạng thái của Dashboard
/// Thay đổi theo hành động của người dùng
enum DashboardContext {
  normal,         // Default - AI recommendations
  afterMatch,      // Sau khi chơi match
  afterDrill,     // Sau khi hoàn thành drill
  afterKnowledge,  // Sau khi đọc knowledge
  streakWarning,  // Cảnh báo streak sắp mất
}

/// Dashboard State
class DashboardState {
  final DashboardContext context;
  final DateTime? lastMatchTime;
  final DateTime? lastDrillTime;
  final DateTime? lastKnowledgeTime;
  final Map<String, int>? missAnalysis; // Phân tích cú miss sau match
  final String? completedDrillCode;
  final String? completedKnowledgeId;
  final int streakDays;
  final int lastActivityDay;

  DashboardState({
    this.context = DashboardContext.normal,
    this.lastMatchTime,
    this.lastDrillTime,
    this.lastKnowledgeTime,
    this.missAnalysis,
    this.completedDrillCode,
    this.completedKnowledgeId,
    this.streakDays = 0,
    this.lastActivityDay = 0,
  });

  DashboardState copyWith({
    DashboardContext? context,
    DateTime? lastMatchTime,
    DateTime? lastDrillTime,
    DateTime? lastKnowledgeTime,
    Map<String, int>? missAnalysis,
    String? completedDrillCode,
    String? completedKnowledgeId,
    int? streakDays,
    int? lastActivityDay,
  }) {
    return DashboardState(
      context: context ?? this.context,
      lastMatchTime: lastMatchTime ?? this.lastMatchTime,
      lastDrillTime: lastDrillTime ?? this.lastDrillTime,
      lastKnowledgeTime: lastKnowledgeTime ?? this.lastKnowledgeTime,
      missAnalysis: missAnalysis ?? this.missAnalysis,
      completedDrillCode: completedDrillCode ?? this.completedDrillCode,
      completedKnowledgeId: completedKnowledgeId ?? this.completedKnowledgeId,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDay: lastActivityDay ?? this.lastActivityDay,
    );
  }

  /// Reset về normal context
  DashboardState reset() {
    return DashboardState(
      streakDays: streakDays,
      lastActivityDay: DateTime.now().day,
    );
  }
}

/// Dashboard Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState());

  /// Gọi sau khi hoàn thành match
  void onMatchCompleted({
    required int totalMisses,
    Map<String, int>? missByCategory,
  }) {
    state = state.copyWith(
      context: DashboardContext.afterMatch,
      lastMatchTime: DateTime.now(),
      missAnalysis: missByCategory ?? _defaultMissAnalysis(totalMisses),
    );
  }

  /// Gọi sau khi hoàn thành drill
  void onDrillCompleted(String drillCode, int newLevel) {
    state = state.copyWith(
      context: DashboardContext.afterDrill,
      lastDrillTime: DateTime.now(),
      completedDrillCode: drillCode,
    );
  }

  /// Gọi sau khi hoàn thành knowledge
  void onKnowledgeCompleted(String knowledgeId) {
    state = state.copyWith(
      context: DashboardContext.afterKnowledge,
      lastKnowledgeTime: DateTime.now(),
      completedKnowledgeId: knowledgeId,
    );
  }

  /// Gọi khi streak sắp hết
  void onStreakWarning(int daysInactive) {
    state = state.copyWith(
      context: DashboardContext.streakWarning,
    );
  }

  /// Reset về normal
  void reset() {
    state = state.reset();
  }

  /// Cập nhật streak
  void updateStreak(int days) {
    state = state.copyWith(streakDays: days);
  }

  Map<String, int> _defaultMissAnalysis(int total) {
    // Demo data
    return {
      'position': (total * 0.7).round(),
      'stop': (total * 0.15).round(),
      'follow': (total * 0.1).round(),
      'other': (total * 0.05).round(),
    };
  }
}

/// Dashboard Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

/// Today's Goals Provider
class TodayGoals {
  final int drillsCompleted;
  final int drillsTarget;
  final bool knowledgeRead;
  final bool testPassed;

  TodayGoals({
    this.drillsCompleted = 0,
    this.drillsTarget = 2,
    this.knowledgeRead = false,
    this.testPassed = false,
  });

  bool get allCompleted =>
      drillsCompleted >= drillsTarget && knowledgeRead && testPassed;

  double get drillsProgress =>
      drillsTarget > 0 ? drillsCompleted / drillsTarget : 0;
}

final todayGoalsProvider = StateProvider<TodayGoals>((ref) => TodayGoals());

/// Ongoing Drill Provider - Drill đang tập dở
class OngoingDrill {
  final String drillCode;
  final String drillName;
  final int currentLevel;
  final double progressPercent;
  final DateTime lastAttempt;

  OngoingDrill({
    required this.drillCode,
    required this.drillName,
    required this.currentLevel,
    required this.progressPercent,
    required this.lastAttempt,
  });

  bool get isStale {
    final now = DateTime.now();
    return now.difference(lastAttempt).inDays >= 1;
  }
}

final ongoingDrillProvider = StateProvider<OngoingDrill?>((ref) => null);
