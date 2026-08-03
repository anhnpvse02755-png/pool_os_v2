import 'package:flutter/material.dart';

import '../../data/models/match.dart';
import 'shot_map_painter.dart';

/// Shot map view for a match — uses shot coordinates from the match
/// timeline (if recorded) or empty placeholder.
class ShotMapView extends StatelessWidget {
  const ShotMapView({super.key, required this.match, this.showHeat = false});
  final Match match;
  final bool showHeat;

  List<ShotPoint> _extract() {
    // We don't have shot-by-shot coordinates stored in the current
    // schema, so this view shows the available data (timeline events)
    // as a basic sequence. Coordinates default to grid where possible.
    final points = <ShotPoint>[];
    int i = 0;
    for (final rack in match.racks) {
      for (final s in rack.shots) {
        // Pseudo-coordinates for visualisation: alternate positions.
        final cueDx = 0.5 + (i % 3) * 0.1;
        final targetDx = (i % 5) * 0.2 + 0.1;
        points.add(ShotPoint(
          cue: OffsetFraction(cueDx, 0.5),
          target: OffsetFraction(targetDx, 0.5),
          pocket: const OffsetFraction(0, 1),
          made: s.result == 'made',
        ));
        i++;
      }
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final shots = _extract();
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: shots.isEmpty
              ? const Center(child: Text('No shots recorded.'))
              : CustomPaint(painter: ShotMapPainter(shots: shots, showHeat: showHeat)),
        ),
      ),
    );
  }
}