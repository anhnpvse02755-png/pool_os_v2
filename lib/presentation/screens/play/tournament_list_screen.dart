import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/tournament.dart';

class TournamentListScreen extends StatelessWidget {
  const TournamentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournaments = TournamentLibrary.tournaments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Đang diễn ra'),
                  Tab(text: 'Sắp tới'),
                  Tab(text: 'Đã kết thúc'),
                ],
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryGreen,
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _TournamentList(
                    tournaments: tournaments
                        .where((t) => t.status == 'in_progress')
                        .toList(),
                    emptyMessage: 'Không có giải đang diễn ra',
                  ),
                  _TournamentList(
                    tournaments: tournaments
                        .where((t) => t.status == 'upcoming')
                        .toList(),
                    emptyMessage: 'Không có giải sắp tới',
                  ),
                  _TournamentList(
                    tournaments: tournaments
                        .where((t) => t.status == 'completed')
                        .toList(),
                    emptyMessage: 'Không có giải đã kết thúc',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo giải đấu mới'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo giải'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

class _TournamentList extends StatelessWidget {
  final List<Tournament> tournaments;
  final String emptyMessage;

  const _TournamentList({
    required this.tournaments,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TournamentCard(
            tournament: tournament,
            onTap: () => context.push('/play/tournament/${tournament.id}'),
          ).animate().fadeIn(delay: (index * 100).ms),
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;

  const _TournamentCard({
    required this.tournament,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (tournament.status) {
      case 'in_progress':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (tournament.status) {
      case 'in_progress':
        return 'Đang diễn ra';
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return tournament.status;
    }
  }

  IconData _getTypeIcon() {
    switch (tournament.type) {
      case 'league':
        return Icons.groups;
      case 'local':
        return Icons.location_on;
      case 'regional':
        return Icons.map;
      case 'national':
        return Icons.flag;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(), size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        tournament.type.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tournament.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  tournament.venue ?? 'Chưa xác định',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${tournament.maxParticipants ?? 0} người',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                if (tournament.startDate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(tournament.startDate!),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
