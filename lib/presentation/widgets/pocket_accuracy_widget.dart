// ============================================================================
// POCKET ACCURACY WIDGET - Sprint-9C
// Displays pocket-level accuracy statistics from match recording data
// ============================================================================

import 'package:flutter/material.dart';
import '../../data/models/match.dart';

/// Pocket accuracy data extracted from rack data
class PocketAccuracy {
  final String pocketName;
  final String pocketPosition;
  final int attempts;
  final int made;
  final double accuracy;

  const PocketAccuracy({
    required this.pocketName,
    required this.pocketPosition,
    required this.attempts,
    required this.made,
    required this.accuracy,
  });
}

/// Widget to display pocket-level accuracy statistics
class PocketAccuracyWidget extends StatelessWidget {
  const PocketAccuracyWidget({
    super.key,
    required this.racks,
    this.showDetails = true,
  });

  final List<Rack> racks;
  final bool showDetails;

  /// Extract pocket accuracy from rack shots
  /// Note: Current match schema doesn't store per-pocket shot data,
  /// so we estimate from overall statistics
  List<PocketAccuracy> calculateAccuracy() {
    if (racks.isEmpty) return [];

    final totalBallsPotted = racks.fold<int>(0, (sum, r) => sum + r.totalBallsPotted);
    final totalMisses = racks.fold<int>(0, (sum, r) => sum + r.easyMissCount + r.hardMissCount);
    final totalAttempts = totalBallsPotted + totalMisses;

    if (totalAttempts == 0) return [];

    // Estimate per-pocket distribution (simplified model)
    // Real implementation would need shot-by-shot coordinates
    final pockets = <String, _PocketStats>{
      'Corner 1': _PocketStats(),
      'Side 1': _PocketStats(),
      'Corner 2': _PocketStats(),
      'Side 2': _PocketStats(),
      'Corner 3': _PocketStats(),
      'Corner 4': _PocketStats(),
    };

    // Distribute shots based on typical 8-ball shot distribution
    // Corner pockets: ~70% of shots, Side pockets: ~30%
    final cornerShare = (totalBallsPotted * 0.7 / 4).round();
    final sideShare = (totalBallsPotted * 0.3 / 2).round();

    for (final pocket in pockets.keys) {
      final isCorner = pocket.startsWith('Corner');
      final share = isCorner ? cornerShare : sideShare;

      // Estimate made based on overall accuracy
      final accuracy = totalAttempts > 0 ? (totalBallsPotted / totalAttempts) : 0.7;
      final made = (share * accuracy).round();

      pockets[pocket] = _PocketStats(attempts: share, made: made);
    }

    return pockets.entries.map((e) {
      final stats = e.value;
      final acc = stats.attempts > 0 ? (stats.made / stats.attempts) * 100 : 0.0;
      return PocketAccuracy(
        pocketName: e.key,
        pocketPosition: _getPosition(e.key),
        attempts: stats.attempts,
        made: stats.made,
        accuracy: acc,
      );
    }).toList();
  }

  String _getPosition(String pocket) {
    switch (pocket) {
      case 'Corner 1':
        return 'Top-Left';
      case 'Side 1':
        return 'Top-Middle';
      case 'Corner 2':
        return 'Top-Right';
      case 'Side 2':
        return 'Bottom-Left';
      case 'Corner 3':
        return 'Bottom-Middle';
      case 'Corner 4':
        return 'Bottom-Right';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = calculateAccuracy();

    if (accuracy.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary header
        _buildSummaryHeader(context, accuracy),
        const SizedBox(height: 16),

        // Pocket grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: accuracy.length,
          itemBuilder: (context, index) {
            return _PocketCard(pocket: accuracy[index]);
          },
        ),

        // Note about data availability
        const SizedBox(height: 12),
        _buildDataNote(context),
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context, List<PocketAccuracy> accuracy) {
    final totalAttempts = accuracy.fold<int>(0, (sum, p) => sum + p.attempts);
    final totalMade = accuracy.fold<int>(0, (sum, p) => sum + p.made);
    final overallAccuracy = totalAttempts > 0 ? (totalMade / totalAttempts) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Tổng bi',
            value: '$totalMade/$totalAttempts',
            color: Theme.of(context).colorScheme.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          _SummaryItem(
            label: 'Accuracy',
            value: '${overallAccuracy.toStringAsFixed(1)}%',
            color: _getAccuracyColor(overallAccuracy),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.gps_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cần ghi ít nhất 1 trận đấu để xem thống kê',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dữ liệu ước tính từ thống kê tổng. Shot-by-shot coordinates sẽ cải thiện độ chính xác.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.blue;
    if (accuracy >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _PocketStats {
  int attempts;
  int made;
  _PocketStats({this.attempts = 0, this.made = 0});
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _PocketCard extends StatelessWidget {
  const _PocketCard({required this.pocket});

  final PocketAccuracy pocket;

  @override
  Widget build(BuildContext context) {
    final accuracyColor = _getAccuracyColor(pocket.accuracy);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pocket icon
          Icon(
            Icons.gps_fixed,
            size: 20,
            color: accuracyColor,
          ),
          const SizedBox(height: 4),

          // Accuracy percentage
          Text(
            '${pocket.accuracy.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accuracyColor,
                ),
          ),

          // Pocket name
          Text(
            pocket.pocketName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),

          // Attempts
          Text(
            '${pocket.made}/${pocket.attempts}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.blue;
    if (accuracy >= 40) return Colors.orange;
    return Colors.red;
  }
}
