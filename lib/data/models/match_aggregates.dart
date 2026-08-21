// ============================================================================
// MATCH STATS MODEL - Sprint-11
// Typed model for match aggregate statistics
// ============================================================================

/// Typed Match Statistics from player matches
/// Replaces raw Map<String, dynamic> return from repository
class MatchStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int avgDurationMinutes;
  final int totalRacks;
  final int totalFouls;
  final int totalBreaks;

  const MatchStats({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.avgDurationMinutes,
    required this.totalRacks,
    required this.totalFouls,
    required this.totalBreaks,
  });

  /// Create empty stats
  factory MatchStats.empty() {
    return const MatchStats(
      totalMatches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      winRate: 0.0,
      avgDurationMinutes: 0,
      totalRacks: 0,
      totalFouls: 0,
      totalBreaks: 0,
    );
  }

  /// Create from raw map (backward compatibility)
  factory MatchStats.fromMap(Map<String, dynamic> map) {
    return MatchStats(
      totalMatches: map['totalMatches'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      losses: map['losses'] as int? ?? 0,
      draws: map['draws'] as int? ?? 0,
      winRate: (map['winRate'] as num?)?.toDouble() ?? 0.0,
      avgDurationMinutes: map['avgDuration'] as int? ?? 0,
      totalRacks: map['totalRacks'] as int? ?? 0,
      totalFouls: map['totalFouls'] as int? ?? 0,
      totalBreaks: map['totalBreaks'] as int? ?? 0,
    );
  }
}
