import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Một mục trên thanh hành động dưới cùng.
class BarAction {
  const BarAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;

  /// null = vô hiệu, hiển thị mờ.
  final VoidCallback? onTap;
}

/// Thanh hành động dưới cùng, 3-5 mục chia đều.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.actions});

  final List<BarAction> actions;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      key: const Key('bottom-action-bar-container'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        border: Border(top: BorderSide(color: AppColors.border(brightness))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final a in actions)
              Expanded(
                child: Opacity(
                  key: Key('bar-action-${a.label}'),
                  opacity: a.onTap == null ? 0.38 : 1.0,
                  child: InkWell(
                    onTap: a.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            a.icon,
                            size: 22,
                            color: AppColors.primary(brightness),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
