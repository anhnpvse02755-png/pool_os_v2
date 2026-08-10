import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_service.dart';
import '../../../core/services/coach_types.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(performanceSummaryProvider);
    final weaknessesAsync = ref.watch(weaknessAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            summaryAsync.when(
              data: (summary) => _OverviewCard(summary: summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Strengths & Weaknesses
            weaknessesAsync.when(
              data: (weaknesses) => _WeaknessesSection(weaknesses: weaknesses),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Recommendations
            Text(
              'Khuyến nghị',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            summaryAsync.when(
              data: (summary) => _RecommendationsSection(summary: summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final PerformanceSummary summary;

  const _OverviewCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.indigo.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Tổng quan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: 'Tỷ lệ thành công',
                  value: '${summary.overallAccuracy}%',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Tổng buổi',
                  value: '${summary.totalSessions}',
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: 'Tổng bi',
                  value: '${summary.totalShots}',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _WeaknessesSection extends StatelessWidget {
  final List<WeaknessAnalysis> weaknesses;

  const _WeaknessesSection({required this.weaknesses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_down, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Text(
              'Điểm yếu cần cải thiện',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (weaknesses.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tuyệt vời! Bạn không có điểm yếu nào được phát hiện.',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          )
        else
          ...weaknesses.take(3).map((w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WeaknessCard(weakness: w),
            );
          }),
      ],
    );
  }
}

class _WeaknessCard extends StatelessWidget {
  final WeaknessAnalysis weakness;

  const _WeaknessCard({required this.weakness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${weakness.currentRate}%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weakness.drillName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            weakness.suggestion,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weakness.attempts} lần thử',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  final PerformanceSummary summary;

  const _RecommendationsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecommendationCard(
          icon: Icons.fitness_center,
          title: 'Tập trung vào điểm yếu',
          description: 'Dành thời gian luyện tập các kỹ năng có tỷ lệ thành công thấp.',
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _RecommendationCard(
          icon: Icons.timer,
          title: 'Luyện tập đều đặn',
          description: 'Tập ít nhất 3 lần/tuần để cải thiện nhanh hơn.',
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        _RecommendationCard(
          icon: Icons.psychology,
          title: 'Học lý thuyết',
          description: 'Đọc các bài viết trong Knowledge Library để hiểu rõ hơn.',
          color: Colors.green,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
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
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
