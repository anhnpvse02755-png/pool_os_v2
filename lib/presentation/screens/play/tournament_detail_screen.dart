import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/models/tournament.dart';

class TournamentDetailScreen extends StatelessWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    final tournament = TournamentLibrary.getTournament(tournamentId);

    if (tournament == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chi tiết giải đấu')),
        body: Center(child: Text('Không tìm thấy giải đấu')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getStatusColor(tournament.status),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tournament.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                _RegisterButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đăng ký thành công!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                        Divider(color: AppColors.lightBorder),
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Địa điểm',
                          value: tournament.venue ?? 'Chưa xác định',
                        ),
                        Divider(color: AppColors.lightBorder),
                        _InfoRow(
                          icon: Icons.people,
                          label: 'Số người tham gia',
                          value: '${tournament.maxParticipants ?? 0}',
                        ),
                        Divider(color: AppColors.lightBorder),
                        _InfoRow(
                          icon: Icons.category,
                          label: 'Loại giải',
                          value: _getTypeName(tournament.type),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  SizedBox(height: AppSpacing.xxl),

                  // Bracket Section
                  _SectionHeader(title: 'Cặp đấu'),
                  SizedBox(height: AppSpacing.sm),

                  // Demo bracket
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                        SizedBox(height: AppSpacing.xxl),
                        _BracketRound(
                          name: 'Tứ kết',
                          matches: [
                            _BracketMatch.demo(player1: 'Nguyễn Văn A', player2: 'Trần Văn B'),
                            _BracketMatch.demo(player1: 'Hoàng Văn E', player2: 'Đặng Văn F'),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        _BracketRound(
                          name: 'Bán kết',
                          matches: [
                            _BracketMatch.demo(player1: 'Nguyễn Văn A', player2: 'Hoàng Văn E'),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        _BracketRound(
                          name: 'Chung kết',
                          matches: [
                            _BracketMatch.demo(player1: '?', player2: '?', isFinal: true),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  SizedBox(height: AppSpacing.xxl),

                  // Participants
                  _SectionHeader(title: 'Người tham gia'),
                  SizedBox(height: AppSpacing.sm),

                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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

                  SizedBox(height: 100),
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
        return AppColors.success;
      case 'upcoming':
        return AppColors.accent;
      case 'completed':
        return AppColors.lightTextSecondary;
      default:
        return AppColors.lightTextSecondary;
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
    );
  }
}

class _RegisterButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _RegisterButton({required this.onPressed});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          margin: EdgeInsets.only(right: AppSpacing.sm),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            'ĐĂNG KÝ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
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
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600),
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
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        ...matches.map((m) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isFinal ? AppColors.gold.withValues(alpha: 0.08) : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isFinal ? AppColors.gold : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _PlayerRow(
            name: player1,
            score: score1,
            isWinner: winner == 1,
          ),
          Divider(height: 4, color: AppColors.lightBorder),
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
          Icon(Icons.check_circle, size: 16, color: AppColors.success)
        else
          SizedBox(width: 16),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            name == '?' ? 'Chưa xác định' : name,
            style: TextStyle(
              fontWeight: isWinner ? FontWeight.w600 : FontWeight.normal,
              color: name == '?' ? AppColors.lightTextTertiary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        if (score != null)
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isWinner ? AppColors.success : AppColors.lightTextSecondary,
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
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(name)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Seed #$seed',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
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
        return AppColors.gold;
      case 2:
        return AppColors.lightTextSecondary;
      case 3:
        return Color(0xFFCD7F32);
      default:
        return AppColors.lightBorder;
    }
  }
}
