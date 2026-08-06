import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/drills_library.dart';

/// Sprint 3A Task 4 — Next Action (Forward Path).
///
/// This widget renders the offboarding panel of the Completion Experience.
/// It is *engine-agnostic*: the recommendation source is currently
/// `DrillLibrary.getRecommendedDrills()` (rule-based, accepted lock) but
/// the panel does not know that. Any source that returns `List<Drill>`
/// can drop in here without changing the Completion Experience surface.
///
/// Two primary options:
///   - Tập lại (Retry) — same drill.
///   - Thử drill khác (Next Drill) — recommended (filtered to exclude current).
class NextActionPanel extends StatelessWidget {
  final String currentDrillCode;
  final List<Drill> Function() recommendationsSource;
  final NextActionTone tone;

  const NextActionPanel({
    super.key,
    required this.currentDrillCode,
    required this.tone,
    this.recommendationsSource = DrillLibrary.getRecommendedDrills,
  });

  String get _narrative {
    switch (tone) {
      case NextActionTone.improved:
        return 'Đã tiến bộ — giờ thử drill tiếp theo nhé.';
      case NextActionTone.stable:
        return 'Giữ vững — tiếp tục phong độ.';
      case NextActionTone.declined:
        return 'Lần này chưa tốt — thử lại nhé.';
      case NextActionTone.first:
        return 'Lần đầu xong — sẵn sàng tập tiếp chưa?';
    }
  }

  Drill? _nextDrill() {
    final recs = recommendationsSource();
    if (recs.isEmpty) return null;
    final next = recs.firstWhere(
      (d) => d.code != currentDrillCode,
      orElse: () => recs.first,
    );
    return next.code == currentDrillCode ? null : next;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextDrill();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Narrative bridge (Layer 0 — copy only, no logic).
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _narrative,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
        // Primary action: Retry same drill.
        FilledButton.icon(
          onPressed: () =>
              context.push('/training/session/new?drill=$currentDrillCode'),
          icon: const Icon(Icons.replay_outlined),
          label: const Text('Tập lại'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        // Secondary action: Try a different drill.
        OutlinedButton.icon(
          onPressed: next == null
              ? null
              : () => context.push('/training/session/new?drill=${next.code}'),
          icon: const Icon(Icons.arrow_forward_outlined),
          label: Text(
            next == null ? 'Đã hết drill gợi ý' : 'Thử: ${next.nameVi}',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            foregroundColor: AppTheme.primaryGreen,
            side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
          ),
        ),
      ],
    );
  }
}

enum NextActionTone { improved, stable, declined, first }