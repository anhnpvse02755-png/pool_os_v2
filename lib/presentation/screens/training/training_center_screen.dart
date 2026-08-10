import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';
import '../../../knowledge/knowledge_provider.dart';

class TrainingCenterScreen extends ConsumerWidget {
  const TrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knowledgeState = ref.watch(knowledgeProvider);
    final knowledgeCount = knowledgeState.allKnowledge.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/training/history'),
            tooltip: 'Lịch sử tập',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Learning Paths - AI Personalized
            _buildSectionHeader(
              context,
              'Lộ trình của bạn',
              subtitle: 'AI cá nhân hóa',
              icon: Icons.auto_awesome,
              color: AppTheme.accentGold,
            ),
            const SizedBox(height: 12),
            _LearningPathsCard(
              onTapRecommended: () => context.push('/training/recommended'),
              onStartDrill: (code) => context.push('/training/session/new?drill=$code'),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.school,
                    title: 'All Drills',
                    subtitle: '${DrillLibrary.getAllDrills().length} bài tập',
                    color: AppTheme.primaryGreen,
                    onTap: () => context.push('/training/drills'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.menu_book,
                    title: 'Knowledge',
                    subtitle: '$knowledgeCount bài viết',
                    color: Colors.blue,
                    onTap: () => context.push('/training/knowledge'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // AI Coach
            _buildSectionHeader(
              context,
              'AI Coach',
              subtitle: 'Phân tích & đề xuất',
              icon: Icons.psychology,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _AICoachCard(
              onTap: () => context.push('/coach'),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Progress
            _buildSectionHeader(
              context,
              'Tiến độ của bạn',
              subtitle: 'Theo dõi hành trình',
              icon: Icons.trending_up,
              color: Colors.teal,
            ),
            const SizedBox(height: 12),
            _ProgressCard(
              onTap: () => context.push('/training/progress'),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Drill Categories
            _buildSectionHeader(
              context,
              'Thư viện bài tập',
              subtitle: 'Tất cả đều mở - Tự chọn bài tập bạn thích',
              icon: Icons.fitness_center,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            ...DrillLibrary.categories.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DrillCategoryTile(
                  category: entry.value,
                  color: _getCategoryColor(entry.key),
                  onTap: () => context.push('/training/drills/${entry.value.id}'),
                ),
              ).animate().fadeIn(delay: (400 + entry.key * 50).ms);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}

class _LearningPathsCard extends StatelessWidget {
  final VoidCallback onTapRecommended;
  final Function(String) onStartDrill;

  const _LearningPathsCard({
    required this.onTapRecommended,
    required this.onStartDrill,
  });

  @override
  Widget build(BuildContext context) {
    // Honest message - no data yet
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGold.withValues(alpha: 0.1),
            AppTheme.accentGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 40),
          const SizedBox(height: 12),
          Text(
            'Chưa có đề xuất cá nhân hóa',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tập ít nhất 1 bài tập để Coach AI phân tích và đưa ra đề xuất phù hợp với bạn.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push('/training/drills'),
            icon: const Icon(Icons.school),
            label: const Text('Xem bài tập'),
          ),
        ],
      ),
    );
  }
}

class _RecommendedDrillTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int stars;
  final String reason;
  final Color color;
  final VoidCallback onStart;

  const _RecommendedDrillTile({
    required this.icon,
    required this.title,
    required this.stars,
    required this.reason,
    required this.color,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          size: 12,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  reason,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onStart,
            child: const Text('Tập'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
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

class _AICoachCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AICoachCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Coach phân tích & đề xuất',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Xem phân tích chi tiết từ Coach',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ProgressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Real progress data will be loaded from drill sessions
    // Using default placeholder until data is available
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tiến độ tập luyện',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Placeholder - real data loaded from drill sessions
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Hoàn thành bài tập để xem tiến độ',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;

  const _ProgressItem({
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DrillCategoryTile extends StatelessWidget {
  final DrillCategory category;
  final Color color;
  final VoidCallback onTap;

  const _DrillCategoryTile({
    required this.category,
    required this.color,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (category.icon) {
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
          border: Border.all(color: Colors.grey.shade200),
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
              child: Icon(_getIcon(), color: color),
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
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
