import 'package:flutter/material.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';

/// PoolOS Action Button
/// Used for success/miss recording buttons in drill session
class ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSuccess;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSuccess,
    this.onPressed,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSuccess = widget.isSuccess;
    final backgroundColor = isSuccess ? AppColors.success : AppColors.error;

    return GestureDetector(
      onTapDown:
          widget.onPressed == null ? null : (_) => setState(() => _isPressed = true),
      onTapUp:
          widget.onPressed == null ? null : (_) => setState(() => _isPressed = false),
      onTapCancel:
          widget.onPressed == null ? null : () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.space3),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
