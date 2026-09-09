import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

/// Ô bo tròn nền pastel chứa một Material icon.
///
/// CỐ Ý dùng icon chứ không dùng emoji: emoji hiển thị khác nhau giữa các hệ
/// điều hành và trình đọc màn hình đọc tên emoji nghe lạc lõng. Vẻ ấm áp đến
/// từ ô pastel, không từ bản thân emoji.
///
/// [toneIndex] phải gán theo danh mục ỔN ĐỊNH — cùng một danh mục luôn cùng
/// tông, để người dùng học được màu.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.toneIndex,
    this.size = 56,
  });

  final IconData icon;
  final int toneIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      key: const Key('icon-tile-container'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.pastelFor(toneIndex, brightness),
        borderRadius: BorderRadius.circular(
            size / AppSpacing.iconTileSize * AppSpacing.radiusTile),
      ),
      child: Icon(
        icon,
        key: const Key('icon-tile-icon'),
        size: size * 0.46,
        color: AppColors.primary(brightness),
      ),
    );
  }
}
