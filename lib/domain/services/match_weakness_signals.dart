/// Aggregate weakness signals from a recent match window.
class MatchWeaknessSignals {
  final int matchesPlayed;
  final int easyMisses;
  final int positionErrors;
  final int fouls;
  final int safetyErrors;
  final int banksMissed;
  final int kicksMissed;
  final int combosMissed;
  final int jumpsMissed;

  const MatchWeaknessSignals({
    this.matchesPlayed = 0,
    this.easyMisses = 0,
    this.positionErrors = 0,
    this.fouls = 0,
    this.safetyErrors = 0,
    this.banksMissed = 0,
    this.kicksMissed = 0,
    this.combosMissed = 0,
    this.jumpsMissed = 0,
  });

  /// Convert raw counts to drill-tag priorities (higher = needs more focus).
  Set<String> toTags() {
    final s = <String>{};
    if (easyMisses > 0) s.add('aim');
    if (easyMisses > 0) s.add('cut');
    if (positionErrors > 0) s.add('position');
    if (positionErrors > 0) s.add('cue_ball_control');
    if (fouls > 0) s.add('pre_shot_routine');
    if (safetyErrors > 0) s.add('safety');
    if (banksMissed > 0) s.add('bank');
    if (kicksMissed > 0) s.add('kick');
    if (combosMissed > 0) s.add('combo');
    if (jumpsMissed > 0) s.add('jump');
    if (s.isEmpty) {
      // No weakness signals → recommend overall foundation.
      s.add('fundamentals');
    }
    return s;
  }

  MatchWeaknessSignals copyWith({
    int? matchesPlayed,
    int? easyMisses,
    int? positionErrors,
    int? fouls,
    int? safetyErrors,
    int? banksMissed,
    int? kicksMissed,
    int? combosMissed,
    int? jumpsMissed,
  }) =>
      MatchWeaknessSignals(
        matchesPlayed: matchesPlayed ?? this.matchesPlayed,
        easyMisses: easyMisses ?? this.easyMisses,
        positionErrors: positionErrors ?? this.positionErrors,
        fouls: fouls ?? this.fouls,
        safetyErrors: safetyErrors ?? this.safetyErrors,
        banksMissed: banksMissed ?? this.banksMissed,
        kicksMissed: kicksMissed ?? this.kicksMissed,
        combosMissed: combosMissed ?? this.combosMissed,
        jumpsMissed: jumpsMissed ?? this.jumpsMissed,
      );
}