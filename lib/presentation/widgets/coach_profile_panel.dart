import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/match_repository.dart';
import '../../domain/services/coach_profile_aggregator.dart';

/// Coach profile panel — embeds in Coach screen or Home.
class CoachProfilePanel extends ConsumerStatefulWidget {
  const CoachProfilePanel({super.key, this.playerId = ''});
  final String playerId;

  @override
  ConsumerState<CoachProfilePanel> createState() => _CoachProfilePanelState();
}

class _CoachProfilePanelState extends ConsumerState<CoachProfilePanel> {
  CoachProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await CoachProfileAggregator(ref.read(matchRepositoryProvider))
        .generate(widget.playerId);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  Color _toneColor(String tone) {
    switch (tone) {
      case 'Hot':
        return Colors.redAccent;
      case 'Rising':
        return Colors.green;
      case 'Slumping':
        return Colors.grey;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    final p = _profile;
    if (p == null || p.matchesAnalyzed == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.insights, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Chưa có match nào trong 30 ngày để AI Coach phân tích.'),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text('AI Coach Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _toneColor(p.tone).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.tone,
                      style: TextStyle(
                          color: _toneColor(p.tone), fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kpi('Matches', '${p.matchesAnalyzed}')),
                const SizedBox(width: 8),
                Expanded(child: _kpi('Win %', '${p.winRate.toStringAsFixed(1)}%')),
                const SizedBox(width: 8),
                Expanded(child: _kpi('Wins/Losses', '${p.wins}/${p.losses}')),
              ],
            ),
            const SizedBox(height: 12),
            ...p.skillScores.entries.map((e) => _skillBar(e.key, e.value)),
            if (p.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Recommendations',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              ...p.recommendations.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(children: [
                      Icon(Icons.arrow_right, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(r)),
                    ]),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kpi(String label, String value) => Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      );

  Widget _skillBar(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${score.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}
