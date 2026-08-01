import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';

class TrainingCenterScreen extends StatelessWidget {
  const TrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () => context.push('/training/assessment'),
            tooltip: 'Đánh giá kỹ năng',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildSectionTitle(context, 'Bắt đầu tập'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.play_arrow,
                    title: 'Tập nhanh',
                    subtitle: 'Chọn bài tập',
                    color: AppTheme.primaryGreen,
                    onTap: () => context.push('/training/drills'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.auto_awesome,
                    title: 'AI đề xuất',
                    subtitle: 'Bài tập phù hợp',
                    color: AppTheme.accentGold,
                    onTap: () => context.push('/training/recommended'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Today's Training
            _buildSectionTitle(context, 'Bài tập hôm nay'),
            const SizedBox(height: 12),
            _TodayTrainingCard(
              onStart: () => context.push('/training/session/active'),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // Drill Categories
            _buildSectionTitle(context, 'Thư viện bài tập'),
            const SizedBox(height: 12),
            ...DrillLibrary.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DrillCategoryCard(
                  category: category,
                  onTap: () => context.push('/training/drills/${category.id}'),
                ).animate().fadeIn(delay: 200.ms),
              );
            }),

            const SizedBox(height: 24),

            // Recent Sessions
            _buildSectionTitle(
              context,
              'Buổi tập gần đây',
              action: TextButton(
                onPressed: () => context.push('/training/history'),
                child: const Text('Xem tất cả'),
              ),
            ),
            const SizedBox(height: 12),
            _RecentSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (action != null) action,
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTrainingCard extends StatelessWidget {
  final VoidCallback onStart;

  const _TodayTrainingCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    // Placeholder data - sẽ lấy từ Coach AI
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.today, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bài tập hôm nay',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Draw Shot & Position',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              _TrainingStat(label: 'Bài tập', value: '3'),
              SizedBox(width: 24),
              _TrainingStat(label: 'Ước tính', value: '25 phút'),
              SizedBox(width: 24),
              _TrainingStat(label: 'Mục tiêu', value: '90%'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Bắt đầu tập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingStat extends StatelessWidget {
  final String label;
  final String value;

  const _TrainingStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _DrillCategoryCard extends StatelessWidget {
  final DrillCategory category;
  final VoidCallback onTap;

  const _DrillCategoryCard({
    required this.category,
    required this.onTap,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'sports':
        return Icons.sports;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'shield':
        return Icons.shield;
      case 'flash_on':
        return Icons.flash_on;
      case 'star':
        return Icons.star;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(category.icon),
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${category.drills.length} bài tập',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder - sẽ load từ database
    return Column(
      children: [
        _RecentSessionItem(
          date: 'Hôm nay, 14:30',
          title: 'Draw Shot Practice',
          stats: '10 reps • 80% success',
        ),
        const SizedBox(height: 8),
        _RecentSessionItem(
          date: 'Hôm qua, 18:45',
          title: 'Position Control',
          stats: '15 reps • 73% success',
        ),
        const SizedBox(height: 8),
        _RecentSessionItem(
          date: '01/08/2026',
          title: 'Straight Pot',
          stats: '20 reps • 95% success',
        ),
      ],
    );
  }
}

class _RecentSessionItem extends StatelessWidget {
  final String date;
  final String title;
  final String stats;

  const _RecentSessionItem({
    required this.date,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  stats,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
