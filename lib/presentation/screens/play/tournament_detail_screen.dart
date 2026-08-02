import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/tournament.dart';

class TournamentDetailScreen extends StatelessWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    final tournament = TournamentLibrary.getTournament(tournamentId);

    if (tournament == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy giải đấu')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tournament.name,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(tournament.status),
                      _getStatusColor(tournament.status).withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              if (tournament.status == 'upcoming')
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đăng ký thành công!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    'ĐĂNG KÝ',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
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
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Thời gian',
                          value: tournament.startDate != null
                              ? '${_formatDate(tournament.startDate!)} - ${_formatDate(tournament.endDate ?? tournament.startDate!)}'
                              : 'Chưa xác định',
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Địa điểm',
                          value: tournament.venue ?? 'Chưa xác định',
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.people,
                          label: 'Số người tham gia',
                          value: '${tournament.maxParticipants ?? 0}',
                        ),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.category,
                          label: 'Loại giải',
                          value: _getTypeName(tournament.type),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 24),

                  // Bracket Section
                  Text(
                    'Cặp đấu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Demo bracket
                  Container(
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
                        _BracketRound(
                          name: 'Vòng 1/8',
                          matches: [
                            _BracketMatch.demo(player1: 'Nguyễn Văn A', player2: 'Trần Văn B', score1: 3, score2: 1, winner: 1),
                            _BracketMatch.demo(player1: 'Lê Văn C', player2: 'Phạm Văn D', score1: 2, score2: 3, winner: 2),
                            _BracketMatch.demo(player1: 'Hoàng Văn E', player2: 'Đặng Văn F'),
                            _BracketMatch.demo(player1: 'Bùi Văn G', player2: 'Đỗ Văn H'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BracketRound(
                          name: 'Tứ kết',
                          matches: [
                            _BracketMatch.demo(player1: 'Nguyễn Văn A', player2: 'Trần Văn B'),
                            _BracketMatch.demo(player1: 'Hoàng Văn E', player2: 'Đặng Văn F'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BracketRound(
                          name: 'Bán kết',
                          matches: [
                            _BracketMatch.demo(player1: 'Nguyễn Văn A', player2: 'Hoàng Văn E'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BracketRound(
                          name: 'Chung kết',
                          matches: [
                            _BracketMatch.demo(player1: '?', player2: '?', isFinal: true),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Participants
                  Text(
                    'Người tham gia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  Container(
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
                      children: List.generate(8, (index) {
                        return _ParticipantRow(
                          rank: index + 1,
                          name: _getDemoName(index),
                          seed: index + 1,
                        );
                      }),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getTypeName(String type) {
    switch (type) {
      case 'league':
        return 'Giải đấu thường xuyên';
      case 'local':
        return 'Giải địa phương';
      case 'regional':
        return 'Giải khu vực';
      case 'national':
        return 'Giải quốc gia';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _getDemoName(int index) {
    final names = [
      'Nguyễn Văn A', 'Trần Văn B', 'Lê Văn C', 'Phạm Văn D',
      'Hoàng Văn E', 'Đặng Văn F', 'Bùi Văn G', 'Đỗ Văn H',
    ];
    return index < names.length ? names[index] : 'Player ${index + 1}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _BracketRound extends StatelessWidget {
  final String name;
  final List<_BracketMatch> matches;

  const _BracketRound({
    required this.name,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        ...matches.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: m,
            )),
      ],
    );
  }
}

class _BracketMatch extends StatelessWidget {
  final String player1;
  final String player2;
  final int? score1;
  final int? score2;
  final int? winner;
  final bool isFinal;

  const _BracketMatch._({
    required this.player1,
    required this.player2,
    this.score1,
    this.score2,
    this.winner,
    this.isFinal = false,
  });

  factory _BracketMatch.demo({
    required String player1,
    required String player2,
    int? score1,
    int? score2,
    int? winner,
    bool isFinal = false,
  }) {
    return _BracketMatch._(
      player1: player1,
      player2: player2,
      score1: score1,
      score2: score2,
      winner: winner,
      isFinal: isFinal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasWinner = winner != null;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isFinal ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFinal ? Colors.amber.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          _PlayerRow(
            name: player1,
            score: score1,
            isWinner: winner == 1,
          ),
          const Divider(height: 4),
          _PlayerRow(
            name: player2,
            score: score2,
            isWinner: winner == 2,
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final int? score;
  final bool isWinner;

  const _PlayerRow({
    required this.name,
    this.score,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isWinner)
          Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen)
        else
          const SizedBox(width: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name == '?' ? 'Chưa xác định' : name,
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              color: name == '?' ? Colors.grey : Colors.black,
            ),
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? AppTheme.primaryGreen : Colors.grey,
            ),
          ),
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  final int rank;
  final String name;
  final int seed;

  const _ParticipantRow({
    required this.rank,
    required this.name,
    required this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Seed #$seed',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.grey.shade300;
    }
  }
}
