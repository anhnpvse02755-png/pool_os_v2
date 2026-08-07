// ============================================================================
// PLAYER INTELLIGENCE MODEL - Phase 6
// Personal Intelligence Layer for Coach AI
//
// Coach AI must understand the PLAYER, not just Pool.
// Built continuously from practice, matches, reflections.
// ============================================================================

/// Player Intelligence Model
/// A living model of the player that updates over time.
/// This is not a CRUD profile - it's a dynamic intelligence layer.
class PlayerIntelligence {
  /// Unique player identifier
  final String playerId;

  /// Identity layer - Who is this player
  final PlayerIdentity identity;

  /// Skill profile - Current skill levels
  final SkillProfile skillProfile;

  /// Progress tracking - How are they improving?
  final ProgressTracker progress;

  /// Mistake patterns - What mistakes do they make?
  final MistakePatterns mistakePatterns;

  /// Practice patterns - How do they practice?
  final PracticePatterns practicePatterns;

  /// Match patterns - How do they perform in matches?
  final MatchPatterns matchPatterns;

  /// Mental model - Psychological profile
  final MentalModel mentalModel;

  /// Learning history - What have they learned?
  final LearningHistory learningHistory;

  /// Recommendation history - What have we recommended?
  final RecommendationHistory recommendations;

  /// Short-term memory - Recent context
  final ShortTermMemory shortTermMemory;

  /// Working memory - Current conversation context
  final WorkingMemory workingMemory;

  /// Timestamp of last update
  final DateTime updatedAt;

  PlayerIntelligence({
    required this.playerId,
    required this.identity,
    required this.skillProfile,
    required this.progress,
    required this.mistakePatterns,
    required this.practicePatterns,
    required this.matchPatterns,
    required this.mentalModel,
    required this.learningHistory,
    required this.recommendations,
    required this.shortTermMemory,
    required this.workingMemory,
    required this.updatedAt,
  });

