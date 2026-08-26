import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// PoolOS Logo Widget
/// Minimal mark representing pool/billiards trajectory
class PoolOSLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const PoolOSLogo({
    super.key,
    this.size = 120,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.accentColor(Theme.of(context).brightness);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(color: logoColor),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw trajectory line (cue ball path)
    final startX = size.width * 0.15;
    final startY = size.height * 0.5;
    final endX = size.width * 0.75;
    final endY = size.height * 0.25;

    // Main trajectory line with curve
    final path = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.6,
        endX,
        endY,
      );

    canvas.drawPath(path, paint);

    // Draw start ball (cue ball)
    final ballPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(startX, startY),
      size.width * 0.08,
      ballPaint,
    );

    // Draw end ball (target)
    canvas.drawCircle(
      Offset(endX, endY),
      size.width * 0.1,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(endX, endY),
      size.width * 0.08,
      ballPaint,
    );

    // Draw arrow head at end
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowSize = size.width * 0.12;
    final arrowX = endX;
    final arrowY = endY + arrowSize * 0.3;

    canvas.drawLine(
      Offset(arrowX - arrowSize * 0.5, arrowY - arrowSize * 0.3),
      Offset(arrowX, arrowY),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(arrowX + arrowSize * 0.3, arrowY - arrowSize * 0.5),
      Offset(arrowX, arrowY),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// PoolOS Logo with Text
class PoolOSLogoWithText extends StatelessWidget {
  final double logoSize;
  final double textSize;
  final Color? color;

  const PoolOSLogoWithText({
    super.key,
    this.logoSize = 40,
    this.textSize = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.accentColor(Theme.of(context).brightness);
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PoolOSLogo(size: logoSize, color: logoColor),
        const SizedBox(width: 12),
        Text(
          'PoolOS',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: textSize,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
