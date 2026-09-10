import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

/// Một người chơi trên thanh điểm.
class ScorePlayer {
  const ScorePlayer({required this.name, required this.score, this.icon});

  final String name;
  final int score;

  /// Icon tuỳ chọn đứng trước tên — ví dụ đánh dấu người đang bắn.
  final IconData? icon;
}

/// Thanh điểm nền xanh rêu, chia đều cho N người chơi.
///
/// Vạch ngăn chỉ chèn GIỮA các ô nên số vạch luôn ít hơn số người chơi 1 —
/// danh sách rỗng hoặc một người thì không có vạch nào.
class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key, required this.players});

  final List<ScorePlayer> players;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      key: const Key('score-bar-container'),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          for (var i = 0; i < players.length; i++) ...[
            if (i > 0)
              Container(
                // Key có index: Flutter cấm các con cùng cha trùng Key.
                key: ValueKey('score-bar-divider-$i'),
                width: 1,
                height: 34,
                color: Colors.white24,
              ),
            Expanded(child: _PlayerCell(player: players[i])),
          ],
        ],
      ),
    );
  }
}

class _PlayerCell extends StatelessWidget {
  const _PlayerCell({required this.player});

  final ScorePlayer player;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (player.icon != null) ...[
              Icon(player.icon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                player.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${player.score}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
