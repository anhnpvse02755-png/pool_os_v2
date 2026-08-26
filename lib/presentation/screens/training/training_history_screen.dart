import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/training_session.dart';

class TrainingHistoryScreen extends ConsumerStatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  ConsumerState<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends ConsumerState<TrainingHistoryScreen> {
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  List<TrainingSession> _applyFilters(List<TrainingSession> history) {
    var result = history;

    if (_selectedFilter != 'all') {
      result = result.where((h) => h.drillCode.startsWith(_selectedFilter)).toList();
    }

    if (_dateRange != null) {
      result = result.where((h) {
        return h.completedAt.isAfter(_dateRange!.start) &&
               h.completedAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return result;
  }

  Map<String, dynamic> _computeStats(List<TrainingSession> history) {
    if (history.isEmpty) {
      return {'sessions': 0, 'minutes': 0, 'avgScore': 0, 'shots': 0};
    }
    final totalSessions = history.length;
    final totalMinutes = history.fold<int>(0, (sum, h) => sum + h.duration);
    final avgScore = history.fold<int>(0, (sum, h) => sum + h.score) ~/ totalSessions;
    final totalShots = history.fold<int>(0, (sum, h) => sum + h.shotsMade);

    return {
      'sessions': totalSessions,
      'minutes': totalMinutes,
      'avgScore': avgScore,
      'shots': totalShots,
    };
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(trainingHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Lich su tap luyen'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text('Loi: $error', textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (history) {
          final filtered = _applyFilters(history);
          final stats = _computeStats(history);

          return Column(
            children: [
              // Summary Stats
              _buildSummaryStats(stats),

              // Filter chips
              _buildFilterChips(),

              // History List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final session = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _HistoryCard(
                              session: session,
                              onTap: () => context.push('/training/session/${session.id}'),
                            ).animate().fadeIn(delay: (index * 50).ms),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryStats(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            icon: Icons.fitness_center,
            value: '${stats['sessions']}',
            label: 'Buoi tap',
            color: AppColors.accent,
          ),
          _SummaryItem(
            icon: Icons.timer,
            value: '${stats['minutes']}m',
            label: 'Tong thoi gian',
            color: AppColors.warning,
          ),
          _SummaryItem(
            icon: Icons.star,
            value: '${stats['avgScore']}%',
            label: 'Diem TB',
            color: AppColors.gold,
          ),
          _SummaryItem(
            icon: Icons.sports_cricket,
            value: '${stats['shots']}',
            label: 'Bi danh',
            color: AppColors.success,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tat ca'),
            selected: _selectedFilter == 'all',
            onSelected: (_) => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Stop'),
            selected: _selectedFilter == 'STOP',
            onSelected: (_) => setState(() => _selectedFilter = 'STOP'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Draw'),
            selected: _selectedFilter == 'DRAW',
            onSelected: (_) => setState(() => _selectedFilter = 'DRAW'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Follow'),
            selected: _selectedFilter == 'FOLLOW',
            onSelected: (_) => setState(() => _selectedFilter = 'FOLLOW'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Position'),
            selected: _selectedFilter == 'POSITION',
            onSelected: (_) => setState(() => _selectedFilter = 'POSITION'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Bank'),
            selected: _selectedFilter == 'BANK',
            onSelected: (_) => setState(() => _selectedFilter = 'BANK'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.lightTextTertiary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chua co lich su tap luyen',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bat dau mot bai tap de xem lich su',
            style: TextStyle(
              color: AppColors.lightTextTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _PrimaryButton(
            onPressed: () => context.push('/training/session/new'),
            label: 'Bat dau tap',
            icon: Icons.play_arrow,
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bo loc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sap xep theo ngay'),
              subtitle: const Text('Moi nhat truoc'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Sap xep theo diem'),
              subtitle: const Text('Cao nhat truoc'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Sap xep theo cai thien'),
              subtitle: const Text('Tien bo nhieu nhat'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TrainingSession session;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.session,
    required this.onTap,
  });

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h truoc';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngay truoc';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = session.shotsMade + session.shotsMissed > 0
        ? (session.shotsMade * 100 / (session.shotsMade + session.shotsMissed)).round()
        : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.drillName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightTextPrimary),
                      ),
                      Text(
                        _formatDate(session.completedAt),
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${session.duration}m',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _getScoreColor(session.score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '${session.score}%',
                        style: TextStyle(
                          color: _getScoreColor(session.score),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatChip(
                  label: 'Accuracy',
                  value: '$accuracy%',
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Shots',
                  value: '${session.shotsMade}/${session.shotsMade + session.shotsMissed}',
                  color: const Color(0xFF14B8A6),
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Level',
                  value: '${session.level}',
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  const _PrimaryButton({required this.onPressed, required this.label, this.icon});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
