import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_types.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(performanceSummaryProvider);
    final progressMap = ref.watch(allDrillProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Tien do cua ban'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            summaryAsync.when(
              data: (summary) => _SummaryCard(summary: summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Progress by Category
            Text(
              'Tien do theo danh muc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            _buildCategoryProgress(context, progressMap),

            const SizedBox(height: AppSpacing.xxl),

            // Recent Activity
            Text(
              'Hoat dong gan day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

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
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _ActivityTile(progress: progress),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyProgress() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: AppColors.lightTextTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chua co tien do',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bat dau tap de xem tien do cua ban',
            style: TextStyle(color: AppColors.lightTextTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: AppColors.lightTextTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chua co hoat dong',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Tong quan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                icon: Icons.fitness_center,
                value: '${summary.totalSessions}',
                label: 'Buoi tap',
              ),
              _SummaryItem(
                icon: Icons.sports_cricket,
                value: '${summary.totalShots}',
                label: 'Tong bi',
              ),
              _SummaryItem(
                icon: Icons.percent,
                value: '${summary.overallAccuracy}%',
                label: 'Do chinh xac',
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
        const SizedBox(height: AppSpacing.sm),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              Expanded(
                child: Text(
                  progress.drillName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightTextPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _getRateColor(rate).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 8,
              backgroundColor: AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation(_getRateColor(rate)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${progress.totalAttempts} lan tap - ${progress.successfulAttempts} thanh cong',
            style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class _ActivityTile extends StatelessWidget {
  final SimpleDrillProgress progress;

  const _ActivityTile({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
                  progress.drillName,
                  style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.lightTextPrimary),
                ),
                Text(
                  _formatDate(progress.lastAttemptedAt),
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${progress.successRate.toStringAsFixed(0)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chua tap';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phut truoc';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} gio truoc';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngay truoc';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
