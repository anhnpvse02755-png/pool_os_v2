import 'package:intl/intl.dart';

import '../../data/models/match.dart';
import '../../data/models/match_analysis.dart';
import '../../data/repositories/match_repository.dart';
import '../services/match_statistics_service.dart';

/// Weekly report — aggregates the last 7 days of matches + drills.
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final double winRate;
  final int racksPlayed;
  final int totalFouls;
  final int totalBreakAndRun;
  final int totalRunOuts;
  final List<Match> matches;
  final List<String> topStrengths;
  final List<String> topWeaknesses;
  final List<String> suggestedDrills;

  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.racksPlayed,
    required this.totalFouls,
    required this.totalBreakAndRun,
    required this.totalRunOuts,
    required this.matches,
    required this.topStrengths,
    required this.topWeaknesses,
    required this.suggestedDrills,
  });
}

class WeeklyReportGenerator {
  WeeklyReportGenerator(this._matchRepo, this._stats);
  final IMatchRepository _matchRepo;
  final MatchStatisticsService _stats;

  Future<WeeklyReport> generate({String? playerId, DateTime? weekEnd}) async {
    final end = weekEnd ?? DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    final all = playerId != null
        ? await _matchRepo.getMatchesByPlayer(playerId)
        : await _matchRepo.getAllMatches();

    final matches = all
        .where((m) =>
            m.createdAt.isAfter(start) && m.createdAt.isBefore(end.add(const Duration(days: 1))))
        .toList();

    int wins = 0, losses = 0, racksPlayed = 0, fouls = 0;
    int breakAndRun = 0, runOuts = 0;
    final Map<String, int> strengthCount = {};
    final Map<String, int> weaknessCount = {};
    final Set<String> drills = {};
    for (final m in matches) {
      if (m.isWin) wins++;
      if (m.isLoss) losses++;
      racksPlayed += m.racks.length;
      for (final r in m.racks) {
        fouls += r.fouls;
        if (r.isBreakAndRun) breakAndRun++;
        if (r.isRunOut) runOuts++;
      }
      final a = m.analysis;
      if (a != null) {
        for (final s in a.strengths) {
          strengthCount.update(s, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final w in a.weaknesses) {
          weaknessCount.update(w, (v) => v + 1, ifAbsent: () => 1);
        }
        drills.addAll(a.suggestedDrills);
      }
    }

    final strengthList = strengthCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final weaknessList = weaknessCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return WeeklyReport(
      weekStart: start,
      weekEnd: end,
      matchesPlayed: matches.length,
      wins: wins,
      losses: losses,
      winRate: matches.isEmpty ? 0 : wins / matches.length * 100,
      racksPlayed: racksPlayed,
      totalFouls: fouls,
      totalBreakAndRun: breakAndRun,
      totalRunOuts: runOuts,
      matches: matches,
      topStrengths: strengthList.take(3).map((e) => e.key).toList(),
      topWeaknesses: weaknessList.take(3).map((e) => e.key).toList(),
      suggestedDrills: drills.toList(),
    );
  }
}
