import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Nền kem ấm (hoặc than ám xanh) kèm vài mảng màu mờ.
///
/// Blob đặt cố định và làm mờ mạnh — chúng là kết cấu nền, không phải hình
/// trang trí cần chú ý. Đặt widget này dưới cùng của body màn hình.
class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;

    final peach = isLight ? AppColors.lightBlobPeach : AppColors.darkBlobPeach;
    final mint = isLight ? AppColors.lightBlobMint : AppColors.darkBlobMint;
    final butter =
        isLight ? AppColors.lightBlobButter : AppColors.darkBlobButter;

    return Container(
      key: const Key('soft-background-ground'),
      decoration: BoxDecoration(color: AppColors.background(brightness)),
      child: Stack(
        children: [
          Positioned.fill(
            key: const Key('soft-background-blobs'),
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -60,
                      child: _Blob(color: peach, size: 260),
                    ),
                    Positioned(
                      top: 220,
                      left: -90,
                      child: _Blob(color: mint, size: 220),
                    ),
                    Positioned(
                      bottom: -70,
                      right: -40,
                      child: _Blob(color: butter, size: 240),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
