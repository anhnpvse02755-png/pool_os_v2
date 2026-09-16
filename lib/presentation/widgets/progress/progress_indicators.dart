import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// PoolOS Linear Progress Bar
class LinearProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? fillColor;

  const LinearProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = backgroundColor ?? AppColors.border(brightness);
    // `accentColor` trả xanh điện — tông mà đợt redesign này tồn tại để loại.
    final fgColor = fillColor ?? AppColors.primary(brightness);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                height: height,
                decoration: BoxDecoration(
                  color: fgColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// PoolOS Circular Progress Indicator
class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = backgroundColor ?? AppColors.border(brightness);
    // `accentColor` trả xanh điện — tông mà đợt redesign này tồn tại để loại.
    final fgColor = progressColor ?? AppColors.primary(brightness);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
