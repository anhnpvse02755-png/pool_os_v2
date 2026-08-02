import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/training_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(performanceSummaryProvider);
    final progressAsync = ref.watch(allDrillProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến độ của bạn'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            summaryAsync.when(
              data: (summary) => _SummaryCard(summary: summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Progress by Category
            Text(
              'Tiến độ theo danh mục',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            progressAsync.when(
              data: (progress) => _buildCategoryProgress(context, progress),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Hoạt động gần đây',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            progressAsync.when(
              data: (progress) => _buildRecentActivity(context, progress),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, List<dynamic> progress) {
    // Group by category
    final categories = <String, List<dynamic>>{};
    for (final p in progress) {
      // TODO: Group by category
    }

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
      child: Column(
        children: [
          _CategoryProgressRow(
            category: 'Potting',
            icon: Icons.center_focus_strong,
            color: Colors.blue,
            progress: 0.6,
          ),
          const Divider(),
          _CategoryProgressRow(
            category: 'Cue Ball',
            icon: Icons.circle_outlined,
            color: Colors.orange,
            progress: 0.4,
          ),
          const Divider(),
          _CategoryProgressRow(
            category: 'Position',
            icon: Icons.gps_fixed,
            color: Colors.purple,
            progress: 0.3,
          ),
          const Divider(),
          _CategoryProgressRow(
            category: 'Safety',
            icon: Icons.shield,
            color: Colors.green,
            progress: 0.5,
          ),
          const Divider(),
          _CategoryProgressRow(
            category: 'Special',
            icon: Icons.star,
            color: Colors.red,
            progress: 0.2,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildRecentActivity(BuildContext context, List<dynamic> progress) {
    if (progress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Chưa có hoạt động',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: progress.take(5).map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ActivityCard(progress: p),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _SummaryCard extends StatelessWidget {
  final dynamic summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Bài tập đã làm',
                  value: '${summary.totalDrillsStarted}',
                  icon: Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Đã hoàn thành',
                  value: '${summary.totalDrillsCompleted}',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Tỷ lệ thành công',
                  value: '${summary.averageSuccessRate.toStringAsFixed(0)}%',
                  icon: Icons.trending_up,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Thời gian tập',
                  value: summary.practiceTimeFormatted,
                  icon: Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color color;
  final double progress;

  const _CategoryProgressRow({
    required this.category,
    required this.icon,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final dynamic progress;

  const _ActivityCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
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
                  progress.drillCode ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Level ${progress.currentLevel} • ${progress.overallSuccessRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(progress.lastAttemptAt),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}p trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}ngày trước';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
