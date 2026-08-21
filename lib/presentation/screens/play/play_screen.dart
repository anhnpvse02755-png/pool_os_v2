import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/play/history'),
            tooltip: 'Lịch sử đấu',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            _buildSectionTitle(context, 'Bắt đầu chơi'),
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
                Expanded(
                  child: _PlayCard(
                    icon: Icons.groups,
                    title: 'Giao lưu',
                    subtitle: 'Đấu với bạn',
                    color: Colors.blue,
                    onTap: () => context.push('/play/friendly'),
                  ),
                ),
              ],
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Match Recording
            _buildSectionTitle(context, 'Ghi nhận trận đấu'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MatchRecordingCard(
                    onTap: () => context.push('/play/recording'),
                  ),
                ),
                const SizedBox(width: 12),
                // Sprint-12: Manual Match Log
                Expanded(
                  child: _PlayCard(
                    icon: Icons.edit_note,
                    title: 'Ghi kết quả',
                    subtitle: 'Nhập kết quả thủ công',
                    color: Colors.green,
                    onTap: () => context.push('/play/log'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // Competition Types
            _buildSectionTitle(context, 'Thể loại thi đấu'),
            const SizedBox(height: 12),
            _CompetitionTypeCard(
              icon: Icons.emoji_events,
              title: 'Giải đấu',
              subtitle: 'Tournament',
              color: Colors.purple,
              onTap: () => context.push('/play/tournament'),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            _CompetitionTypeCard(
              icon: Icons.groups,
              title: 'League',
              subtitle: 'Đấu league với CLB',
              color: Colors.teal,
              onTap: () => context.push('/play/tournament'),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Recent Matches
            _buildSectionTitle(
              context,
              'Trận gần đây',
              action: TextButton(
                onPressed: () => context.push('/play/history'),
                child: const Text('Xem tất cả'),
              ),
            ),
            const SizedBox(height: 12),
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
                fontWeight: FontWeight.bold,
              ),
        ),
        if (action != null) action,
      ],
    );
  }
}

class _PlayCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchRecordingCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MatchRecordingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.videocam,
                color: AppTheme.primaryGreen,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Match Recording',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ghi lại trận đấu thực tế, tính điểm tự động',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _CompetitionTypeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
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
        const SizedBox(height: 8),
        _RecentMatchItem(
          date: 'Hôm qua, 20:00',
          player1: 'Bạn',
          player2: 'Minh',
          score: '3 - 7',
          result: 'lose',
        ),
        const SizedBox(height: 8),
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
  final String result; // 'win', 'lose', 'draw'

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
        return Colors.green;
      case 'lose':
        return Colors.red;
      default:
        return Colors.grey;
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$player1 vs $player2',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  score,
                  style: TextStyle(
                    color: resultColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                resultLabel,
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: AppTheme.textSecondary,
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
      appBar: AppBar(title: const Text('Đấu nhanh')),
      body: const Center(
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
      appBar: AppBar(title: const Text('Giao lưu')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.blue),
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
      appBar: AppBar(title: const Text('Match Recording')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: AppTheme.primaryGreen),
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
      appBar: AppBar(title: const Text('Lịch sử đấu')),
      body: const Center(
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
