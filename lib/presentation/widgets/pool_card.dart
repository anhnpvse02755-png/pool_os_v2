import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/shadows.dart';
import '../../core/theme/spacing.dart';

/// Thẻ bo góc lớn, shadow mềm — khối xây dựng chính của giao diện.
///
/// [selected] = false dùng bề mặt chìm, đúng như trạng thái xám của thẻ chưa
/// chọn trong thiết kế tham chiếu.
class PoolCard extends StatelessWidget {
  const PoolCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = true,
    this.padding,
    this.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets? padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final r = radius ?? AppSpacing.radiusMd;

    final content = Container(
      key: const Key('pool-card-container'),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.surface(brightness)
            : AppColors.surfaceRecessed(brightness),
        borderRadius: BorderRadius.circular(r),
        boxShadow: AppShadows.soft(brightness),
        // Nền tối nuốt shadow, nên phải có viền mới thấy được mép thẻ.
        border: brightness == Brightness.dark
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: content,
      ),
    );
  }
}
