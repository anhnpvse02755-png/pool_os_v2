import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/services/notification_service.dart';

/// Notification Screen - Redesigned with Minimalist Luxury
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Thông báo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Đánh dấu đã đọc',
                style: TextStyle(color: AppColors.accentColor(brightness)),
              ),
            ),
        ],
      ),
      body: notificationState.notifications.isEmpty
          ? _buildEmptyState(brightness)
          : _buildNotificationList(context, ref, notificationState, brightness),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textTertiary(brightness),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Không có thông báo',
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Thông báo sẽ hiện khi bạn cần',
            style: TextStyle(
              color: AppColors.textTertiary(brightness),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    NotificationState state,
    Brightness brightness,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(context, ref, notification),
            onDismiss: () {
              ref.read(notificationProvider.notifier).removeNotification(notification.id);
            },
            brightness: brightness,
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    PoolNotification notification,
  ) {
    ref.read(notificationProvider.notifier).markAsRead(notification.id);

    if (notification.actionRoute != null) {
      context.push(notification.actionRoute!);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final PoolNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Brightness brightness;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
    required this.brightness,
  });

  Color _getTypeColor() {
    switch (notification.type) {
      case 'streak_warning':
        return AppColors.warning;
      case 'level_up':
        return AppColors.success;
      case 'test_available':
        return AppColors.accentColor(brightness);
      case 'match_analysis':
        return Colors.purple;
      case 'streak_milestone':
        return AppColors.gold;
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'streak_warning':
        return Icons.local_fire_department;
      case 'level_up':
        return Icons.trending_up;
      case 'test_available':
        return Icons.quiz;
      case 'match_analysis':
        return Icons.analytics;
      case 'streak_milestone':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isUnread
                ? color.withValues(alpha: 0.05)
                : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isUnread
                  ? color.withValues(alpha: 0.2)
                  : AppColors.lightBorder,
            ),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                              fontSize: 15,
                              color: AppColors.textPrimary(brightness),
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (notification.actionLabel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.actionLabel!,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
