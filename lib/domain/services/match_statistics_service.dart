import '../../data/models/match.dart';
import '../../data/models/match_analysis.dart';
import '../../data/models/shot.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/shot_repository.dart';

/// Aggregates a Match into a flat statistics map.
///
/// Equivalent to V1's `MatchStatisticsService`.
///
/// Axes:
///   - totalRacks
///   - winPercent
///   - breaks / breakAndRun / runOuts / goldenBreaks
///   - safetyCount / safetySuccess / safetySuccessRate
///   - fouls / scratches
///   - missed easy / hard
///   - positionErrors
///   - kicks / banks / jumpShots / comboShots / caromShots
///   - cueBall: stop / draw / follow / sideSpin / positionQuality distribution
///   - mental: confidence / focus / pressure / tilt distribution
///   - physical: sleep / fatigue / energy / eyeCondition
class MatchStatisticsService {
  MatchStatisticsService(this._matchRepo, this._shotRepo);
  final IMatchRepository _matchRepo;
  final IShotRepository _shotRepo;

  Future<Map<String, dynamic>> computeMatchStatistics(String matchId) async {
    final match = await _matchRepo.getMatchById(matchId);
    if (match == null) return {};
    final racks = await _matchRepo.getRacksByMatch(matchId);
    final playerState = await _matchRepo.getPlayerState(matchId);
    final equipment = await _matchRepo.getEquipmentSnapshot(matchId);
    final shots = await _shotRepo.getShotsByMatch(matchId);

    return _aggregate(match, racks, shots, playerState, equipment);
  }

  Map<String, dynamic> _aggregate(
    Match match,
    List<Rack> racks,
    List<Shot> shots,
    PlayerStateSnapshot? state,
    MatchEquipmentSnapshot? equipment,
  ) {
    int totalRacks = racks.length;
    int wins = racks.where((r) => r.isWin).length;
    double winPercent =
        totalRacks > 0 ? (wins / totalRacks) * 100 : 0.0;

    int breaks = racks.where((r) => r.breakShot).length;
    int breakAndRun = racks.where((r) => r.isBreakAndRun).length;
    int runOuts = racks.where((r) => r.isRunOut).length;
    int goldenBreaks =
        racks.where((r) => r.goldenBreak == true).length;

    int safetyCount =
        racks.fold(0, (a, r) => a + r.safetyPlays);
    int safetySuccess = safetyCount -
        racks.fold(0, (a, r) => a + r.safetyErrorCount);
    double safetySuccessRate =
        safetyCount > 0 ? (safetySuccess / safetyCount) * 100 : 0.0;

    int fouls = racks.fold(0, (a, r) => a + r.fouls);
    int scratches = racks.fold(0, (a, r) => a + r.scratchErrorCount);
    int easyMisses = racks.fold(0, (a, r) => a + r.easyMissCount);
    int hardMisses = racks.fold(0, (a, r) => a + r.hardMissCount);
    int positionErrors =
        racks.fold(0, (a, r) => a + r.positionErrorCount);
    int kicks = racks.fold(0, (a, r) => a + r.kickErrorCount);
    int banks = racks.fold(0, (a, r) => a + r.bankShotCount);
    int jumps = racks.fold(0, (a, r) => a + r.jumpErrorCount);
    int combos = racks.fold(0, (a, r) => a + r.comboShotCount);
    int caroms = racks.fold(0, (a, r) => a + r.caromShotCount);

    // Cue ball — derived from shots
    final cueBallStats = _cueBallStats(shots);

    // Shot-type accuracy from shots
    final shotAccuracy = _shotAccuracy(shots);

    return {
      // Basic
      'matchId': match.id,
      'totalRacks': totalRacks,
      'winPercent': winPercent,
      'breaks': breaks,
      'breakAndRun': breakAndRun,
      'runOuts': runOuts,
      'goldenBreaks': goldenBreaks,

      // Safety
      'safetyCount': safetyCount,
      'safetySuccess': safetySuccess,
      'safetySuccessRate': safetySuccessRate,

      // Errors
      'fouls': fouls,
      'scratches': scratches,
      'easyMisses': easyMisses,
      'hardMisses': hardMisses,
      'positionErrors': positionErrors,

      // Specialty shots
      'kicks': kicks,
      'banks': banks,
      'jumps': jumps,
      'combos': combos,
      'caroms': caroms,

      // Cue ball
      'stopShots': cueBallStats['stop'] ?? 0,
      'drawShots': cueBallStats['draw'] ?? 0,
      'followShots': cueBallStats['follow'] ?? 0,
      'sideSpinUses': cueBallStats['side_spin'] ?? 0,
      'positionQuality': cueBallStats['position_quality'],

      // Shot accuracy
      'shotAccuracy': shotAccuracy,

      // Mental
      'confidence': state?.confidence,
      'focus': state?.focus,
      'pressure': state?.pressure,
      'tilt': state?.tilt,

      // Physical
      'sleep': state?.sleep,
      'fatigue': state?.fatigue,
      'energy': state?.energy,
      'eyeCondition': state?.eyeCondition,

      // Equipment
      'cue': equipment?.cueName,
      'shaft': equipment?.shaftMaterial,
      'tip': equipment?.tipBrand,
      'tipHardness': equipment?.tipHardness,
      'chalk': equipment?.chalk,
    };
  }

