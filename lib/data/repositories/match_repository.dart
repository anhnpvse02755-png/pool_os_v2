import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import '../models/match.dart';
import '../models/match_analysis.dart';

/// Repository interface for matches.
///
/// Implementations:
///   - LocalMatchRepository (SharedPreferences, offline-first)
///   - SupabaseMatchRepository (future, online sync)
///
/// Per the architecture rules:
///   * No hardcoded persistence
///   * Offline-first
///   * Ready for Supabase sync
abstract class IMatchRepository {
  Future<List<Match>> getAllMatches();
  Future<Match?> getMatchById(String id);
  Future<List<Match>> getMatchesByPlayer(String playerId);
  Future<List<Match>> getMatchesBySession(String sessionId);
  Future<void> saveMatch(Match match);
  Future<void> deleteMatch(String id);
  Future<void> updateMatch(Match match);

  // Sub-resources
  Future<void> saveRack(String matchId, Rack rack);
  Future<List<Rack>> getRacksByMatch(String matchId);

  Future<void> savePlayerState(PlayerStateSnapshot state);
  Future<PlayerStateSnapshot?> getPlayerState(String matchId);

  Future<void> saveEquipmentSnapshot(MatchEquipmentSnapshot snapshot);
  Future<MatchEquipmentSnapshot?> getEquipmentSnapshot(String matchId);

  Future<void> saveTimelineEntry(String matchId, MatchTimelineEntry entry);
  Future<List<MatchTimelineEntry>> getTimeline(String matchId);

  Future<void> saveAnalysis(MatchAnalysis analysis);
  Future<MatchAnalysis?> getAnalysis(String matchId);

  // Stats
  Future<Map<String, dynamic>> getPlayerAggregates(String playerId);
}

/// Local offline-first implementation.
///
/// Stores everything in SharedPreferences under JSON-encoded keys.
class LocalMatchRepository implements IMatchRepository {
  LocalMatchRepository();

  static const _kMatchesKey = 'poolos_v2.matches';
  static const _kRacksPrefix = 'poolos_v2.racks.';
  static const _kPlayerStatePrefix = 'poolos_v2.player_state.';
  static const _kEquipmentPrefix = 'poolos_v2.equipment.';
  static const _kTimelinePrefix = 'poolos_v2.timeline.';
  static const _kAnalysisPrefix = 'poolos_v2.analysis.';

  // -- Top-level ----------------------------------------------------------

  Future<List<Match>> _readAll() async {
    final raw = LocalStorageService.prefs.getString(_kMatchesKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => Match.fromJson(j)).toList();
  }

  Future<void> _writeAll(List<Match> matches) async {
    final raw = jsonEncode(matches.map((m) => m.toJson()).toList());
    await LocalStorageService.prefs.setString(_kMatchesKey, raw);
  }

