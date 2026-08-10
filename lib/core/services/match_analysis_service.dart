// ============================================================================
// MATCH ANALYSIS SERVICE - Phase 8
// Analyzes match recording data and generates Coach AI recommendations
//
// This service:
// 1. Analyzes rack data from match recording
// 2. Identifies patterns (strengths/weaknesses)
// 3. Generates drill recommendations based on match performance
// 4. Integrates with PlayerIntelligence for Coach AI
// ============================================================================

import '../models/match_analysis.dart';
import '../../data/models/match.dart';

/// Service for analyzing match recording data
class MatchAnalysisService {
  /// Analyze a list of racks and return analysis
  MatchAnalysis analyzeRacks(String matchId, List<Rack> racks) {
    return MatchAnalysis.fromRacks(matchId, racks);
  }

  /// Convert analysis to weakness-based drill recommendations
  List<DrillRecommendation> getRecommendations(MatchAnalysis analysis) {
    final recommendations = <DrillRecommendation>[];

    if (analysis.totalRacks == 0) {
      return recommendations;
    }

    // Calculate error threshold (30% of racks)
    final errorThreshold = analysis.totalRacks * 0.3;

    // Generate recommendations based on weaknesses
    // Priority 1: Miss dễ (aiming issues)
    if (analysis.easyMisses > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'AIMING_BASIC',
        drillName: 'Luyện Aiming Cơ Bản',
        reason: 'Miss cú dễ: ${analysis.easyMisses} lần trong ${analysis.totalRacks} racks. '
            'Cần cải thiện aim để giảm miss không đáng có.',
        priority: 1,
        category: 'aiming',
      ));
    }

    // Priority 2: Hard miss (advanced aiming)
    if (analysis.hardMisses > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'CUT_SHOTS',
        drillName: 'Luyện Cú Cắt',
        reason: 'Miss cú khó: ${analysis.hardMisses} lần. Cần cải thiện kỹ thuật '
            'cú cắt để xử lý các tình huống khó.',
        priority: 2,
        category: 'shot_making',
      ));
    }

    // Priority 3: Position errors
    if (analysis.positionErrors > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'POSITION_CONTROL',
        drillName: 'Kiểm Soát Position',
        reason: 'Lỗi position: ${analysis.positionErrors} lần. Cần tập trung '
            'vào kiểm soát bi cái sau cú đánh.',
        priority: 3,
        category: 'position',
      ));
    }

    // Priority 4: Scratches (cue ball control)
    if (analysis.scratches > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'DRAW_SHOT',
        drillName: 'Luyện Draw Shot',
        reason: 'Scratch: ${analysis.scratches} lần. Cần cải thiện kiểm soát '
            'động lực và draw để tránh scratch.',
        priority: 4,
        category: 'cue_ball_control',
      ));
    }

    // Priority 5: Safety errors
    if (analysis.safetyErrors > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'SAFETY_PLAY',
        drillName: 'Luyện Safety Play',
        reason: 'Lỗi safety: ${analysis.safetyErrors} lần. Cần cải thiện kỹ '
            'năng chơi safety để giành lợi thế.',
        priority: 5,
        category: 'safety',
      ));
    }

    // Priority 6: Kick errors
    if (analysis.kickErrors > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'KICK_SHOTS',
        drillName: 'Luyện Kick Shots',
        reason: 'Lỗi kick: ${analysis.kickErrors} lần. Cần cải thiện kỹ thuật '
            'đánh bi đá để xử lý các tình huống khó.',
        priority: 6,
        category: 'advanced_shots',
      ));
    }

    // Priority 7: Fouls
    if (analysis.fouls > errorThreshold) {
      recommendations.add(DrillRecommendation(
        drillCode: 'FOUL_PREVENTION',
        drillName: 'Tránh Fouls',
        reason: 'Fouls: ${analysis.fouls} lần. Cần chú ý hơn khi đánh để '
            'tránh bị phạt.',
        priority: 7,
        category: 'game_sense',
      ));
    }

    // If no specific weaknesses, suggest based on general improvement
    if (recommendations.isEmpty && analysis.longestRun < 5) {
      recommendations.add(DrillRecommendation(
        drillCode: 'RUN_OUT_PRACTICE',
        drillName: 'Luyện Run Out',
        reason: 'Run dài nhất: ${analysis.longestRun} bi. Cần tập để cải thiện '
            'khả năng chạy bàn.',
        priority: 8,
        category: 'shot_making',
      ));
    }

    // Sort by priority
    recommendations.sort((a, b) => a.priority.compareTo(b.priority));

    return recommendations;
  }

  /// Get match summary for Coach Home display
  MatchAnalysisSummary getSummary(MatchAnalysis analysis) {
    return MatchAnalysisSummary(
      winRate: '${analysis.winRate.toStringAsFixed(0)}%',
      longestRun: analysis.longestRun,
      totalBalls: analysis.totalBallsPotted,
      topStrength: analysis.strengths.isNotEmpty ? analysis.strengths.first : null,
      topMistake: analysis.commonMistakes.isNotEmpty ? analysis.commonMistakes.first : null,
      recommendations: getRecommendations(analysis),
    );
  }

  /// Generate Coach AI insights from analysis
  String generateCoachInsight(MatchAnalysis analysis) {
    if (analysis.totalRacks == 0) {
      return 'Chưa có dữ liệu trận đấu để phân tích.';
    }

    final parts = <String>[];

    // Win rate
    if (analysis.winRate > 60) {
      parts.add('Tỷ lệ thắng ${analysis.winRate.toStringAsFixed(0)}% - Khá tốt!');
    } else if (analysis.winRate < 40) {
      parts.add('Tỷ lệ thắng ${analysis.winRate.toStringAsFixed(0)}% - Cần cải thiện thêm.');
    }

    // Longest run
    if (analysis.longestRun >= 5) {
      parts.add('Long run $analysis.longestRun bi - Ấn tượng!');
    }

    // Top weakness
    if (analysis.commonMistakes.isNotEmpty) {
      parts.add('Cần chú ý: ${analysis.commonMistakes.first}');
    }

    return parts.isNotEmpty ? parts.join(' ') : 'Trận đấu khá cân bằng.';
  }
}

/// Summary for Coach Home display
class MatchAnalysisSummary {
  final String winRate;
  final int longestRun;
  final int totalBalls;
  final String? topStrength;
  final String? topMistake;
  final List<DrillRecommendation> recommendations;

  const MatchAnalysisSummary({
    required this.winRate,
    required this.longestRun,
    required this.totalBalls,
    this.topStrength,
    this.topMistake,
    required this.recommendations,
  });
}
