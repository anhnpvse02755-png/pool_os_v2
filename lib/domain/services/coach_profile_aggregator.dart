import 'package:intl/intl.dart';

import '../../data/repositories/match_repository.dart';

/// Aggregated coaching profile — rolling skill ratings + tone summary.
///
/// Generated from a player's match history, optionally filtered by
/// recent window (default last 30 days).
class CoachProfile {
  final String playerId;
  final DateTime generatedAt;
  final int matchesAnalyzed;
  final int wins;
  final int losses;
  final double winRate;
  final Map<String, double> skillScores; // 0..100 per skill axis
  final String tone; // "Hot", "Steady", "Slumping", "Rising"
  final List<String> recommendations;

  const CoachProfile({
    required this.playerId,
    required this.generatedAt,
    required this.matchesAnalyzed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.skillScores,
    required this.tone,
    required this.recommendations,
  });
}

class CoachProfileAggregator {
  CoachProfileAggregator(this._repo);
  final IMatchRepository _repo;

  Future<CoachProfile> generate(String playerId,
      {Duration window = const Duration(days: 30)}) async {
    final matches = await _repo.getMatchesByPlayer(playerId);
    final cutoff = DateTime.now().subtract(window);
    final recent =
        matches.where((m) => m.createdAt.isAfter(cutoff)).toList();

    int wins = 0, losses = 0, racksTotal = 0, racksWon = 0;
    int breakAndRun = 0;
    int easyMisses = 0;
    int positionErrors = 0;
    int safetyPlays = 0;
    int safetyErrors = 0;
    int fouls = 0;
    int banks = 0, jumps = 0, combos = 0;

    for (final m in recent) {
      if (m.isWin) wins++;
      if (m.isLoss) losses++;
      racksTotal += m.racks.length;
      racksWon += m.racks.where((r) => r.isWin).length;
      for (final r in m.racks) {
        if (r.isBreakAndRun) breakAndRun++;
        easyMisses += r.easyMissCount;
        positionErrors += r.positionErrorCount;
        safetyPlays += r.safetyPlays;
        safetyErrors += r.safetyErrorCount;
        fouls += r.fouls;
        banks += r.bankShotCount;
        jumps += r.jumpErrorCount;
        combos += r.comboShotCount;
      }
    }

    final skillScores = _score(
      racksWon: racksWon,
      racksTotal: racksTotal,
      breakAndRun: breakAndRun,
      easyMisses: easyMisses,
      positionErrors: positionErrors,
      safetySuccess: safetyPlays - safetyErrors,
      safetyPlays: safetyPlays,
      fouls: fouls,
      banks: banks,
      jumps: jumps,
      combos: combos,
    );

    final tone = _tone(recent);

    final recs = _recommendations(skillScores, easyMisses, positionErrors, fouls);

    return CoachProfile(
      playerId: playerId,
      generatedAt: DateTime.now(),
      matchesAnalyzed: recent.length,
      wins: wins,
      losses: losses,
      winRate: recent.isEmpty ? 0 : wins / recent.length * 100,
      skillScores: skillScores,
      tone: tone,
      recommendations: recs,
    );
  }

  Map<String, double> _score({
    required int racksWon,
    required int racksTotal,
    required int breakAndRun,
    required int easyMisses,
    required int positionErrors,
    required int safetySuccess,
    required int safetyPlays,
    required int fouls,
    required int banks,
    required int jumps,
    required int combos,
  }) {
    final rackWinPct = racksTotal == 0 ? 50.0 : racksWon / racksTotal * 100;
    final safetyRate =
        safetyPlays == 0 ? 50.0 : safetySuccess / safetyPlays * 100;
    final specialtiesScore = (banks + jumps + combos).toDouble() * 5;
    final foulingPenalty = fouls * 5.0;
    final easyMissPenalty = easyMisses * 3.0;
    final posErrorPenalty = positionErrors * 2.0;
    return {
      'Cutting': rackWinPct.clamp(0, 100),
      'Break & Run': (breakAndRun.toDouble() * 10).clamp(0, 100),
      'Safety': safetyRate.clamp(0, 100),
      'Specialty': (specialtiesScore - foulingPenalty).clamp(0, 100),
      'Discipline':
          (100 - easyMissPenalty - foulingPenalty - posErrorPenalty)
              .clamp(0, 100),
    };
  }

  String _tone(List matches) {
    if (matches.length < 3) return 'Steady';
    final winCount = matches.where((m) => m.isWin).length;
    final rate = winCount / matches.length;
    if (rate >= 0.65) return 'Hot';
    if (rate >= 0.45) return 'Steady';
    final last3 = matches.take(3).toList();
    final last3Wins = last3.where((m) => m.isWin).length;
    if (last3Wins == 0) return 'Slumping';
    if (last3Wins == 3) return 'Rising';
    return 'Steady';
  }

  List<String> _recommendations(Map<String, double> skills,
      int easyMisses, int positionErrors, int fouls) {
    final out = <String>[];
    if ((skills['Cutting'] ?? 0) < 50) {
      out.add('Tập trung cải thiện Cutting bằng stun-line drills.');
    }
    if ((skills['Break & Run'] ?? 0) < 40) {
      out.add('Run-out drills 5-ball trở lên để nâng Break & Run.');
    }
    if ((skills['Safety'] ?? 0) < 50) {
      out.add('Drill Safety pattern trên bàn 9-foot.');
    }
    if (easyMisses > 5) {
      out.add('Xem lại cơ chế cơ bản — bỏ quá nhiều easy misses.');
    }
    if (positionErrors > 5) {
      out.add('Cue Ball Control drills (stop / follow).');
    }
    if (fouls > 5) {
      out.add('Pre-shot routine — giảm fouls.');
    }
    return out;
  }

  String formattedDate(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);
}
