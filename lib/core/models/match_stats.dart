// ============================================================================
// MATCH ANALYSIS MODEL - Phase 8
// Rack-level analysis for Coach AI integration
//
// Analyzes match recording data to feed into Coach AI for:
// 1. Identifying patterns from real matches
// 2. Generating weakness-based drill recommendations
// 3. Tracking improvement over time
// ============================================================================

import '../../data/models/match.dart';

/// Match Rack Analysis - Raw rack-level data from match recording
/// Used by Coach AI to identify patterns and weaknesses
class MatchRackAnalysis {
  final String matchId;
  final int totalRacks;
  final int wins;
  final int losses;
  final int totalBallsPotted;
  final int longestRun;
  final int easyMisses;
  final int hardMisses;
  final int scratches;
  final int positionErrors;
  final int safetyErrors;
  final int fouls;
  final int kickErrors;
  final int jumpErrors;
  final int bankShots;
  final int comboShots;
  final int caromShots;
  final Map<String, int> shotTypes;
  final List<String> commonMistakes;
  final List<String> strengths;
  final double winRate;
  final DateTime analyzedAt;

  const MatchRackAnalysis({
    required this.matchId,
    required this.totalRacks,
    required this.wins,
    required this.losses,
    required this.totalBallsPotted,
    required this.longestRun,
    required this.easyMisses,
    required this.hardMisses,
    required this.scratches,
    required this.positionErrors,
    required this.safetyErrors,
    required this.fouls,
    required this.kickErrors,
    required this.jumpErrors,
    required this.bankShots,
    required this.comboShots,
    required this.caromShots,
    required this.shotTypes,
    required this.commonMistakes,
    required this.strengths,
    required this.winRate,
    required this.analyzedAt,
  });

  /// Create empty analysis
  factory MatchRackAnalysis.empty() {
    return MatchRackAnalysis(
      matchId: '',
      totalRacks: 0,
      wins: 0,
      losses: 0,
      totalBallsPotted: 0,
      longestRun: 0,
      easyMisses: 0,
      hardMisses: 0,
      scratches: 0,
      positionErrors: 0,
      safetyErrors: 0,
      fouls: 0,
      kickErrors: 0,
      jumpErrors: 0,
      bankShots: 0,
      comboShots: 0,
      caromShots: 0,
      shotTypes: const {},
      commonMistakes: const [],
      strengths: const [],
      winRate: 0.0,
      analyzedAt: DateTime.now(),
    );
  }

  /// Create from list of racks
  factory MatchRackAnalysis.fromRacks(String matchId, List<Rack> racks) {
    if (racks.isEmpty) {
      return MatchRackAnalysis.empty();
    }

    // Calculate basic stats
    final wins = racks.where((r) => r.result == 'win').length;
    final losses = racks.where((r) => r.result == 'lose').length;
    final totalBallsPotted = racks.fold<int>(0, (sum, r) => sum + r.totalBallsPotted);
    final longestRun = racks.fold<int>(0, (max, r) => r.longestRun > max ? r.longestRun : max);
    final easyMisses = racks.fold<int>(0, (sum, r) => sum + r.easyMissCount);
    final hardMisses = racks.fold<int>(0, (sum, r) => sum + r.hardMissCount);
    final scratches = racks.fold<int>(0, (sum, r) => sum + r.scratchErrorCount);
    final positionErrors = racks.fold<int>(0, (sum, r) => sum + r.positionErrorCount);
    final safetyErrors = racks.fold<int>(0, (sum, r) => sum + r.safetyErrorCount);
    final fouls = racks.fold<int>(0, (sum, r) => sum + r.fouls);
    final kickErrors = racks.fold<int>(0, (sum, r) => sum + r.kickErrorCount);
    final jumpErrors = racks.fold<int>(0, (sum, r) => sum + r.jumpErrorCount);
    final bankShots = racks.fold<int>(0, (sum, r) => sum + r.bankShotCount);
    final comboShots = racks.fold<int>(0, (sum, r) => sum + r.comboShotCount);
    final caromShots = racks.fold<int>(0, (sum, r) => sum + r.caromShotCount);

    // Build shot types map
    final shotTypes = <String, int>{
      'bank': bankShots,
      'combo': comboShots,
      'carom': caromShots,
      'kick': kickErrors,
      'jump': jumpErrors,
    };

    // Identify patterns
    final commonMistakes = _identifyCommonMistakes(
      easyMisses: easyMisses,
      hardMisses: hardMisses,
      scratches: scratches,
      positionErrors: positionErrors,
      safetyErrors: safetyErrors,
      fouls: fouls,
      kickErrors: kickErrors,
      jumpErrors: jumpErrors,
      totalRacks: racks.length,
    );

    final strengths = _identifyStrengths(
      wins: wins,
      longestRun: longestRun,
      bankShots: bankShots,
      caromShots: caromShots,
      kickErrors: kickErrors,
      totalRacks: racks.length,
    );

    final winRate = racks.isNotEmpty ? (wins / racks.length) * 100 : 0.0;

    return MatchRackAnalysis(
      matchId: matchId,
      totalRacks: racks.length,
      wins: wins,
      losses: losses,
      totalBallsPotted: totalBallsPotted,
      longestRun: longestRun,
      easyMisses: easyMisses,
      hardMisses: hardMisses,
      scratches: scratches,
      positionErrors: positionErrors,
      safetyErrors: safetyErrors,
      fouls: fouls,
      kickErrors: kickErrors,
      jumpErrors: jumpErrors,
      bankShots: bankShots,
      comboShots: comboShots,
      caromShots: caromShots,
      shotTypes: shotTypes,
      commonMistakes: commonMistakes,
      strengths: strengths,
      winRate: winRate,
      analyzedAt: DateTime.now(),
    );
  }

