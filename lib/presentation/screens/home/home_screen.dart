import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/services/coach_service.dart';
import '../../../core/services/coach_types.dart';
import '../../../knowledge/drill_code_bridge.dart';

/// PoolOS Home Screen - Redesigned with Minimalist Luxury
/// Trả lời: "Hôm nay tôi nên làm gì?"
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final learningPathAsync = ref.watch(learningPathProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and logo
              _buildHeader(context, brightness),
              const SizedBox(height: AppSpacing.space6),

              // Context-based content
              _buildContextContent(context, ref, dashboardState, learningPathAsync, brightness),
              const SizedBox(height: AppSpacing.space6),

              // Today's Goal
              _buildTodayGoalSection(context, ref, brightness),
              const SizedBox(height: AppSpacing.space6),

              // Progress Section
              _buildProgressSection(context, ref, brightness),
              const SizedBox(height: AppSpacing.space6),

              // Quick Actions
              _buildQuickActionsSection(context, ref, learningPathAsync, brightness),
              const SizedBox(height: 100), // Bottom nav spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);
    final accentColor = AppColors.accentColor(brightness);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'PoolOS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Profile avatar
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle(brightness),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: accentColor,
              size: 24,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildContextContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState dashboardState,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
    Brightness brightness,
  ) {
    switch (dashboardState.context) {
      case DashboardContext.afterMatch:
        return _buildAfterMatchCard(context, ref, dashboardState, brightness);
      case DashboardContext.afterDrill:
        return _buildAfterDrillCard(context, ref, dashboardState, brightness);
      case DashboardContext.afterKnowledge:
        return _buildAfterKnowledgeCard(context, ref, dashboardState, brightness);
      case DashboardContext.streakWarning:
        return _buildStreakWarningCard(context, ref, brightness);
      case DashboardContext.normal:
      default:
        return _buildAICoachSection(context, ref, learningPathAsync, brightness);
    }
  }

  /// AI Coach Section - Primary CTA
  Widget _buildAICoachSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
    Brightness brightness,
  ) {
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      width: double.infinity,
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
          // AI Coach header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              const Text(
                'AI Coach',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),

          // Greeting message
          Text(
            _getCoachGreeting(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),

          // Today's recommended drill
          learningPathAsync.when(
            data: (path) {
              if (path.isEmpty) {
                return _buildEmptyRecommendations(brightness);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's recommended:",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  ...path.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_right,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.drillNameVi,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => _buildEmptyRecommendations(brightness),
          ),

          const SizedBox(height: AppSpacing.space5),

          // Start Training button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final path = learningPathAsync.valueOrNull;
                if (path != null && path.isNotEmpty) {
                  final first = path.first;
                  final resolvedCode = resolveDrillCode(first.drillCode) ?? first.drillCode;
                  context.push(
                    '/training/session/new?drill=$resolvedCode&level=1&target=10',
                  );
                } else {
                  context.go('/training');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Training',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  /// Context: Sau khi chơi Match
  Widget _buildAfterMatchCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    Brightness brightness,
  ) {
    final missAnalysis = state.missAnalysis ?? {};
    final totalMisses = missAnalysis.values.fold(0, (a, b) => a + b);
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_score, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Match Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You had $totalMisses misses. Want to improve?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/training'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade600,
              elevation: 0,
            ),
            child: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  /// Context: Sau khi tập Drill
  Widget _buildAfterDrillCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    Brightness brightness,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                'Session Complete!',
                style: TextStyle(
                  color: AppColors.textPrimary(brightness),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Great work on your training!',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go('/training'),
            child: const Text('Continue Training'),
          ),
        ],
      ),
    );
  }

  /// Context: Sau khi đọc Knowledge
  Widget _buildAfterKnowledgeCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    Brightness brightness,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: AppColors.accentColor(brightness), size: 20),
              const SizedBox(width: 8),
              Text(
                'Knowledge Acquired!',
                style: TextStyle(
                  color: AppColors.textPrimary(brightness),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Great job learning! Ready to practice?',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/training'),
            child: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  /// Context: Streak Warning
  Widget _buildStreakWarningCard(
    BuildContext context,
    WidgetRef ref,
    Brightness brightness,
  ) {
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning,
            AppColors.warningLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Keep your streak!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Train today to maintain your streak.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go('/training'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.warning,
              elevation: 0,
            ),
            child: const Text('Train'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommendations(Brightness brightness) {
    return Text(
      'Start your training journey today!',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 14,
      ),
    );
  }

  /// Today's Goal Section
  Widget _buildTodayGoalSection(BuildContext context, WidgetRef ref, Brightness brightness) {
    final goals = ref.watch(todayGoalsProvider);
    final learningPathAsync = ref.watch(learningPathProvider);

    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);

    void goToTraining() {
      final path = learningPathAsync.valueOrNull;
      if (path != null && path.isNotEmpty) {
        final first = path.first;
        final resolvedCode = resolveDrillCode(first.drillCode) ?? first.drillCode;
        context.push('/training/session/new?drill=$resolvedCode&level=1&target=10');
      } else {
        context.go('/training/drills');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          "TODAY'S GOAL",
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        // Goals card
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              // Training goal
              _GoalRow(
                icon: Icons.fitness_center,
                label: '${goals.drillsCompleted}/${goals.drillsTarget} drills',
                isDone: goals.drillsCompleted >= goals.drillsTarget,
                onTap: goals.drillsCompleted < goals.drillsTarget ? goToTraining : null,
                brightness: brightness,
              ),
              Divider(color: AppColors.border(brightness)),
              // Knowledge goal
              _GoalRow(
                icon: Icons.article,
                label: 'Read knowledge article',
                isDone: goals.knowledgeRead,
                onTap: goals.knowledgeRead ? null : () => context.push('/training/knowledge'),
                brightness: brightness,
              ),
              Divider(color: AppColors.border(brightness)),
              // Test goal
              _GoalRow(
                icon: Icons.quiz,
                label: 'Pass Level Test',
                isDone: goals.testPassed,
                onTap: goals.testPassed ? null : () => context.push('/training/assessment'),
                brightness: brightness,
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  /// Progress Section
  Widget _buildProgressSection(BuildContext context, WidgetRef ref, Brightness brightness) {
    final goals = ref.watch(todayGoalsProvider);

    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);
    final accentColor = AppColors.accentColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'YOUR STATS',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/coach/analysis'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),

        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: '${goals.drillsCompleted + 127}', // Example data
                label: 'Sessions',
                brightness: brightness,
              ),
              Container(width: 1, height: 40, color: AppColors.border(brightness)),
              _StatItem(
                value: '72%',
                label: 'Accuracy',
                brightness: brightness,
              ),
              Container(width: 1, height: 40, color: AppColors.border(brightness)),
              _StatItem(
                value: '8',
                label: 'Day Streak',
                brightness: brightness,
                valueColor: AppColors.gold,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  /// Quick Actions Section
  Widget _buildQuickActionsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
    Brightness brightness,
  ) {
    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);
    final accentColor = AppColors.accentColor(brightness);

    void goToTraining() {
      final path = learningPathAsync.valueOrNull;
      if (path != null && path.isNotEmpty) {
        final first = path.first;
        final resolvedCode = resolveDrillCode(first.drillCode) ?? first.drillCode;
        context.push('/training/session/new?drill=$resolvedCode&level=1&target=10');
      } else {
        context.go('/training');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.play_arrow,
                label: 'Start Training Session',
                onTap: goToTraining,
                brightness: brightness,
              ),
              Divider(color: AppColors.border(brightness), height: 1),
              _ActionRow(
                icon: Icons.history,
                label: 'View Training History',
                onTap: () => context.push('/training/history'),
                brightness: brightness,
              ),
              Divider(color: AppColors.border(brightness), height: 1),
              _ActionRow(
                icon: Icons.emoji_events,
                label: 'Daily Challenge',
                onTap: () => context.go('/training'),
                brightness: brightness,
                badge: 'New',
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  String _getCoachGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning! Let's start with some aiming drills.";
    } else if (hour < 18) {
      return "Afternoon practice makes perfect. Ready for a session?";
    } else {
      return "Evening wind-down session? Let's keep the streak going!";
    }
  }
}

/// Goal Row Widget
class _GoalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final VoidCallback? onTap;
  final Brightness brightness;
  final bool isSpecial;

  const _GoalRow({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.brightness,
    this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);
    final accentColor = AppColors.accentColor(brightness);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.successSubtleLight
                    : AppColors.accentSubtle(brightness),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDone ? Icons.check : icon,
                color: isDone ? AppColors.success : accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDone ? textSecondary : textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (isSpecial && !isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Suggested',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isDone)
              Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else if (onTap != null)
              Icon(Icons.chevron_right, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Brightness brightness;
  final Color? valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.brightness,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: valueColor ?? textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Action Row Widget
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Brightness brightness;
  final String? badge;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.brightness,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(brightness);
    final textSecondary = AppColors.textSecondary(brightness);
    final accentColor = AppColors.accentColor(brightness);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
