// ============================================================================
// PLAY PROVIDER - Match Recording & Quick Play
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PlayState {
  final List<MatchRecord> matches;
  final MatchRecord? currentMatch;
  final bool isRecording;
  final String? error;

  const PlayState({
    this.matches = const [],
    this.currentMatch,
    this.isRecording = false,
    this.error,
  });

  PlayState copyWith({
    List<MatchRecord>? matches,
    MatchRecord? currentMatch,
    bool? isRecording,
    String? error,
  }) {
    return PlayState(
      matches: matches ?? this.matches,
      currentMatch: currentMatch ?? this.currentMatch,
      isRecording: isRecording ?? this.isRecording,
      error: error,
    );
  }
}

class MatchRecord {
  final String id;
  final String opponent;
  final String gameType;
  final String result; // 'win', 'lose', 'draw'
  final int playerScore;
  final int opponentScore;
  final DateTime playedAt;
  final int duration; // minutes
  final List<RackRecord> racks;
  final String? notes;

  const MatchRecord({
    required this.id,
    required this.opponent,
    required this.gameType,
    required this.result,
    required this.playerScore,
    required this.opponentScore,
    required this.playedAt,
    required this.duration,
    this.racks = const [],
    this.notes,
  });
}

class RackRecord {
  final int rackNumber;
  final int playerScore;
  final int opponentScore;
  final String? winner; // 'player', 'opponent'
  final List<String> fouls;
  final String? notes;

  const RackRecord({
    required this.rackNumber,
    required this.playerScore,
    required this.opponentScore,
    this.winner,
    this.fouls = const [],
    this.notes,
  });
}

class PlayNotifier extends StateNotifier<PlayState> {
  PlayNotifier() : super(const PlayState()) {
    _loadDemoData();
  }

  void _loadDemoData() {
    final matches = [
      MatchRecord(
        id: const Uuid().v4(),
        opponent: 'Nguyễn Văn A',
        gameType: '8-ball',
        result: 'win',
        playerScore: 5,
        opponentScore: 3,
        playedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: 45,
      ),
      MatchRecord(
        id: const Uuid().v4(),
        opponent: 'Trần Văn B',
        gameType: '8-ball',
        result: 'lose',
        playerScore: 3,
        opponentScore: 5,
        playedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: 52,
      ),
      MatchRecord(
        id: const Uuid().v4(),
        opponent: 'Lê Văn C',
        gameType: '9-ball',
        result: 'win',
        playerScore: 5,
        opponentScore: 2,
        playedAt: DateTime.now().subtract(const Duration(days: 2)),
        duration: 38,
      ),
    ];

    state = state.copyWith(matches: matches);
  }

  void startMatch({
    required String opponent,
    required String gameType,
    required int raceTo,
    String? notes,
  }) {
    final match = MatchRecord(
      id: const Uuid().v4(),
      opponent: opponent,
      gameType: gameType,
      result: 'in_progress',
      playerScore: 0,
      opponentScore: 0,
      playedAt: DateTime.now(),
      duration: 0,
      racks: [],
      notes: notes,
    );

    state = state.copyWith(currentMatch: match, isRecording: true);
  }

  void recordRack({
    required int playerScore,
    required int opponentScore,
    required String winner,
    List<String>? fouls,
    String? notes,
  }) {
    if (state.currentMatch == null) return;

    final rack = RackRecord(
      rackNumber: state.currentMatch!.racks.length + 1,
      playerScore: playerScore,
      opponentScore: opponentScore,
      winner: winner,
      fouls: fouls ?? [],
      notes: notes,
    );

    final updatedRacks = [...state.currentMatch!.racks, rack];
    final totalPlayerScore = updatedRacks.fold<int>(0, (sum, r) => sum + r.playerScore);
    final totalOpponentScore = updatedRacks.fold<int>(0, (sum, r) => sum + r.opponentScore);

    final updatedMatch = MatchRecord(
      id: state.currentMatch!.id,
      opponent: state.currentMatch!.opponent,
      gameType: state.currentMatch!.gameType,
      result: state.currentMatch!.result,
      playerScore: totalPlayerScore,
      opponentScore: totalOpponentScore,
      playedAt: state.currentMatch!.playedAt,
      duration: DateTime.now().difference(state.currentMatch!.playedAt).inMinutes,
      racks: updatedRacks,
      notes: state.currentMatch!.notes,
    );

    state = state.copyWith(currentMatch: updatedMatch);
  }

  void endMatch({required String result}) {
    if (state.currentMatch == null) return;

    final finalMatch = MatchRecord(
      id: state.currentMatch!.id,
      opponent: state.currentMatch!.opponent,
      gameType: state.currentMatch!.gameType,
      result: result,
      playerScore: state.currentMatch!.playerScore,
      opponentScore: state.currentMatch!.opponentScore,
      playedAt: state.currentMatch!.playedAt,
      duration: DateTime.now().difference(state.currentMatch!.playedAt).inMinutes,
      racks: state.currentMatch!.racks,
      notes: state.currentMatch!.notes,
    );

    state = state.copyWith(
      matches: [...state.matches, finalMatch],
      currentMatch: null,
      isRecording: false,
    );
  }

  void cancelMatch() {
    state = state.copyWith(
      currentMatch: null,
      isRecording: false,
    );
  }

  List<MatchRecord> getMatchHistory({String? gameType, String? result}) {
    var filtered = state.matches;

    if (gameType != null) {
      filtered = filtered.where((m) => m.gameType == gameType).toList();
    }

    if (result != null) {
      filtered = filtered.where((m) => m.result == result).toList();
    }

    // Sort by date, newest first
    filtered.sort((a, b) => b.playedAt.compareTo(a.playedAt));

    return filtered;
  }

  Map<String, dynamic> getStats() {
    final matches = state.matches;
    if (matches.isEmpty) {
      return {
        'totalMatches': 0,
        'wins': 0,
        'losses': 0,
        'draws': 0,
        'winRate': 0.0,
        'avgDuration': 0,
      };
    }

    final wins = matches.where((m) => m.result == 'win').length;
    final losses = matches.where((m) => m.result == 'lose').length;
    final draws = matches.where((m) => m.result == 'draw').length;
    final avgDuration = matches.fold<int>(0, (sum, m) => sum + m.duration) ~/ matches.length;

    return {
      'totalMatches': matches.length,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': (wins / matches.length * 100).roundToDouble(),
      'avgDuration': avgDuration,
    };
  }
}

final playProvider = StateNotifierProvider<PlayNotifier, PlayState>((ref) {
  return PlayNotifier();
});

// Quick stats provider
final playStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final playNotifier = ref.read(playProvider.notifier);
  return playNotifier.getStats();
});

// Match history provider
final matchHistoryProvider = Provider.family<List<MatchRecord>, Map<String, String?>?>((ref, filters) {
  final playNotifier = ref.read(playProvider.notifier);
  return playNotifier.getMatchHistory(
    gameType: filters?['gameType'],
    result: filters?['result'],
  );
});
