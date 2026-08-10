import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';

/// Sprint 4C Task 19 — Unified Timeline
///
/// Combines training sessions + match history into a single chronological view.
/// Coach AI reads temporal patterns across domains from this data.
class UnifiedTimelineScreen extends ConsumerStatefulWidget {
  const UnifiedTimelineScreen({super.key});

  @override
  ConsumerState<UnifiedTimelineScreen> createState() => _UnifiedTimelineScreenState();
}

class _UnifiedTimelineScreenState extends ConsumerState<UnifiedTimelineScreen> {
  bool _loading = true;
  String? _error;

  List<_TimelineEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trainingHistory = await ref.read(trainingHistoryProvider.future);
      final matchRepo = ref.read(matchRepositoryProvider);
      final matches = await matchRepo.getAllMatches();

      // Combine and sort by date (newest first)
      final entries = <_TimelineEntry>[];

      for (final session in trainingHistory) {
        entries.add(_TimelineEntry(
          id: session.id,
          type: _EntryType.training,
          date: session.completedAt,
          title: session.drillName,
          subtitle: 'Score: ${session.score}% • ${session.duration}m',
          icon: Icons.fitness_center,
          color: Colors.blue,
          drillCode: session.drillCode,
        ));
      }

      for (final match in matches) {
        entries.add(_TimelineEntry(
          id: match.id,
          type: _EntryType.match,
          date: match.createdAt,
          title: 'vs ${match.opponentName ?? match.opponent ?? 'Unknown'}',
          subtitle: match.resultSummary ?? '${match.playerScore}-${match.opponentScore}',
          icon: match.isWin ? Icons.emoji_events : Icons.sports,
          color: match.isWin ? Colors.green : Colors.red,
        ));
      }

      // Sort by date descending
      entries.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _entries.isEmpty
                  ? _buildEmpty()
                  : _buildTimeline(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chưa có hoạt động nào'),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu tập luyện hoặc ghi trận đấu để xem timeline.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // Group by date
    final grouped = <String, List<_TimelineEntry>>{};
    final fmt = DateFormat('EEEE, dd/MM');

    for (final entry in _entries) {
      final key = fmt.format(entry.date);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final dayEntries = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),
            // Entries for this date
            ...dayEntries.map((e) => _buildEntryCard(e)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _formatDateHeader(String formatted) {
    final now = DateTime.now();
    final today = DateFormat('EEEE, dd/MM').format(now);
    final yesterday = DateFormat('EEEE, dd/MM').format(now.subtract(const Duration(days: 1)));

    if (formatted == today) return 'Hôm nay';
    if (formatted == yesterday) return 'Hôm qua';
    return formatted;
  }

  Widget _buildEntryCard(_TimelineEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.color.withValues(alpha: 0.15),
          child: Icon(entry.icon, color: entry.color, size: 20),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: entry.type == _EntryType.training
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.type == _EntryType.training ? 'Tập' : 'Đấu',
                style: TextStyle(
                  fontSize: 10,
                  color: entry.type == _EntryType.training ? Colors.blue : Colors.purple,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Text(
          DateFormat('HH:mm').format(entry.date),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        onTap: () {
          if (entry.type == _EntryType.training) {
            context.push('/training/session/${entry.id}');
          } else {
            context.push('/play/match/${entry.id}/summary');
          }
        },
      ),
    );
  }
}

enum _EntryType { training, match }

class _TimelineEntry {
  final String id;
  final _EntryType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? drillCode;

  _TimelineEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.drillCode,
  });
}
