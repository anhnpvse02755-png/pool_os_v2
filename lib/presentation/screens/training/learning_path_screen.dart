import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/coach_types.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final learningPathAsync = ref.watch(learningPathProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Lộ trình của bạn'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(learningPathProvider),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SoftBackground(
        child: learningPathAsync.when(
          data: (path) => _buildContent(context, ref, path),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.lg),
                Text('Lỗi: $error'),
                const SizedBox(height: AppSpacing.lg),
                _PrimaryButton(
                  onPressed: () => ref.invalidate(learningPathProvider),
                  label: 'Thử lại',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<LearningPathItem> path) {
    final brightness = Theme.of(context).brightness;

    if (path.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          //
          // Nền là dải `primary(brightness)` — ĐỔI theo chế độ — nên chữ dùng
          // `onPrimary(brightness)` chứ không phải trắng cứng: chế độ tối
          // primary là #34A97C, trắng trên đó chỉ còn ~2.5:1.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary(brightness),
                  AppColors.primary(brightness).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: AppColors.onPrimary(brightness)),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tuần này',
                      style: TextStyle(
                        color: AppColors.onPrimary(brightness),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'AI de xuat ${path.length} bai tap cho ban',
                  // KHÔNG hạ alpha xuống 0.9 như bản cũ: luật của bộ này là
                  // không đặt alpha lên MÀU CHỮ, và ở chế độ tối chữ sẫm mờ đi
                  // là mất luôn phần tương phản ít ỏi còn lại.
                  style: TextStyle(
                    color: AppColors.onPrimary(brightness),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: AppSpacing.xxl),

          // Follow AI / Skip AI
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang theo lộ trình AI...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  label: 'Follow AI',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/training/drills'),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Tự chọn'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    side: BorderSide(color: AppColors.primary(brightness)),
                    foregroundColor: AppColors.primary(brightness),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: AppSpacing.xxl),

          // Learning path items
          ...path.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _LearningPathCard(
                item: item,
                order: index + 1,
                onStart: () {
                  context.push(
                    '/training/session/new?drill=${item.drillCode}',
                  );
                },
                onSkip: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã bỏ qua'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ).animate().fadeIn(delay: (200 + index * 100).ms),
            );
          }),

          const SizedBox(height: AppSpacing.lg),

          // Note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border(brightness)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.textSecondary(brightness), size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Ban co the bo qua bat ky bai tap nao. Tat ca bai tap deu mo cho ban.',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: AppColors.textTertiary(brightness),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Chưa có lộ trình',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary(brightness),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tập ít nhất 1 bài tập để nhận đề xuất từ Coach',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _PrimaryButton(
              onPressed: () => context.push('/onboarding/interests'),
              label: 'Chọn sở thích',
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningPathCard extends ConsumerWidget {
  final LearningPathItem item;
  final int order;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _LearningPathCard({
    required this.item,
    required this.order,
    required this.onStart,
    required this.onSkip,
  });

  /// Tông của mức ưu tiên.
  ///
  /// BỘ ANH EM ba phần tử: warning 38° / green 157-163° / chữ trung tính.
  /// Ba sắc này cách nhau xa, không có cặp nào dưới 20°.
  Color _getPriorityColor(Brightness brightness) {
    switch (item.priority) {
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.primary(brightness);
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  String _getPriorityLabel() {
    switch (item.priority) {
      case 1:
        return 'Ưu tiên cao';
      case 2:
        return 'Khuyến nghị';
      default:
        return 'Bổ sung';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      radius: AppSpacing.radiusLg,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(brightness)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: TextStyle(
                        color: _getPriorityColor(brightness),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.drillNameVi,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary(brightness),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(brightness)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _getPriorityLabel(),
                              style: TextStyle(
                                color: _getPriorityColor(brightness),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.reason,
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Ô thời lượng CỐ Ý không có màu: một con số phút là dữ
                      // kiện trung tính, không mã hoá kết quả nào. Ô độ khó
                      // ngay cạnh nó mới là ô mang nghĩa, và giữ nó là ô DUY
                      // NHẤT có màu trong hàng thì mắt bắt được ngay.
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background(brightness),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '${item.estimatedMinutes} phut',
                              style: TextStyle(
                                color: AppColors.textSecondary(brightness),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(brightness)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _getDifficultyLabel(),
                              style: TextStyle(
                                color: _getDifficultyColor(brightness),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border(brightness)),

          _buildKnowledgeChips(context, ref),

          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xs, AppSpacing.sm, AppSpacing.sm),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Bỏ qua'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary(brightness),
                  ),
                ),
                const Spacer(),
                _PrimaryButton(
                  onPressed: onStart,
                  label: 'Bắt đầu',
                  icon: Icons.play_arrow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tông của mức độ khó — bốn bậc, giống hệt `drill_detail_screen`.
  ///
  /// `expert` KHÔNG được gộp vào `primary`: chế độ tối primary #34A97C lệch 3°
  /// hue so với `success` nên bài dễ nhất và bài khó nhất sẽ trông y hệt nhau.
  /// Token `difficultyExpert` sinh ra đúng vì lý do đó.
  Color _getDifficultyColor(Brightness brightness) {
    switch (item.difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      case 'expert':
        return AppColors.difficultyExpert(brightness);
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  Widget _buildKnowledgeChips(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final related = ref.watch(learningKnowledgeProvider(item));
    if (related.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book,
                  size: 14, color: AppColors.accentLabel(brightness)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Đọc trước khi tập',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.accentLabel(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: related.map((k) {
              return ActionChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                label: Text(
                  k.titleVi ?? k.title,
                  style: const TextStyle(fontSize: 11),
                ),
                avatar: const Icon(Icons.article_outlined, size: 12),
                onPressed: () {
                  context.push('/training/knowledge/${k.slug}');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel() {
    switch (item.difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'expert':
        return 'Expert';
      default:
        return item.difficulty;
    }
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  const _PrimaryButton({required this.onPressed, required this.label, this.icon});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            // Cả hai nhánh nền đều đổi theo chế độ, nên chữ dùng
            // `onPrimary(brightness)`.
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: AppColors.onPrimary(brightness), size: 18),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary(brightness))),
            ],
          ),
        ),
      ),
    );
  }
}
