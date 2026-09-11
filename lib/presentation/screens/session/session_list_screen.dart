import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        title: Text(
          'Buổi chơi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.textSecondary(brightness)),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pool,
                  size: 48,
                  color: AppColors.primary(brightness),
                ),
              ).animate().scale(duration: 400.ms),
              SizedBox(height: AppSpacing.xxl),
              Text(
                'Chưa có buổi chơi nào',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(brightness),
                    ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: AppSpacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Bắt đầu ghi lại buổi chơi đầu tiên\nđể theo dõi tiến bộ của bạn',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary(brightness),
                        height: 1.5,
                      ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: _PrimaryButton(
                  onPressed: () => context.push('/session/create'),
                  label: 'Tạo buổi chơi mới',
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary(brightness).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/session/create'),
          icon: const Icon(Icons.add),
          label: const Text('Buổi mới'),
          backgroundColor: AppColors.primary(brightness),
          foregroundColor: AppColors.onPrimary(brightness),
          elevation: 0,
        ),
      ).animate().fadeIn(delay: 500.ms).scale(delay: 500.ms),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _PrimaryButton({required this.onPressed, required this.label});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
