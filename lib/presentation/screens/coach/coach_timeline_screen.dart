// ============================================================================
// COACH TIMELINE SCREEN - Phase 7B.3
// Recommendation History and Progress Story
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
    final trainingState = ref.watch(trainingProvider);
    final progressMap = ref.watch(allDrillProgressProvider);

    // Build timeline from sessions
    final entries = _buildTimeline(trainingState, progressMap);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Coach'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: entries.isEmpty
          ? _buildEmptyState(context)
          : _buildTimelineList(context, entries),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu tập để Coach ghi lại tiến độ của bạn',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, List<TimelineEntry> entries) {
    // Group entries by date
    final groupedEntries = _groupByDate(entries);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final dayEntries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            _buildDateHeader(context, date),
            const SizedBox(height: 12),

            // Entries for this date
            ...dayEntries.asMap().entries.map((entry) {
              return _TimelineEntryCard(
                entry: entry.value,
                isFirst: entry.key == 0,
                isLast: entry.key == dayEntries.length - 1,
              ).animate().fadeIn(delay: Duration(milliseconds: entry.key * 100));
            }),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
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
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.bold,
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

    // Sort by date descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  List<TimelineEntry> _buildTimeline(
    TrainingState trainingState,
    Map<String, SimpleDrillProgress> progressMap,
  ) {
    final entries = <TimelineEntry>[];

    // Build from sessions
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

    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));

    return entries.take(20).toList();
  }
}

class _TimelineEntryCard extends StatelessWidget {
  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  const _TimelineEntryCard({
    required this.entry,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
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
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                      Icon(
                        _getIcon(),
                        size: 20,
                        color: _getIconColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
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
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.result ?? '',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      entry.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                  if (entry.drillCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(entry.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
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
        return AppTheme.accentGold;
      case TimelineEntryType.practice:
        return AppTheme.primaryGreen;
      case TimelineEntryType.match:
        return Colors.purple;
      case TimelineEntryType.coachAdvice:
        return Colors.blue;
      case TimelineEntryType.break_:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
