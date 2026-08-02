import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_service.dart';

/// Training Plan Screen - Weekly Plan
class TrainingPlanScreen extends ConsumerWidget {
  const TrainingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningPathAsync = ref.watch(learningPathProvider);
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch tuần này'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh plan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang cập nhật kế hoạch...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Header
            _buildWeekHeader(context, weekStart),
            const SizedBox(height: 24),

            // AI Summary
            _buildAISummary(context),
            const SizedBox(height: 24),

            // Daily Plan
            Text(
              'Lịch tập',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            _buildDailyPlan(context, ref, weekStart, learningPathAsync),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
          const SizedBox(height: 16),
          Row(
            children: [
              _WeekStat(
                icon: Icons.fitness_center,
                value: '5',
                label: 'bài tập',
              ),
              const SizedBox(width: 24),
              _WeekStat(
                icon: Icons.timer,
                value: '2h',
                label: 'tổng thời gian',
              ),
              const SizedBox(width: 24),
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

  Widget _buildAISummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI nhận xét',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tuần này tập trung vào Position Control. Bạn đang tiến bộ tốt, hãy duy trì nhịp độ!',
                  style: TextStyle(
                    color: Colors.blue.shade700,
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
  ) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final today = DateTime.now().weekday - 1;

    // Demo plan
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
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.primaryGreen.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade200,
                width: isToday ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                // Day
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${weekStart.day + index}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: isRest
                      ? Row(
                          children: [
                            Icon(
                              Icons.spa,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nghỉ ngơi',
                              style: TextStyle(
                                color: Colors.grey.shade600,
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
                                  color: Colors.amber.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Kiểm tra cuối tuần',
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                                  const SizedBox(height: 8),
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

                // Action
                if (!isRest && !isTest)
                  IconButton(
                    icon: Icon(
                      isToday ? Icons.play_circle_filled : Icons.play_circle_outline,
                      color: isToday ? AppTheme.primaryGreen : Colors.grey.shade400,
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
        return Colors.orange;
      case 'draw':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'safety':
        return Colors.teal;
      default:
        return Colors.grey;
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
              style: const TextStyle(
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
