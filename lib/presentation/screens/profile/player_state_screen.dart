import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';
import '../../../data/models/match_analysis.dart';
import '../../../data/repositories/match_repository.dart';

/// Player State screen — shows aggregated mental + physical axes from the
/// last N matches, plus an editable snapshot for "now".
class PlayerStateScreen extends StatefulWidget {
  const PlayerStateScreen({super.key});

  @override
  State<PlayerStateScreen> createState() => _PlayerStateScreenState();
}

class _PlayerStateScreenState extends State<PlayerStateScreen> {
  final _matchRepo = LocalMatchRepository();
  List<PlayerStateSnapshot> _states = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await _matchRepo.getAllMatches();
    final all = <PlayerStateSnapshot>[];
    for (final m in matches) {
      final s = await _matchRepo.getPlayerState(m.id);
      if (s != null) all.add(s);
    }
    if (!mounted) return;
    setState(() {
      _states = all;
      _loading = false;
    });
  }

  Map<String, double> get _averages {
    if (_states.isEmpty) return {};
    final n = _states.length;
    return {
      'confidence':
          _states.fold(0, (a, s) => a + s.confidence) / n,
      'focus': _states.fold(0, (a, s) => a + s.focus) / n,
      'pressure':
          _states.fold(0, (a, s) => a + s.pressure) / n,
      'tilt': _states.fold(0, (a, s) => a + s.tilt) / n,
      if (_states.any((s) => s.sleep != null))
        'sleep': _states
                .where((s) => s.sleep != null)
                .fold(0, (a, s) => a + s.sleep!) /
            _states.where((s) => s.sleep != null).length,
    };
  }

  Map<String, double> get _physicalAverages {
    if (_states.isEmpty) return {};
    final wFatigue = _states.where((s) => s.fatigue != null).toList();
    final wEnergy = _states.where((s) => s.energy != null).toList();
    final wEye = _states.where((s) => s.eyeCondition != null).toList();
    return {
      if (wFatigue.isNotEmpty)
        'fatigue':
            wFatigue.fold(0, (a, s) => a + s.fatigue!) / wFatigue.length,
      if (wEnergy.isNotEmpty)
        'energy':
            wEnergy.fold(0, (a, s) => a + s.energy!) / wEnergy.length,
      if (wEye.isNotEmpty)
        'eyeCondition': wEye.fold(0, (a, s) => a + s.eyeCondition!) / wEye.length,
    };
  }

  Widget _buildBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(value.toStringAsFixed(1) + '/5',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 5).clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                value <= 2
                    ? Colors.red
                    : value <= 3
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player State')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _states.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.psychology,
                            size: 64, color: AppTheme.primary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có dữ liệu Player State',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hoàn thành trận đấu đầu tiên để bắt đầu ghi nhận trạng thái tinh thần và thể chất.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle('Mental (trung bình ${_states.length} trận)'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            for (final entry in _averages.entries)
                              if (!['sleep'].contains(entry.key))
                                _buildBar(_labelize(entry.key), entry.value),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 16),
                    _sectionTitle('Physical'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            for (final entry in _physicalAverages.entries)
                              _buildBar(_labelize(entry.key), entry.value),
                            if (_averages['sleep'] != null)
                              _buildBar('Sleep (giờ/đêm)',
                                  (_averages['sleep'] ?? 7) / 2.4),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),
                    _sectionTitle('Trận gần đây'),
                    ..._states.reversed.take(5).map((s) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _colorFor(s.confidence),
                              child: Text('${s.confidence}',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(
                                'Match ${s.matchId.substring(0, s.matchId.length.clamp(0, 10))}…'),
                            subtitle: Text(
                                'Focus ${s.focus}/5  •  Pressure ${s.pressure}/5  •  Tilt ${s.tilt}/5'),
                            trailing: Text(_date(s.capturedAt)),
                          ),
                        )),
                  ],
                ),
    );
  }

  Widget _sectionTitle(String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(s,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      );

  String _labelize(String key) {
    return key.replaceAllMapped(RegExp(r'([A-Z])'),
        (m) => ' ${m.group(1)!.toLowerCase()}');
  }

  Color _colorFor(int confidence) {
    if (confidence <= 2) return Colors.red;
    if (confidence <= 3) return Colors.orange;
    return Colors.green;
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
