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

  /// Create from JSON (Sprint-8 persistence)
  factory PlayerIntelligence.fromJson(Map<String, dynamic> json) {
    return PlayerIntelligence(
      playerId: json['playerId'] as String? ?? 'current_user',
      identity: json['identity'] != null
          ? PlayerIdentity.fromJson(json['identity'] as Map<String, dynamic>)
          : PlayerIdentity.empty(),
      skillProfile: json['skillProfile'] != null
          ? SkillProfile.fromJson(json['skillProfile'] as Map<String, dynamic>)
          : SkillProfile.empty(),
      progress: json['progress'] != null
          ? ProgressTracker.fromJson(json['progress'] as Map<String, dynamic>)
          : ProgressTracker.empty(),
      mistakePatterns: json['mistakePatterns'] != null
          ? MistakePatterns.fromJson(json['mistakePatterns'] as Map<String, dynamic>)
          : MistakePatterns.empty(),
      practicePatterns: json['practicePatterns'] != null
          ? PracticePatterns.fromJson(json['practicePatterns'] as Map<String, dynamic>)
          : PracticePatterns.empty(),
      matchPatterns: json['matchPatterns'] != null
          ? MatchPatterns.fromJson(json['matchPatterns'] as Map<String, dynamic>)
          : MatchPatterns.empty(),
      mentalModel: json['mentalModel'] != null
          ? MentalModel.fromJson(json['mentalModel'] as Map<String, dynamic>)
          : MentalModel.empty(),
      learningHistory: json['learningHistory'] != null
          ? LearningHistory.fromJson(json['learningHistory'] as Map<String, dynamic>)
          : LearningHistory.empty(),
      recommendations: json['recommendations'] != null
          ? RecommendationHistory.fromJson(json['recommendations'] as Map<String, dynamic>)
          : RecommendationHistory.empty(),
      shortTermMemory: json['shortTermMemory'] != null
          ? ShortTermMemory.fromJson(json['shortTermMemory'] as Map<String, dynamic>)
          : ShortTermMemory.empty(),
      workingMemory: json['workingMemory'] != null
          ? WorkingMemory.fromJson(json['workingMemory'] as Map<String, dynamic>)
          : WorkingMemory.empty(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON (Sprint-8 persistence)
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'identity': identity.toJson(),
      'skillProfile': skillProfile.toJson(),
      'progress': progress.toJson(),
      'mistakePatterns': mistakePatterns.toJson(),
      'practicePatterns': practicePatterns.toJson(),
      'matchPatterns': matchPatterns.toJson(),
      'mentalModel': mentalModel.toJson(),
      'learningHistory': learningHistory.toJson(),
      'recommendations': recommendations.toJson(),
      'shortTermMemory': shortTermMemory.toJson(),
      'workingMemory': workingMemory.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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

  factory PlayerIdentity.fromJson(Map<String, dynamic> json) {
    return PlayerIdentity(
      name: json['name'] as String? ?? 'Player',
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      primaryGoal: json['primaryGoal'] as String?,
      experienceLevel: ExperienceLevel.fromString(json['experienceLevel'] as String? ?? 'beginner'),
      playStyle: PlayStyle.fromString(json['playStyle'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startedAt': startedAt?.toIso8601String(),
      'primaryGoal': primaryGoal,
      'experienceLevel': experienceLevel.name,
      'playStyle': playStyle?.name,
    };
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

  static ExperienceLevel fromString(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExperienceLevel.beginner,
    );
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

  static PlayStyle? fromString(String? value) {
    if (value == null) return null;
    return PlayStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PlayStyle.strategic,
    );
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

  factory SkillProfile.fromJson(Map<String, dynamic> json) {
    final skillsMap = json['skills'] as Map<String, dynamic>? ?? {};
    return SkillProfile(
      skills: skillsMap.map((k, v) => MapEntry(k, SkillLevel.fromJson(v as Map<String, dynamic>))),
      overallLevel: ExperienceLevel.fromString(json['overallLevel'] as String? ?? 'beginner'),
      primaryStrength: json['primaryStrength'] as String?,
      primaryWeakness: json['primaryWeakness'] as String?,
      mostPracticedSkills: (json['mostPracticedSkills'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills.map((k, v) => MapEntry(k, v.toJson())),
      'overallLevel': overallLevel.name,
      'primaryStrength': primaryStrength,
      'primaryWeakness': primaryWeakness,
      'mostPracticedSkills': mostPracticedSkills,
    };
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

  factory SkillLevel.fromJson(Map<String, dynamic> json) {
    return SkillLevel(
      skillId: json['skillId'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      sessionsPracticed: json['sessionsPracticed'] as int? ?? 0,
      lastPracticed: json['lastPracticed'] != null ? DateTime.parse(json['lastPracticed'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'level': level,
      'sessionsPracticed': sessionsPracticed,
      'lastPracticed': lastPracticed?.toIso8601String(),
    };
  }

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

  factory ProgressTracker.fromJson(Map<String, dynamic> json) {
    final historyList = json['trendHistory'] as List<dynamic>? ?? [];
    return ProgressTracker(
      trendHistory: historyList.map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>)).toList(),
      currentTrend: TrendDirection.fromString(json['currentTrend'] as String? ?? 'stable'),
      personalBest: json['personalBest'] != null ? ProgressPoint.fromJson(json['personalBest'] as Map<String, dynamic>) : null,
      improvementRate: (json['improvementRate'] as num?)?.toDouble() ?? 0,
      consistencyScore: json['consistencyScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trendHistory': trendHistory.map((e) => e.toJson()).toList(),
      'currentTrend': currentTrend.name,
      'personalBest': personalBest?.toJson(),
      'improvementRate': improvementRate,
      'consistencyScore': consistencyScore,
    };
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

  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int? ?? 0,
      type: ProgressTypeExtension.fromString(json['type'] as String? ?? 'training'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'type': type.name,
    };
  }
}

enum ProgressType { training, match }

extension ProgressTypeExtension on ProgressType {
  static ProgressType fromString(String value) {
    return ProgressType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProgressType.training,
    );
  }
}

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

  static TrendDirection fromString(String value) {
    return TrendDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TrendDirection.stable,
    );
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

  factory MistakePatterns.fromJson(Map<String, dynamic> json) {
    final patternsList = json['patterns'] as List<dynamic>? ?? [];
    return MistakePatterns(
      patterns: patternsList.map((e) => MistakePattern.fromJson(e as Map<String, dynamic>)).toList(),
      topMistakes: (json['topMistakes'] as List<dynamic>?)?.cast<String>() ?? [],
      improvingMistakes: (json['improvingMistakes'] as List<dynamic>?)?.cast<String>() ?? [],
      newMistakes: (json['newMistakes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patterns': patterns.map((e) => e.toJson()).toList(),
      'topMistakes': topMistakes,
      'improvingMistakes': improvingMistakes,
      'newMistakes': newMistakes,
    };
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

  factory MistakePattern.fromJson(Map<String, dynamic> json) {
    return MistakePattern(
      mistakeId: json['mistakeId'] as String? ?? '',
      mistakeName: json['mistakeName'] as String? ?? '',
      frequency: json['frequency'] as int? ?? 0,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen'] as String) : DateTime.now(),
      isImproving: json['isImproving'] as bool? ?? false,
      associatedCauses: (json['associatedCauses'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mistakeId': mistakeId,
      'mistakeName': mistakeName,
      'frequency': frequency,
      'lastSeen': lastSeen.toIso8601String(),
      'isImproving': isImproving,
      'associatedCauses': associatedCauses,
    };
  }
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

  factory PracticePatterns.fromJson(Map<String, dynamic> json) {
    return PracticePatterns(
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      lastSession: json['lastSession'] != null ? DateTime.parse(json['lastSession'] as String) : null,
      avgSessionLength: json['avgSessionLength'] as int? ?? 0,
      sessionsThisWeek: json['sessionsThisWeek'] as int? ?? 0,
      sessionsThisMonth: json['sessionsThisMonth'] as int? ?? 0,
      favoriteDrills: (json['favoriteDrills'] as List<dynamic>?)?.cast<String>() ?? [],
      consistency: json['consistency'] != null
          ? ConsistencyMetrics.fromJson(json['consistency'] as Map<String, dynamic>)
          : ConsistencyMetrics.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'lastSession': lastSession?.toIso8601String(),
      'avgSessionLength': avgSessionLength,
      'sessionsThisWeek': sessionsThisWeek,
      'sessionsThisMonth': sessionsThisMonth,
      'favoriteDrills': favoriteDrills,
      'consistency': consistency.toJson(),
    };
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

  factory ConsistencyMetrics.fromJson(Map<String, dynamic> json) {
    return ConsistencyMetrics(
      regularity: json['regularity'] as int? ?? 0,
      preferredTime: json['preferredTime'] as int? ?? 0,
      preferredDay: json['preferredDay'] as int? ?? 0,
      deviationFromHabit: (json['deviationFromHabit'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regularity': regularity,
      'preferredTime': preferredTime,
      'preferredDay': preferredDay,
      'deviationFromHabit': deviationFromHabit,
    };
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

  factory MatchPatterns.fromJson(Map<String, dynamic> json) {
    return MatchPatterns(
      totalMatches: json['totalMatches'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      currentStreak: json['currentStreak'] != null ? StreakInfo.fromJson(json['currentStreak'] as Map<String, dynamic>) : const StreakInfo(type: StreakType.none, count: 0),
      longestWinStreak: json['longestWinStreak'] != null ? StreakInfo.fromJson(json['longestWinStreak'] as Map<String, dynamic>) : const StreakInfo(type: StreakType.none, count: 0),
      longestLossStreak: json['longestLossStreak'] != null ? StreakInfo.fromJson(json['longestLossStreak'] as Map<String, dynamic>) : const StreakInfo(type: StreakType.none, count: 0),
      opponentAnalysis: json['opponentAnalysis'] != null ? PerformanceByOpponent.fromJson(json['opponentAnalysis'] as Map<String, dynamic>) : PerformanceByOpponent.empty(),
      conditionAnalysis: json['conditionAnalysis'] != null ? PerformanceByCondition.fromJson(json['conditionAnalysis'] as Map<String, dynamic>) : PerformanceByCondition.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': winRate,
      'currentStreak': currentStreak.toJson(),
      'longestWinStreak': longestWinStreak.toJson(),
      'longestLossStreak': longestLossStreak.toJson(),
      'opponentAnalysis': opponentAnalysis.toJson(),
      'conditionAnalysis': conditionAnalysis.toJson(),
    };
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

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      type: StreakTypeExtension.fromString(json['type'] as String? ?? 'none'),
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'count': count,
    };
  }
}

enum StreakType { win, loss, none }

extension StreakTypeExtension on StreakType {
  static StreakType fromString(String value) {
    return StreakType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StreakType.none,
    );
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

  static MentalTrend fromString(String value) {
    return MentalTrend.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MentalTrend.stable,
    );
  }
}

class PerformanceByOpponent {
  final Map<String, OpponentRecord> records;

  const PerformanceByOpponent({
    required this.records,
  });

  factory PerformanceByOpponent.empty() {
    return const PerformanceByOpponent(records: {});
  }

  factory PerformanceByOpponent.fromJson(Map<String, dynamic> json) {
    final recordsMap = json['records'] as Map<String, dynamic>? ?? {};
    return PerformanceByOpponent(
      records: recordsMap.map((k, v) => MapEntry(k, OpponentRecord.fromJson(v as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'records': records.map((k, v) => MapEntry(k, v.toJson())),
    };
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

  factory OpponentRecord.fromJson(Map<String, dynamic> json) {
    return OpponentRecord(
      opponentName: json['opponentName'] as String? ?? '',
      timesPlayed: json['timesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      lastPlayed: json['lastPlayed'] != null ? DateTime.parse(json['lastPlayed'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opponentName': opponentName,
      'timesPlayed': timesPlayed,
      'wins': wins,
      'losses': losses,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }
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

  factory PerformanceByCondition.fromJson(Map<String, dynamic> json) {
    return PerformanceByCondition(
      homeWinRate: json['homeWinRate'] as int? ?? 0,
      awayWinRate: json['awayWinRate'] as int? ?? 0,
      pressureWinRate: json['pressureWinRate'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeWinRate': homeWinRate,
      'awayWinRate': awayWinRate,
      'pressureWinRate': pressureWinRate,
    };
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

  factory MentalModel.fromJson(Map<String, dynamic> json) {
    return MentalModel(
      confidence: json['confidence'] as int? ?? 50,
      focus: json['focus'] as int? ?? 50,
      pressureHandling: json['pressureHandling'] as int? ?? 50,
      tiltTendency: json['tiltTendency'] as int? ?? 50,
      mentalBlocks: (json['mentalBlocks'] as List<dynamic>?)?.cast<String>() ?? [],
      triggers: (json['triggers'] as List<dynamic>?)?.cast<String>() ?? [],
      trend: MentalTrend.fromString(json['trend'] as String? ?? 'stable'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'focus': focus,
      'pressureHandling': pressureHandling,
      'tiltTendency': tiltTendency,
      'mentalBlocks': mentalBlocks,
      'triggers': triggers,
      'trend': trend.name,
    };
  }

  MentalModel updateFromReflection(ReflectionData reflection) {
    return this;
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

  factory LearningHistory.fromJson(Map<String, dynamic> json) {
    final entriesList = json['entries'] as List<dynamic>? ?? [];
    final masteredMap = json['conceptMasteredAt'] as Map<String, dynamic>? ?? {};
    return LearningHistory(
      entries: entriesList.map((e) => LearningEntry.fromJson(e as Map<String, dynamic>)).toList(),
      masteredConcepts: (json['masteredConcepts'] as List<dynamic>?)?.cast<String>() ?? [],
      inProgressConcepts: (json['inProgressConcepts'] as List<dynamic>?)?.cast<String>() ?? [],
      conceptMasteredAt: masteredMap.map((k, v) => MapEntry(k, DateTime.parse(v as String))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'masteredConcepts': masteredConcepts,
      'inProgressConcepts': inProgressConcepts,
      'conceptMasteredAt': conceptMasteredAt.map((k, v) => MapEntry(k, v.toIso8601String())),
    };
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

  factory LearningEntry.fromJson(Map<String, dynamic> json) {
    return LearningEntry(
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      type: json['type'] as String? ?? 'drill',
      itemId: json['itemId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      improvementScore: json['improvementScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'type': type,
      'itemId': itemId,
      'description': description,
      'improvementScore': improvementScore,
    };
  }
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

  factory RecommendationHistory.fromJson(Map<String, dynamic> json) {
    final entriesList = json['entries'] as List<dynamic>? ?? [];
    final countMap = json['drillRecommendationCount'] as Map<String, dynamic>? ?? {};
    return RecommendationHistory(
      entries: entriesList.map((e) => RecommendationEntry.fromJson(e as Map<String, dynamic>)).toList(),
      drillRecommendationCount: countMap.map((k, v) => MapEntry(k, v as int)),
      lastRecommendation: json['lastRecommendation'] != null ? DateTime.parse(json['lastRecommendation'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'drillRecommendationCount': drillRecommendationCount,
      'lastRecommendation': lastRecommendation?.toIso8601String(),
    };
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

  factory RecommendationEntry.fromJson(Map<String, dynamic> json) {
    return RecommendationEntry(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      drillCode: json['drillCode'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'drillCode': drillCode,
      'reason': reason,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
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

  factory ShortTermMemory.fromJson(Map<String, dynamic> json) {
    return ShortTermMemory(
      recentSessions: (json['recentSessions'] as List<dynamic>?)?.map((e) => MemoryEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      recentMatches: (json['recentMatches'] as List<dynamic>?)?.map((e) => MemoryEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      recentReflections: (json['recentReflections'] as List<dynamic>?)?.map((e) => MemoryEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      recentObservations: (json['recentObservations'] as List<dynamic>?)?.map((e) => MemoryEntry.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recentSessions': recentSessions.map((e) => e.toJson()).toList(),
      'recentMatches': recentMatches.map((e) => e.toJson()).toList(),
      'recentReflections': recentReflections.map((e) => e.toJson()).toList(),
      'recentObservations': recentObservations.map((e) => e.toJson()).toList(),
    };
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

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
      type: MemoryTypeExtension.fromString(json['type'] as String? ?? 'session'),
      data: (json['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'data': data,
    };
  }
}

enum MemoryType { session, match, reflection, observation, recommendation }

extension MemoryTypeExtension on MemoryType {
  static MemoryType fromString(String value) {
    return MemoryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemoryType.session,
    );
  }
}

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

  factory WorkingMemory.fromJson(Map<String, dynamic> json) {
    return WorkingMemory(
      currentTopics: (json['currentTopics'] as List<dynamic>?)?.cast<String>() ?? [],
      pendingQuestions: (json['pendingQuestions'] as List<dynamic>?)?.cast<String>() ?? [],
      context: (json['context'] as Map<String, dynamic>?) ?? {},
      conversationStart: json['conversationStart'] != null ? DateTime.parse(json['conversationStart'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentTopics': currentTopics,
      'pendingQuestions': pendingQuestions,
      'context': context,
      'conversationStart': conversationStart.toIso8601String(),
    };
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
