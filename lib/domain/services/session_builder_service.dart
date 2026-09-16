import '../../core/models/session_item.dart';
import '../../knowledge/knowledge_graph_service.dart' as kg;
import '../../core/providers/training_provider.dart';

/// Session Builder Service
///
/// Thuật toán chọn bài tập theo Dac-Ta-Man-Hinh-Buoi-Tap-Hom-Nay.md.
/// Gộp Mục 3 (Retest) + Mục 4 (Trình tạo buổi tập).
///
/// Các ngưỡng có thể tinh chỉnh trong config.
class SessionBuilderService {
  SessionBuilderService({required this._kg});

  final kg.KnowledgeGraphService _kg;

  // ── Config (tinh chỉnh sau) ────────────────────────────────────────────────

  /// Ngưỡng ngày cần retest theo difficulty tier của DrillNode
  static const Map<String, int> retestThresholds = {
    'beginner': 14,
    'intermediate': 21,
    'advanced': 30,
    'expert': 30,
  };

  /// Cho phép vượt thời gian tối đa bao nhiêu %
  static const double overflowAllowance = 0.15;

  /// Giới hạn bài retest trong 1 buổi
  static const int maxRetestPerSession = 2;

  /// Ngưỡng điểm yếu: chênh lệch % so với trung bình phải >= 20 mới coi là nổi bật
  static const int weaknessGapThreshold = 20;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Tạo buổi tập đề xuất cho [availableMinutes].
  ProposedSession buildSession({
    required int availableMinutes,
    required List<TrainingSession> trainingHistory,
    required List<String> completedDrillCodes,
  }) {
    final candidates = _collectCandidates(trainingHistory, completedDrillCodes);

    if (candidates.isEmpty) {
      final starter = _kg.getStarterDrill();
      if (starter != null) {
        return ProposedSession.fromItems([
          SessionItem(
            drillCode: starter.code,
            drillName: starter.nameVi,
            priority: SessionPriority.path,
            estimatedMinutes: starter.estimatedMinutes,
            reason: 'Đây là bước đầu tiên trong lộ trình học của bạn.',
          ),
        ]);
      }
      return ProposedSession.empty();
    }

    final sorted = _sortCandidates(candidates);
    final selected = _fillByTime(sorted, availableMinutes);
    return ProposedSession.fromItems(selected);
  }

  /// Thay thế 1 bài bị bỏ qua.
  List<SessionItem> skipItem({
    required List<SessionItem> currentItems,
    required String drillCodeToSkip,
    required int availableMinutes,
    required List<TrainingSession> trainingHistory,
    required List<String> completedDrillCodes,
  }) {
    final remaining = currentItems.where((i) => i.drillCode != drillCodeToSkip).toList();
    final currentTotal = remaining.fold(0, (sum, i) => sum + i.estimatedMinutes);
    final returnedTime = availableMinutes - currentTotal;

    final allCandidates = _collectCandidates(trainingHistory, completedDrillCodes);
    final sorted = _sortCandidates(allCandidates);

    for (final c in sorted) {
      if (currentItems.any((i) => i.drillCode == c.drillCode)) continue;
      if (c.estimatedMinutes <= returnedTime * (1 + overflowAllowance)) {
        return [...remaining, c];
      }
    }
    return remaining;
  }

  // ── Bước 1: Tập hợp ứng viên ───────────────────────────────────────────

  List<SessionItem> _collectCandidates(
    List<TrainingSession> history,
    List<String> completedCodes,
  ) {
    final candidates = <SessionItem>[];
    final seen = <String>{};

    for (final item in _buildRetestCandidates(history)) {
      if (!seen.contains(item.drillCode)) {
        candidates.add(item);
        seen.add(item.drillCode);
      }
    }
    for (final item in _buildWeaknessCandidates(history)) {
      if (!seen.contains(item.drillCode)) {
        candidates.add(item);
        seen.add(item.drillCode);
      }
    }
    final pathItem = _buildNextPathCandidate(completedCodes);
    if (pathItem != null && !seen.contains(pathItem.drillCode)) {
      candidates.add(pathItem);
    }
    return candidates;
  }