  @override
  Future<List<Match>> getAllMatches() async {
    final all = await _readAll();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<Match?> getMatchById(String id) async {
    final all = await _readAll();
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Match>> getMatchesByPlayer(String playerId) async {
    final all = await getAllMatches();
    return all.where((m) => m.playerId == playerId).toList();
  }

  @override
  Future<List<Match>> getMatchesBySession(String sessionId) async {
    final all = await getAllMatches();
    return all.where((m) => m.sessionId.toString() == sessionId).toList();
  }

  @override
  Future<void> saveMatch(Match match) async {
    final all = await _readAll();
    final idx = all.indexWhere((m) => m.id == match.id);
    final updated = match.copyWith(updatedAt: DateTime.now());
    if (idx >= 0) {
      all[idx] = updated;
    } else {
      all.add(updated);
    }
    await _writeAll(all);
  }

  @override
  Future<void> updateMatch(Match match) => saveMatch(match);

  @override
  Future<void> deleteMatch(String id) async {
    final all = await _readAll();
    all.removeWhere((m) => m.id == id);
    await _writeAll(all);
    await LocalStorageService.prefs.remove('$_kRacksPrefix$id');
    await LocalStorageService.prefs.remove('$_kPlayerStatePrefix$id');
    await LocalStorageService.prefs.remove('$_kEquipmentPrefix$id');
    await LocalStorageService.prefs.remove('$_kTimelinePrefix$id');
    await LocalStorageService.prefs.remove('$_kAnalysisPrefix$id');
  }

  // -- Racks --------------------------------------------------------------

  @override
  Future<void> saveRack(String matchId, Rack rack) async {
    final racks = await getRacksByMatch(matchId);
    final idx = racks.indexWhere((r) => r.id == rack.id);
    if (idx >= 0) {
      racks[idx] = rack;
    } else {
      racks.add(rack);
    }
    final raw = jsonEncode(racks.map((r) => r.toJson()).toList());
    await LocalStorageService.prefs.setString('$_kRacksPrefix$matchId', raw);
  }

  @override
  Future<List<Rack>> getRacksByMatch(String matchId) async {
    final raw = LocalStorageService.prefs.getString('$_kRacksPrefix$matchId');
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((j) => Rack.fromJson(j)).toList();
  }

  // -- Player State -------------------------------------------------------

  @override
  Future<void> savePlayerState(PlayerStateSnapshot state) async {
    await LocalStorageService.prefs.setString(
      '$_kPlayerStatePrefix${state.matchId}',
      jsonEncode(state.toJson()),
    );
  }

  @override
  Future<PlayerStateSnapshot?> getPlayerState(String matchId) async {
    final raw = LocalStorageService.prefs.getString('$_kPlayerStatePrefix$matchId');
    if (raw == null || raw.isEmpty) return null;
    return PlayerStateSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  // -- Equipment Snapshot -------------------------------------------------

  @override
  Future<void> saveEquipmentSnapshot(MatchEquipmentSnapshot snapshot) async {
    await LocalStorageService.prefs.setString(
      '$_kEquipmentPrefix${snapshot.matchId}',
      jsonEncode(snapshot.toJson()),
    );
  }

  @override
  Future<MatchEquipmentSnapshot?> getEquipmentSnapshot(String matchId) async {
    final raw = LocalStorageService.prefs.getString('$_kEquipmentPrefix$matchId');
    if (raw == null || raw.isEmpty) return null;
    return MatchEquipmentSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  // -- Timeline -----------------------------------------------------------

  @override
  Future<void> saveTimelineEntry(String matchId, MatchTimelineEntry entry) async {
    final entries = await getTimeline(matchId);
    entries.add(entry);
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await LocalStorageService.prefs.setString('$_kTimelinePrefix$matchId', raw);
  }

  @override
  Future<List<MatchTimelineEntry>> getTimeline(String matchId) async {
    final raw = LocalStorageService.prefs.getString('$_kTimelinePrefix$matchId');
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list
        .map((j) => MatchTimelineEntry.fromJson(j))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // -- Analysis -----------------------------------------------------------

  @override
  Future<void> saveAnalysis(MatchAnalysis analysis) async {
    await LocalStorageService.prefs.setString(
      '$_kAnalysisPrefix${analysis.matchId}',
      jsonEncode(analysis.toJson()),
    );
  }

  @override
  Future<MatchAnalysis?> getAnalysis(String matchId) async {
    final raw = LocalStorageService.prefs.getString('$_kAnalysisPrefix$matchId');
    if (raw == null || raw.isEmpty) return null;
    return MatchAnalysis.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // -- Aggregates ---------------------------------------------------------

  @override
  Future<Map<String, dynamic>> getPlayerAggregates(String playerId) async {
    final matches = await getMatchesByPlayer(playerId);
    if (matches.isEmpty) {
      return {
        'totalMatches': 0,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'winRate': 0.0,
        'avgDuration': 0,
        'totalRacks': 0,
        'totalFouls': 0,
        'totalBreaks': 0,
      };
    }
    int wins = 0, losses = 0, draws = 0;
    int totalRacks = 0;
    int totalFouls = 0;
    int totalBreaks = 0;
    int totalDuration = 0;
    for (final m in matches) {
      if (m.isWin) wins++;
      if (m.isLoss) losses++;
      if (m.isDraw) draws++;
      totalRacks += m.racks.length;
      for (final r in m.racks) {
        totalFouls += r.fouls;
        if (r.breakShot) totalBreaks++;
      }
      totalDuration += m.duration ?? 0;
    }
    return {
      'totalMatches': matches.length,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': matches.isEmpty ? 0.0 : wins / matches.length,
      'avgDuration': matches.isEmpty ? 0 : totalDuration ~/ matches.length,
      'totalRacks': totalRacks,
      'totalFouls': totalFouls,
      'totalBreaks': totalBreaks,
    };
  }
}

/// Match Statistics aggregate (lightweight, used by UI)
class MatchStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int totalRacksPlayed;
  final int totalBallsPocketed;
  final double avgRacksPerMatch;

  const MatchStats({
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0.0,
    this.totalRacksPlayed = 0,
    this.totalBallsPocketed = 0,
    this.avgRacksPerMatch = 0.0,
  });
}