  /// Create a new player intelligence model
  factory PlayerIntelligence.empty(String playerId) {
    return PlayerIntelligence(
      playerId: playerId,
      identity: PlayerIdentity.empty(),
      skillProfile: SkillProfile.empty(),
      progress: ProgressTracker.empty(),
      mistakePatterns: MistakePatterns.empty(),
      practicePatterns: PracticePatterns.empty(),
      matchPatterns: MatchPatterns.empty(),
      mentalModel: MentalModel.empty(),
      learningHistory: LearningHistory.empty(),
      recommendations: RecommendationHistory.empty(),
      shortTermMemory: ShortTermMemory.empty(),
      workingMemory: WorkingMemory.empty(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update with new session data
  PlayerIntelligence updateWithSession(TrainingSessionData session) {
    return copyWith(
      progress: progress.addSession(session),
      mistakePatterns: mistakePatterns.updateFromSession(session),
      practicePatterns: practicePatterns.addSession(session),
      shortTermMemory: shortTermMemory.addSession(session),
      updatedAt: DateTime.now(),
    );
  }

  /// Update with new match data
  PlayerIntelligence updateWithMatch(MatchData match) {
    return copyWith(
      matchPatterns: matchPatterns.addMatch(match),
      mistakePatterns: mistakePatterns.updateFromMatch(match),
      progress: progress.addMatch(match),
      updatedAt: DateTime.now(),
    );
  }

  /// Update with reflection
  PlayerIntelligence updateWithReflection(ReflectionData reflection) {
    return copyWith(
      mentalModel: mentalModel.updateFromReflection(reflection),
      learningHistory: learningHistory.addReflection(reflection),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate player summary for Coach
  PlayerSummary toSummary() {
    return PlayerSummary(
      name: identity.name,
      overallLevel: skillProfile.overallLevel,
      primaryStrength: skillProfile.primaryStrength,
      primaryWeakness: skillProfile.primaryWeakness,
      currentTrend: progress.currentTrend,
      topMistakes: mistakePatterns.topMistakes.take(3).toList(),
      recommendedFocus: _determineRecommendedFocus(),
      confidence: _calculateConfidence(),
    );
  }

  String _determineRecommendedFocus() {
    // Logic to determine what to focus on next
    if (mistakePatterns.topMistakes.isNotEmpty) {
      return 'Cải thiện: ${mistakePatterns.topMistakes.first}';
    }
    return 'Tiếp tục luyện tập để duy trì phong độ';
  }

  int _calculateConfidence() {
    // Based on data completeness
    int score = 0;
    if (skillProfile.skills.isNotEmpty) score += 30;
    if (mistakePatterns.patterns.isNotEmpty) score += 30;
    if (progress.trendHistory.isNotEmpty) score += 20;
    if (practicePatterns.totalSessions > 5) score += 20;
    return score.clamp(0, 100);
  }

  PlayerIntelligence copyWith({
    String? playerId,
    PlayerIdentity? identity,
    SkillProfile? skillProfile,
    ProgressTracker? progress,
    MistakePatterns? mistakePatterns,
    PracticePatterns? practicePatterns,
    MatchPatterns? matchPatterns,
    MentalModel? mentalModel,
    LearningHistory? learningHistory,
    RecommendationHistory? recommendations,
    ShortTermMemory? shortTermMemory,
    WorkingMemory? workingMemory,
    DateTime? updatedAt,
  }) {
    return PlayerIntelligence(
      playerId: playerId ?? this.playerId,
      identity: identity ?? this.identity,
      skillProfile: skillProfile ?? this.skillProfile,
      progress: progress ?? this.progress,
      mistakePatterns: mistakePatterns ?? this.mistakePatterns,
      practicePatterns: practicePatterns ?? this.practicePatterns,
      matchPatterns: matchPatterns ?? this.matchPatterns,
      mentalModel: mentalModel ?? this.mentalModel,
      learningHistory: learningHistory ?? this.learningHistory,
      recommendations: recommendations ?? this.recommendations,
      shortTermMemory: shortTermMemory ?? this.shortTermMemory,
      workingMemory: workingMemory ?? this.workingMemory,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ============================================================================
// PLAYER IDENTITY - Who is this player?
// ============================================================================

class PlayerIdentity {
  /// Player display name
  final String name;

  /// When they started
  final DateTime? startedAt;

  /// Primary goal
  final String? primaryGoal;

  /// Experience level (self-reported)
  final ExperienceLevel experienceLevel;

  /// Preferred play style
  final PlayStyle? playStyle;

  const PlayerIdentity({
    required this.name,
    this.startedAt,
    this.primaryGoal,
    this.experienceLevel = ExperienceLevel.beginner,
    this.playStyle,
  });

  factory PlayerIdentity.empty() {
    return const PlayerIdentity(name: 'Player');
  }

  int get daysSinceStart {
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt!).inDays;
  }
}

enum ExperienceLevel {
  beginner,    // < 6 months
  intermediate, // 6-24 months
  advanced,    // 2-5 years
  expert;      // > 5 years

  String get label {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'Mới chơi';
      case ExperienceLevel.intermediate:
        return 'Trung bình';
      case ExperienceLevel.advanced:
        return 'Nâng cao';
      case ExperienceLevel.expert:
        return 'Chuyên gia';
    }
  }
}

enum PlayStyle {
  aggressive,
  defensive,
  strategic,
  technical;

  String get label {
    switch (this) {
      case PlayStyle.aggressive:
        return 'Tấn công';
      case PlayStyle.defensive:
        return 'Phòng thủ';
      case PlayStyle.strategic:
        return 'Chiến lược';
      case PlayStyle.technical:
        return 'Kỹ thuật';
    }
  }
}

// ============================================================================
// SKILL PROFILE - What skills do they have?
// ============================================================================

class SkillProfile {
  /// Individual skill levels (0-100)
  final Map<String, SkillLevel> skills;

  /// Overall skill level
  final ExperienceLevel overallLevel;

  /// Primary strength (highest skill)
  final String? primaryStrength;

  /// Primary weakness (lowest skill)
  final String? primaryWeakness;

  /// Most practiced skills
  final List<String> mostPracticedSkills;

  const SkillProfile({
    required this.skills,
    required this.overallLevel,
    this.primaryStrength,
    this.primaryWeakness,
    this.mostPracticedSkills = const [],
  });

  factory SkillProfile.empty() {
    return const SkillProfile(
      skills: {},
      overallLevel: ExperienceLevel.beginner,
    );
  }

  SkillLevel getSkill(String skillId) {
    return skills[skillId] ?? SkillLevel.novice;
  }

  SkillLevel? getPrimaryStrength() {
    if (skills.isEmpty) return null;
    return skills.entries
        .reduce((a, b) => a.value.level > b.value.level ? a : b)
        .value;
  }

  SkillLevel? getPrimaryWeakness() {
    if (skills.isEmpty) return null;
    return skills.entries
        .reduce((a, b) => a.value.level < b.value.level ? a : b)
        .value;
  }
}

class SkillLevel {
  final String skillId;
  final int level; // 0-100
  final int sessionsPracticed;
  final DateTime? lastPracticed;

  const SkillLevel({
    required this.skillId,
    required this.level,
    this.sessionsPracticed = 0,
    this.lastPracticed,
  });

  static const novice = SkillLevel(skillId: '', level: 0);
  static const beginner = SkillLevel(skillId: '', level: 25);
  static const intermediate = SkillLevel(skillId: '', level: 50);
  static const advanced = SkillLevel(skillId: '', level: 75);
  static const expert = SkillLevel(skillId: '', level: 100);

  String get label {
    if (level < 20) return 'Sơ cấp';
    if (level < 40) return 'Cơ bản';
    if (level < 60) return 'Trung bình';
    if (level < 80) return 'Khá';
    return 'Giỏi';
  }
}

// ============================================================================
// PROGRESS TRACKER - How are they improving?
// ============================================================================

class ProgressTracker {
  /// Historical scores
  final List<ProgressPoint> trendHistory;

  /// Current trend direction
  final TrendDirection currentTrend;

  /// Best performance ever
  final ProgressPoint? personalBest;

  /// Recent improvement rate
  final double improvementRate; // per week

  /// Consistency score (0-100)
  final int consistencyScore;

  const ProgressTracker({
    required this.trendHistory,
    required this.currentTrend,
    this.personalBest,
    required this.improvementRate,
    required this.consistencyScore,
  });

  factory ProgressTracker.empty() {
    return const ProgressTracker(
      trendHistory: [],
      currentTrend: TrendDirection.stable,
      improvementRate: 0,
      consistencyScore: 0,
    );
  }

  ProgressTracker addSession(TrainingSessionData session) {
    final newPoint = ProgressPoint(
      date: session.completedAt,
      score: session.score,
      type: ProgressType.training,
    );

    final updatedHistory = [...trendHistory, newPoint];

    return ProgressTracker(
      trendHistory: updatedHistory,
      currentTrend: _calculateTrend(updatedHistory),
      personalBest: _updatePersonalBest(personalBest, newPoint),
      improvementRate: _calculateImprovementRate(updatedHistory),
      consistencyScore: _calculateConsistency(updatedHistory),
    );
  }

  ProgressTracker addMatch(MatchData match) {
    final winRate = match.won ? 100 : 0;
    final newPoint = ProgressPoint(
      date: match.playedAt,
      score: winRate,
      type: ProgressType.match,
    );

    final updatedHistory = [...trendHistory, newPoint];

    return ProgressTracker(
      trendHistory: updatedHistory,
      currentTrend: _calculateTrend(updatedHistory),
      personalBest: _updatePersonalBest(personalBest, newPoint),
      improvementRate: _calculateImprovementRate(updatedHistory),
      consistencyScore: _calculateConsistency(updatedHistory),
    );
  }

  TrendDirection _calculateTrend(List<ProgressPoint> history) {
    if (history.length < 5) return TrendDirection.stable;

    final recent = history.take(5).map((p) => p.score).average;
    final older = history.skip(5).take(5).map((p) => p.score).average;

    if (recent - older > 5) return TrendDirection.improving;
    if (older - recent > 5) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  ProgressPoint? _updatePersonalBest(ProgressPoint? current, ProgressPoint newPoint) {
    if (current == null || newPoint.score > current.score) {
      return newPoint;
    }
    return current;
  }

  double _calculateImprovementRate(List<ProgressPoint> history) {
    if (history.length < 10) return 0;
    // Simplified: compare first 5 vs last 5
    return 0;
  }

  int _calculateConsistency(List<ProgressPoint> history) {
    if (history.isEmpty) return 0;
    final scores = history.map((p) => p.score).toList();
    final mean = scores.average;
    final variance = scores.map((s) => (s - mean) * (s - mean)).reduce((a, b) => a + b) / scores.length;
    return (100 - variance.clamp(0, 100)).round();
  }
}

class ProgressPoint {
  final DateTime date;
  final int score;
  final ProgressType type;

  const ProgressPoint({
    required this.date,
    required this.score,
    required this.type,
  });
}

enum ProgressType { training, match }

enum TrendDirection {
  improving,
  stable,
  declining;

  String get label {
    switch (this) {
      case TrendDirection.improving:
        return 'Đang tiến bộ';
      case TrendDirection.stable:
        return 'Ổn định';
      case TrendDirection.declining:
        return 'Cần cải thiện';
    }
  }
}

extension on Iterable<num> {
  double get average => isEmpty ? 0 : (reduce((a, b) => a + b) / length).toDouble();
}

// ============================================================================
// MISTAKE PATTERNS - What mistakes do they make?
// ============================================================================

class MistakePatterns {
  /// Historical mistakes with frequency
  final List<MistakePattern> patterns;

  /// Top recurring mistakes
  final List<String> topMistakes;

  /// Mistakes they're improving on
  final List<String> improvingMistakes;

  /// New mistakes recently
  final List<String> newMistakes;

  const MistakePatterns({
    required this.patterns,
    required this.topMistakes,
    required this.improvingMistakes,
    required this.newMistakes,
  });

  factory MistakePatterns.empty() {
    return const MistakePatterns(
      patterns: [],
      topMistakes: [],
      improvingMistakes: [],
      newMistakes: [],
    );
  }

  MistakePatterns updateFromSession(TrainingSessionData session) {
    // Add mistakes from session
    return this;
  }

  MistakePatterns updateFromMatch(MatchData match) {
    // Add mistakes from match rack analysis
    return this;
  }
}

class MistakePattern {
  final String mistakeId;
  final String mistakeName;
  final int frequency; // times seen
  final DateTime lastSeen;
  final bool isImproving;
  final List<String> associatedCauses;

  const MistakePattern({
    required this.mistakeId,
    required this.mistakeName,
    required this.frequency,
    required this.lastSeen,
    required this.isImproving,
    this.associatedCauses = const [],
  });
}

// ============================================================================
// PRACTICE PATTERNS - How do they practice?
// ============================================================================

class PracticePatterns {
  final int totalSessions;
  final int totalMinutes;
  final DateTime? lastSession;
  final int avgSessionLength; // minutes
  final int sessionsThisWeek;
  final int sessionsThisMonth;
  final List<String> favoriteDrills;
  final ConsistencyMetrics consistency;

  const PracticePatterns({
    required this.totalSessions,
    required this.totalMinutes,
    this.lastSession,
    required this.avgSessionLength,
    required this.sessionsThisWeek,
    required this.sessionsThisMonth,
    required this.favoriteDrills,
    required this.consistency,
  });

  factory PracticePatterns.empty() {
    return PracticePatterns(
      totalSessions: 0,
      totalMinutes: 0,
      avgSessionLength: 0,
      sessionsThisWeek: 0,
      sessionsThisMonth: 0,
      favoriteDrills: const [],
      consistency: ConsistencyMetrics.empty(),
    );
  }

  PracticePatterns addSession(TrainingSessionData session) {
    return PracticePatterns(
      totalSessions: totalSessions + 1,
      totalMinutes: totalMinutes + session.durationMinutes,
      lastSession: session.completedAt,
      avgSessionLength: ((avgSessionLength * totalSessions) + session.durationMinutes) ~/ (totalSessions + 1),
      sessionsThisWeek: _isThisWeek(session.completedAt) ? sessionsThisWeek + 1 : sessionsThisWeek,
      sessionsThisMonth: _isThisMonth(session.completedAt) ? sessionsThisMonth + 1 : sessionsThisMonth,
      favoriteDrills: _updateFavoriteDrills(favoriteDrills, session.drillCode),
      consistency: consistency.addSession(session),
    );
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now.subtract(Duration(days: now.weekday)));
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  List<String> _updateFavoriteDrills(List<String> current, String drillCode) {
    final updated = [drillCode, ...current.where((d) => d != drillCode)];
    return updated.take(5).toList();
  }
}

class ConsistencyMetrics {
  final int regularity; // 0-100
  final int preferredTime; // morning/afternoon/evening
  final int preferredDay; // day of week
  final double deviationFromHabit;

  const ConsistencyMetrics({
    required this.regularity,
    required this.preferredTime,
    required this.preferredDay,
    required this.deviationFromHabit,
  });

  factory ConsistencyMetrics.empty() {
    return const ConsistencyMetrics(
      regularity: 0,
      preferredTime: 0,
      preferredDay: 0,
      deviationFromHabit: 0,
    );
  }

  ConsistencyMetrics addSession(TrainingSessionData session) {
    return this;
  }
}

// ============================================================================
// MATCH PATTERNS - How do they perform in matches?
// ============================================================================

class MatchPatterns {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final StreakInfo currentStreak;
  final StreakInfo longestWinStreak;
  final StreakInfo longestLossStreak;
  final PerformanceByOpponent opponentAnalysis;
  final PerformanceByCondition conditionAnalysis;

  const MatchPatterns({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.currentStreak,
    required this.longestWinStreak,
    required this.longestLossStreak,
    required this.opponentAnalysis,
    required this.conditionAnalysis,
  });

  factory MatchPatterns.empty() {
    return MatchPatterns(
      totalMatches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      winRate: 0,
      currentStreak: const StreakInfo(type: StreakType.none, count: 0),
      longestWinStreak: const StreakInfo(type: StreakType.none, count: 0),
      longestLossStreak: const StreakInfo(type: StreakType.none, count: 0),
      opponentAnalysis: PerformanceByOpponent.empty(),
      conditionAnalysis: PerformanceByCondition.empty(),
    );
  }

  MatchPatterns addMatch(MatchData match) {
    return this;
  }
}

class StreakInfo {
  final StreakType type;
  final int count;

  const StreakInfo({
    required this.type,
    required this.count,
  });
}

enum StreakType { win, loss, none }

class PerformanceByOpponent {
  final Map<String, OpponentRecord> records;

  const PerformanceByOpponent({
    required this.records,
  });

  factory PerformanceByOpponent.empty() {
    return const PerformanceByOpponent(records: {});
  }
}

class OpponentRecord {
  final String opponentName;
  final int timesPlayed;
  final int wins;
  final int losses;
  final DateTime lastPlayed;

  const OpponentRecord({
    required this.opponentName,
    required this.timesPlayed,
    required this.wins,
    required this.losses,
    required this.lastPlayed,
  });
}

class PerformanceByCondition {
  final int homeWinRate;
  final int awayWinRate;
  final int pressureWinRate;

  const PerformanceByCondition({
    required this.homeWinRate,
    required this.awayWinRate,
    required this.pressureWinRate,
  });

  factory PerformanceByCondition.empty() {
    return const PerformanceByCondition(
      homeWinRate: 0,
      awayWinRate: 0,
      pressureWinRate: 0,
    );
  }
}

// ============================================================================
// MENTAL MODEL - Psychological profile
// ============================================================================

class MentalModel {
  final int confidence; // 0-100
  final int focus; // 0-100
  final int pressureHandling; // 0-100
  final int tiltTendency; // 0-100
  final List<String> mentalBlocks;
  final List<String> triggers;
  final MentalTrend trend;

  const MentalModel({
    required this.confidence,
    required this.focus,
    required this.pressureHandling,
    required this.tiltTendency,
    required this.mentalBlocks,
    required this.triggers,
    required this.trend,
  });

  factory MentalModel.empty() {
    return const MentalModel(
      confidence: 50,
      focus: 50,
      pressureHandling: 50,
      tiltTendency: 50,
      mentalBlocks: [],
      triggers: [],
      trend: MentalTrend.stable,
    );
  }

  MentalModel updateFromReflection(ReflectionData reflection) {
    return this;
  }
}

enum MentalTrend {
  improving,
  stable,
  declining;

  String get label {
    switch (this) {
      case MentalTrend.improving:
        return 'Đang cải thiện';
      case MentalTrend.stable:
        return 'Ổn định';
      case MentalTrend.declining:
        return 'Cần chú ý';
    }
  }
}

// ============================================================================
// LEARNING HISTORY - What have they learned?
// ============================================================================

class LearningHistory {
  final List<LearningEntry> entries;
  final List<String> masteredConcepts;
  final List<String> inProgressConcepts;
  final Map<String, DateTime> conceptMasteredAt;

  const LearningHistory({
    required this.entries,
    required this.masteredConcepts,
    required this.inProgressConcepts,
    required this.conceptMasteredAt,
  });

  factory LearningHistory.empty() {
    return const LearningHistory(
      entries: [],
      masteredConcepts: [],
      inProgressConcepts: [],
      conceptMasteredAt: {},
    );
  }

  LearningHistory addReflection(ReflectionData reflection) {
    return this;
  }
}

class LearningEntry {
  final DateTime date;
  final String type; // drill, concept, mistake_fix
  final String itemId;
  final String description;
  final int? improvementScore;

  const LearningEntry({
    required this.date,
    required this.type,
    required this.itemId,
    required this.description,
    this.improvementScore,
  });
}

// ============================================================================
// RECOMMENDATION HISTORY - What have we recommended?
// ============================================================================

class RecommendationHistory {
  final List<RecommendationEntry> entries;
  final Map<String, int> drillRecommendationCount;
  final DateTime? lastRecommendation;

  const RecommendationHistory({
    required this.entries,
    required this.drillRecommendationCount,
    this.lastRecommendation,
  });

  factory RecommendationHistory.empty() {
    return const RecommendationHistory(
      entries: [],
      drillRecommendationCount: {},
      lastRecommendation: null,
    );
  }

  RecommendationHistory addRecommendation(String drillCode, String reason) {
    return this;
  }

  RecommendationHistory markAsCompleted(String recommendationId) {
    return this;
  }
}

class RecommendationEntry {
  final String id;
  final DateTime createdAt;
  final String drillCode;
  final String reason;
  final bool completed;
  final DateTime? completedAt;

  const RecommendationEntry({
    required this.id,
    required this.createdAt,
    required this.drillCode,
    required this.reason,
    required this.completed,
    this.completedAt,
  });
}

// ============================================================================
// SHORT-TERM MEMORY - Recent context
// ============================================================================

class ShortTermMemory {
  final List<MemoryEntry> recentSessions;
  final List<MemoryEntry> recentMatches;
  final List<MemoryEntry> recentReflections;
  final List<MemoryEntry> recentObservations;

  const ShortTermMemory({
    required this.recentSessions,
    required this.recentMatches,
    required this.recentReflections,
    required this.recentObservations,
  });

  factory ShortTermMemory.empty() {
    return const ShortTermMemory(
      recentSessions: [],
      recentMatches: [],
      recentReflections: [],
      recentObservations: [],
    );
  }

  ShortTermMemory addSession(TrainingSessionData session) {
    final entry = MemoryEntry(
      timestamp: session.completedAt,
      type: MemoryType.session,
      data: {
        'drillCode': session.drillCode,
        'score': session.score,
        'duration': session.durationMinutes,
      },
    );
    return ShortTermMemory(
      recentSessions: [entry, ...recentSessions.where((e) => e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))],
      recentMatches: recentMatches,
      recentReflections: recentReflections,
      recentObservations: recentObservations,
    );
  }

  MemoryEntry? getLastSession() => recentSessions.isNotEmpty ? recentSessions.first : null;
  MemoryEntry? getLastMatch() => recentMatches.isNotEmpty ? recentMatches.first : null;
  MemoryEntry? getLastReflection() => recentReflections.isNotEmpty ? recentReflections.first : null;
}

class MemoryEntry {
  final DateTime timestamp;
  final MemoryType type;
  final Map<String, dynamic> data;

  const MemoryEntry({
    required this.timestamp,
    required this.type,
    required this.data,
  });
}

enum MemoryType { session, match, reflection, observation, recommendation }

// ============================================================================
// WORKING MEMORY - Current conversation context
// ============================================================================

class WorkingMemory {
  final List<String> currentTopics;
  final List<String> pendingQuestions;
  final Map<String, dynamic> context;
  final DateTime conversationStart;

  const WorkingMemory({
    required this.currentTopics,
    required this.pendingQuestions,
    required this.context,
    required this.conversationStart,
  });

  factory WorkingMemory.empty() {
    return WorkingMemory(
      currentTopics: [],
      pendingQuestions: [],
      context: {},
      conversationStart: DateTime.now(),
    );
  }

  WorkingMemory addTopic(String topic) {
    return WorkingMemory(
      currentTopics: [...currentTopics, topic],
      pendingQuestions: pendingQuestions,
      context: context,
      conversationStart: conversationStart,
    );
  }

  WorkingMemory clear() {
    return WorkingMemory.empty();
  }
}

// ============================================================================
// PLAYER SUMMARY - Quick overview for Coach
// ============================================================================

class PlayerSummary {
  final String name;
  final ExperienceLevel overallLevel;
  final String? primaryStrength;
  final String? primaryWeakness;
  final TrendDirection currentTrend;
  final List<String> topMistakes;
  final String recommendedFocus;
  final int confidence; // How confident is Coach about this profile

  const PlayerSummary({
    required this.name,
    required this.overallLevel,
    this.primaryStrength,
    this.primaryWeakness,
    required this.currentTrend,
    required this.topMistakes,
    required this.recommendedFocus,
    required this.confidence,
  });

  String toCoachStatement() {
    final parts = <String>[];

    parts.add('$name là người chơi ${overallLevel.label}.');

    if (primaryStrength != null) {
      parts.add('�iểm mạnh: $primaryStrength.');
    }

    if (primaryWeakness != null) {
      parts.add('Cần cải thiện: $primaryWeakness.');
    }

    parts.add('Xu hướng: ${currentTrend.label}.');

    if (topMistakes.isNotEmpty) {
      parts.add('Lỗi thường gặp: ${topMistakes.join(', ')}.');
    }

    parts.add('Hôm nay mình khuyên: $recommendedFocus');

    return parts.join(' ');
  }
}

// ============================================================================
// DATA CLASSES - For updates
// ============================================================================

class TrainingSessionData {
  final String drillCode;
  final int score;
  final int durationMinutes;
  final DateTime completedAt;
  final List<String> mistakes;
  final Map<String, dynamic> metrics;

  const TrainingSessionData({
    required this.drillCode,
    required this.score,
    required this.durationMinutes,
    required this.completedAt,
    this.mistakes = const [],
    this.metrics = const {},
  });
}

class MatchData {
  final String opponentName;
  final bool won;
  final int playerScore;
  final int opponentScore;
  final int durationMinutes;
  final DateTime playedAt;
  final List<String> mistakes;
  final String? venue;

  const MatchData({
    required this.opponentName,
    required this.won,
    required this.playerScore,
    required this.opponentScore,
    required this.durationMinutes,
    required this.playedAt,
    this.mistakes = const [],
    this.venue,
  });
}

class ReflectionData {
  final String content;
  final DateTime createdAt;
  final List<String> insights;
  final Map<String, dynamic> selfAssessment;

  const ReflectionData({
    required this.content,
    required this.createdAt,
    this.insights = const [],
    this.selfAssessment = const {},
  });
}
