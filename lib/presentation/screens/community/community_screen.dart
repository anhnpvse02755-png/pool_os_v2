import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cộng đồng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bảng xếp hạng'),
              Tab(text: 'Người chơi'),
              Tab(text: 'Hoạt động'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LeaderboardTab(),
            _PlayersTab(),
            _ActivityTab(),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Demo data
    final leaders = [
      {'name': 'Nguyễn Văn A', 'rank': 'Pro', 'points': 2500, 'avatar': 'A'},
      {'name': 'Trần Văn B', 'rank': 'Pro', 'points': 2350, 'avatar': 'B'},
      {'name': 'Lê Văn C', 'rank': 'Expert', 'points': 2100, 'avatar': 'C'},
      {'name': 'Phạm Văn D', 'rank': 'Expert', 'points': 1950, 'avatar': 'D'},
      {'name': 'Hoàng Văn E', 'rank': 'Advanced', 'points': 1800, 'avatar': 'E'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top 3 Podium
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.1),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd
              _PodiumItem(
                rank: 2,
                name: leaders[1]['name'] as String,
                points: leaders[1]['points'] as int,
                avatar: leaders[1]['avatar'] as String,
                height: 80,
                color: Colors.grey.shade400,
              ),
              // 1st
              _PodiumItem(
                rank: 1,
                name: leaders[0]['name'] as String,
                points: leaders[0]['points'] as int,
                avatar: leaders[0]['avatar'] as String,
                height: 100,
                color: Colors.amber,
              ),
              // 3rd
              _PodiumItem(
                rank: 3,
                name: leaders[2]['name'] as String,
                points: leaders[2]['points'] as int,
                avatar: leaders[2]['avatar'] as String,
                height: 60,
                color: Colors.brown.shade300,
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),

        // Rest of leaderboard
        Text(
          'Bảng xếp hạng',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        ...leaders.skip(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final leader = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LeaderboardItem(
              rank: index + 4,
              name: leader['name'] as String,
              points: leader['points'] as int,
              avatar: leader['avatar'] as String,
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

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
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
        const SizedBox(height: 8),
        Text(
          name.split(' ').last,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          '$points pts',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        // Podium
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
              style: const TextStyle(
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

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PlayerCard(
            name: player['name'] as String,
            level: player['level'] as String,
            drills: player['drills'] as int,
            avatar: player['avatar'] as String,
            onTap: () => _showPlayerProfile(context, player),
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }

  void _showPlayerProfile(BuildContext context, Map<String, dynamic> player) {
    showModalBottomSheet(
      context: context,
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

  const _PlayerCard({
    required this.name,
    required this.level,
    required this.drills,
    required this.avatar,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      Icon(Icons.fitness_center, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '$drills drills',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: AppTheme.primaryGreen),
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
        return Colors.orange;
      case 'Advanced':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}

class _PlayerProfileSheet extends StatelessWidget {
  final Map<String, dynamic> player;

  const _PlayerProfileSheet({required this.player});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['avatar'] as String,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            player['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              player['level'] as String,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn(label: 'Drills', value: '${player['drills']}'),
              _StatColumn(label: 'Win Rate', value: '72%'),
              _StatColumn(label: 'Rank', value: '#${1}'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi lời mời kết bạn'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Kết bạn'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi lời thách đấu'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.sports_cricket),
                  label: const Text('Thách đấu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
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

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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

class _ActivityTab extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ActivityItem(
            user: activity['user'] as String,
            action: activity['action'] as String,
            target: activity['target'] as String,
            time: activity['time'] as String,
            avatar: activity['avatar'] as String,
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

  const _ActivityItem({
    required this.user,
    required this.action,
    required this.target,
    required this.time,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: user.split(' ').last,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $action '),
                  TextSpan(
                    text: target,
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ],
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
