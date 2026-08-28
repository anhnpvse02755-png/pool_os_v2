import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/drill_session.dart';
import '../../../data/models/personal_best.dart';
import '../../../data/repositories/drill_session_repository.dart';
import '../../../data/repositories/personal_best_repository.dart';
import '../../widgets/reflection_card.dart';
import '../../widgets/next_action_panel.dart';

class DrillCompletionScreen extends ConsumerWidget {
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

  Future<_ReflectionData> _loadReflection(WidgetRef ref) async {
    final player = await ref.read(currentPlayerProvider.future);
    if (player == null) {
      return _ReflectionData(
        previousAccuracy: null,
        pb: null,
        isFirstSession: true,
        currentAccuracy: _accuracy,
      );
    }

    final sessionRepo = LocalDrillSessionRepository();
    final all = await sessionRepo.getAll(player.id);
    final drillSessions = all
        .where((s) =>
            s.id != session.id &&
            s.drillRuns.any((r) => r.drillCode == drillCode))
        .toList();
    double? previous;
    if (drillSessions.isNotEmpty) {
      previous = drillSessions.first.accuracy;
    }

    final pbRepo = LocalPersonalBestRepository();
    final pbs = await pbRepo.getForDrill(player.id, drillCode);
    final pb = pbs
        .where((p) => p.metric == PbMetric.highestAccuracy)
        .map<double?>((p) => p.value)
        .firstWhere((_) => true, orElse: () => null);

    return _ReflectionData(
      previousAccuracy: previous,
      pb: pb,
      isFirstSession: previous == null && pb == null,
      currentAccuracy: _accuracy,
    );
  }

  NextActionTone _resolveTone(_ReflectionData data) {
    if (data.isFirstSession) return NextActionTone.first;
    final prev = data.previousAccuracy;
    if (prev == null) return NextActionTone.stable;
    final delta = data.currentAccuracy - prev;
    if (delta > 0.5) return NextActionTone.improved;
    if (delta < -0.5) return NextActionTone.declined;
    return NextActionTone.stable;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final duration = Duration(minutes: session.totalMinutes);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Buổi tập hoàn thành'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/training');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Hero pass / fail indicator.
              _CompletionHero(
                passed: _passed,
                drillTitle: _drill?.nameVi ?? session.title,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: AppSpacing.xxl),

              // Stat cards.
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Thời gian',
                      value: '${duration.inMinutes}',
                      unit: 'phút',
                      icon: Icons.timer_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Lần đánh',
                      value: '${session.attempts.length}',
                      unit: 'lan',
                      icon: Icons.sports_esports_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Chính xác',
                      value: _accuracy.toStringAsFixed(0),
                      unit: '%',
                      icon: Icons.percent_outlined,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: 'Trượt',
                      value: '${session.totalShotsMissed}',
                      unit: 'lan',
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Pass-criteria line.
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: _passed
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: _passed
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _passed ? Icons.verified_outlined : Icons.info_outline,
                      color: _passed ? AppColors.success : AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _passed
                            ? 'Dat tieu chi ($_passThreshold lan thanh cong).'
                            : 'Chua dat - can $_passThreshold lan thanh cong de qua muc.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Reflection block
              FutureBuilder<_ReflectionData>(
                future: _loadReflection(ref),
                builder: (context, snapshot) {
                  final data = snapshot.data ??
                      _ReflectionData(
                        previousAccuracy: null,
                        pb: null,
                        isFirstSession: true,
                        currentAccuracy: _accuracy,
                      );
                  return ReflectionCards(
                    accuracy: _accuracy,
                    previousAccuracy: data.previousAccuracy,
                    pb: data.pb,
                    isFirstSession: data.isFirstSession,
                  ).animate().fadeIn(delay: 350.ms);
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Next Action
              FutureBuilder<_ReflectionData>(
                future: _loadReflection(ref),
                builder: (context, snapshot) {
                  final data = snapshot.data ??
                      _ReflectionData(
                        previousAccuracy: null,
                        pb: null,
                        isFirstSession: true,
                        currentAccuracy: _accuracy,
                      );
                  return NextActionPanel(
                    currentDrillCode: drillCode,
                    tone: _resolveTone(data),
                  ).animate().fadeIn(delay: 450.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionData {
  final double? previousAccuracy;
  final double? pb;
  final bool isFirstSession;
  final double currentAccuracy;

  const _ReflectionData({
    required this.previousAccuracy,
    required this.pb,
    required this.isFirstSession,
    required this.currentAccuracy,
  });
}

class _CompletionHero extends StatelessWidget {
  final bool passed;
  final String drillTitle;

  const _CompletionHero({required this.passed, required this.drillTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = passed ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events_outlined : Icons.flag_outlined,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            drillTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            passed ? 'Hoàn thành xuất sắc' : 'Hoàn thành, tiếp tục cố gắng',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
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
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
