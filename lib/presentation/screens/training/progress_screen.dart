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
    final progressMap = ref.watch(allDrillProgressProvider);

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

            _buildCategoryProgress(context, progressMap),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Hoạt động gần đây',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            _buildRecentActivity(context, progressMap),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, Map<String, SimpleDrillProgress> progressMap) {
    if (progressMap.isEmpty) {
      return _buildEmptyProgress();
    }

    final progressList = progressMap.values.toList();

    return Column(
      children: progressList.map((progress) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ProgressCard(progress: progress),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(BuildContext context, Map<String, SimpleDrillProgress> progressMap) {
    if (progressMap.isEmpty) {
      return _buildEmptyActivity();
    }

    final sortedProgress = progressMap.values.toList()
      ..sort((a, b) {
        if (a.lastAttemptedAt == null && b.lastAttemptedAt == null) return 0;
        if (a.lastAttemptedAt == null) return 1;
        if (b.lastAttemptedAt == null) return -1;
        return b.lastAttemptedAt!.compareTo(a.lastAttemptedAt!);
      });

    return Column(
      children: sortedProgress.take(5).map((progress) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ActivityTile(progress: progress),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có tiến độ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bắt đầu tập để xem tiến độ của bạn',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có hoạt động',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PerformanceSummary summary;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Tổng quan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                icon: Icons.fitness_center,
                value: '${summary.totalSessions}',
                label: 'Buổi tập',
              ),
              _SummaryItem(
                icon: Icons.sports_cricket,
                value: '${summary.totalShots}',
                label: 'Tổng bi',
              ),
              _SummaryItem(
                icon: Icons.percent,
                value: '${summary.overallAccuracy}%',
                label: 'Độ chính xác',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final SimpleDrillProgress progress;

  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final rate = progress.successRate;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.drillName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRateColor(rate).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getRateColor(rate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_getRateColor(rate)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.totalAttempts} lần tập • ${progress.successfulAttempts} thành công',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _ActivityTile extends StatelessWidget {
  final SimpleDrillProgress progress;

  const _ActivityTile({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
                  progress.drillName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDate(progress.lastAttemptedAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${progress.successRate.toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa tập';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
