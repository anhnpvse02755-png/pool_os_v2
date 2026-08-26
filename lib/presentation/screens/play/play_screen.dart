import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Play',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppColors.lightTextSecondary),
            onPressed: () => context.push('/play/history'),
            tooltip: 'Lịch sử đấu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildSectionTitle(context, 'Bắt đầu chơi'),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _PlayCard(
                    icon: Icons.flash_on,
                    title: 'Đấu nhanh',
                    subtitle: 'Bắt đầu ngay',
                    color: Colors.orange,
                    onTap: () => context.push('/play/quick'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PlayCard(
                    icon: Icons.groups,
                    title: 'Giao lưu',
                    subtitle: 'Đấu với bạn',
                    color: AppColors.accent,
                    onTap: () => context.push('/play/friendly'),
                  ),
                ),
              ],
            ).animate().fadeIn(),

            SizedBox(height: AppSpacing.xxl),

            // Match Recording
            _buildSectionTitle(context, 'Ghi nhận trận đấu'),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MatchRecordingCard(
                    onTap: () => context.push('/play/recording'),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PlayCard(
                    icon: Icons.edit_note,
                    title: 'Ghi kết quả',
                    subtitle: 'Nhập kết quả thủ công',
                    color: AppColors.success,
                    onTap: () => context.push('/play/log'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: AppSpacing.xxl),

            // Competition Types
            _buildSectionTitle(context, 'Thể loại thi đấu'),
            SizedBox(height: AppSpacing.md),
            _CompetitionTypeCard(
              icon: Icons.emoji_events,
              title: 'Giải đấu',
              subtitle: 'Tournament',
              color: Colors.purple,
              onTap: () => context.push('/play/tournament'),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.md),
            _CompetitionTypeCard(
              icon: Icons.groups,
              title: 'League',
              subtitle: 'Đấu league với CLB',
              color: Colors.teal,
              onTap: () => context.push('/play/tournament'),
            ).animate().fadeIn(delay: 250.ms),

            SizedBox(height: AppSpacing.xxl),

            // Recent Matches
            _buildSectionTitle(
              context,
              'Trận gần đây',
              action: TextButton(
                onPressed: () => context.push('/play/history'),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _RecentMatchesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
        ),
        if (action != null) action,
      ],
    );
  }
}

class _PlayCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PlayCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PlayCard> createState() => _PlayCardState();
}

class _PlayCardState extends State<_PlayCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, widget.color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchRecordingCard extends StatefulWidget {
  final VoidCallback onTap;

  const _MatchRecordingCard({required this.onTap});

  @override
  State<_MatchRecordingCard> createState() => _MatchRecordingCardState();
}

class _MatchRecordingCardState extends State<_MatchRecordingCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
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
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.videocam,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Recording',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ghi lại trận đấu thực tế, tính điểm tự động',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionTypeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CompetitionTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CompetitionTypeCard> createState() => _CompetitionTypeCardState();
}

class _CompetitionTypeCardState extends State<_CompetitionTypeCard> {
  double _scale = 1.0;

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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentMatchesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecentMatchItem(
          date: 'Hôm nay, 15:30',
          player1: 'Bạn',
          player2: 'Nam',
          score: '7 - 5',
          result: 'win',
        ),
        SizedBox(height: AppSpacing.sm),
        _RecentMatchItem(
          date: 'Hôm qua, 20:00',
          player1: 'Bạn',
          player2: 'Minh',
          score: '3 - 7',
          result: 'lose',
        ),
        SizedBox(height: AppSpacing.sm),
        _RecentMatchItem(
          date: '01/08/2026',
          player1: 'Bạn',
          player2: 'CLB Sài Gòn',
          score: '11 - 9',
          result: 'win',
        ),
      ],
    );
  }
}

class _RecentMatchItem extends StatelessWidget {
  final String date;
  final String player1;
  final String player2;
  final String score;
  final String result;

  const _RecentMatchItem({
    required this.date,
    required this.player1,
    required this.player2,
    required this.score,
    required this.result,
  });

  Color get resultColor {
    switch (result) {
      case 'win':
        return AppColors.success;
      case 'lose':
        return AppColors.error;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String get resultLabel {
    switch (result) {
      case 'win':
        return 'Thắng';
      case 'lose':
        return 'Thua';
      default:
        return 'Hòa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                result == 'win' ? 'W' : result == 'lose' ? 'L' : 'D',
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$player1 vs $player2',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  score,
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  resultLabel,
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                date,
                style: TextStyle(
                  color: AppColors.lightTextTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for Play features
class QuickMatchPlaceholder extends StatelessWidget {
  const QuickMatchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text('Đấu nhanh', style: TextStyle(color: AppColors.lightTextPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Đấu nhanh', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class FriendlyMatchPlaceholder extends StatelessWidget {
  const FriendlyMatchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text('Giao lưu', style: TextStyle(color: AppColors.lightTextPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            Text('Giao lưu với bạn', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class MatchRecordingPlaceholder extends StatelessWidget {
  const MatchRecordingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text('Match Recording', style: TextStyle(color: AppColors.lightTextPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            Text('Match Recording', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class MatchHistoryPlaceholder extends StatelessWidget {
  const MatchHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        title: Text('Lịch sử đấu', style: TextStyle(color: AppColors.lightTextPrimary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Lịch sử đấu', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Tính năng đang phát triển', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
