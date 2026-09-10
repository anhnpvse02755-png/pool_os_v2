import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_types.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final summaryAsync = ref.watch(performanceSummaryProvider);
    final progressMap = ref.watch(allDrillProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Tiến độ của bạn'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
      ),
      body: SoftBackground(
        child: SingleChildScrollView(
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
                'Tiến độ theo danh mục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildCategoryProgress(context, progressMap),

              const SizedBox(height: AppSpacing.xxl),

              // Recent Activity
              Text(
                'Hoạt động gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              _buildRecentActivity(context, progressMap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, Map<String, SimpleDrillProgress> progressMap) {
    final brightness = Theme.of(context).brightness;
    if (progressMap.isEmpty) {
      return _buildEmptyProgress(brightness);
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
    final brightness = Theme.of(context).brightness;
    if (progressMap.isEmpty) {
      return _buildEmptyActivity(brightness);
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

  Widget _buildEmptyProgress(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: AppColors.textTertiary(brightness)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chưa có tiến độ',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bắt đầu tập để xem tiến độ của bạn',
            style: TextStyle(color: AppColors.textTertiary(brightness), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textTertiary(brightness)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chưa có hoạt động',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary(brightness),
            // Đuôi loang 0.86, KHÔNG phải 0.8. Nền thẫm dần nên chỗ yếu nhất
            // là stop cuối: ở bản tối `primary` #34A97C tại 0.80 kết tủa
            // thành #2D8C67, chữ `onPrimary(dark)` chỉ còn 4.11:1. Sàn ở đây
            // là 4.5:1 chứ không phải 3:1 vì tiêu đề thẻ là 18px và nhãn phụ
            // 12px — đều dưới ngưỡng 18.66px của "chữ lớn". 0.86 cho #2F956E
            // và 4.58:1; bản sáng cùng lúc lên 7.91:1.
            AppColors.primary(brightness).withValues(alpha: 0.86),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events,
                  color: AppColors.onPrimary(brightness), size: 28),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Tổng quan',
                style: TextStyle(
                  color: AppColors.onPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;

    // Nền là dải loang `primary` — phụ thuộc chế độ, nên mực cũng phải lật
    // theo chế độ. Mực để NGUYÊN độ đục: `white70` cũ hạ nhãn 12px xuống
    // dưới sàn, và ở bản tối `onPrimary` vốn đã thẫm nên pha loãng thêm là
    // hỏng hẳn. Thứ bậc do cỡ chữ 24 vs 12 và độ đậm lo.
    return Column(
      children: [
        Icon(icon, color: AppColors.onPrimary(brightness), size: 24),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            color: AppColors.onPrimary(brightness),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;
    final rate = progress.successRate;

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.drillName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary(brightness)),
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
              backgroundColor: AppColors.border(brightness),
              valueColor: AlwaysStoppedAnimation(_getRateColor(rate)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${progress.totalAttempts} lan tap - ${progress.successfulAttempts} thanh cong',
            style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Ba bậc giữ nguyên ba tông ngữ nghĩa: success 160°, warning 38°, error 0°.
  // Không bậc nào rơi vào họ xanh của `primary`, nên bộ này không cần đổi.
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          // Ô 40px nền `accent` mờ + icon `accent` là đúng hình dạng IconTile.
          // Tông 0 (mint) gắn cố định với "buổi tập" trên toàn app.
          const IconTile(
            icon: Icons.fitness_center,
            toneIndex: 0,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.drillName,
                  style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary(brightness)),
                ),
                Text(
                  _formatDate(progress.lastAttemptedAt),
                  style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${progress.successRate.toStringAsFixed(0)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(brightness)),
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
