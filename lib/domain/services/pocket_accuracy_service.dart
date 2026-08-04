import '../../data/models/match.dart';

enum PocketPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension PocketPositionName on PocketPosition {
  String get label {
    switch (this) {
      case PocketPosition.topLeft:
        return 'Top Left';
      case PocketPosition.topCenter:
        return 'Top Center';
      case PocketPosition.topRight:
        return 'Top Right';
      case PocketPosition.bottomLeft:
        return 'Bottom Left';
      case PocketPosition.bottomCenter:
        return 'Bottom Center';
      case PocketPosition.bottomRight:
        return 'Bottom Right';
    }
  }
}

class PocketStat {
  final PocketPosition position;
  final int attempts;
  final int made;
  PocketStat({
    required this.position,
    required this.attempts,
    required this.made,
  });
  double get accuracy => attempts == 0 ? 0 : made / attempts * 100;
}

class PocketAccuracyService {
  /// Aggregate pocket accuracy across a match.
  List<PocketStat> compute(Match match) {
    final stats = {
      for (final p in PocketPosition.values) p: PocketStat(position: p, attempts: 0, made: 0),
    };

    for (final rack in match.racks) {
      for (final s in rack.shots) {
        // Use a deterministic pocket derived from the index for now.
        // V2 model has `shotNumber` (no separate `attempt` field); each shot
        // in a rack is a single attempt.
        final idx = (s.shotNumber + 0) % PocketPosition.values.length;
        final pos = PocketPosition.values[idx];
        final stat = stats[pos]!;
        stats[pos] = PocketStat(
          position: pos,
          attempts: stat.attempts + 1,
          made: stat.made + (s.result == 'made' ? 1 : 0),
        );
      }
    }
    return stats.values.toList()..sort((a, b) => a.position.index.compareTo(b.position.index));
  }
}