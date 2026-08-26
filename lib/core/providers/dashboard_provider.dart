import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/drill_progress.dart';
import '../../core/providers/repository_providers.dart';
import 'training_provider.dart';

/// Dashboard Context - Trạng thái của Dashboard
/// Thay đổi theo hành động của người dùng
enum DashboardContext {
  normal,         // Default - AI recommendations
  afterMatch,      // Sau khi chơi match
  afterDrill,     // Sau khi hoàn thành drill
  afterKnowledge,  // Sau khi đọc knowledge
  streakWarning,  // Cảnh báo streak sắp mất
}

/// Dashboard Stats - Real data from repositories
class DashboardStats {
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final double winRate;
  final int practiceMinutes;
  final int drillsCompleted;
  final int activeDays;
  final double skillLevel; // 0.0 - 1.0

  DashboardStats({
    this.totalMatches = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.winRate = 0.0,
    this.practiceMinutes = 0,
    this.drillsCompleted = 0,
    this.activeDays = 0,
    this.skillLevel = 0.0,
  });

  factory DashboardStats.fromAggregates(Map<String, dynamic> agg, int drills, int minutes) {
    final total = (agg['totalMatches'] as int?) ?? 0;
    final wins = (agg['wins'] as int?) ?? 0;
    return DashboardStats(
      totalMatches: total,
      totalWins: wins,
      totalLosses: (agg['losses'] as int?) ?? 0,
      winRate: total > 0 ? wins / total : 0.0,
      practiceMinutes: minutes,
      drillsCompleted: drills,
      activeDays: 0,
      skillLevel: 0.0,
    );
  }
}

/// Strength/Weakness Analysis
class SkillAnalysis {
  final List<SkillItem> strengths;
  final List<SkillItem> weaknesses;

  SkillAnalysis({
    this.strengths = const [],
    this.weaknesses = const [],
  });
}

class SkillItem {
  final String name;
  final String nameVi;
  final double score; // 0.0 - 1.0
  final String drillCode;

  SkillItem({
    required this.name,
    required this.nameVi,
    required this.score,
    required this.drillCode,
  });
}

/// Recent Activity Item
class RecentActivity {
  final String id;
  final String type; // 'drill', 'match', 'knowledge'
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? drillCode;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.drillCode,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    if (diff.inDays < 7) return '${diff.inDays}ngày trước';
    return '${diff.inDays ~/ 7}tuần trước';
  }
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
/// Sprint-18 Part 2: Now reads from persistent TrainingNotifier to count
/// completed drills for today. This replaces the hardcoded StateProvider
/// that was never updated when drills were completed.
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

/// Calculates how many drills were completed today from training sessions.
int _countTodaySessions(List<dynamic> sessions) {
  if (sessions.isEmpty) return 0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int count = 0;
  for (final session in sessions) {
    final date = session.date as DateTime?;
    if (date == null) continue;

    final sessionDay = DateTime(date.year, date.month, date.day);
    if (sessionDay.isAtSameMomentAs(today)) {
      count++;
    }
  }
  return count;
}

/// Today Goals Provider - reads from persistent TrainingNotifier storage.
/// Sprint-18 Part 2: This replaces the StateProvider pattern that was never
/// updated. Now it reads from trainingNotifierProvider which persists to
/// LocalStorageService, so the count survives app restarts.
final todayGoalsProvider = Provider<TodayGoals>((ref) {
  // Watch trainingNotifierProvider so this updates when sessions are added
  final trainingState = ref.watch(trainingNotifierProvider);

  // Count sessions completed today
  final todayCount = _countTodaySessions(trainingState.sessions);

  return TodayGoals(
    drillsCompleted: todayCount,
    drillsTarget: 2,
    // Note: knowledgeRead and testPassed remain UI-only for now
    // They would need persistent storage to track properly
  );
});

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

/// ============================================================================
/// Real Data Providers - Fetch from repositories
/// ============================================================================

/// Dashboard Stats Provider - Real match stats from repository
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final drillRepo = ref.watch(drillRepositoryProvider);

  // Get match aggregates
  final aggregates = await matchRepo.getPlayerAggregates('current');

  // Get drill progress count
  final progress = await drillRepo.getUserProgress();
  final completedDrills = progress.where((p) => p.completedAt != null).length;

  // Get practice minutes from sessions
  final sessions = await drillRepo.getTrainingHistory(limit: 100);
  final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + (s.duration ?? 0));

  return DashboardStats.fromAggregates(aggregates, completedDrills, totalMinutes);
});

