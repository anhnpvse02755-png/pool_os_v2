import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  String _selectedGoal = 'all';
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _recommendations = [
    {
      'type': 'personalized',
      'title': 'Cải thiện Draw Shot',
      'subtitle': 'Dựa trên phong cách chơi của bạn',
      'reason': 'Bạn có xu hướng đánh mạnh. Hãy tập trung vào kiểm soát lực.',
      'drills': [
        {'name': 'Draw Shot Lv1', 'duration': '15 phút', 'difficulty': 'Dễ'},
        {'name': 'Draw Shot Lv2', 'duration': '20 phút', 'difficulty': 'Trung bình'},
      ],
      'progress': 0.4,
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
    {
      'type': 'weakness',
      'title': 'Position Play yếu',
      'subtitle': 'Điểm cần cải thiện',
      'reason': 'Tỷ lệ kiểm soát vị trí của bạn thấp hơn mức trung bình.',
      'drills': [
        {'name': 'Position Control Lv1', 'duration': '25 phút', 'difficulty': 'Trung bình'},
        {'name': 'Position Control Lv2', 'duration': '30 phút', 'difficulty': 'Khó'},
      ],
      'progress': 0.25,
      'icon': Icons.gps_fixed,
      'color': Colors.blue,
    },
    {
      'type': 'challenge',
      'title': 'Thử thách: Bank Shot',
      'subtitle': 'Nâng cao kỹ năng',
      'reason': 'Bạn chưa tập Bank Shot. Đây là kỹ năng quan trọng.',
      'drills': [
        {'name': 'Bank Shot Lv1', 'duration': '20 phút', 'difficulty': 'Trung bình'},
        {'name': 'Bank Shot Lv2', 'duration': '25 phút', 'difficulty': 'Khó'},
      ],
      'progress': 0.0,
      'icon': Icons.shield,
      'color': Colors.purple,
    },
    {
      'type': 'maintenance',
      'title': 'Ôn tập: Stop Shot',
      'subtitle': 'Duy trì kỹ năng',
      'reason': 'Đã 3 ngày không tập Stop Shot. Hãy ôn lại để duy trì.',
      'drills': [
        {'name': 'Stop Shot Lv1', 'duration': '10 phút', 'difficulty': 'Dễ'},
        {'name': 'Stop Shot Lv2', 'duration': '15 phút', 'difficulty': 'Trung bình'},
      ],
      'progress': 0.75,
      'icon': Icons.refresh,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI đề xuất'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Goal Filter
          _buildGoalFilter(),

          // PageView
          Expanded(
            child: PageView.builder(
              itemCount: _getFilteredRecommendations().length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final rec = _getFilteredRecommendations()[index];
                return _RecommendationCard(
                  recommendation: rec,
                  onStartDrill: (drill) {
                    context.push('/training/session/new?drill=$drill');
                  },
                ).animate().fadeIn();
              },
            ),
          ),

          // Page Indicator
          _buildPageIndicator(),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRecommendations() {
    if (_selectedGoal == 'all') return _recommendations;
    return _recommendations.where((r) => r['type'] == _selectedGoal).toList();
  }

  Widget _buildGoalFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _GoalChip(
              label: 'Tất cả',
              isSelected: _selectedGoal == 'all',
              onTap: () => setState(() => _selectedGoal = 'all'),
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Cá nhân hóa',
              isSelected: _selectedGoal == 'personalized',
              onTap: () => setState(() => _selectedGoal = 'personalized'),
              icon: Icons.person,
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Điểm yếu',
              isSelected: _selectedGoal == 'weakness',
              onTap: () => setState(() => _selectedGoal = 'weakness'),
              icon: Icons.trending_down,
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Thử thách',
              isSelected: _selectedGoal == 'challenge',
              onTap: () => setState(() => _selectedGoal = 'challenge'),
              icon: Icons.emoji_events,
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Ôn tập',
              isSelected: _selectedGoal == 'maintenance',
              onTap: () => setState(() => _selectedGoal = 'maintenance'),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final filtered = _getFilteredRecommendations();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          filtered.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentIndex
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/training/assessment'),
                icon: const Icon(Icons.psychology),
                label: const Text('Đánh giá lại'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final filtered = _getFilteredRecommendations();
                  if (filtered.isNotEmpty) {
                    final rec = filtered[_currentIndex];
                    final drills = rec['drills'] as List;
                    if (drills.isNotEmpty) {
                      final drillCode = _getDrillCode(drills[0]['name'] as String);
                      context.push('/training/session/new?drill=$drillCode');
                    }
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDrillCode(String drillName) {
    final name = drillName.toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    return name;
  }

  void _refreshRecommendations() {
    setState(() {
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã làm mới đề xuất'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryGreen,
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final Function(String) onStartDrill;

  const _RecommendationCard({
    required this.recommendation,
    required this.onStartDrill,
  });

  @override
  Widget build(BuildContext context) {
    final drills = recommendation['drills'] as List;
    final color = recommendation['color'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recommendation['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation['subtitle'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 20),

          // Reason
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân tích AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendation['reason'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 20),

          // Progress
          if (recommendation['progress'] > 0) ...[
            Text(
              'Tiến độ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: recommendation['progress'] as double,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${((recommendation['progress'] as double) * 100).round()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Drills
          Text(
            'Bài tập đề xuất',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...drills.asMap().entries.map((entry) {
            final index = entry.key;
            final drill = entry.value as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DrillCard(
                name: drill['name'] as String,
                duration: drill['duration'] as String,
                difficulty: drill['difficulty'] as String,
                color: color,
                onStart: () => onStartDrill(drill['name'] as String),
              ).animate().fadeIn(delay: (150 + index * 50).ms),
            );
          }),
        ],
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  final String name;
  final String duration;
  final String difficulty;
  final Color color;
  final VoidCallback onStart;

  const _DrillCard({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.color,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fitness_center, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(difficulty),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_circle, color: color, size: 32),
            onPressed: onStart,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return Colors.green;
      case 'Trung bình':
        return Colors.orange;
      case 'Khó':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
