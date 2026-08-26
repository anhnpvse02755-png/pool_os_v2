// ============================================================================
// COACH TIMELINE SCREEN - Phase 7B.3
// Recommendation History and Progress Story
// Redesigned with Minimalist Luxury Design System
//
// Coach remembers:
// - What was recommended
// - What user did
// - Results
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/training_provider.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_types.dart';
import '../../widgets/coach/explain_bottom_sheet.dart';
import '../training/drill_detail_screen.dart';

/// Timeline Entry
class TimelineEntry {
  final DateTime date;
  final TimelineEntryType type;
  final String title;
  final String? subtitle;
  final String? result;
  final String? drillCode;
  final bool completed;

  TimelineEntry({
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
    this.result,
    this.drillCode,
    this.completed = false,
  });
}

enum TimelineEntryType {
  recommendation,
  practice,
  match,
  coachAdvice,
  break_,
}

/// Coach Timeline Screen
class CoachTimelineScreen extends ConsumerWidget {
  const CoachTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingState = ref.watch(trainingNotifierProvider);
    final progressMap = ref.watch(allDrillProgressProvider);
    final brightness = Theme.of(context).brightness;

    final entries = _buildTimeline(trainingState, progressMap);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Lịch sử Coach',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(brightness)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: entries.isEmpty
          ? _buildEmptyState(context, brightness)
          : _buildTimelineList(context, entries, brightness),
    );
  }

  Widget _buildEmptyState(BuildContext context, Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textTertiary(brightness),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có lịch sử',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bắt đầu tập để Coach ghi lại tiến độ của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, List<TimelineEntry> entries, Brightness brightness) {
    final groupedEntries = _groupByDate(entries);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final dayEntries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context, date, brightness),
            const SizedBox(height: AppSpacing.md),

            ...dayEntries.asMap().entries.map((entry) {
              return _TimelineEntryCard(
                entry: entry.value,
                isFirst: entry.key == 0,
                isLast: entry.key == dayEntries.length - 1,
                brightness: brightness,
              ).animate().fadeIn(delay: Duration(milliseconds: entry.key * 100));
            }),

            const SizedBox(height: AppSpacing.xxl),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, Brightness brightness) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String label;
    if (dateOnly == today) {
      label = 'HÔM NAY';
    } else if (dateOnly == yesterday) {
      label = 'HÔM QUA';
    } else {
      label = _formatDate(date);
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.accentColor(brightness),
        letterSpacing: 1,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Map<DateTime, List<TimelineEntry>> _groupByDate(List<TimelineEntry> entries) {
    final grouped = <DateTime, List<TimelineEntry>>{};

    for (final entry in entries) {
      final dateOnly = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(entry);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  List<TimelineEntry> _buildTimeline(
    TrainingState trainingState,
    Map<String, SimpleDrillProgress> progressMap,
  ) {
    final entries = <TimelineEntry>[];

    for (final session in trainingState.sessions) {
      entries.add(TimelineEntry(
        date: session.date,
        type: TimelineEntryType.practice,
        title: session.drillName,
        subtitle: 'Đã tập',
        result: '${session.score}%',
        drillCode: session.drillCode,
        completed: session.score >= 70,
      ));
    }

    entries.sort((a, b) => b.date.compareTo(a.date));

    return entries.take(20).toList();
  }
}

class _TimelineEntryCard extends StatelessWidget {
  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final Brightness brightness;

  const _TimelineEntryCard({
    required this.entry,
    this.isFirst = false,
    this.isLast = false,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppColors.accentColor(brightness).withValues(alpha: 0.3),
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getIconColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getIconColor().withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.accentColor(brightness).withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: AppShadows.sm(brightness),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIcon(),
                        size: 20,
                        color: _getIconColor(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(brightness),
                          ),
                        ),
                      ),
                      if (entry.completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            entry.result ?? '',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      entry.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                  if (entry.drillCode != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondary(brightness),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(entry.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (entry.type) {
      case TimelineEntryType.recommendation:
        return Icons.lightbulb;
      case TimelineEntryType.practice:
        return Icons.pool;
      case TimelineEntryType.match:
        return Icons.emoji_events;
      case TimelineEntryType.coachAdvice:
        return Icons.psychology;
      case TimelineEntryType.break_:
        return Icons.hotel;
    }
  }

  Color _getIconColor() {
    switch (entry.type) {
      case TimelineEntryType.recommendation:
        return AppColors.gold;
      case TimelineEntryType.practice:
        return AppColors.accentColor(brightness);
      case TimelineEntryType.match:
        return Colors.purple;
      case TimelineEntryType.coachAdvice:
        return Colors.blue;
      case TimelineEntryType.break_:
        return AppColors.textTertiary(brightness);
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
