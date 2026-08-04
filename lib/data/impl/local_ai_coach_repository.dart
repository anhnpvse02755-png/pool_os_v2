import '../../data/datasources/local/local_storage_datasource.dart';
import '../../data/repositories/ai_coach_repository.dart';

/// Local AI Coach Repository Implementation
class LocalAICoachRepository implements AICoachRepository {
  @override
  Future<List<AIRecommendation>> getRecommendations() async {
    final data = await LocalStorageDataSource.getRecommendations();
    return data.map((json) => _recommendationFromJson(json)).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  @override
  Future<List<AIRecommendation>> getRecommendationsByType(RecommendationType type) async {
    final recommendations = await getRecommendations();
    return recommendations.where((r) => r.type == type).toList();
  }

  @override
  Future<void> saveFeedback(String recommendationId, bool isAccepted) async {
    final recommendations = await LocalStorageDataSource.getRecommendations();
    final index = recommendations.indexWhere((r) => r['id'] == recommendationId);
    if (index != -1) {
      recommendations[index]['isAccepted'] = isAccepted;
      await LocalStorageDataSource.saveRecommendations(recommendations);
    }
  }

  @override
  Future<List<CoachingSession>> getHistory({int? limit}) async {
    final data = await LocalStorageDataSource.getCoachingHistory();
    var history = data.map((json) => _coachingSessionFromJson(json)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && history.length > limit) {
      history = history.take(limit).toList();
    }
    return history;
  }

  @override
  Future<WeeklyAnalysis?> getWeeklyAnalysis() async {
    final history = await getHistory(limit: 10);
    if (history.isEmpty) return null;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return WeeklyAnalysis(
      weekNumber: _getWeekNumber(now),
      totalSessions: history.length,
      totalMinutes: history.length * 20, // Demo: 20 min per session
      drillsCompleted: history.length,
      matchesPlayed: 0,
      improvementPercent: 5.0,
      strengths: 'Position Control đang cải thiện tốt',
      areasToImprove: 'Safety play cần luyện thêm',
      weekStart: weekStart,
      weekEnd: now,
    );
  }

  @override
  Future<StreakInfo> getStreakInfo() async {
    final data = await LocalStorageDataSource.getStreakInfo();
    return StreakInfo(
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActivityDate: data['lastActivityDate'] != null
          ? DateTime.parse(data['lastActivityDate'])
          : null,
    );
  }

  @override
  Future<void> updateStreak() async {
    final streak = await getStreakInfo();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = streak.currentStreak;

    if (streak.lastActivityDate != null) {
      final lastActivity = DateTime(
        streak.lastActivityDate!.year,
        streak.lastActivityDate!.month,
        streak.lastActivityDate!.day,
      );
      final daysDiff = today.difference(lastActivity).inDays;

      if (daysDiff == 1) {
        // Consecutive day - increase streak
        newStreak = streak.currentStreak + 1;
      } else if (daysDiff > 1) {
        // Streak broken - reset
        newStreak = 1;
      }
    } else {
      // First activity
      newStreak = 1;
    }

    final longestStreak = newStreak > streak.longestStreak ? newStreak : streak.longestStreak;

    await LocalStorageDataSource.saveStreakInfo({
      'currentStreak': newStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': now.toIso8601String(),
    });
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(firstDayOfYear).inDays;
    return ((days + firstDayOfYear.weekday) / 7).ceil();
  }

  AIRecommendation _recommendationFromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'],
      title: json['title'],
      reason: json['reason'],
      type: RecommendationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecommendationType.basedOnPerformance,
      ),
      drillCode: json['drillCode'],
      priority: json['priority'] ?? 1,
      createdAt: DateTime.parse(json['createdAt']),
      isAccepted: json['isAccepted'] ?? false,
    );
  }

  CoachingSession _coachingSessionFromJson(Map<String, dynamic> json) {
    return CoachingSession(
      id: json['id'],
      type: json['type'],
      summary: json['summary'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
