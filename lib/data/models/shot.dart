/// Shot model — restored from Pool OS V1.
///
/// V1 `Shot` (`features/shot/domain/models/shot.dart`) had 12 fields.
/// V2 adds cue ball intent + stat axes for the AI analysis pipeline.
class Shot {
  final String id;
  final String rackId;
  final int shotNumber;
  final String shotType; // break / opening / normal / safety / jump / bank / masse / combo / carom
  final String difficulty; // easy / medium / hard / extreme
  final String result; // made / missed / scratch / foul
  final String? positionQuality; // perfect / good / playable / recovery / bad
  final String? decision;
  final String? confidence; // very_confident / confident / unsure / guessing
  final String? playerNote;

  // V2 extension: cue ball intent — what the player meant to do.
  final String? intent; // pot / position / safety / break / escape / stop / draw / follow / side_spin

  // V2 extension: why it failed (null when made).
  final String? missReason;

  // V2 extension: cue ball spin axis tracker.
  final String? spinAxis; // none / english_left / english_right / top / bottom / combination

  final DateTime createdAt;

  Shot({
    required this.id,
    required this.rackId,
    required this.shotNumber,
    required this.shotType,
    required this.difficulty,
    required this.result,
    this.positionQuality,
    this.decision,
    this.confidence,
    this.playerNote,
    this.intent,
    this.missReason,
    this.spinAxis,
    required this.createdAt,
  });

  bool get isMade => result == 'made';
  bool get isMissed => result == 'missed';
  bool get isScratch => result == 'scratch';
  bool get isFoul => result == 'foul';

  Shot copyWith({
    String? id,
    String? rackId,
    int? shotNumber,
    String? shotType,
    String? difficulty,
    String? result,
    String? positionQuality,
    String? decision,
    String? confidence,
    String? playerNote,
    String? intent,
    String? missReason,
    String? spinAxis,
    DateTime? createdAt,
  }) =>
      Shot(
        id: id ?? this.id,
        rackId: rackId ?? this.rackId,
        shotNumber: shotNumber ?? this.shotNumber,
        shotType: shotType ?? this.shotType,
        difficulty: difficulty ?? this.difficulty,
        result: result ?? this.result,
        positionQuality: positionQuality ?? this.positionQuality,
        decision: decision ?? this.decision,
        confidence: confidence ?? this.confidence,
        playerNote: playerNote ?? this.playerNote,
        intent: intent ?? this.intent,
        missReason: missReason ?? this.missReason,
        spinAxis: spinAxis ?? this.spinAxis,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rackId': rackId,
        'shotNumber': shotNumber,
        'shotType': shotType,
        'difficulty': difficulty,
        'result': result,
        'positionQuality': positionQuality,
        'decision': decision,
        'confidence': confidence,
        'playerNote': playerNote,
        'intent': intent,
        'missReason': missReason,
        'spinAxis': spinAxis,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Shot.fromJson(Map<String, dynamic> json) => Shot(
        id: json['id'] as String,
        rackId: json['rackId'] as String,
        shotNumber: json['shotNumber'] as int,
        shotType: json['shotType'] as String,
        difficulty: json['difficulty'] as String,
        result: json['result'] as String,
        positionQuality: json['positionQuality'] as String?,
        decision: json['decision'] as String?,
        confidence: json['confidence'] as String?,
        playerNote: json['playerNote'] as String?,
        intent: json['intent'] as String?,
        missReason: json['missReason'] as String?,
        spinAxis: json['spinAxis'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

/// Shot types — V1 list, plus V2 extensions.
class ShotTypes {
  static const String breakShot = 'break';
  static const String openingShot = 'opening';
  static const String normalShot = 'normal';
  static const String safetyShot = 'safety';
  static const String jumpShot = 'jump';
  static const String bankShot = 'bank';
  static const String masse = 'masse';
  static const String comboShot = 'combo'; // V2
  static const String caromShot = 'carom'; // V2

  static const List<String> all = [
    breakShot,
    openingShot,
    normalShot,
    safetyShot,
    jumpShot,
    bankShot,
    masse,
    comboShot,
    caromShot,
  ];
}

class ShotDifficulty {
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';
  static const String extreme = 'extreme';

  static const List<String> all = [easy, medium, hard, extreme];
}

class ShotResult {
  static const String made = 'made';
  static const String missed = 'missed';
  static const String scratch = 'scratch';
  static const String foul = 'foul';

  static const List<String> all = [made, missed, scratch, foul];
}

class PositionQuality {
  static const String perfect = 'perfect';
  static const String good = 'good';
  static const String playable = 'playable';
  static const String recovery = 'recovery';
  static const String bad = 'bad';

  static const List<String> all = [perfect, good, playable, recovery, bad];
}

class ShotConfidence {
  static const String veryConfident = 'very_confident';
  static const String confident = 'confident';
  static const String unsure = 'unsure';
  static const String guessing = 'guessing';

  static const List<String> all = [veryConfident, confident, unsure, guessing];
}

class ShotIntent {
  static const String pot = 'pot';
  static const String stop = 'stop';
  static const String draw = 'draw';
  static const String follow = 'follow';
  static const String sideSpin = 'side_spin';
  static const String position = 'position';
  static const String safety = 'safety';
  static const String break_ = 'break';
  static const String escape = 'escape';

  static const List<String> all = [
    pot,
    stop,
    draw,
    follow,
    sideSpin,
    position,
    safety,
    break_,
    escape,
  ];
}
