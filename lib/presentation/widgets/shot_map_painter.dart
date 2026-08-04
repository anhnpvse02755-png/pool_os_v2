import 'package:flutter/material.dart';

/// Pure painter for shot map — 2D pool table with shots plotted as
/// cue ball → target ball → pocket vectors.
///
/// Caller passes a list of `ShotPoint` already normalised to a 0..1
/// coordinate space (0 = top-left corner of the table).
class ShotMapPainter extends CustomPainter {
  ShotMapPainter({
    required this.shots,
    this.showHeat = false,
  });
  final List<ShotPoint> shots;
  final bool showHeat;

  @override
  void paint(Canvas canvas, Size size) {
    final paintTable = Paint()..color = const Color(0xFF0E5C3B);
    final paintBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final paintRail = Paint()
      ..color = const Color(0xFF1E7E55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Table
    final rect = Offset.zero & size;
    canvas.drawRect(rect, paintTable);
    canvas.drawRect(rect.deflate(4), paintRail);
    canvas.drawRect(rect, paintBorder);

    // Pockets — 6 standard positions.
    final pockets = _pockets(size);
    for (final p in pockets) {
      canvas.drawCircle(p, 12, Paint()..color = Colors.black);
    }

    if (shots.isEmpty) return;

    if (showHeat) {
      _paintHeat(canvas, size);
    }

    for (final s in shots) {
      final cue = s.cue.times(size);
      final target = s.target.times(size);
      final pocket = s.pocket?.times(size);

      // Cue ball
      canvas.drawCircle(cue, 6, Paint()..color = Colors.white);
      canvas.drawCircle(cue, 6,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);

      // Path cue -> target
      final pathPaint = Paint()
        ..color = s.made ? Colors.green : Colors.redAccent
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(cue, target, pathPaint);

      // Target ball
      canvas.drawCircle(target, 5, Paint()..color = Colors.yellow);

      // Path to pocket (if any)
      if (pocket != null) {
        final pPath = Paint()
          ..color = s.made ? Colors.greenAccent : Colors.redAccent
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(target, pocket, pPath);
      }
    }
  }

  void _paintHeat(Canvas canvas, Size size) {
    // Bin target points into 8x4 grid; darker cell = more attempts.
    const cols = 16, rows = 8;
    final grid = List.generate(rows, (_) => List.filled(cols, 0));
    for (final s in shots) {
      final tx = (s.target.dx * (cols - 1)).floor().clamp(0, cols - 1);
      final ty = (s.target.dy * (rows - 1)).floor().clamp(0, rows - 1);
      grid[ty][tx] += 1;
    }
    int maxV = 1;
    for (final r in grid) {
      for (final v in r) {
        if (v > maxV) maxV = v;
      }
    }
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final v = grid[y][x];
        if (v == 0) continue;
        final alpha = (v / maxV).clamp(0.0, 1.0);
        final p = Paint()..color = Colors.redAccent.withOpacity(alpha * 0.4);
        canvas.drawRect(
          Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
          p,
        );
      }
    }
  }

  List<Offset> _pockets(Size size) {
    return [
      const Offset(0, 0),
      Offset(size.width / 2, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width / 2, size.height),
      Offset(size.width, size.height),
    ];
  }

  @override
  bool shouldRepaint(covariant ShotMapPainter old) =>
      old.shots != shots || old.showHeat != showHeat;
}

class ShotPoint {
  final OffsetFraction cue;
  final OffsetFraction target;
  final OffsetFraction? pocket;
  final bool made;
  const ShotPoint({
    required this.cue,
    required this.target,
    this.pocket,
    required this.made,
  });
}

class OffsetFraction {
  final double dx;
  final double dy;
  const OffsetFraction(this.dx, this.dy);
  Offset times(Size s) => Offset(dx * s.width, dy * s.height);
}