  List<SessionItem> _buildRetestCandidates(List<TrainingSession> history) {
    final items = <SessionItem>[];
    final today = DateTime.now();

    final latestByDrill = <String, TrainingSession>{};
    for (final s in history) {
      final ex = latestByDrill[s.drillCode];
      if (ex == null || s.date.isAfter(ex.date)) {
        latestByDrill[s.drillCode] = s;
      }
    }

    for (final entry in latestByDrill.entries) {
      final session = entry.value;
      final drill = _kg.getDrill(entry.key);
      if (drill == null) continue;

      final drillSessions = history.where((s) => s.drillCode == entry.key).toList();
      if (drillSessions.length < 2 && session.score < 70) continue;

      final threshold = retestThresholds[drill.difficulty.name] ?? 21;
      final daysSince = today.difference(session.date).inDays;

      if (daysSince >= threshold) {
        final urgency = daysSince - threshold;
        items.add(SessionItem(
          drillCode: drill.code,
          drillName: drill.nameVi,
          priority: SessionPriority.retest,
          estimatedMinutes: drill.estimatedMinutes,
          reason: 'Bạn chưa luyện bài này $daysSince ngày — nên ôn lại để giữ phong độ.',
          daysSinceLastPractice: daysSince,
          urgencyScore: urgency.toDouble(),
        ));
      }
    }

    items.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return items;
  }

  List<SessionItem> _buildWeaknessCandidates(List<TrainingSession> history) {
    final items = <SessionItem>[];

    final scoresByDrill = <String, List<int>>{};
    for (final s in history) {
      scoresByDrill.putIfAbsent(s.drillCode, () => []).add(s.score);
    }

    for (final entry in scoresByDrill.entries) {
      if (entry.value.length < 2) continue;

      final avg = entry.value.fold<int>(0, (sum, s) => sum + s) ~/ entry.value.length;
      final drill = _kg.getDrill(entry.key);
      if (drill == null) continue;

      if (avg < 70) {
        final gap = 70 - avg;
        if (gap >= weaknessGapThreshold) {
          items.add(SessionItem(
            drillCode: drill.code,
            drillName: drill.nameVi,
            priority: SessionPriority.weakness,
            estimatedMinutes: drill.estimatedMinutes,
            reason: 'Tỉ lệ thành công trung bình $avg% đang thấp hơn mức mong đợi.',
            urgencyScore: gap.toDouble(),
          ));
        }
      }
    }

    items.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    return items;
  }

  SessionItem? _buildNextPathCandidate(List<String> completedCodes) {
    final allDrills = _kg.getAllDrills();
    for (final drill in allDrills) {
      if (!completedCodes.contains(drill.code)) {
        return SessionItem(
          drillCode: drill.code,
          drillName: drill.nameVi,
          priority: SessionPriority.path,
          estimatedMinutes: drill.estimatedMinutes,
          reason: 'Đây là bước tiếp theo trong lộ trình học của bạn.',
          urgencyScore: 0,
        );
      }
    }
    return null;
  }

  // ── Bước 2: Sắp xếp ────────────────────────────────────────────────────

  List<SessionItem> _sortCandidates(List<SessionItem> candidates) {
    final retests = candidates.where((i) => i.priority == SessionPriority.retest).toList();
    final rest = candidates.where((i) => i.priority != SessionPriority.retest).toList();
    return [...retests.take(maxRetestPerSession), ...rest];
  }

  // ── Bước 3: Lấp đầy theo thời gian ────────────────────────────────────

  List<SessionItem> _fillByTime(List<SessionItem> candidates, int availableMinutes) {
    if (availableMinutes < 4) {
      return candidates.isNotEmpty ? [candidates.first] : [];
    }

    final selected = <SessionItem>[];
    var remaining = availableMinutes;

    for (final c in candidates) {
      final minutes = selected.isEmpty ? c.estimatedMinutes + 2 : c.estimatedMinutes;
      final maxAllowed = remaining * (1 + overflowAllowance);

      if (minutes <= maxAllowed) {
        selected.add(c);
        remaining -= c.estimatedMinutes;
      }
      if (remaining <= 2) break;
    }

    if (selected.isEmpty && candidates.isNotEmpty) {
      return [candidates.first];
    }
    return selected;
  }
}
