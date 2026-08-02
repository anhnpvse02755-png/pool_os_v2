import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  final List<Map<String, dynamic>> _demoHistory = [
    {
      'id': '1',
      'drillName': 'Stop Shot Lv1',
      'drillCode': 'STOP_LV1',
      'date': DateTime.now().subtract(const Duration(hours: 1)),
      'duration': const Duration(minutes: 15),
      'score': 85,
      'shotsAttempted': 20,
      'shotsMade': 17,
      'improvement': 5,
    },
    {
      'id': '2',
      'drillName': 'Draw Shot Lv2',
      'drillCode': 'DRAW_LV2',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'duration': const Duration(minutes: 20),
      'score': 72,
      'shotsAttempted': 25,
      'shotsMade': 18,
      'improvement': 3,
    },
    {
      'id': '3',
      'drillName': 'Position Control Lv1',
      'drillCode': 'POSITION_LV1',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'duration': const Duration(minutes: 25),
      'score': 68,
      'shotsAttempted': 15,
      'shotsMade': 10,
      'improvement': -2,
    },
    {
      'id': '4',
      'drillName': 'Follow Shot Lv1',
      'drillCode': 'FOLLOW_LV1',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      'duration': const Duration(minutes: 18),
      'score': 78,
      'shotsAttempted': 22,
      'shotsMade': 17,
      'improvement': 8,
    },
    {
      'id': '5',
      'drillName': 'Bank Shot Lv1',
      'drillCode': 'BANK_LV1',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'duration': const Duration(minutes: 30),
      'score': 55,
      'shotsAttempted': 20,
      'shotsMade': 11,
      'improvement': 0,
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    var result = _demoHistory;

    if (_selectedFilter != 'all') {
      result = result.where((h) => h['drillCode'].toString().startsWith(_selectedFilter)).toList();
    }

    if (_dateRange != null) {
      result = result.where((h) {
        final date = h['date'] as DateTime;
        return date.isAfter(_dateRange!.start) && date.isBefore(_dateRange!.end);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Summary Stats
          _buildSummaryStats(),

          // Filter chips
          _buildFilterChips(),

          // History List
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final history = _filteredHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(
                          history: history,
                          onTap: () => context.push('/training/history/${history['id']}'),
                        ).animate().fadeIn(delay: (index * 50).ms),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalSessions = _demoHistory.length;
    final totalMinutes = _demoHistory.fold<int>(
      0,
      (sum, h) => sum + (h['duration'] as Duration).inMinutes,
    );
    final avgScore = (_demoHistory.fold<int>(0, (sum, h) => sum + (h['score'] as int)) / totalSessions).round();
    final totalShots = _demoHistory.fold<int>(0, (sum, h) => sum + (h['shotsMade'] as int));

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
            value: '$totalSessions',
            label: 'Buổi tập',
            color: Colors.blue,
          ),
          _SummaryItem(
            icon: Icons.timer,
            value: '${totalMinutes}m',
            label: 'Tổng thời gian',
            color: Colors.orange,
          ),
          _SummaryItem(
            icon: Icons.star,
            value: '$avgScore%',
            label: 'Điểm TB',
            color: Colors.amber,
          ),
          _SummaryItem(
            icon: Icons.sports_cricket,
            value: '$totalShots',
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
  final Map<String, dynamic> history;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final score = history['score'] as int;
    final improvement = history['improvement'] as int;
    final shotsMade = history['shotsMade'] as int;
    final shotsAttempted = history['shotsAttempted'] as int;
    final accuracy = (shotsMade / shotsAttempted * 100).round();

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
                        history['drillName'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        _formatDate(history['date'] as DateTime),
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
                      '${history['duration'].inMinutes}m',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          color: _getScoreColor(score),
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
                  value: '$shotsMade/$shotsAttempted',
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Improve',
                  value: improvement >= 0 ? '+$improvement' : '$improvement',
                  color: improvement >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
