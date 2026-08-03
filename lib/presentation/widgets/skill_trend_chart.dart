import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/match_repository.dart';

/// Per-skill trend chart — line chart derived from match history.
///
/// X axis: time (date), Y axis: rolling-window win %.
class SkillTrendChart extends ConsumerStatefulWidget {
  const SkillTrendChart({
    super.key,
    this.playerId = '',
    this.skill = 'winRate',
    this.color = Colors.blue,
    this.height = 160,
  });
  final String playerId;
  final String skill;
  final Color color;
  final double height;

  @override
  ConsumerState<SkillTrendChart> createState() => _SkillTrendChartState();
}

class _SkillTrendChartState extends ConsumerState<SkillTrendChart> {
  List<_Point> _points = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await ref.read(matchRepositoryProvider).getAllMatches();
    final recent = matches.take(20).toList().reversed.toList();
    final pts = <_Point>[];
    int win = 0, total = 0;
    for (final m in recent) {
      total++;
      if (m.isWin) win++;
      pts.add(_Point(m.createdAt, total == 0 ? 0 : win / total * 100));
    }
    if (!mounted) return;
    setState(() {
      _points = pts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
          height: widget.height,
          child: const Center(child: CircularProgressIndicator()));
    }
    if (_points.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('Chưa có dữ liệu')),
      );
    }
    return SizedBox(
      height: widget.height,
      child: CustomPaint(
        painter: _LineChartPainter(
          points: _points,
          color: widget.color,
          axisColor: Colors.grey.shade400,
        ),
        child: Container(),
      ),
    );
  }
}

class _Point {
  final DateTime t;
  final double v;
  const _Point(this.t, this.v);
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.color,
    required this.axisColor,
  });
  final List<_Point> points;
  final Color color;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minX = points.first.t.millisecondsSinceEpoch.toDouble();
    final maxX = points.last.t.millisecondsSinceEpoch.toDouble();
    final minY = 0.0;
    final maxY = 100.0;

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 16),
        Offset(size.width, size.height - 16), axisPaint);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x =
          (p.t.millisecondsSinceEpoch - minX) / (maxX - minX) * size.width;
      final y = size.height -
          16 -
          ((p.v - minY) / (maxY - minY)) * (size.height - 32);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color;
    for (final p in points) {
      final x =
          (p.t.millisecondsSinceEpoch - minX) / (maxX - minX) * size.width;
      final y = size.height -
          16 -
          ((p.v - minY) / (maxY - minY)) * (size.height - 32);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.points != points || old.color != color;
}
