import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_service.dart';
import '../../../core/services/coach_types.dart';

/// PoolOS Analysis/Progress Screen - Redesigned with Minimalist Luxury
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final summaryAsync = ref.watch(performanceSummaryProvider);
    final weaknessesAsync = ref.watch(weaknessAnalysisProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background(brightness),
              elevation: 0,
              title: Text(
                'Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Overview Card
                  summaryAsync.when(
                    data: (summary) => _OverviewCard(
                      summary: summary,
                      brightness: brightness,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Stats Row
                  summaryAsync.when(
                    data: (summary) => _StatsRow(
                      summary: summary,
                      brightness: brightness,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Weaknesses Section
                  weaknessesAsync.when(
                    data: (weaknesses) => _WeaknessesSection(
                      weaknesses: weaknesses,
                      brightness: brightness,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Recommendations Section
                  summaryAsync.when(
                    data: (summary) => _RecommendationsSection(
                      summary: summary,
                      brightness: brightness,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 100), // Bottom nav spacing
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overview Card with Gradient
class _OverviewCard extends StatelessWidget {
  final PerformanceSummary summary;
  final Brightness brightness;

  const _OverviewCard({
    required this.summary,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.space2),
              const Text(
                'Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),

          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Sessions',
                  value: '${summary.totalSessions}',
                  brightness: brightness,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Shots',
                  value: '${summary.totalShots}',
                  brightness: brightness,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Accuracy',
                  value: '${summary.overallAccuracy}%',
                  brightness: brightness,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

/// Overview Stat
class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Brightness brightness;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Stats Row
class _StatsRow extends StatelessWidget {
  final PerformanceSummary summary;
  final Brightness brightness;

  const _StatsRow({
    required this.summary,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer,
            value: '${summary.totalMinutes}m',
            label: 'Total Time',
            color: AppColors.accentColor(brightness),
            brightness: brightness,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            value: '${summary.totalSessions}',
            label: 'Sessions',
            color: AppColors.success,
            brightness: brightness,
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: _StatCard(
            icon: Icons.track_changes,
            value: '${summary.weakestDrill?.rate ?? 0}%',
            label: 'Needs Work',
            color: AppColors.warning,
            brightness: brightness,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Brightness brightness;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.space2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Weaknesses Section
class _WeaknessesSection extends StatelessWidget {
  final List<WeaknessAnalysis> weaknesses;
  final Brightness brightness;

  const _WeaknessesSection({
    required this.weaknesses,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_down, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.space2),
            Text(
              'AREAS TO IMPROVE',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),

        if (weaknesses.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.space4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: AppShadows.sm(brightness),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Text(
                    'Great job! No weaknesses detected.',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...weaknesses.take(3).map((w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: _WeaknessCard(
                weakness: w,
                brightness: brightness,
              ),
            );
          }),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

/// Weakness Card
class _WeaknessCard extends StatelessWidget {
  final WeaknessAnalysis weakness;
  final Brightness brightness;

  const _WeaknessCard({
    required this.weakness,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                  vertical: AppSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${weakness.currentRate}%',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  weakness.drillName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            weakness.suggestion,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Recommendations Section
class _RecommendationsSection extends StatelessWidget {
  final PerformanceSummary summary;
  final Brightness brightness;

  const _RecommendationsSection({
    required this.summary,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDATIONS',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(Icons.auto_awesome, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus on ${summary.weakestDrill?.name ?? "aiming drills"}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(brightness),
                          ),
                        ),
                        Text(
                          summary.weakestDrill != null ? 'Practice more to improve' : 'Keep practicing!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
}
