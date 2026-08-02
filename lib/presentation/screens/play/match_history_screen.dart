import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Load from database
    final matches = <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử trận đấu'),
      ),
      body: matches.isEmpty
          ? _buildEmptyState(context)
          : _buildMatchList(context, matches),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_cricket, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Chưa có trận đấu nào',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu ghi lại trận đấu để xem lịch sử',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/play/recording'),
              icon: const Icon(Icons.add),
              label: const Text('Record Match'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchList(BuildContext context, List<dynamic> matches) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _MatchCard(match: match).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final dynamic match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final isWin = match.result == 'win';

    return InkWell(
      onTap: () {
        // TODO: Navigate to match detail
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Result badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isWin
                        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                        size: 16,
                        color: isWin ? AppTheme.primaryGreen : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isWin ? 'Thắng' : 'Thua',
                        style: TextStyle(
                          color: isWin ? AppTheme.primaryGreen : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Match type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match.matchType ?? 'Friendly',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${match.playerScore}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isWin ? AppTheme.primaryGreen : Colors.grey.shade600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Text(
                  '${match.opponentScore}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isWin ? Colors.grey.shade600 : Colors.red,
                  ),
                ),
              ],
            ),
            if (match.opponent != null) ...[
              const SizedBox(height: 4),
              Text(
                'vs ${match.opponent}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                  icon: Icons.timer,
                  label: _formatDuration(match.duration),
                ),
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(match.createdAt),
                ),
                if (match.racks != null)
                  _InfoChip(
                    icon: Icons.layers,
                    label: '${match.racks.length} racks',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
