import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../domain/services/ai_progress_score_service.dart';

class AiProgressScoreCard extends ConsumerStatefulWidget {
  const AiProgressScoreCard({super.key, this.playerId});
  final String? playerId;

  @override
  ConsumerState<AiProgressScoreCard> createState() => _AiProgressScoreCardState();
}

class _AiProgressScoreCardState extends ConsumerState<AiProgressScoreCard> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = AiProgressScoreService(ref.read(matchRepositoryProvider));
    final data = await svc.compute(playerId: widget.playerId);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    final total = _data?['totalScore'] as int? ?? 0;
    final trend = _data?['trend'] as String? ?? 'steady';
    final breakdown =
        (_data?['breakdown'] as Map<String, dynamic>?) ?? const {};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: AppColors.primary(brightness)),
                const SizedBox(width: 8),
                const Text('Điểm tiến bộ theo AI',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _trendColor(trend, brightness).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(trend,
                      style: TextStyle(
                          color: _trendColor(trend, brightness),
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('$total / 100',
                style: const TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...breakdown.entries.map((e) => _bar(e.key, (e.value as num).toDouble(), brightness)),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double score, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (score / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.border(brightness),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary(brightness)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(score.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Color _trendColor(String trend, Brightness brightness) {
    switch (trend) {
      case 'rising':
        return AppColors.success;
      case 'declining':
        return AppColors.error;
      default:
        return AppColors.primary(brightness);
    }
  }
}