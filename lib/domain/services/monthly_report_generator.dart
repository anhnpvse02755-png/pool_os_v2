import 'package:intl/intl.dart';

import '../../data/models/match.dart';
import '../../data/models/match_analysis.dart';
import '../../data/repositories/match_repository.dart';

class MonthlyReport {
  final int year;
  final int month;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final double winRate;
  final int racksPlayed;
  final int breakAndRun;
  final int runOuts;
  final Map<String, int> strengths;
  final Map<String, int> weaknesses;
  final List<String> suggestedDrills;
  final String narrative;
  const MonthlyReport({
    required this.year,
    required this.month,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.racksPlayed,
    required this.breakAndRun,
    required this.runOuts,
    required this.strengths,
    required this.weaknesses,
    required this.suggestedDrills,
    required this.narrative,
  });
}

class MonthlyReportGenerator {
  MonthlyReportGenerator(this._repo);
  final IMatchRepository _repo;

  Future<MonthlyReport> generate({
    required int year,
    required int month,
    String? playerId,
  }) async {
    final matches = playerId != null
        ? await _repo.getMatchesByPlayer(playerId)
        : await _repo.getAllMatches();
    final filtered = matches.where((m) =>
        m.createdAt.year == year && m.createdAt.month == month).toList();

    int wins = 0, losses = 0, racksPlayed = 0, br = 0, runOuts = 0;
    final Map<String, int> strengths = {};
    final Map<String, int> weaknesses = {};
    final Set<String> drills = {};

    for (final m in filtered) {
      if (m.isWin) wins++;
      if (m.isLoss) losses++;
      racksPlayed += m.racks.length;
      for (final r in m.racks) {
        if (r.isBreakAndRun) br++;
        if (r.isRunOut) runOuts++;
      }
      final a = m.analysis;
      if (a != null) {
        for (final s in a.strengths) {
          strengths.update(s, (v) => v + 1, ifAbsent: () => 1);
        }
        for (final w in a.weaknesses) {
          weaknesses.update(w, (v) => v + 1, ifAbsent: () => 1);
        }
        drills.addAll(a.suggestedDrills);
      }
    }

    final narrative = _composeNarrative(
      filtered.length, wins, losses, br, runOuts, strengths, weaknesses,
    );

    return MonthlyReport(
      year: year,
      month: month,
      matchesPlayed: filtered.length,
      wins: wins,
      losses: losses,
      winRate: filtered.isEmpty ? 0 : wins / filtered.length * 100,
      racksPlayed: racksPlayed,
      breakAndRun: br,
      runOuts: runOuts,
      strengths: strengths,
      weaknesses: weaknesses,
      suggestedDrills: drills.toList(),
      narrative: narrative,
    );
  }

  String monthLabel(int month) => DateFormat.MMMM('vi').format(DateTime(2026, month));

  String _composeNarrative(
    int matches,
    int wins,
    int losses,
    int br,
    int runOuts,
    Map<String, int> strengths,
    Map<String, int> weaknesses,
  ) {
    if (matches == 0) {
      return 'Chưa có trận đấu nào trong tháng.';
    }
    final topStrength = strengths.entries
        .toList()
        .fold<MapEntry<String, int>?>(null,
            (best, e) => best == null || e.value > best.value ? e : best);
    final topWeakness = weaknesses.entries
        .toList()
        .fold<MapEntry<String, int>?>(null,
            (best, e) => best == null || e.value > best.value ? e : best);
    final strengthText = topStrength == null
        ? 'điểm mạnh chưa rõ'
        : 'điểm mạnh là "${topStrength.key}"';
    final weaknessText = topWeakness == null
        ? 'điểm yếu chưa rõ'
        : 'cần cải thiện "${topWeakness.key}"';
    return 'Tháng này bạn đã chơi $matches trận ($wins thắng / $losses thua), '
        '$br break & run, $runOuts run-out. $strengthText, $weaknessText.';
  }
}