  /// Identify common mistakes from stats
  static List<String> _identifyCommonMistakes({
    required int easyMisses,
    required int hardMisses,
    required int scratches,
    required int positionErrors,
    required int safetyErrors,
    required int fouls,
    required int kickErrors,
    required int jumpErrors,
    required int totalRacks,
  }) {
    final mistakes = <String>[];
    final threshold = totalRacks > 0 ? totalRacks * 0.3 : 1;

    if (easyMisses > threshold) {
      mistakes.add('Miss cú dễ: $easyMisses lần');
    }
    if (positionErrors > threshold) {
      mistakes.add('Lỗi position: $positionErrors lần');
    }
    if (scratches > threshold) {
      mistakes.add('Scratch: $scratches lần');
    }
    if (safetyErrors > threshold) {
      mistakes.add('Lỗi safety: $safetyErrors lần');
    }
    if (fouls > threshold) {
      mistakes.add('Fouls: $fouls lần');
    }
    if (kickErrors > threshold) {
      mistakes.add('Lỗi kick: $kickErrors lần');
    }
    if (jumpErrors > threshold) {
      mistakes.add('Cue nhảy: $jumpErrors lần');
    }

    return mistakes;
  }

  /// Identify strengths from stats
  static List<String> _identifyStrengths({
    required int wins,
    required int longestRun,
    required int bankShots,
    required int caromShots,
    required int kickErrors,
    required int totalRacks,
  }) {
    final strengths = <String>[];

    // High win rate
    if (totalRacks > 0 && wins / totalRacks > 0.6) {
      strengths.add('Win rate cao: ${(wins / totalRacks * 100).toInt()}%');
    }

    // Good long runs
    if (longestRun >= 5) {
      strengths.add('Long run tốt: $longestRun bi');
    }

    // Bank shots
    if (bankShots >= 3) {
      strengths.add('Bank shots: $bankShots lần');
    }

    // Carom shots
    if (caromShots >= 2) {
      strengths.add('Carom: $caromShots lần');
    }

    // Low kick errors relative to attempts
    if (kickErrors <= 1) {
      strengths.add('Kiểm soát kick tốt');
    }

    return strengths;
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'totalRacks': totalRacks,
        'wins': wins,
        'losses': losses,
        'totalBallsPotted': totalBallsPotted,
        'longestRun': longestRun,
        'easyMisses': easyMisses,
        'hardMisses': hardMisses,
        'scratches': scratches,
        'positionErrors': positionErrors,
        'safetyErrors': safetyErrors,
        'fouls': fouls,
        'kickErrors': kickErrors,
        'jumpErrors': jumpErrors,
        'bankShots': bankShots,
        'comboShots': comboShots,
        'caromShots': caromShots,
        'shotTypes': shotTypes,
        'commonMistakes': commonMistakes,
        'strengths': strengths,
        'winRate': winRate,
        'analyzedAt': analyzedAt.toIso8601String(),
      };

  factory MatchRackAnalysis.fromJson(Map<String, dynamic> json) => MatchRackAnalysis(
        matchId: json['matchId'] as String,
        totalRacks: json['totalRacks'] as int,
        wins: json['wins'] as int,
        losses: json['losses'] as int,
        totalBallsPotted: json['totalBallsPotted'] as int,
        longestRun: json['longestRun'] as int,
        easyMisses: json['easyMisses'] as int,
        hardMisses: json['hardMisses'] as int,
        scratches: json['scratches'] as int,
        positionErrors: json['positionErrors'] as int,
        safetyErrors: json['safetyErrors'] as int,
        fouls: json['fouls'] as int,
        kickErrors: json['kickErrors'] as int,
        jumpErrors: json['jumpErrors'] as int,
        bankShots: json['bankShots'] as int,
        comboShots: json['comboShots'] as int,
        caromShots: json['caromShots'] as int,
        shotTypes: Map<String, int>.from(json['shotTypes'] as Map),
        commonMistakes: List<String>.from(json['commonMistakes'] as List),
        strengths: List<String>.from(json['strengths'] as List),
        winRate: (json['winRate'] as num).toDouble(),
        analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      );
}

/// Drill recommendation generated from match analysis
class DrillRecommendation {
  final String drillCode;
  final String drillName;
  final String reason;
  final int priority;
  final String category;

  const DrillRecommendation({
    required this.drillCode,
    required this.drillName,
    required this.reason,
    required this.priority,
    required this.category,
  });
}
