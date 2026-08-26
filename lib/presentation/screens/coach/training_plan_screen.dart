import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_service.dart';
import '../../../core/services/coach_types.dart';

/// Training Plan Screen - Weekly Plan
/// Redesigned with Minimalist Luxury Design System
class TrainingPlanScreen extends ConsumerWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningPathAsync = ref.watch(learningPathProvider);
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Kế hoạch tuần này',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textSecondary(brightness)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đang cập nhật kế hoạch...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.accentColor(brightness),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekHeader(context, weekStart, brightness),
            const SizedBox(height: AppSpacing.xxl),
            _buildAISummary(context, brightness),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Lịch tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildDailyPlan(context, ref, weekStart, learningPathAsync, brightness),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context, DateTime weekStart, Brightness brightness) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(Icons.calendar_month, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tuần này',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    dateFormat,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _WeekStat(
                icon: Icons.fitness_center,
                value: '5',
                label: 'bài tập',
              ),
              const SizedBox(width: AppSpacing.xxl),
              _WeekStat(
                icon: Icons.timer,
                value: '2h',
                label: 'tổng thời gian',
              ),
              const SizedBox(width: AppSpacing.xxl),
              _WeekStat(
                icon: Icons.local_fire_department,
                value: '7',
                label: 'streak',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildAISummary(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentColor(brightness).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accentColor(brightness).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.accentColor(brightness), size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI nhận xét',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tuần này tập trung vào Position Control. Bạn đang tiến bộ tốt, hãy duy trì nhịp độ!',
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDailyPlan(
    BuildContext context,
    WidgetRef ref,
    DateTime weekStart,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
    Brightness brightness,
  ) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = DateTime.now().weekday - 1;
    final accentColor = AppColors.accentColor(brightness);

    final plan = [
      ['position', 'draw'],
      ['stop', 'knowledge'],
      ['follow', 'position'],
      ['safety', 'draw'],
      ['rest', null],
      ['position', 'follow'],
      ['test', null],
    ];

    return Column(
      children: List.generate(7, (index) {
        final isToday = index == today;
        final dayPlan = plan[index];
        final isRest = dayPlan[0] == 'rest';
        final isTest = dayPlan[0] == 'test';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isToday
                  ? accentColor.withValues(alpha: 0.05)
                  : AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isToday
                    ? accentColor
                    : AppColors.lightBorder,
                width: isToday ? 2 : 1,
              ),
              boxShadow: AppShadows.sm(brightness),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isToday
                        ? accentColor
                        : AppColors.background(brightness),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isToday ? Colors.white : AppColors.textSecondary(brightness),
                        ),
                      ),
                      Text(
                        '${weekStart.day + index}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textTertiary(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                Expanded(
                  child: isRest
                      ? Row(
                          children: [
                            Icon(
                              Icons.spa,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Nghỉ ngơi',
                              style: TextStyle(
                                color: AppColors.textSecondary(brightness),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : isTest
                          ? Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: AppColors.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Kiểm tra cuối tuần',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary(brightness),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dayPlan[0] != null)
                                  _PlanItem(
                                    icon: _getDrillIcon(dayPlan[0]!),
                                    label: _getDrillName(dayPlan[0]!),
                                    color: _getDrillColor(dayPlan[0]!),
                                  ),
                                if (dayPlan[1] != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  _PlanItem(
                                    icon: Icons.article,
                                    label: dayPlan[1] == 'knowledge'
                                        ? 'Đọc bài kiến thức'
                                        : _getDrillName(dayPlan[1]!),
                                    color: Colors.purple,
                                  ),
                                ],
                              ],
                            ),
                ),

                if (!isRest && !isTest)
                  IconButton(
                    icon: Icon(
                      isToday ? Icons.play_circle_filled : Icons.play_circle_outline,
                      color: isToday ? accentColor : AppColors.textTertiary(brightness),
                      size: 32,
                    ),
                    onPressed: () {
                      if (dayPlan[0] != null) {
                        context.push(
                          '/training/session/new?drill=${dayPlan[0]}&level=1',
                        );
                      }
                    },
                  ),
              ],
            ),
          ).animate().fadeIn(delay: (200 + index * 50).ms),
        );
      }),
    );
  }

  IconData _getDrillIcon(String drill) {
    switch (drill) {
      case 'position':
        return Icons.gps_fixed;
      case 'stop':
        return Icons.block;
      case 'draw':
        return Icons.arrow_back;
      case 'follow':
        return Icons.arrow_forward;
      case 'safety':
        return Icons.shield;
      default:
        return Icons.fitness_center;
    }
  }

  String _getDrillName(String drill) {
    switch (drill) {
      case 'position':
        return 'Position Control';
      case 'stop':
        return 'Stop Shot';
      case 'draw':
        return 'Draw Shot';
      case 'follow':
        return 'Follow Shot';
      case 'safety':
        return 'Safety Play';
      default:
        return drill;
    }
  }

  Color _getDrillColor(String drill) {
    switch (drill) {
      case 'position':
        return Colors.purple;
      case 'stop':
        return AppColors.warning;
      case 'draw':
        return Colors.blue;
      case 'follow':
        return AppColors.success;
      case 'safety':
        return Colors.teal;
      default:
        return AppColors.lightTextSecondary;
    }
  }
}

class _WeekStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeekStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PlanItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary(Theme.of(context).brightness),
          ),
        ),
      ],
    );
  }
}
