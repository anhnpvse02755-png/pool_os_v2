/// Match Analysis — auto-generated AI summary of a completed match.
///
/// This is the V2 Match Summary "AI Analysis" section. Stored alongside the
/// match so it can be replayed without re-running the engine.
class MatchAnalysis {
  final String matchId;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> biggestMistakes;
  final String? mostImprovedSkill;
  final List<String> suggestedDrills;
  final List<String> relatedKnowledgeArticles;
  final String? recommendedLearningPath;
  final DateTime generatedAt;

  const MatchAnalysis({
    required this.matchId,
    required this.strengths,
    required this.weaknesses,
    required this.biggestMistakes,
    this.mostImprovedSkill,
    this.suggestedDrills = const [],
    this.relatedKnowledgeArticles = const [],
    this.recommendedLearningPath,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'biggestMistakes': biggestMistakes,
        'mostImprovedSkill': mostImprovedSkill,
        'suggestedDrills': suggestedDrills,
        'relatedKnowledgeArticles': relatedKnowledgeArticles,
        'recommendedLearningPath': recommendedLearningPath,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory MatchAnalysis.fromJson(Map<String, dynamic> json) => MatchAnalysis(
        matchId: json['matchId'] as String,
        strengths: (json['strengths'] as List).cast<String>(),
        weaknesses: (json['weaknesses'] as List).cast<String>(),
        biggestMistakes: (json['biggestMistakes'] as List).cast<String>(),
        mostImprovedSkill: json['mostImprovedSkill'] as String?,
        suggestedDrills: (json['suggestedDrills'] as List?)?.cast<String>() ?? const [],
        relatedKnowledgeArticles:
            (json['relatedKnowledgeArticles'] as List?)?.cast<String>() ??
                const [],
        recommendedLearningPath: json['recommendedLearningPath'] as String?,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}

/// Player state snapshot — V1 mental + physical axes captured per match.
class PlayerStateSnapshot {
  final String id;
  final String matchId;

  // Mental axes (each 1-5)
  final int confidence;
  final int focus;
  final int pressure;
  final int tilt;
  final int? composure;

  // Physical axes
  final int? sleep; // hours
  final int? fatigue; // 1-5
  final int? energy; // 1-5
  final int? eyeCondition; // 1-5

  // V2 extensions
  final int? heartRate;
  final String? mood;

  final DateTime capturedAt;

  const PlayerStateSnapshot({
    required this.id,
    required this.matchId,
    required this.confidence,
    required this.focus,
    required this.pressure,
    required this.tilt,
    this.composure,
    this.sleep,
    this.fatigue,
    this.energy,
    this.eyeCondition,
    this.heartRate,
    this.mood,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'confidence': confidence,
        'focus': focus,
        'pressure': pressure,
        'tilt': tilt,
        'composure': composure,
        'sleep': sleep,
        'fatigue': fatigue,
        'energy': energy,
        'eyeCondition': eyeCondition,
        'heartRate': heartRate,
        'mood': mood,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory PlayerStateSnapshot.fromJson(Map<String, dynamic> json) =>
      PlayerStateSnapshot(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        confidence: json['confidence'] as int,
        focus: json['focus'] as int,
        pressure: json['pressure'] as int,
        tilt: json['tilt'] as int,
        composure: json['composure'] as int?,
        sleep: json['sleep'] as int?,
        fatigue: json['fatigue'] as int?,
        energy: json['energy'] as int?,
        eyeCondition: json['eyeCondition'] as int?,
        heartRate: json['heartRate'] as int?,
        mood: json['mood'] as String?,
        capturedAt: DateTime.parse(json['capturedAt'] as String),
      );
}

/// Match Equipment snapshot — RFC-302 V1 capability.
///
/// At the moment a match is recorded, the equipment state is frozen so
/// historical matches are never invalidated when equipment is updated.
class MatchEquipmentSnapshot {
  final String id;
  final String matchId;
  final String? cueId;
  final String? cueName;
  final String? cueBrand;
  final String? cueModel;
  final String? shaftMaterial;
  final double? shaftDiameter;
  final String? tipBrand;
  final double? tipDiameter;
  final String? tipHardness;
  final double? weight;
  final String? balance;
  final String? joint;
  final String? chalk;
  final String? extension;
  final DateTime capturedAt;

  const MatchEquipmentSnapshot({
    required this.id,
    required this.matchId,
    this.cueId,
    this.cueName,
    this.cueBrand,
    this.cueModel,
    this.shaftMaterial,
    this.shaftDiameter,
    this.tipBrand,
    this.tipDiameter,
    this.tipHardness,
    this.weight,
    this.balance,
    this.joint,
    this.chalk,
    this.extension,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'cueId': cueId,
        'cueName': cueName,
        'cueBrand': cueBrand,
        'cueModel': cueModel,
        'shaftMaterial': shaftMaterial,
        'shaftDiameter': shaftDiameter,
        'tipBrand': tipBrand,
        'tipDiameter': tipDiameter,
        'tipHardness': tipHardness,
        'weight': weight,
        'balance': balance,
        'joint': joint,
        'chalk': chalk,
        'extension': extension,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory MatchEquipmentSnapshot.fromJson(Map<String, dynamic> json) =>
      MatchEquipmentSnapshot(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        cueId: json['cueId'] as String?,
        cueName: json['cueName'] as String?,
        cueBrand: json['cueBrand'] as String?,
        cueModel: json['cueModel'] as String?,
        shaftMaterial: json['shaftMaterial'] as String?,
        shaftDiameter: (json['shaftDiameter'] as num?)?.toDouble(),
        tipBrand: json['tipBrand'] as String?,
        tipDiameter: (json['tipDiameter'] as num?)?.toDouble(),
        tipHardness: json['tipHardness'] as String?,
        weight: (json['weight'] as num?)?.toDouble(),
        balance: json['balance'] as String?,
        joint: json['joint'] as String?,
        chalk: json['chalk'] as String?,
        extension: json['extension'] as String?,
        capturedAt: DateTime.parse(json['capturedAt'] as String),
      );
}

/// Match Timeline entry — per-rack chronological events.
class MatchTimelineEntry {
  final String id;
  final String matchId;
  final int rackNumber;
  final String eventType; // rack_start, break, safety_exchange, miss, break_and_run, run_out, golden_break, timeout, turning_point, final_rack, rack_end
  final String? description;
  final DateTime timestamp;

  const MatchTimelineEntry({
    required this.id,
    required this.matchId,
    required this.rackNumber,
    required this.eventType,
    this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'matchId': matchId,
        'rackNumber': rackNumber,
        'eventType': eventType,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MatchTimelineEntry.fromJson(Map<String, dynamic> json) =>
      MatchTimelineEntry(
        id: json['id'] as String,
        matchId: json['matchId'] as String,
        rackNumber: json['rackNumber'] as int,
        eventType: json['eventType'] as String,
        description: json['description'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class TimelineEventTypes {
  static const String rackStart = 'rack_start';
  static const String break_ = 'break';
  static const String safetyExchange = 'safety_exchange';
  static const String miss = 'miss';
  static const String breakAndRun = 'break_and_run';
  static const String runOut = 'run_out';
  static const String goldenBreak = 'golden_break';
  static const String timeout = 'timeout';
  static const String turningPoint = 'turning_point';
  static const String finalRack = 'final_rack';
  static const String rackEnd = 'rack_end';

  static const List<String> all = [
    rackStart,
    break_,
    safetyExchange,
    miss,
    breakAndRun,
    runOut,
    goldenBreak,
    timeout,
    turningPoint,
    finalRack,
    rackEnd,
  ];
}
