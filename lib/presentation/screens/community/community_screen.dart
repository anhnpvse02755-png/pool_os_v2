import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';

/// Community Screen - Redesigned with Minimalist Luxury
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          backgroundColor: AppColors.background(brightness),
          elevation: 0,
          title: Text(
            'Cộng đồng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          bottom: TabBar(
            labelColor: AppColors.accentColor(brightness),
            unselectedLabelColor: AppColors.textSecondary(brightness),
            indicatorColor: AppColors.accentColor(brightness),
            tabs: const [
              Tab(text: 'Bảng xếp hạng'),
              Tab(text: 'Người chơi'),
              Tab(text: 'Hoạt động'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderboardTab(brightness: brightness),
            _PlayersTab(brightness: brightness),
            _ActivityTab(brightness: brightness),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final Brightness brightness;
  const _LeaderboardTab({required this.brightness});

  @override
  Widget build(BuildContext context) {
    final leaders = [
      {'name': 'Nguyễn Văn A', 'rank': 'Pro', 'points': 2500, 'avatar': 'A'},
      {'name': 'Trần Văn B', 'rank': 'Pro', 'points': 2350, 'avatar': 'B'},
      {'name': 'Lê Văn C', 'rank': 'Expert', 'points': 2100, 'avatar': 'C'},
      {'name': 'Phạm Văn D', 'rank': 'Expert', 'points': 1950, 'avatar': 'D'},
      {'name': 'Hoàng Văn E', 'rank': 'Advanced', 'points': 1800, 'avatar': 'E'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentColor(brightness).withValues(alpha: 0.1),
                AppColors.surface(brightness),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumItem(
                rank: 2,
                name: leaders[1]['name'] as String,
                points: leaders[1]['points'] as int,
                avatar: leaders[1]['avatar'] as String,
                height: 80,
                color: Colors.grey.shade400,
                brightness: brightness,
              ),
              _PodiumItem(
                rank: 1,
                name: leaders[0]['name'] as String,
                points: leaders[0]['points'] as int,
                avatar: leaders[0]['avatar'] as String,
                height: 100,
                color: AppColors.gold,
                brightness: brightness,
              ),
              _PodiumItem(
                rank: 3,
                name: leaders[2]['name'] as String,
                points: leaders[2]['points'] as int,
                avatar: leaders[2]['avatar'] as String,
                height: 60,
                color: Colors.brown.shade300,
                brightness: brightness,
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Bảng xếp hạng',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...leaders.skip(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final leader = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _LeaderboardItem(
              rank: index + 4,
              name: leader['name'] as String,
              points: leader['points'] as int,
              avatar: leader['avatar'] as String,
              brightness: brightness,
            ).animate().fadeIn(delay: (index * 100).ms),
          );
        }),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final String avatar;
  final double height;
  final Color color;
  final Brightness brightness;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
    required this.height,
    required this.color,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -5,
              left: 0,
              right: 0,
              child: Icon(
                rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
                color: color,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name.split(' ').last,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        Text(
          '$points pts',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final String avatar;
  final Brightness brightness;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background(brightness),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary(brightness),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppColors.accentColor(brightness),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(brightness),
              ),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  final Brightness brightness;
  const _PlayersTab({required this.brightness});

  @override
  Widget build(BuildContext context) {
    final players = [
      {'name': 'Nguyễn Văn A', 'level': 'Pro', 'drills': 45, 'avatar': 'A'},
      {'name': 'Trần Văn B', 'level': 'Pro', 'drills': 42, 'avatar': 'B'},
      {'name': 'Lê Văn C', 'level': 'Expert', 'drills': 38, 'avatar': 'C'},
      {'name': 'Phạm Văn D', 'level': 'Expert', 'drills': 35, 'avatar': 'D'},
      {'name': 'Hoàng Văn E', 'level': 'Advanced', 'drills': 30, 'avatar': 'E'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PlayerCard(
            name: player['name'] as String,
            level: player['level'] as String,
            drills: player['drills'] as int,
            avatar: player['avatar'] as String,
            onTap: () => _showPlayerProfile(context, player),
            brightness: brightness,
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }

  void _showPlayerProfile(BuildContext context, Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(Theme.of(context).brightness),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PlayerProfileSheet(player: player),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final String level;
  final int drills;
  final String avatar;
  final VoidCallback onTap;
  final Brightness brightness;

  const _PlayerCard({
    required this.name,
    required this.level,
    required this.drills,
    required this.avatar,
    required this.onTap,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.sm(brightness),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: AppColors.accentColor(brightness),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor(level).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: _getLevelColor(level),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.fitness_center, size: 14, color: AppColors.textSecondary(brightness)),
                      const SizedBox(width: 4),
                      Text(
                        '$drills drills',
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: AppColors.accentColor(brightness)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã gửi lời mời kết bạn đến $name'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Pro':
        return Colors.purple;
      case 'Expert':
        return AppColors.warning;
      case 'Advanced':
        return Colors.blue;
      default:
        return AppColors.success;
    }
  }
}

class _PlayerProfileSheet extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerProfileSheet({required this.player});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['avatar'] as String,
                style: TextStyle(
                  color: AppColors.accentColor(brightness),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            player['name'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              player['level'] as String,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(label: 'Drills', value: '${player['drills']}', brightness: brightness),
              _StatColumn(label: 'Win Rate', value: '72%', brightness: brightness),
              _StatColumn(label: 'Rank', value: '#1', brightness: brightness),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã gửi lời mời kết bạn'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(Icons.person_add, color: AppColors.accentColor(brightness)),
                  label: Text('Kết bạn', style: TextStyle(color: AppColors.accentColor(brightness))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentColor(brightness)),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã gửi lời thách đấu'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(Icons.sports_cricket, color: Colors.white),
                  label: Text('Thách đấu', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor(brightness),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Brightness brightness;

  const _StatColumn({required this.label, required this.value, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final Brightness brightness;
  const _ActivityTab({required this.brightness});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'user': 'Nguyễn Văn A', 'action': 'hoàn thành', 'target': 'Position Lv3', 'time': '2 phút trước', 'avatar': 'A'},
      {'user': 'Trần Văn B', 'action': 'đạt rank', 'target': 'Expert', 'time': '15 phút trước', 'avatar': 'B'},
      {'user': 'Lê Văn C', 'action': 'thi đấu', 'target': 'thắng 3-1', 'time': '1 giờ trước', 'avatar': 'C'},
      {'user': 'Phạm Văn D', 'action': 'đăng ký', 'target': 'Weekly League', 'time': '2 giờ trước', 'avatar': 'D'},
      {'user': 'Hoàng Văn E', 'action': 'chia sẻ', 'target': 'Achievement mới', 'time': '3 giờ trước', 'avatar': 'E'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _ActivityItem(
            user: activity['user'] as String,
            action: activity['action'] as String,
            target: activity['target'] as String,
            time: activity['time'] as String,
            avatar: activity['avatar'] as String,
            brightness: brightness,
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String user;
  final String action;
  final String target;
  final String time;
  final String avatar;
  final Brightness brightness;

  const _ActivityItem({
    required this.user,
    required this.action,
    required this.target,
    required this.time,
    required this.avatar,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppColors.accentColor(brightness),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: AppColors.textPrimary(brightness)),
                children: [
                  TextSpan(
                    text: user.split(' ').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $action '),
                  TextSpan(
                    text: target,
                    style: TextStyle(color: AppColors.accentColor(brightness)),
                  ),
                ],
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: AppColors.textTertiary(brightness),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
