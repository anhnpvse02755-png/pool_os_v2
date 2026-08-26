import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/models/tournament.dart';

class TournamentListScreen extends StatelessWidget {
  const TournamentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tournaments = TournamentLibrary.tournaments;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Giải đấu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Tabs
            Container(
              color: AppColors.lightSurface,
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Đang diễn ra',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Sắp tới',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Đã kết thúc',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.lightTextSecondary,
                indicatorColor: AppColors.accent,
                indicatorWeight: 3,
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            context.push('/play/tournament/create');
          },
          icon: Icon(Icons.add),
          label: Text('Tạo giải'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 40,
                color: AppColors.lightTextTertiary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              emptyMessage,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _TournamentCard(
            tournament: tournament,
            onTap: () => context.push('/play/tournament/${tournament.id}'),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
        );
      },
    );
  }
}

class _TournamentCard extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback onTap;

  const _TournamentCard({
    required this.tournament,
    required this.onTap,
  });

  @override
  State<_TournamentCard> createState() => _TournamentCardState();
}

class _TournamentCardState extends State<_TournamentCard> {
  double _scale = 1.0;

  Color _getStatusColor() {
    switch (widget.tournament.status) {
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

  String _getStatusText() {
    switch (widget.tournament.status) {
      case 'in_progress':
        return 'Đang diễn ra';
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return widget.tournament.status;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.tournament.type) {
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getTypeIcon(), size: 12, color: AppColors.lightTextSecondary),
                        SizedBox(width: 4),
                        Text(
                          widget.tournament.type.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                widget.tournament.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    text: widget.tournament.venue ?? 'Chưa xác định',
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.people_outline,
                    text: '${widget.tournament.maxParticipants ?? 0} người',
                  ),
                  if (widget.tournament.startDate != null) ...[
                    SizedBox(width: AppSpacing.md),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text: _formatDate(widget.tournament.startDate!),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.lightTextSecondary),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
