import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
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
  /// GIỮ ĐỦ BỐN NHÁNH, và không cần đi tìm hue thứ tư. Có hai khiếm khuyết đã
  /// được cân ở đây, và cả hai tan cùng một lúc ở NƠI DÙNG chứ không phải ở
  /// bảng màu:
  ///
  /// 1. `success` (hue 160) và `primary` bản tối (hue 157) cách nhau 3° nên hai
  ///    bậc cao nhất gần như trùng sắc — trước khi đổi token, nhánh ">= 70" là
  ///    `accent` hue 217, tách bạch hẳn.
  /// 2. Nặng hơn nhiều: hồi nền còn tô ĐẶC, chữ trắng đặt lên ba trong bốn bậc
  ///    không đọc nổi ở chế độ sáng — `success` 2.54:1, `warning` 2.15:1,
  ///    `error` 3.76:1. Lỗi này có từ trước đợt đổi token.
  ///
  /// Lời giải là LÀM NHẠT NỀN (loang alpha 0.18 -> 0.10 trên `background` —
  /// thẻ không có `color:` và không nằm trong thẻ nào, nó nằm thẳng trong
  /// `SoftBackground`) chứ không phải đổi màu trả về ở đây: chữ chuyển sang
  /// `textPrimary(brightness)` và cả bốn bậc lên trên 8.8:1 ở chế độ sáng
  /// (bản đo cũ ghi 10:1 vì đo nhầm trên `surface`). Nền nhạt rồi thì 3° hue cũng
  /// hết quan trọng — bốn sắc đều mờ như nhau và CHỮ ('Xuất sắc!' / 'Tốt lắm!')
  /// mới là thứ phân biệt bậc. Gộp hai bậc về cùng `success` từng được cân nhắc
  /// và đã bỏ: nó làm chế độ sáng TỆ ĐI chứ không tốt lên.
  ///
  /// `test/theme/design_tokens_test.dart` khoá nền đã loang của cả bốn bậc.
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
                    // LOANG, không phải tô đặc — cùng lỗi và cùng cách sửa như
                    // nền header của `drill_detail_screen`.
                    //
                    // Tô đặc thì chữ trắng trên ba trong bốn bậc KHÔNG đọc
                    // được ở chế độ sáng, tức chế độ duy nhất đang phát hành:
                    // `success` 2.54:1, `warning` 2.15:1, `error` 3.76:1. Đây
                    // là lỗi có từ trước, không phải do đổi token sinh ra.
                    // Không hue nào cứu được vì vấn đề nằm ở ĐỘ ĐẬM của nền
                    // chứ không ở hex.
                    //
                    // Nền THẬT ở dưới là `background(brightness)`: hộp này chỉ
                    // đặt `gradient:` và `boxShadow:`, không có `color:`, và
                    // không có thẻ nào bọc — nó nằm thẳng trong `SoftBackground`.
                    // Loang lên đó đưa cả bốn bậc lên trên 8.8:1 với
                    // `textPrimary`. Nó cũng xoá luôn hai vấn đề khác: nền hết
                    // bão hoà nên không còn ai phải ngồi cân `onPrimary`, và
                    // khoảng cách 3° hue giữa `success` với `primary` bản tối
                    // hết quan trọng vì ở alpha 0.18 cả bốn sắc đều nhạt —
                    // chữ 'Xuất sắc!' / 'Tốt lắm!' mới là thứ phân biệt bậc.
                    //
                    // `withValues` trên nền Container là hợp lệ: luật cấm alpha
                    // chỉ áp cho MÀU CHỮ.
                    gradient: LinearGradient(
                      colors: [
                        tone.withValues(alpha: 0.18),
                        tone.withValues(alpha: 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    // Bóng đổ theo tông cũ đậm hơn cả cái thẻ nó đỡ. Nền nay
                    // là một mảng nhạt như thẻ thường, nên dùng bóng mềm chung.
                    boxShadow: AppShadows.soft(brightness),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${successRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(brightness),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tỷ lệ thành công',
                        // `textSecondary` đã thử và ĐÃ BỎ: bậc ">= 70" dùng
                        // `primary(light)` #0F4032 rất thẫm, nên ngay ở alpha
                        // 0.18 nền đã đủ tối để nhãn phụ chỉ còn 3.91:1 (bản đo
                        // cũ ghi 4.27:1 vì đo nhầm trên `surface`). Thứ
                        // bậc do cỡ chữ 48 vs 14 lo, không cần nhạt màu thêm.
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Progress bar
                      //
                      // TRANG TRÍ vs MANG NGHĨA, xử lí khác nhau:
                      // - rãnh chỉ là cái máng, giữ alpha nhưng đổi sang
                      //   `textPrimary` để nó đọc được trên nền NHẠT (trắng ở
                      //   alpha bất kì gần như tàng hình ở đây);
                      // - phần đã chạy MÃ HOÁ tỉ lệ nên là đối tượng đồ hoạ
                      //   mang nghĩa, sàn 3:1.
                      //
                      // Phần đã chạy CỐ Ý không lấy `tone`: `tone` đặc ở bậc
                      // `warning` chế độ sáng chỉ còn 1.73:1 với nền và 1.40:1
                      // với rãnh — dưới hẳn sàn.
                      //
                      // `primary` thì KHÔNG bị loại vì tương phản, và câu đó ở
                      // bản trước là SAI: nó viện 2.89:1 với rãnh ở bậc
                      // `success` chế độ tối, nhưng con số ấy đo nền loang phủ
                      // lên `surface`. Nền thật là `background`, và trên nền
                      // thật chỗ đó là 3.25:1 — ĐẠT sàn 3:1; chỗ tệ nhất của
                      // `primary` qua cả bốn bậc x hai stop x hai chế độ là
                      // 3.15:1, vẫn đạt. Lý do thật để giữ `textPrimary` là
                      // BIÊN: `primary` chỉ hơn sàn 5% ở chỗ tệ nhất và là màu
                      // SẮC có thể trùng họ xanh rêu với chính nền loang (bậc
                      // ">= 70" tô bằng nó).
                      //
                      // Rãnh và phần đã chạy nay là CÙNG một mực, khác nhau ở
                      // độ đặc (0.12 vs 1.0). Mực thì luôn nghịch với nền theo
                      // đúng định nghĩa `textPrimary`, nên cách này đạt ≥7.2:1
                      // ở mọi bậc và cả hai chế độ mà không phải dò từng hex.
                      // Bậc nào là bậc nào đã có sắc nền và dòng chữ nói rồi.
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: LinearProgressIndicator(
                          value: successRate / 100,
                          minHeight: 12,
                          backgroundColor: AppColors.textPrimary(brightness)
                              .withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.textPrimary(brightness)),
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
