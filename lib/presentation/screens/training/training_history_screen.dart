import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('Lịch sử tập luyện'),
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
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('Lỗi: $error', textAlign: TextAlign.center),
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
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final session = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            label: 'Buổi tập',
            color: Colors.blue,
          ),
          _SummaryItem(
            icon: Icons.timer,
            value: '${stats['minutes']}m',
            label: 'Tổng thời gian',
            color: Colors.orange,
          ),
          _SummaryItem(
            icon: Icons.star,
            value: '${stats['avgScore']}%',
            label: 'Điểm TB',
            color: Colors.amber,
          ),
          _SummaryItem(
            icon: Icons.sports_cricket,
            value: '${stats['shots']}',
            label: 'Bi đánh',
            color: Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: _selectedFilter == 'all',
            onSelected: (_) => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Stop'),
            selected: _selectedFilter == 'STOP',
            onSelected: (_) => setState(() => _selectedFilter = 'STOP'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Draw'),
            selected: _selectedFilter == 'DRAW',
            onSelected: (_) => setState(() => _selectedFilter = 'DRAW'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Follow'),
            selected: _selectedFilter == 'FOLLOW',
            onSelected: (_) => setState(() => _selectedFilter = 'FOLLOW'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Position'),
            selected: _selectedFilter == 'POSITION',
            onSelected: (_) => setState(() => _selectedFilter = 'POSITION'),
          ),
          const SizedBox(width: 8),
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
          Icon(Icons.history, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử tập luyện',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu một bài tập để xem lịch sử',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/training/session/new'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu tập'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sắp xếp theo ngày'),
              subtitle: const Text('Mới nhất trước'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Sắp xếp theo điểm'),
              subtitle: const Text('Cao nhất trước'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Sắp xếp theo cải thiện'),
              subtitle: const Text('Tiến bộ nhiều nhất'),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
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
            color: Colors.grey.shade600,
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
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.drillName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatDate(session.completedAt),
                        style: TextStyle(
                          color: Colors.grey.shade500,
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
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(session.score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
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
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'Accuracy',
                  value: '$accuracy%',
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Shots',
                  value: '${session.shotsMade}/${session.shotsMade + session.shotsMissed}',
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Level',
                  value: '${session.level}',
                  color: Colors.purple,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
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
