import 'package:flutter/material.dart';
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
            labelColor: AppColors.primary(brightness),
            unselectedLabelColor: AppColors.textSecondary(brightness),
            indicatorColor: AppColors.primary(brightness),
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
                AppColors.primary(brightness).withValues(alpha: 0.1),
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
                color: AppColors.silver,
                onTintColor: AppColors.silverOnTint(brightness),
                brightness: brightness,
              ),
              _PodiumItem(
                rank: 1,
                name: leaders[0]['name'] as String,
                points: leaders[0]['points'] as int,
                avatar: leaders[0]['avatar'] as String,
                height: 100,
                color: AppColors.gold,
                onTintColor: AppColors.goldOnTint(brightness),
                brightness: brightness,
              ),
              _PodiumItem(
                rank: 3,
                name: leaders[2]['name'] as String,
                points: leaders[2]['points'] as int,
                avatar: leaders[2]['avatar'] as String,
                height: 60,
                color: AppColors.bronze,
                onTintColor: AppColors.bronzeOnTint(brightness),
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

  /// Bản đọc được của [color] khi nó phải làm CHỮ hoặc NÉT trên nền dịu của
  /// chính mình. Đo thật: chữ avatar cùng màu với nền 30% của nó chỉ được
  /// 2,11-2,84:1, và viền/icon huy chương trên nền thẻ tụt còn 2,87 ở chế độ
  /// tối. Luật vệ sinh token KHÔNG bắt được hai chỗ này vì chúng chỉ đọc mã
  /// nguồn, không đo tương phản.
  final Color onTintColor;
  final Brightness brightness;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatar,
    required this.height,
    required this.color,
    required this.onTintColor,
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
                border: Border.all(color: onTintColor, width: 3),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: onTintColor,
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
                color: onTintColor,
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
                color: AppColors.onPrimary(brightness),
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
              color: AppColors.primary(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppColors.primary(brightness),
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
                color: AppColors.primary(brightness).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    color: AppColors.primary(brightness),
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
                          color: _levelTint(level, brightness)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: _levelOnTint(level, brightness),
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
              icon: Icon(Icons.person_add, color: AppColors.primary(brightness)),
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

}

/// Tông NỀN của bốn bậc trình độ, theo THỨ HẠNG.
///
/// Dùng đúng bộ bốn hue tách bạch mà hệ có — `difficultyExpert` 262° / họ xanh
/// rêu 157-163° / `warning` 38° / `error` 0° — giống `assessment_screen`.
///
/// `Advanced` KHÔNG giữ xanh điện của Material: đó là tông mà đợt redesign
/// này tồn tại để loại bỏ. Bậc mặc định dời từ `success` sang `error` vì nó
/// cùng họ xanh rêu với `primary` của bậc `Expert` ngay trên nó — để nguyên
/// thì hai bậc liền kề trùng sắc.
Color _levelTint(String level, Brightness brightness) {
  switch (level) {
    case 'Pro':
      return AppColors.difficultyExpert(brightness);
    case 'Expert':
      return AppColors.primary(brightness);
    case 'Advanced':
      return AppColors.warning;
    default:
      return AppColors.error;
  }
}

/// Tông CHỮ đặt trên nền 10% của [_levelTint].
///
/// Không phải lúc nào cũng trùng màu nền. Đo thật: `warning` làm chữ trên nền
/// 10% của chính nó chỉ được 1,82:1 ở chế độ sáng, `error` được 3,01 sáng /
/// 4,39 tối — cả hai trượt sàn 4,5. Hệ đã có sẵn `warningOnTint`/`errorOnTint`
/// đúng cho chiều này. `difficultyExpert` và `primary` tự đạt nên dùng thẳng.
Color _levelOnTint(String level, Brightness brightness) {
  switch (level) {
    case 'Pro':
      return AppColors.difficultyExpert(brightness);
    case 'Expert':
      return AppColors.primary(brightness);
    case 'Advanced':
      return AppColors.warningOnTint(brightness);
    default:
      return AppColors.errorOnTint(brightness);
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
              color: AppColors.primary(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['avatar'] as String,
                style: TextStyle(
                  color: AppColors.primary(brightness),
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
              color: _levelTint(player['level'] as String, brightness)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              player['level'] as String,
              style: TextStyle(
                color: _levelOnTint(player['level'] as String, brightness),
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
                  icon: Icon(Icons.person_add, color: AppColors.primary(brightness)),
                  label: Text('Kết bạn', style: TextStyle(color: AppColors.primary(brightness))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary(brightness)),
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
                  icon: Icon(Icons.sports_cricket,
                      color: AppColors.onPrimary(brightness)),
                  label: Text('Thách đấu',
                      style: TextStyle(color: AppColors.onPrimary(brightness))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(brightness),
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
              color: AppColors.primary(brightness).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: AppColors.primary(brightness),
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
                    style: TextStyle(color: AppColors.primary(brightness)),
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
