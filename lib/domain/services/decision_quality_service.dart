import '../../data/models/match.dart';

/// Decision-quality grade — grades each shot's intent vs outcome.
enum DecisionQuality { optimal, suboptimal, poor, unknown }

extension DecisionQualityLabel on DecisionQuality {
  String get label {
    switch (this) {
      case DecisionQuality.optimal:
        return 'Tối ưu';
      case DecisionQuality.suboptimal:
        return 'Chưa tối ưu';
      case DecisionQuality.poor:
        return 'Kém';
      case DecisionQuality.unknown:
        return 'Không rõ';
    }
  }
}

class ShotGrade {
  final String shotId;
  final DecisionQuality quality;
  final String note;
  const ShotGrade({
    required this.shotId,
    required this.quality,
    this.note = '',
  });
}

class DecisionQualityService {
  /// Grade each shot in a match.
  ///
  /// Heuristic for the offline version:
  ///   - made + safety/positional intent → optimal
  ///   - missed + safety intent → optimal (good decision, unlucky)
  ///   - missed + easy miss → poor
  ///   - missed + fouls → poor
  List<ShotGrade> grade(Match match) {
    final out = <ShotGrade>[];
    for (final rack in match.racks) {
      for (final s in rack.shots) {
        DecisionQuality q;
        String note;
        if (s.result == 'made') {
          q = DecisionQuality.optimal;
          note = 'Hoàn thành tốt.';
        } else if (s.result == 'foul' || s.result == 'scratch') {
          q = DecisionQuality.poor;
          note = 'Phạm lỗi — cần xem lại quy trình.';
        } else if (s.shotType.contains('easy')) {
          q = DecisionQuality.poor;
          note = 'Easy miss — sai điểm ngắm hoặc cơ chế.';
        } else {
          q = DecisionQuality.suboptimal;
          note = 'Shot khó thực hiện.';
        }
        out.add(ShotGrade(shotId: s.id, quality: q, note: note));
      }
    }
    return out;
  }

  /// Aggregate.
  Map<DecisionQuality, int> aggregate(List<ShotGrade> grades) {
    final m = <DecisionQuality, int>{
      DecisionQuality.optimal: 0,
      DecisionQuality.suboptimal: 0,
      DecisionQuality.poor: 0,
      DecisionQuality.unknown: 0,
    };
    for (final g in grades) {
      m[g.quality] = (m[g.quality] ?? 0) + 1;
    }
    return m;
  }
}