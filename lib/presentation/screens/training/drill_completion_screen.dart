import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';
import '../../../data/models/drill_session.dart';

/// Sprint 3A Task 2 — Completion Experience.
///
/// Reached from DrillSessionScreen after `_finishSession()` calls
/// `DrillSessionRecoveryService.complete()`. The user should perceive this
/// as a distinct state from the instructions view, not a state-flip on the
/// same screen.
class DrillCompletionScreen extends StatelessWidget {
  final DrillSession session;
  final String drillCode;

  const DrillCompletionScreen({
    super.key,
    required this.session,
    required this.drillCode,
  });

  Drill? get _drill => DrillLibrary.getDrill(drillCode);

  int get _passThreshold {
    final drill = _drill;
    if (drill == null || drill.levels.isEmpty) return 8;
    return drill.levels.first.passCount;
  }

  bool get _passed => session.totalShotsMade >= _passThreshold;

  double get _accuracy => session.accuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = Duration(minutes: session.totalMinutes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buổi tập hoàn thành'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop back to the DrillSessionScreen so the user can review
            // the instructions / start a fresh session without leaving
            // the training flow.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/training');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Hero pass / fail indicator.
              _CompletionHero(
                passed: _passed,
                drillTitle: _drill?.nameVi ?? session.title,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 24),

              // Stat cards.
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Thời gian',
                      value: '${duration.inMinutes}',
                      unit: 'phút',
                      icon: Icons.timer_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Lần đánh',
                      value: '${session.attempts.length}',
                      unit: 'lần',
                      icon: Icons.sports_esports_outlined,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Chính xác',
                      value: _accuracy.toStringAsFixed(0),
                      unit: '%',
                      icon: Icons.percent_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Trượt',
                      value: '${session.totalShotsMissed}',
                      unit: 'lần',
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Pass-criteria line.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _passed
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _passed ? Icons.verified_outlined : Icons.info_outline,
                      color: _passed ? AppTheme.primaryGreen : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _passed
                            ? 'Đạt tiêu chí ($_passThreshold lần thành công).'
                            : 'Chưa đạt — cần $_passThreshold lần thành công để qua mức.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const Spacer(),

              // Forward action placeholder. Task 4 will replace this with a
              // Recommendation-driven Next Action.
              FilledButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/training');
                  }
                },
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Tập lại'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionHero extends StatelessWidget {
  final bool passed;
  final String drillTitle;

  const _CompletionHero({required this.passed, required this.drillTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = passed ? AppTheme.primaryGreen : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.emoji_events_outlined : Icons.flag_outlined,
            size: 64,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            drillTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            passed ? 'Hoàn thành xuất sắc' : 'Hoàn thành, tiếp tục cố gắng',
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}