  Map<String, dynamic> _cueBallStats(List<Shot> shots) {
    int stop = 0, draw = 0, follow = 0, sideSpin = 0;
    final posQ = <String, int>{};
    for (final s in shots) {
      switch (s.intent) {
        case 'stop':
          stop++;
          break;
        case 'draw':
          draw++;
          break;
        case 'follow':
          follow++;
          break;
        case 'side_spin':
          sideSpin++;
          break;
      }
      if (s.positionQuality != null) {
        posQ.update(s.positionQuality!, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return {
      'stop': stop,
      'draw': draw,
      'follow': follow,
      'side_spin': sideSpin,
      'position_quality': posQ,
    };
  }

  /// Accuracy per shot type.
  Map<String, double> _shotAccuracy(List<Shot> shots) {
    final out = <String, int>{};
    final made = <String, int>{};
    for (final s in shots) {
      out.update(s.shotType, (v) => v + 1, ifAbsent: () => 1);
      if (s.isMade) {
        made.update(s.shotType, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final accuracy = <String, double>{};
    for (final entry in out.entries) {
      final attempts = entry.value;
      final m = made[entry.key] ?? 0;
      accuracy[entry.key] = attempts == 0 ? 0.0 : m / attempts;
    }
    return accuracy;
  }

  /// Aggregate stats across multiple matches for the player.
  Future<Map<String, dynamic>> aggregatePlayerStats(String playerId) async {
    final matches = await _matchRepo.getMatchesByPlayer(playerId);
    if (matches.isEmpty) return {'matches': 0};
    int totalRacks = 0;
    int wins = 0;
    int totalFouls = 0;
    int totalBreakAndRun = 0;
    int totalRunOuts = 0;
    double totalConfidence = 0;
    int stateCount = 0;
    for (final m in matches) {
      totalRacks += m.racks.length;
      wins += m.racks.where((r) => r.isWin).length;
      totalFouls += m.racks.fold(0, (a, r) => a + r.fouls);
      totalBreakAndRun += m.racks.where((r) => r.isBreakAndRun).length;
      totalRunOuts += m.racks.where((r) => r.isRunOut).length;
      if (m.playerState != null) {
        totalConfidence += m.playerState!.confidence;
        stateCount++;
      }
    }
    return {
      'matches': matches.length,
      'wins': wins,
      'racks': totalRacks,
      'winPercent': totalRacks > 0 ? (wins / totalRacks) * 100 : 0.0,
      'fouls': totalFouls,
      'breakAndRun': totalBreakAndRun,
      'runOuts': totalRunOuts,
      'avgConfidence': stateCount > 0 ? totalConfidence / stateCount : 0.0,
    };
  }
}

/// `MatchReviewEngine` — generates AI analysis for a completed match.
///
/// Replacement for V1 `MatchReviewEngine`.
///
/// Output:
///   - strengths
///   - weaknesses
///   - biggestMistakes
///   - mostImprovedSkill
///   - suggestedDrills
///   - relatedKnowledgeArticles
///   - recommendedLearningPath
class MatchReviewEngine {
  MatchReviewEngine(this._stats);
  final MatchStatisticsService _stats;

  Future<MatchAnalysis> generateAnalysis(String matchId) async {
    final s = await _stats.computeMatchStatistics(matchId);
    if (s.isEmpty) {
      return MatchAnalysis(
        matchId: matchId,
        strengths: [],
        weaknesses: [],
        biggestMistakes: [],
        generatedAt: DateTime.now(),
      );
    }

    final strengths = <String>[];
    final weaknesses = <String>[];
    final biggestMistakes = <String>[];
    final suggestedDrills = <String>[];

    // Win %
    if ((s['winPercent'] ?? 0) >= 60) {
      strengths.add('Win rate is strong (${s['winPercent']}%)');
    } else if ((s['winPercent'] ?? 0) < 40) {
      weaknesses.add('Win rate below 40% — focus on rack wins');
    }

    // Break & Run
    if ((s['breakAndRun'] ?? 0) >= 1) {
      strengths.add('Break-and-run active — ${s['breakAndRun']} this match');
    } else {
      weaknesses.add('No break-and-runs — extend run-out drills');
      suggestedDrills.add('5-Ball Run-Out Drill');
    }

    // Safety success
    if ((s['safetyCount'] as int? ?? 0) > 0) {
      final rate = s['safetySuccessRate'] as double? ?? 0;
      if (rate >= 70) {
        strengths.add('Safety success rate $rate%');
      } else if (rate < 50) {
        weaknesses.add('Safety success rate only $rate%');
        suggestedDrills.add('Safety Pattern Drill');
      }
    }

    // Fouls
    if ((s['fouls'] ?? 0) > 3) {
      weaknesses.add('${s['fouls']} fouls — review pre-shot routine');
      biggestMistakes.add('High foul count');
    }

    // Easy misses
    if ((s['easyMisses'] ?? 0) > 2) {
      weaknesses.add('${s['easyMisses']} easy misses — improve fundamentals');
      biggestMistakes.add('Missed easy shots');
      suggestedDrills.add('Stun Line Drill');
    }

    // Position errors
    if ((s['positionErrors'] ?? 0) > 3) {
      weaknesses.add('${s['positionErrors']} position errors — improve cue ball control');
      suggestedDrills.add('Stop-and-Follow Drill');
    }

    // Mental
    final conf = s['confidence'];
    final focus = s['focus'];
    if (conf != null && conf <= 2) {
      weaknesses.add('Low confidence (${conf}/5) — visualization exercises');
    }
    if (focus != null && focus <= 2) {
      weaknesses.add('Focus dips (${focus}/5) — pre-shot routine work');
    }

    // Physical
    if (s['fatigue'] != null && (s['fatigue'] as int) >= 4) {
      weaknesses.add('Fatigue is high — review sleep and conditioning');
    }

    // Specialty shots
    if ((s['banks'] ?? 0) == 0) {
      suggestedDrills.add('Banks in the Corner Drill');
    }
    if ((s['combos'] ?? 0) == 0) {
      suggestedDrills.add('Combo Pattern Drill');
    }

    // Related knowledge
    final articles = <String>[];
    if ((s['positionErrors'] ?? 0) > 2) {
      articles.add('Position Play Fundamentals');
    }
    if ((s['easyMisses'] ?? 0) > 1) {
      articles.add('Shooting Mechanics');
    }
    if ((s['safetySuccessRate'] ?? 100) < 50) {
      articles.add('Defensive Safety Strategy');
    }
    if (conf != null && conf <= 3) {
      articles.add('Mental Game for Pool');
    }

    // Most improved skill — heuristic based on strongest axis
    String? mostImprovedSkill;
    final acc = s['shotAccuracy'] as Map<String, double>? ?? {};
    if (acc.isNotEmpty) {
      final sorted = acc.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.first.value >= 0.7) {
        mostImprovedSkill = sorted.first.key;
      }
    }

    return MatchAnalysis(
      matchId: matchId,
      strengths: strengths,
      weaknesses: weaknesses,
      biggestMistakes: biggestMistakes,
      mostImprovedSkill: mostImprovedSkill,
      suggestedDrills: suggestedDrills,
      relatedKnowledgeArticles: articles,
      recommendedLearningPath:
          suggestedDrills.isEmpty ? null : suggestedDrills.first,
      generatedAt: DateTime.now(),
    );
  }
}
