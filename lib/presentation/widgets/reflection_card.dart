import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Sprint 3A Task 3 — Reflection.
///
/// Three layered cards:
///   1. Immediate Progress (delta vs previous session, primary)
///   2. Personal Best (secondary)
///   3. Coaching Insight (placeholder, reserved for Sprint 3D)
class ReflectionCards extends StatelessWidget {
  final double accuracy;
  final double? previousAccuracy;
  final double? pb;
  final bool isFirstSession;

  const ReflectionCards({
    super.key,
    required this.accuracy,
    required this.previousAccuracy,
    required this.pb,
    required this.isFirstSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Layer 1: Immediate Progress.
        _ImmediateProgress(
          accuracy: accuracy,
          previousAccuracy: previousAccuracy,
          isFirstSession: isFirstSession,
        ),
        const SizedBox(height: 12),
        // Layer 2: Personal Best.
        _PersonalBest(
          accuracy: accuracy,
          pb: pb,
        ),
        const SizedBox(height: 12),
        // Layer 3: Coaching Insight placeholder for Sprint 3D.
        const _CoachInsightPlaceholder(),
      ],
    );
  }
}

class _ImmediateProgress extends StatelessWidget {
  final double accuracy;
  final double? previousAccuracy;
  final bool isFirstSession;

  const _ImmediateProgress({
    required this.accuracy,
    required this.previousAccuracy,
    required this.isFirstSession,
  });

  String _label() {
    if (isFirstSession) return 'Lần đầu tập drill này';
    if (previousAccuracy == null) return 'So với lần trước';
    return 'So với lần trước';
  }

  String _progressSubtitle() {
    if (isFirstSession) return 'PB đã đặt từ session này.';
    if (previousAccuracy == null) return 'Chưa có dữ liệu lần trước.';
    final delta = accuracy - previousAccuracy!;
    if (delta.abs() < 0.5) {
      return 'Gần như không đổi (${previousAccuracy!.toStringAsFixed(0)}% lần trước).';
    }
    final sign = delta > 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(0)}% so với ${previousAccuracy!.toStringAsFixed(0)}%.';
  }

  IconData _progressIcon() {
    if (isFirstSession) return Icons.fiber_new_outlined;
    if (previousAccuracy == null) return Icons.help_outline;
    final delta = accuracy - previousAccuracy!;
    if (delta.abs() < 0.5) return Icons.drag_handle;
    return delta > 0 ? Icons.trending_up : Icons.trending_down;
  }

  Color _progressColor() {
    if (isFirstSession) return AppTheme.primaryGreen;
    if (previousAccuracy == null) return AppTheme.textSecondary;
    final delta = accuracy - previousAccuracy!;
    if (delta.abs() < 0.5) return AppTheme.textSecondary;
    return delta > 0 ? AppTheme.primaryGreen : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _progressColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_progressIcon(), color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                _label(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Hôm nay',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${accuracy.toStringAsFixed(0)}%',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _progressSubtitle(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalBest extends StatelessWidget {
  final double accuracy;
  final double? pb;

  const _PersonalBest({required this.accuracy, required this.pb});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achieved = pb != null && accuracy >= pb!;
    final exceeded = pb != null && accuracy > pb!;

    String headline;
    String body;
    Color color;
    IconData icon;

    if (pb == null) {
      headline = 'Chưa có PB';
      body = 'PB sẽ tự thiết lập khi bạn có nhiều session hơn.';
      color = AppTheme.textSecondary;
      icon = Icons.flag_outlined;
    } else if (exceeded) {
      headline = 'PB MỚI!';
      body = 'PB: ${accuracy.toStringAsFixed(0)}% (trước đó ${pb!.toStringAsFixed(0)}%).';
      color = AppTheme.primaryGreen;
      icon = Icons.emoji_events;
    } else {
      final gap = pb! - accuracy;
      headline = 'PB hiện tại';
      body = '${pb!.toStringAsFixed(0)}% — còn ${gap.toStringAsFixed(0)}% để phá kỷ lục.';
      color = AppTheme.accentGold;
      icon = Icons.military_tech_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                headline,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (achieved && !exceeded)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Bạn đã chạm PB hôm nay.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoachInsightPlaceholder extends StatelessWidget {
  const _CoachInsightPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach Insight',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sẽ có ở Sprint 3D — gợi ý tập tiếp theo dựa trên hiệu suất của bạn.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}