import '../constants/app_constants.dart';

/// Pool Rating Calculator
/// Calculates player's skill rating based on actual performance
class PoolRatingCalculator {
  /// Calculate Pool Rating from assessment answers
  /// Returns a rating from 0-1000
  static int calculateFromAssessment(Map<int, int> answers) {
    // Q3: Peak Run (normalized to 0-100)
    final peakRun = _normalizePeakRun(answers[3] ?? 1);

    // Q4: Average Run (normalized to 0-100)
    final averageRun = _normalizeAverageRun(answers[4] ?? 1);

    // Q5 & Q6: Runout Frequency (normalized to 0-100)
    final runoutFreq = _normalizeRunoutFrequency(answers[5] ?? 0, answers[6] ?? 0);

    // Q7: Break Quality (normalized to 0-100)
    final breakQuality = _normalizeBreakQuality(answers[7] ?? 1);

    // Q8: Position Play (normalized to 0-100)
    final positionPlay = _normalizePositionPlay(answers[8] ?? 1);

    // Calculate weighted average
    final rating = (averageRun * AppConstants.weightAverageRun +
            runoutFreq * AppConstants.weightRunoutFreq +
            positionPlay * AppConstants.weightPositionPlay +
            breakQuality * AppConstants.weightBreakQuality +
            peakRun * AppConstants.weightPeakRun)
        .round();

    return rating.clamp(0, 1000);
  }

  /// Calculate Pool Rating from actual match data
  /// This is the real rating based on performance
  static int calculateFromMatches({
    required int totalMatches,
    required int wins,
    required double averageRun,
    required int totalRunouts,
    required int totalRacks,
    required double breakPocketRate,
    required double positionAccuracy,
  }) {
    // Win rate (0-100)
    final winRate = totalMatches > 0 ? (wins / totalMatches) * 100 : 0;

    // Average run (already 0-100)
    final avgRunScore = averageRun.clamp(0, 100);

    // Runout frequency (0-100)
    final runoutFreq = totalRacks > 0
        ? ((totalRunouts / totalRacks) * 100).clamp(0, 100)
        : 0.0;

    // Break quality (0-100)
    final breakScore = (breakPocketRate * 100).clamp(0, 100);

    // Position accuracy (0-100)
    final posScore = (positionAccuracy * 100).clamp(0, 100);

    // Weighted calculation
    final rating = (avgRunScore * 0.35 +
            runoutFreq * 0.25 +
            posScore * 0.20 +
            breakScore * 0.10 +
            winRate * 0.10)
        .round();

    return rating.clamp(0, 1000);
  }

  /// Get level from rating
  static String getLevelFromRating(int rating) {
    for (final range in AppConstants.ratingRanges) {
      if (rating >= range.min && rating <= range.max) {
        return range.level;
      }
    }
    return 'K';
  }

  /// Get level info
  static PlayerLevel? getLevelInfo(String levelCode) {
    return AppConstants.playerLevels[levelCode];
  }

  /// Calculate confidence based on data amount
  /// More matches = higher confidence
  static double calculateConfidence({
    required int totalRacks,
    required int totalShots,
    required int totalSessions,
  }) {
    // Data points that increase confidence
    int score = 0;

    // Racks: 1 point per 10 racks (max 30)
    score += (totalRacks / 10).floor().clamp(0, 30);

    // Shots: 1 point per 50 shots (max 30)
    score += (totalShots / 50).floor().clamp(0, 30);

    // Sessions: 10 points per session (max 40)
    score += (totalSessions * 10).clamp(0, 40);

    // Normalize to 0-100
    return (score / 100.0).clamp(0.0, 1.0);
  }

  /// Normalize peak run answer to 0-100
  static double _normalizePeakRun(int answer) {
    // 1-8 bi = 12.5 each, 9 (Runout) = 100
    if (answer >= 9) return 100;
    return (answer * 12.5).clamp(0, 100);
  }

  /// Normalize average run answer to 0-100
  static double _normalizeAverageRun(int answer) {
    // 1=10, 2=20, 3=30, 4=40, 5=55, 6=75, 7=100
    switch (answer) {
      case 1:
        return 10;
      case 2:
        return 20;
      case 3:
        return 30;
      case 4:
        return 40;
      case 5:
        return 55;
      case 6:
        return 75;
      case 7:
        return 100;
      default:
        return 10;
    }
  }

  /// Normalize runout frequency to 0-100
  static double _normalizeRunoutFrequency(int q5, int q6) {
    // Q5: 0-4 (never to very often)
    // Q6: racks needed for one runout (higher = worse)

    double freq = 0;

    // Q5 contributes 50%
    freq += q5 * 20; // 0, 20, 40, 60, 80

    // Q6 contributes 50%
    // 0=0, 6=20, 5=35, 4=50, 3=65, 2=80, 1=90, 7=100
    switch (q6) {
      case 0:
        freq += 0;
        break;
      case 6:
        freq += 20;
        break;
      case 5:
        freq += 35;
        break;
      case 4:
        freq += 50;
        break;
      case 3:
        freq += 65;
        break;
      case 2:
        freq += 80;
        break;
      case 1:
        freq += 90;
        break;
      case 7:
        freq += 100;
        break;
    }

    return (freq / 2).clamp(0, 100);
  }

  /// Normalize break quality to 0-100
  static double _normalizeBreakQuality(int answer) {
    // 1=10, 2=25, 3=45, 4=70, 5=100
    switch (answer) {
      case 1:
        return 10;
      case 2:
        return 25;
      case 3:
        return 45;
      case 4:
        return 70;
      case 5:
        return 100;
      default:
        return 10;
    }
  }

  /// Normalize position play to 0-100
  static double _normalizePositionPlay(int answer) {
    // 1=10, 2=30, 3=55, 4=80, 5=100
    switch (answer) {
      case 1:
        return 10;
      case 2:
        return 30;
      case 3:
        return 55;
      case 4:
        return 80;
      case 5:
        return 100;
      default:
        return 10;
    }
  }
}
