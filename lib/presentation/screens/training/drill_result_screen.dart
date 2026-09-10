import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class DrillResultScreen extends StatelessWidget {
  final String drillCode;
  final int totalReps;
  final int successCount;

  const DrillResultScreen({
    super.key,
    required this.drillCode,
    required this.totalReps,
    required this.successCount,
  });

  double get successRate => totalReps > 0 ? (successCount / totalReps) * 100 : 0;

  String get rating {
    if (successRate >= 90) return 'Xuất sắc!';
    if (successRate >= 70) return 'Tốt lắm!';
    if (successRate >= 50) return 'Cần cố gắng hơn';
    return 'Cần luyện tập thêm';
  }

  /// Tông của kết quả.
  ///
  /// Nhận [brightness] vì nhánh "Tốt lắm!" nay dùng `primary(brightness)` —
  /// getter không tham số không với tới được chế độ hiện hành.
  ///
  /// CHÚ Ý cho lô sau: `success` (hue 160) và `primary` bản tối (hue 157) chỉ
  /// cách nhau 3°, nên hai bậc cao nhất của thang này gần như trùng màu ở chế
  /// độ tối — trước khi đổi token thì nhánh ">= 70" là `accent` hue 217, tách
  /// bạch hẳn. Bảng màu hiện không có hue thứ tư vừa đủ xa vừa đổi theo chế độ
  /// (`gold` trùng hệt `warning`, `streak` cách `warning` 13°), nên chuyện này
  /// cần một quyết định thiết kế: gộp hai bậc "đã qua" về cùng `success` và để
  /// chữ phân biệt, hay thêm hẳn một token bậc-bốn.
  Color ratingColor(Brightness brightness) {
    if (successRate >= 90) return AppColors.success;
    if (successRate >= 70) return AppColors.primary(brightness);
    if (successRate >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final drill = DrillLibrary.getDrill(drillCode);
    final tone = ratingColor(brightness);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SoftBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Trophy icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    successRate >= 70
                        ? Icons.emoji_events
                        : Icons.fitness_center,
                    size: 64,
                    color: tone,
                  ),
                )
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.xl),

                // Rating
                Text(
                  rating,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tone,
                      ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.xs),

                if (drill != null)
                  Text(
                    drill.nameVi,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                  ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppSpacing.xxl),

                // Stats cards
                //
                // 'Tổng lần' là một phép đếm, không phải kết quả — tô nó bằng
                // `primary` đặt một ô xanh hue 157 ngay cạnh ô `success` hue
                // 160, cách nhau 3°. Token chữ giữ 'Thành công' là ô DUY NHẤT
                // có màu trong cặp này.
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Tổng lần',
                        value: '$totalReps',
                        icon: Icons.repeat,
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        label: 'Thành công',
                        value: '$successCount',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: AppSpacing.lg),

                // Success rate
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tone,
                        tone.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: tone.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  // Nền là `ratingColor(brightness)` — một hàm CỦA chế độ, nên
                  // chữ trên nó đi theo `onPrimary(brightness)`.
                  child: Column(
                    children: [
                      Text(
                        '${successRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimary(brightness),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tỷ lệ thành công',
                        style: TextStyle(
                          color: AppColors.onPrimary(brightness),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Progress bar
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: LinearProgressIndicator(
                          value: successRate / 100,
                          minHeight: 12,
                          backgroundColor: AppColors.onPrimary(brightness)
                              .withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.onPrimary(brightness)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: AppSpacing.xxl),

                // Coach feedback placeholder
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb,
                              color: AppColors.gold, size: 24),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'AI Coach gợi ý',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        successRate < 70
                            ? 'Ban can tap trung vao do chinh xac hon. Hay chu y den tu the va cach cam co.'
                            : 'Ky thuat cua ban da kha tot! Hay tiep tuc luyen tap de duy tri va cai thien.',
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: AppSpacing.xxl),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: _PrimaryButton(
                    onPressed: () => context.go('/training'),
                    label: 'Về Training Center',
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: _SecondaryButton(
                    onPressed: () {
                      context.go('/training/session/new?drill=$drillCode');
                    },
                    label: 'Tập lại',
                    icon: Icons.replay,
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppSpacing.radiusLg,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  const _PrimaryButton({required this.onPressed, required this.label});
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
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            // Cả hai nhánh nền đều đổi theo chế độ -> `onPrimary(brightness)`.
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Text(widget.label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary(brightness)),
              textAlign: TextAlign.center)),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  const _SecondaryButton({required this.onPressed, required this.label, this.icon});
  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}
class _SecondaryButtonState extends State<_SecondaryButton> {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border:
                Border.all(color: AppColors.primary(brightness), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: AppColors.primary(brightness), size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(brightness)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
