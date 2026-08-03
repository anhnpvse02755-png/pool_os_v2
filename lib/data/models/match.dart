import 'match_analysis.dart';
import 'shot.dart';

/// Match Recording Model — restored from Pool OS V1.
///
/// V1 `Match` had 15 fields. V2 extends to 30+ fields plus embeddings
/// for racks, shots, timeline, equipment snapshot, player state, and
/// AI analysis.
class Match {
  // -- Identity -----------------------------------------------------------
  final String id;
  final String? playerId;
  final int? matchNumber;
  final int? sessionId;

  // -- Basic info ---------------------------------------------------------
  final String gameType; // race_to_5, race_to_7, race_to, ghost_challenge, challenge_match, league_match, tournament_match, practice_match, warm_up, drill
  final int? raceTo;
  final String? opponent;
  final String? partner;
  final String? teamMode; // solo / doubles / team
  final String result; // win / lose / draw
  final String? winner; // player / opponent
  final String? resultSummary; // e.g. "5-3"

  // -- V1 identity-compatibility -----------------------------------------
  final String? matchObjective;

  // -- Date / time --------------------------------------------------------
  final DateTime? startTime;
  final DateTime? endTime;
  final int? duration; // minutes

  // -- Location -----------------------------------------------------------
  final String? venue;
  final String? table;

  // -- V2 fields ---------------------------------------------------------
  final String? opponentName;
  final String? opponentLevel;
  final String? notes;

  // -- V2 score -----------------------------------------------------------
  final int playerScore;
  final int opponentScore;

  // -- V1 detailed result fields ------------------------------------------
  final List<Rack> racks;

  // -- V1 timeline (events) ----------------------------------------------
  final List<MatchTimelineEntry> timeline;

  // -- V1 player state ---------------------------------------------------
  final PlayerStateSnapshot? playerState;

  // -- V1 equipment snapshot (RFC-302) ------------------------------------
  final MatchEquipmentSnapshot? equipmentSnapshot;

  // -- V1 AI analysis ----------------------------------------------------
  final MatchAnalysis? analysis;

  // -- Audit --------------------------------------------------------------
  final DateTime createdAt;
  final DateTime updatedAt;

  // -- Skill ratings (V1) -----------------------------------------------
  final Map<String, double> skillRatings;

