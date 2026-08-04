import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';

/// Match replay screen — step through racks/shots with annotations.
class MatchReplayScreen extends StatefulWidget {
  const MatchReplayScreen({super.key, required this.match});
  final Match match;

  @override
  State<MatchReplayScreen> createState() => _MatchReplayScreenState();
}

class _MatchReplayScreenState extends State<MatchReplayScreen> {
  int _rackIndex = 0;
  int _shotIndex = 0;

  Rack get _currentRack =>
      _rackIndex < widget.match.racks.length ? widget.match.racks[_rackIndex] : _rackDummy();

  Rack _rackDummy() => Rack(
        id: 'empty',
        rackNumber: 0,
        result: 'win',
        createdAt: DateTime.now(),
      );

  void _nextShot() {
    final rack = _currentRack;
    if (_shotIndex + 1 < rack.shots.length) {
      setState(() => _shotIndex++);
    } else if (_rackIndex + 1 < widget.match.racks.length) {
      setState(() {
        _rackIndex++;
        _shotIndex = 0;
      });
    }
  }

  void _prevShot() {
    if (_shotIndex > 0) {
      setState(() => _shotIndex--);
    } else if (_rackIndex > 0) {
      setState(() {
        _rackIndex--;
        _shotIndex = widget.match.racks[_rackIndex].shots.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rack = _currentRack;
    final shot = rack.shots.isNotEmpty && _shotIndex < rack.shots.length
        ? rack.shots[_shotIndex]
        : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Replay — Rack ${rack.rackNumber}/${widget.match.racks.length}'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shot ${_shotIndex + 1}/${rack.shots.length}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  if (shot != null) ...[
                    Text('Type: ${shot.shotType}'),
                    Text('Made: ${shot.result == "made" ? "Yes" : "No"}'),
                    Text('Foul: ${shot.result == "foul" || shot.result == "scratch" ? "Yes" : "No"}'),
                    if (shot.playerNote != null && shot.playerNote!.isNotEmpty)
                      Text('Note: ${shot.playerNote}'),
                  ] else
                    const Text('No shots in this rack.'),
                ],
              ),
            ),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prevShot,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Prev'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                    onPressed: _nextShot,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}