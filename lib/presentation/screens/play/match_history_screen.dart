import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _demoMatches = [
    {
      'id': '1',
      'opponent': 'Nguyễn Văn A',
      'result': 'win',
      'score': '5-3',
      'gameType': '8-ball',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'duration': const Duration(minutes: 45),
    },
    {
      'id': '2',
      'opponent': 'Trần Văn B',
      'result': 'lose',
      'score': '3-5',
      'gameType': '8-ball',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'duration': const Duration(minutes: 52),
    },
    {
      'id': '3',
      'opponent': 'Lê Văn C',
      'result': 'win',
      'score': '5-2',
      'gameType': '9-ball',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'duration': const Duration(minutes: 38),
    },
    {
      'id': '4',
      'opponent': 'Phạm Văn D',
      'result': 'draw',
      'score': '4-4',
      'gameType': '8-ball',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'duration': const Duration(minutes: 60),
    },
    {
      'id': '5',
      'opponent': 'Hoàng Văn E',
      'result': 'win',
      'score': '5-1',
      'gameType': 'straight',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'duration': const Duration(minutes: 35),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMatches {
    if (_selectedFilter == 'all') return _demoMatches;
    return _demoMatches.where((m) => m['result'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đấu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Thắng'),
            Tab(text: 'Thua'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Summary
          _buildStatsSummary(),

          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Bộ lọc: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tất cả'),
                  selected: _selectedFilter == 'all',
                  onSelected: (_) => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('8-Ball'),
                  selected: _selectedFilter == '8-ball',
                  onSelected: (_) => setState(() => _selectedFilter = '8-ball'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('9-Ball'),
                  selected: _selectedFilter == '9-ball',
                  onSelected: (_) => setState(() => _selectedFilter = '9-ball'),
                ),
              ],
            ),
          ),

          // Match List
          Expanded(
            child: _filteredMatches.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMatches.length,
                    itemBuilder: (context, index) {
                      final match = _filteredMatches[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MatchCard(
                          match: match,
                          onTap: () => context.push('/play/match/${match['id']}'),
                        ).animate().fadeIn(delay: (index * 50).ms),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final wins = _demoMatches.where((m) => m['result'] == 'win').length;
    final losses = _demoMatches.where((m) => m['result'] == 'lose').length;
    final total = _demoMatches.length;
    final winRate = total > 0 ? (wins / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Trận', value: '$total'),
          Container(width: 1, height: 40, color: Colors.white30),
          _StatItem(label: 'Thắng', value: '$wins', color: Colors.lightGreenAccent),
          Container(width: 1, height: 40, color: Colors.white30),
          _StatItem(label: 'Thua', value: '$losses', color: Colors.redAccent),
          Container(width: 1, height: 40, color: Colors.white30),
          _StatItem(label: 'Win Rate', value: '$winRate%'),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có trận đấu nào',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu một trận đấu để xem lịch sử',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final result = match['result'] as String;
    final isWin = result == 'win';

    Color resultColor;
    IconData resultIcon;
    String resultText;

    switch (result) {
      case 'win':
        resultColor = Colors.green;
        resultIcon = Icons.emoji_events;
        resultText = 'Thắng';
        break;
      case 'lose':
        resultColor = Colors.red;
        resultIcon = Icons.close;
        resultText = 'Thua';
        break;
      default:
        resultColor = Colors.orange;
        resultIcon = Icons.remove;
        resultText = 'Hòa';
    }

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
        child: Row(
          children: [
            // Result indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(resultIcon, color: resultColor),
            ),
            const SizedBox(width: 16),

            // Match info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'vs ${match['opponent']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match['gameType'] as String,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        match['score'] as String,
                        style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(match['date'] as DateTime),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}p trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
