// ============================================================================
// FakeMatchRepository — in-memory IMatchRepository for widget tests
// ============================================================================
//
// Day 2A.5: provides a no-op IMatchRepository for widget tests. The fake
// records calls and returns canned responses. It deliberately implements
// only the methods that UI currently calls — when new methods are needed
// for tests, add them here, not as a global mock library.
// ============================================================================

import 'package:pool_os_v2/data/repositories/match_repository.dart';
import 'package:pool_os_v2/data/models/match.dart';
import 'package:pool_os_v2/data/models/match_analysis.dart';

class FakeMatchRepository implements IMatchRepository {
  FakeMatchRepository({List<Match>? seeded})
      : _matches = List.of(seeded ?? const []);

  final List<Match> _matches;

  /// Read-only list of matches (mutable copy).
  List<Match> get matches => List.unmodifiable(_matches);

  // -- Read --------------------------------------------------------------

  @override
  Future<List<Match>> getAllMatches() async {
    // Sort newest-first to match LocalMatchRepository behavior.
    final out = List<Match>.of(_matches);
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  @override
  Future<Match?> getMatchById(String id) async {
    try {
      return _matches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Match>> getMatchesByPlayer(String playerId) async =>
      _matches.where((m) => m.playerId == playerId).toList();

  @override
  Future<List<Match>> getMatchesBySession(String sessionId) async =>
      _matches.where((m) => m.sessionId.toString() == sessionId).toList();

  // -- Write -------------------------------------------------------------

  @override
  Future<void> saveMatch(Match match) async {
    final i = _matches.indexWhere((m) => m.id == match.id);
    if (i >= 0) {
      _matches[i] = match;
    } else {
      _matches.add(match);
    }
  }

  @override
  Future<void> deleteMatch(String id) async {
    _matches.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> updateMatch(Match match) async => saveMatch(match);

  // -- Sub-resources (not exercised in current tests; stub) --------------

  final Map<String, List<Rack>> _racks = {};
  final Map<String, PlayerStateSnapshot?> _playerStates = {};
  final Map<String, MatchEquipmentSnapshot?> _equipment = {};
  final Map<String, List<MatchTimelineEntry>> _timeline = {};
  final Map<String, MatchAnalysis?> _analyses = {};

  @override
  Future<void> saveRack(String matchId, Rack rack) async {
    _racks.putIfAbsent(matchId, () => []).add(rack);
  }

  @override
  Future<List<Rack>> getRacksByMatch(String matchId) async =>
      List.unmodifiable(_racks[matchId] ?? const []);

  @override
  Future<void> savePlayerState(PlayerStateSnapshot state) async {
    _playerStates['state'] = state;
  }

  @override
  Future<PlayerStateSnapshot?> getPlayerState(String matchId) async =>
      _playerStates[matchId];

  @override
  Future<void> saveEquipmentSnapshot(MatchEquipmentSnapshot snapshot) async {
    _equipment['snap'] = snapshot;
  }

  @override
  Future<MatchEquipmentSnapshot?> getEquipmentSnapshot(String matchId) async =>
      _equipment[matchId];

  @override
  Future<void> saveTimelineEntry(
      String matchId, MatchTimelineEntry entry) async {
    _timeline.putIfAbsent(matchId, () => []).add(entry);
  }

  @override
  Future<List<MatchTimelineEntry>> getTimeline(String matchId) async =>
      List.unmodifiable(_timeline[matchId] ?? const []);

  @override
  Future<void> saveAnalysis(MatchAnalysis analysis) async {
    _analyses['analysis'] = analysis;
  }

  @override
  Future<MatchAnalysis?> getAnalysis(String matchId) async =>
      _analyses[matchId];

  // -- Aggregates --------------------------------------------------------

  @override
  Future<Map<String, dynamic>> getPlayerAggregates(String playerId) async {
    final list = await getMatchesByPlayer(playerId);
    final wins = list.where((m) => m.isWin).length;
    final losses = list.length - wins;
    return {
      'matchesPlayed': list.length,
      'wins': wins,
      'losses': losses,
      'winRate': list.isEmpty ? 0.0 : wins / list.length,
    };
  }
}