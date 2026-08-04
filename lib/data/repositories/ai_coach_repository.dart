/// AI Coach Repository Interface
/// Abstracts data access for AI coaching features
abstract class AICoachRepository {
  /// Get AI recommendations
  Future<List<AIRecommendation>> getRecommendations();

  /// Get recommendations by type
  Future<List<AIRecommendation>> getRecommendationsByType(RecommendationType type);

  /// Save recommendation feedback
  Future<void> saveFeedback(String recommendationId, bool isAccepted);

  /// Get coaching history
  Future<List<CoachingSession>> getHistory({int? limit});

  /// Get weekly analysis
  Future<WeeklyAnalysis?> getWeeklyAnalysis();

  /// Get streak info
  Future<StreakInfo> getStreakInfo();

  /// Update streak
  Future<void> updateStreak();
}

/// AI Recommendation Model
class AIRecommendation {
  final String id;
  final String title;
  final String reason;
  final RecommendationType type;
  final String drillCode;
  final int priority;
  final DateTime createdAt;
  final bool isAccepted;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.type,
    required this.drillCode,
    required this.priority,
    required this.createdAt,
    this.isAccepted = false,
  });
}

/// Recommendation Types
enum RecommendationType {
  basedOnPerformance,
  basedOnStreak,
  basedOnKnowledge,
  weeklyChallenge,
  improvement,
}

/// Coaching Session Model
class CoachingSession {
  final String id;
  final String type;
  final String summary;
  final DateTime createdAt;

  CoachingSession({
    required this.id,
    required this.type,
    required this.summary,
    required this.createdAt,
  });
}

/// Weekly Analysis Model
class WeeklyAnalysis {
  final int weekNumber;
  final int totalSessions;
  final int totalMinutes;
  final int drillsCompleted;
  final int matchesPlayed;
  final double improvementPercent;
  final String strengths;
  final String areasToImprove;
  final DateTime weekStart;
  final DateTime weekEnd;

  WeeklyAnalysis({
    required this.weekNumber,
    required this.totalSessions,
    required this.totalMinutes,
    required this.drillsCompleted,
    required this.matchesPlayed,
    required this.improvementPercent,
    required this.strengths,
    required this.areasToImprove,
    required this.weekStart,
    required this.weekEnd,
  });
}

/// Streak Info Model
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });
}
