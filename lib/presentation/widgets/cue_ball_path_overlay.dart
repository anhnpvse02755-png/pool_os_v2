import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

import 'shot_map_painter.dart';

/// Cue ball path overlay — focuses on the cue ball trajectory alone.
class CueBallPathOverlay extends StatelessWidget {
  const CueBallPathOverlay({super.key, required this.shots});
  final List<ShotPoint> shots;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.tableLine),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomPaint(
            painter: _CueBallPathPainter(shots),
          ),
        ),
      ),
    );
  }
}

class _CueBallPathPainter extends CustomPainter {
  _CueBallPathPainter(this.shots);
  final List<ShotPoint> shots;

  @override
  void paint(Canvas canvas, Size size) {
    final paintTable = Paint()..color = AppColors.tableFelt;
    final paintBorder = Paint()
      ..color = AppColors.tableLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Offset.zero & size, paintTable);
    canvas.drawRect(Offset.zero & size, paintBorder);

    // Pockets
    final pockets = [
      const Offset(0, 0),
      Offset(size.width / 2, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width / 2, size.height),
      Offset(size.width, size.height),
    ];
    for (final p in pockets) {
      canvas.drawCircle(p, 12, Paint()..color = AppColors.tableLine);
    }

    final path = Path();
    for (int i = 0; i < shots.length; i++) {
      final s = shots[i];
      final cue = s.cue.times(size);
      // Cue path: inferred by drawing a small curve to the next cue.
      if (i == 0) {
        path.moveTo(cue.dx, cue.dy);
      } else {
        path.lineTo(cue.dx, cue.dy);
      }
    }
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    // Render cue ball positions
    for (final s in shots) {
      final cue = s.cue.times(size);
      canvas.drawCircle(cue, 4, Paint()..color = AppColors.ballCue);
    }
  }

  @override
  bool shouldRepaint(covariant _CueBallPathPainter old) =>
      old.shots != shots;
}