  Match({
    required this.id,
    this.playerId,
    this.matchNumber,
    this.sessionId,
    this.gameType = 'race_to',
    this.raceTo,
    this.opponent,
    this.partner,
    this.teamMode,
    this.result = 'lose',
    this.winner,
    this.resultSummary,
    this.matchObjective,
    this.startTime,
    this.endTime,
    this.duration,
    this.venue,
    this.table,
    this.opponentName,
    this.opponentLevel,
    this.notes,
    this.playerScore = 0,
    this.opponentScore = 0,
    this.racks = const [],
    this.timeline = const [],
    this.playerState,
    this.equipmentSnapshot,
    this.analysis,
    this.skillRatings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the match is finished (has endTime or reached raceTo).
  bool get isFinished =>
      endTime != null || (raceTo != null && playerScore >= raceTo!) ||
      (raceTo != null && opponentScore >= raceTo!);

  /// Whether the player won.
  bool get isWin => result == 'win';
  bool get isLoss => result == 'lose';
  bool get isDraw => result == 'draw';

  Match copyWith({
    String? id,
    String? playerId,
    int? matchNumber,
    int? sessionId,
    String? gameType,
    int? raceTo,
    String? opponent,
    String? partner,
    String? teamMode,
    String? result,
    String? winner,
    String? resultSummary,
    String? matchObjective,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? venue,
    String? table,
    String? opponentName,
    String? opponentLevel,
    String? notes,
    int? playerScore,
    int? opponentScore,
    List<Rack>? racks,
    List<MatchTimelineEntry>? timeline,
    PlayerStateSnapshot? playerState,
    MatchEquipmentSnapshot? equipmentSnapshot,
    MatchAnalysis? analysis,
    Map<String, double>? skillRatings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Match(
        id: id ?? this.id,
        playerId: playerId ?? this.playerId,
        matchNumber: matchNumber ?? this.matchNumber,
        sessionId: sessionId ?? this.sessionId,
        gameType: gameType ?? this.gameType,
        raceTo: raceTo ?? this.raceTo,
        opponent: opponent ?? this.opponent,
        partner: partner ?? this.partner,
        teamMode: teamMode ?? this.teamMode,
        result: result ?? this.result,
        winner: winner ?? this.winner,
        resultSummary: resultSummary ?? this.resultSummary,
        matchObjective: matchObjective ?? this.matchObjective,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        duration: duration ?? this.duration,
        venue: venue ?? this.venue,
        table: table ?? this.table,
        opponentName: opponentName ?? this.opponentName,
        opponentLevel: opponentLevel ?? this.opponentLevel,
        notes: notes ?? this.notes,
        playerScore: playerScore ?? this.playerScore,
        opponentScore: opponentScore ?? this.opponentScore,
        racks: racks ?? this.racks,
        timeline: timeline ?? this.timeline,
        playerState: playerState ?? this.playerState,
        equipmentSnapshot: equipmentSnapshot ?? this.equipmentSnapshot,
        analysis: analysis ?? this.analysis,
        skillRatings: skillRatings ?? this.skillRatings,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'matchNumber': matchNumber,
        'sessionId': sessionId,
        'gameType': gameType,
        'raceTo': raceTo,
        'opponent': opponent,
        'opponentName': opponentName,
        'partner': partner,
        'teamMode': teamMode,
        'result': result,
        'winner': winner,
        'resultSummary': resultSummary,
        'matchObjective': matchObjective,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'duration': duration,
        'venue': venue,
        'table': table,
        'opponentLevel': opponentLevel,
        'notes': notes,
        'playerScore': playerScore,
        'opponentScore': opponentScore,
        'racks': racks.map((r) => r.toJson()).toList(),
        'timeline': timeline.map((t) => t.toJson()).toList(),
        'playerState': playerState?.toJson(),
        'equipmentSnapshot': equipmentSnapshot?.toJson(),
        'analysis': analysis?.toJson(),
        'skillRatings': skillRatings,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String,
        playerId: json['playerId'] as String?,
        matchNumber: json['matchNumber'] as int?,
        sessionId: json['sessionId'] as int?,
        gameType: json['gameType'] as String? ?? 'race_to',
        raceTo: json['raceTo'] as int?,
        opponent: json['opponent'] as String?,
        opponentName: json['opponentName'] as String?,
        partner: json['partner'] as String?,
        teamMode: json['teamMode'] as String?,
        result: json['result'] as String? ?? 'lose',
        winner: json['winner'] as String?,
        resultSummary: json['resultSummary'] as String?,
        matchObjective: json['matchObjective'] as String?,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        duration: json['duration'] as int?,
        venue: json['venue'] as String?,
        table: json['table'] as String?,
        opponentLevel: json['opponentLevel'] as String?,
        notes: json['notes'] as String?,
        playerScore: json['playerScore'] as int? ?? 0,
        opponentScore: json['opponentScore'] as int? ?? 0,
        racks: (json['racks'] as List?)
                ?.map((r) => Rack.fromJson(r as Map<String, dynamic>))
                .toList() ??
            const [],
        timeline: (json['timeline'] as List?)
                ?.map((t) => MatchTimelineEntry.fromJson(
                    t as Map<String, dynamic>))
                .toList() ??
            const [],
        playerState: json['playerState'] != null
            ? PlayerStateSnapshot.fromJson(
                json['playerState'] as Map<String, dynamic>)
            : null,
        equipmentSnapshot: json['equipmentSnapshot'] != null
            ? MatchEquipmentSnapshot.fromJson(
                json['equipmentSnapshot'] as Map<String, dynamic>)
            : null,
        analysis: json['analysis'] != null
            ? MatchAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
            : null,
        skillRatings: (json['skillRatings'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            const {},
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );
}

/// Match types — V1 list normalized.
class MatchTypes {
  static const String raceTo = 'race_to';
  static const String raceTo5 = 'race_to_5';
  static const String raceTo7 = 'race_to_7';
  static const String ghostChallenge = 'ghost_challenge';
  static const String challengeMatch = 'challenge_match';
  static const String leagueMatch = 'league_match';
  static const String tournamentMatch = 'tournament_match';
  static const String practiceMatch = 'practice_match';
  static const String warmUp = 'warm_up';
  static const String drill = 'drill';

  static const List<String> all = [
    warmUp,
    raceTo5,
    raceTo7,
    raceTo,
    ghostChallenge,
    challengeMatch,
    leagueMatch,
    tournamentMatch,
    practiceMatch,
    drill,
  ];

  static const Map<String, String> labels = {
    raceTo: 'Race To',
    raceTo5: 'Race to 5',
    raceTo7: 'Race to 7',
    ghostChallenge: 'Ghost Challenge',
    challengeMatch: 'Challenge Match',
    leagueMatch: 'League Match',
    tournamentMatch: 'Tournament Match',
    practiceMatch: 'Practice Match',
    warmUp: 'Warm Up',
    drill: 'Drill',
  };
}

class TeamModes {
  static const String solo = 'solo';
  static const String doubles = 'doubles';
  static const String team = 'team';

  static const List<String> all = [solo, doubles, team];
}

/// Tournament Model
class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final int entryFee;
  final int prizePool;
  final int maxParticipants;
  final int currentParticipants;
  final TournamentStatus status;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    this.entryFee = 0,
    this.prizePool = 0,
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    this.status = TournamentStatus.open,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => Tournament(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now(),
        location: json['location'] as String? ?? '',
        entryFee: json['entryFee'] as int? ?? 0,
        prizePool: json['prizePool'] as int? ?? 0,
        maxParticipants: json['maxParticipants'] as int? ?? 0,
        currentParticipants: json['currentParticipants'] as int? ?? 0,
        status: _parseStatus(json['status']),
      );

  static TournamentStatus _parseStatus(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'open':
          return TournamentStatus.open;
        case 'ongoing':
        case 'in_progress':
          return TournamentStatus.ongoing;
        case 'completed':
        case 'finished':
          return TournamentStatus.completed;
        case 'cancelled':
          return TournamentStatus.cancelled;
        default:
          return TournamentStatus.open;
      }
    }
    if (value is TournamentStatus) return value;
    return TournamentStatus.open;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
        'entryFee': entryFee,
        'prizePool': prizePool,
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'status': status.name,
      };

  bool get isUpcoming => date.isAfter(DateTime.now());
  int get spotsLeft => maxParticipants - currentParticipants;
}

enum TournamentStatus {
  open,
  ongoing,
  completed,
  cancelled,
}

/// Rack (Frame) within a match — full V1 parity + V2 extensions.
class Rack {
  final String id;
  final int rackNumber;
  final String result; // win / lose / draw
  final bool resultBool; // true = player won (V1 parity)
  final bool breakShot;
  final bool? breakSuccess;
  final bool? breakScratch; // V1
  final bool? breakFoul; // V1
  final bool? goldenBreak; // V2 — wingball on break
  final int ballsPottedOnBreak;
  final int longestRun;
  final int totalBallsPotted;
  final int safetyPlays;
  final int fouls;

  // V1 error counts
  final int easyMissCount;
  final int hardMissCount;
  final int scratchErrorCount;
  final int positionErrorCount;
  final int safetyErrorCount;
  final int kickErrorCount;
  final int jumpErrorCount;
  final int bankShotCount; // V2
  final int comboShotCount; // V2
  final int caromShotCount; // V2

  final String? howWon;
  final String? biggestMistake;
  final String? biggestStrength;
  final List<String> bestStrengths; // V1 multi-tag
  final List<String> biggestMistakes; // V1 multi-tag
  final int confidence;
  final String? note;
  final DateTime createdAt;
  /// Per-shot details for this rack. Defaults to empty list so existing
  /// call sites (match_replay_screen, shot_map_view) can read `rack.shots`
  /// without a constructor migration. Populated by match_recording_service.
  final List<Shot> shots;

  Rack({
    required this.id,
    required this.rackNumber,
    required this.result,
    this.resultBool = true,
    this.breakShot = false,
    this.breakSuccess,
    this.breakScratch,
    this.breakFoul,
    this.goldenBreak,
    this.ballsPottedOnBreak = 0,
    this.longestRun = 0,
    this.totalBallsPotted = 0,
    this.safetyPlays = 0,
    this.fouls = 0,
    this.easyMissCount = 0,
    this.hardMissCount = 0,
    this.scratchErrorCount = 0,
    this.positionErrorCount = 0,
    this.safetyErrorCount = 0,
    this.kickErrorCount = 0,
    this.jumpErrorCount = 0,
    this.bankShotCount = 0,
    this.comboShotCount = 0,
    this.caromShotCount = 0,
    this.howWon,
    this.biggestMistake,
    this.biggestStrength,
    this.bestStrengths = const [],
    this.biggestMistakes = const [],
    this.confidence = 3,
    this.note,
    this.shots = const [],
    required this.createdAt,
  });

  bool get isWin => result == 'win';
  bool get isBreakAndRun =>
      breakShot && breakSuccess == true && totalBallsPotted >= 7;
  bool get isRunOut => totalBallsPotted >= 7;

  Rack copyWith({
    String? id,
    int? rackNumber,
    String? result,
    bool? resultBool,
    bool? breakShot,
    bool? breakSuccess,
    bool? breakScratch,
    bool? breakFoul,
    bool? goldenBreak,
    int? ballsPottedOnBreak,
    int? longestRun,
    int? totalBallsPotted,
    int? safetyPlays,
    int? fouls,
    int? easyMissCount,
    int? hardMissCount,
    int? scratchErrorCount,
    int? positionErrorCount,
    int? safetyErrorCount,
    int? kickErrorCount,
    int? jumpErrorCount,
    int? bankShotCount,
    int? comboShotCount,
    int? caromShotCount,
    String? howWon,
    String? biggestMistake,
    String? biggestStrength,
    List<String>? bestStrengths,
    List<String>? biggestMistakes,
    int? confidence,
    String? note,
    List<Shot>? shots,
    DateTime? createdAt,
  }) =>
      Rack(
        id: id ?? this.id,
        rackNumber: rackNumber ?? this.rackNumber,
        result: result ?? this.result,
        resultBool: resultBool ?? this.resultBool,
        breakShot: breakShot ?? this.breakShot,
        breakSuccess: breakSuccess ?? this.breakSuccess,
        breakScratch: breakScratch ?? this.breakScratch,
        breakFoul: breakFoul ?? this.breakFoul,
        goldenBreak: goldenBreak ?? this.goldenBreak,
        ballsPottedOnBreak: ballsPottedOnBreak ?? this.ballsPottedOnBreak,
        longestRun: longestRun ?? this.longestRun,
        totalBallsPotted: totalBallsPotted ?? this.totalBallsPotted,
        safetyPlays: safetyPlays ?? this.safetyPlays,
        fouls: fouls ?? this.fouls,
        easyMissCount: easyMissCount ?? this.easyMissCount,
        hardMissCount: hardMissCount ?? this.hardMissCount,
        scratchErrorCount: scratchErrorCount ?? this.scratchErrorCount,
        positionErrorCount: positionErrorCount ?? this.positionErrorCount,
        safetyErrorCount: safetyErrorCount ?? this.safetyErrorCount,
        kickErrorCount: kickErrorCount ?? this.kickErrorCount,
        jumpErrorCount: jumpErrorCount ?? this.jumpErrorCount,
        bankShotCount: bankShotCount ?? this.bankShotCount,
        comboShotCount: comboShotCount ?? this.comboShotCount,
        caromShotCount: caromShotCount ?? this.caromShotCount,
        howWon: howWon ?? this.howWon,
        biggestMistake: biggestMistake ?? this.biggestMistake,
        biggestStrength: biggestStrength ?? this.biggestStrength,
        bestStrengths: bestStrengths ?? this.bestStrengths,
        biggestMistakes: biggestMistakes ?? this.biggestMistakes,
        confidence: confidence ?? this.confidence,
        note: note ?? this.note,
        shots: shots ?? this.shots,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'rackNumber': rackNumber,
        'result': result,
        'resultBool': resultBool,
        'breakShot': breakShot,
        'breakSuccess': breakSuccess,
        'breakScratch': breakScratch,
        'breakFoul': breakFoul,
        'goldenBreak': goldenBreak,
        'ballsPottedOnBreak': ballsPottedOnBreak,
        'longestRun': longestRun,
        'totalBallsPotted': totalBallsPotted,
        'safetyPlays': safetyPlays,
        'fouls': fouls,
        'easyMissCount': easyMissCount,
        'hardMissCount': hardMissCount,
        'scratchErrorCount': scratchErrorCount,
        'positionErrorCount': positionErrorCount,
        'safetyErrorCount': safetyErrorCount,
        'kickErrorCount': kickErrorCount,
        'jumpErrorCount': jumpErrorCount,
        'bankShotCount': bankShotCount,
        'comboShotCount': comboShotCount,
        'caromShotCount': caromShotCount,
        'howWon': howWon,
        'biggestMistake': biggestMistake,
        'biggestStrength': biggestStrength,
        'bestStrengths': bestStrengths,
        'biggestMistakes': biggestMistakes,
        'confidence': confidence,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Rack.fromJson(Map<String, dynamic> json) => Rack(
        id: json['id'] as String? ?? '',
        rackNumber: json['rackNumber'] as int? ?? 1,
        result: json['result'] as String? ?? 'lose',
        resultBool: json['resultBool'] as bool? ?? (json['result'] == 'win'),
        breakShot: json['breakShot'] as bool? ?? false,
        breakSuccess: json['breakSuccess'] as bool?,
        breakScratch: json['breakScratch'] as bool?,
        breakFoul: json['breakFoul'] as bool?,
        goldenBreak: json['goldenBreak'] as bool?,
        ballsPottedOnBreak: json['ballsPottedOnBreak'] as int? ?? 0,
        longestRun: json['longestRun'] as int? ?? 0,
        totalBallsPotted: json['totalBallsPotted'] as int? ?? 0,
        safetyPlays: json['safetyPlays'] as int? ?? 0,
        fouls: json['fouls'] as int? ?? 0,
        easyMissCount: json['easyMissCount'] as int? ?? 0,
        hardMissCount: json['hardMissCount'] as int? ?? 0,
        scratchErrorCount: json['scratchErrorCount'] as int? ?? 0,
        positionErrorCount: json['positionErrorCount'] as int? ?? 0,
        safetyErrorCount: json['safetyErrorCount'] as int? ?? 0,
        kickErrorCount: json['kickErrorCount'] as int? ?? 0,
        jumpErrorCount: json['jumpErrorCount'] as int? ?? 0,
        bankShotCount: json['bankShotCount'] as int? ?? 0,
        comboShotCount: json['comboShotCount'] as int? ?? 0,
        caromShotCount: json['caromShotCount'] as int? ?? 0,
        howWon: json['howWon'] as String?,
        biggestMistake: json['biggestMistake'] as String?,
        biggestStrength: json['biggestStrength'] as String?,
        bestStrengths: (json['bestStrengths'] as List?)?.cast<String>() ?? const [],
        biggestMistakes: (json['biggestMistakes'] as List?)?.cast<String>() ?? const [],
        confidence: json['confidence'] as int? ?? 3,
        note: json['note'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

enum MatchResult {
  win,
  lose,
  draw,
}

extension MatchResultX on MatchResult {
  String get label {
    switch (this) {
      case MatchResult.win:
        return 'Win';
      case MatchResult.lose:
        return 'Loss';
      case MatchResult.draw:
        return 'Draw';
    }
  }
}
