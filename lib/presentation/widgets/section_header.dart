import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Tiêu đề mục, có biến thể kèm số thứ tự bước.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.step,
  });

  final String title;
  final String? subtitle;

  /// Số thứ tự bước; có giá trị thì hiện badge tròn bên trái.
  final int? step;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          key: const Key('section-header-title'),
          style: AppTypography.displayLg
              .copyWith(color: AppColors.textPrimary(brightness)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            key: const Key('section-header-subtitle'),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary(brightness),
            ),
          ),
        ],
      ],
    );

    if (step == null) return texts;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('section-header-step'),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary(brightness),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: texts),
      ],
    );
  }
}