/// Recent Activities Provider - Combines drill sessions, matches, knowledge
final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final drillRepo = ref.watch(drillRepositoryProvider);

  final activities = <RecentActivity>[];

  // Get recent matches (last 5)
  final matches = await matchRepo.getAllMatches();
  for (final match in matches.take(3)) {
    activities.add(RecentActivity(
      id: 'match_${match.id}',
      type: 'match',
      title: match.isWin ? 'Thắng ${match.opponent ?? 'trận đấu'}' : 'Thua ${match.opponent ?? 'trận đấu'}',
      subtitle: match.resultSummary ?? '',
      timestamp: match.createdAt,
    ));
  }

  // Get recent drill sessions (last 5)
  final sessions = await drillRepo.getTrainingHistory(limit: 5);
  for (final session in sessions) {
    activities.add(RecentActivity(
      id: 'session_${session.id}',
      type: 'drill',
      title: 'Luyện tập ${session.drillName.isNotEmpty ? session.drillName : session.drillCode}',
      subtitle: '${session.shotsMade}/${session.shotsMade + session.shotsMissed} lần',
      timestamp: session.completedAt,
      drillCode: session.drillCode,
    ));
  }

  // Sort by timestamp, newest first
  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return activities.take(5).toList();
});

/// Skill Analysis Provider - Derives strengths/weaknesses from drill progress
final skillAnalysisProvider = FutureProvider<SkillAnalysis>((ref) async {
  final drillRepo = ref.watch(drillRepositoryProvider);
  final progress = await drillRepo.getUserProgress();

  if (progress.isEmpty) {
    return SkillAnalysis();
  }

  // Calculate skill scores from drill completion rates
  final skillScores = <String, _SkillScore>{};

  for (final p in progress) {
    // Estimate skill score from attempts and completion
    final attempts = p.attempts;
    final completedLevels = _countCompletedLevels(p);
    final score = _calculateSkillScore(attempts, completedLevels);

    // Map drill code to skill category
    final category = _drillCodeToCategory(p.drillCode);
    if (skillScores.containsKey(category)) {
      skillScores[category]!.addScore(score);
    } else {
      skillScores[category] = _SkillScore(category, score);
    }
  }

  // Sort and take top/bottom 3
  final sorted = skillScores.values.toList()
    ..sort((a, b) => b.averageScore.compareTo(a.averageScore));

  final strengths = sorted.take(3).map((s) => SkillItem(
    name: s.name,
    nameVi: _categoryNameVi(s.name),
    score: s.averageScore,
    drillCode: '',
  )).toList();

  final weaknesses = sorted.reversed.take(3).map((s) => SkillItem(
    name: s.name,
    nameVi: _categoryNameVi(s.name),
    score: s.averageScore,
    drillCode: '',
  )).toList();

  return SkillAnalysis(strengths: strengths, weaknesses: weaknesses);
});

class _SkillScore {
  final String name;
  double totalScore = 0;
  int count = 0;

  _SkillScore(this.name, double initialScore) {
    totalScore = initialScore;
    count = 1;
  }

  double get averageScore => count > 0 ? totalScore / count : 0;

  void addScore(double score) {
    totalScore += score;
    count++;
  }
}

int _countCompletedLevels(DrillProgress progress) {
  // Simplified: count levels based on attempts
  // Each level requires 10 attempts minimum
  final attempts = progress.attempts;
  return (attempts / 10).floor().clamp(0, 5);
}

double _calculateSkillScore(int attempts, int completedLevels) {
  // Score based on completion and attempts
  if (attempts == 0) return 0;
  final completionRate = completedLevels / 5.0;
  final masteryBonus = (attempts ~/ 50) * 0.1; // Bonus for lots of attempts
  return (completionRate + masteryBonus).clamp(0.0, 1.0);
}

String _drillCodeToCategory(String code) {
  final upper = code.toUpperCase();
  if (upper.contains('POT') || upper.contains('CUT')) return 'potting';
  if (upper.contains('STOP') || upper.contains('FOLLOW') || upper.contains('DRAW')) return 'cueball';
  if (upper.contains('POSITION')) return 'position';
  if (upper.contains('SAFETY')) return 'safety';
  if (upper.contains('BANK') || upper.contains('KICK') || upper.contains('JUMP')) return 'special';
  if (upper.contains('BREAK')) return 'break';
  return 'fundamentals';
}

String _categoryNameVi(String category) {
  switch (category) {
    case 'potting': return 'Đánh bóng';
    case 'cueball': return 'Kiểm soát bi cái';
    case 'position': return 'Vị trí';
    case 'safety': return 'An toàn';
    case 'special': return 'Kỹ năng đặc biệt';
    case 'break': return 'Khai cuộc';
    default: return 'Căn bản';
  }
}
