import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/services/test_logging_service.dart';
import '../../../core/providers/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Account Section
            _buildSectionTitle('Tài khoản'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.person_outline,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Chỉnh sửa thông tin',
                onTap: () => context.push('/profile/edit'),
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Đổi mật khẩu',
                onTap: () => _showFeatureComingSoon(context, 'Đổi mật khẩu'),
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Đổi email',
                onTap: () => _showFeatureComingSoon(context, 'Đổi email'),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Notifications Section
            _buildSectionTitle('Thông báo'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              const _NotificationSettingsItem(),
              const _DailyReminderSettingsItem(),
              _SwitchSettingsItem(
                icon: Icons.emoji_events_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: AppColors.gold,
                title: 'Thông báo giải đấu',
                subtitle: 'Nhận thông báo về giải đấu mới',
                value: true,
                onChanged: (value) {},
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Training Section
            _buildSectionTitle('Luyện tập'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SwitchSettingsItem(
                icon: Icons.auto_awesome,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Đề xuất AI',
                subtitle: 'Nhận đề xuất từ AI Coach',
                value: true,
                onChanged: (value) {},
              ),
              _SettingsItem(
                icon: Icons.timer_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: AppColors.gold,
                title: 'Mục tiêu hàng ngày',
                subtitle: '2 drills / ngày',
                onTap: () => _showFeatureComingSoon(context, 'Mục tiêu hàng ngày'),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // App Section
            _buildSectionTitle('Ứng dụng'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _LanguageSettingsItem(ref: ref),
              _ThemeSettingsItem(ref: ref),
              _SettingsItem(
                icon: Icons.info_outline,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Giới thiệu PoolOS',
                onTap: () => _showAboutDialog(context),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Black Box Section
            _buildSectionTitle('PoolOS Black Box'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.analytics_outlined,
                iconBgColor: AppColors.successSubtleLight,
                iconColor: AppColors.success,
                title: 'Export Coach Package',
                subtitle: 'Share data for analysis',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.successSubtleLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Text(
                    'v2.0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
                onTap: () => context.push('/settings/black-box'),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Support Section
            _buildSectionTitle('Hỗ trợ'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.help_outline,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Trung tâm trợ giúp',
                onTap: () => _showFeatureComingSoon(context, 'Trung tâm trợ giúp'),
              ),
              _SettingsItem(
                icon: Icons.feedback_outlined,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Gửi phản hồi',
                onTap: () => _showFeatureComingSoon(context, 'Gửi phản hồi'),
              ),
              _SettingsItem(
                icon: Icons.star_outline,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: AppColors.gold,
                title: 'Đánh giá ứng dụng',
                onTap: () => _showFeatureComingSoon(context, 'Đánh giá ứng dụng'),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Test Logs Section - For testers
            _buildSectionTitle('Test Logs'),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.bug_report_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: Colors.orange.shade700,
                title: 'Export Test Logs (JSON)',
                subtitle: '${testLogger.logCount} actions logged',
                onTap: () => _exportLogs(context, asJson: true),
              ),
              _SettingsItem(
                icon: Icons.table_chart_outlined,
                iconBgColor: AppColors.accentSubtleLight,
                iconColor: AppColors.accent,
                title: 'Export Test Logs (CSV)',
                subtitle: 'For spreadsheet analysis',
                onTap: () => _exportLogs(context, asJson: false),
              ),
              _SettingsItem(
                icon: Icons.play_arrow_outlined,
                iconBgColor: AppColors.successSubtleLight,
                iconColor: AppColors.success,
                title: 'Start Test Session',
                subtitle: 'Clear logs & begin recording',
                onTap: () => _startTestSession(context),
              ),
              _SettingsItem(
                icon: Icons.delete_outline,
                iconBgColor: AppColors.errorSubtleLight,
                iconColor: AppColors.error,
                title: 'Clear Test Logs',
                subtitle: 'Remove all logged actions',
                onTap: () => _clearLogs(context),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),

            // Logout
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.md),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.lightTextSecondary,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.lightBorder,
                  indent: AppSpacing.lg + 40 + AppSpacing.md,
                ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (100 * 0).ms);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return _PrimaryButton(
      label: 'Đăng xuất',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            content: const Text(
              'Bạn có chắc muốn đăng xuất không?',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/auth/login');
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
      isDestructive: true,
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentSubtleLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.pool, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text(
              'PoolOS',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phiên bản: 1.0.0',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'PoolOS là ứng dụng luyện tập billiards thông minh, '
              'sử dụng AI để cá nhân hóa lộ trình học tập cho người chơi.',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Tính năng đang phát triển'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  Future<void> _exportLogs(BuildContext context, {required bool asJson}) async {
    try {
      if (testLogger.logCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No logs to export. Start a test session first.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );

      await testLogger.shareLogs(asJson: asJson);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${testLogger.logCount} actions'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  void _startTestSession(BuildContext context) {
    testLogger.startSession();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Test session started - logging all actions'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  void _clearLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text(
          'Clear Logs',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to clear all test logs?',
          style: TextStyle(color: AppColors.lightTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              testLogger.clearLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logs cleared'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isDestructive;

  const _PrimaryButton({
    required this.onPressed,
    required this.label,
    this.isDestructive = false,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDestructive
        ? AppColors.error
        : (widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary);

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBgColor ?? AppColors.accentSubtleLight;
    final fgColor = iconColor ?? AppColors.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: fgColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyReminderSettingsItem extends ConsumerWidget {
  const _DailyReminderSettingsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(dailyNotificationServiceProvider);
    final isEnabled = notificationService.isEnabled();
    final hour = notificationService.getHour();
    final minute = notificationService.getMinute();
    final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDailyReminder(context, ref, isEnabled),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhắc lịch tập',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled ? 'Hàng ngày lúc $timeStr' : 'Thông báo nhắc tập hàng ngày',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) => _toggleDailyReminder(context, ref, isEnabled),
                activeColor: Colors.white,
                activeTrackColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleDailyReminder(BuildContext context, WidgetRef ref, bool currentValue) async {
    final notificationService = ref.read(dailyNotificationServiceProvider);

    if (currentValue) {
      await notificationService.disable();
      ref.invalidate(dailyNotificationServiceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tắt nhắc nhở hàng ngày'),
            backgroundColor: AppColors.lightTextSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } else {
      final success = await notificationService.enable();
      ref.invalidate(dailyNotificationServiceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Đã bật nhắc nhở hàng ngày!'
                  : 'Không thể bật thông báo. Kiểm tra quyền trong cài đặt hệ thống.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }
}

class _NotificationSettingsItem extends ConsumerWidget {
  const _NotificationSettingsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showStreakSettings(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông báo streak',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Nhắc nhở khi sắp mất streak',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => const _StreakSettingsSheet(),
    );
  }
}

class _StreakSettingsSheet extends ConsumerStatefulWidget {
  const _StreakSettingsSheet();

  @override
  ConsumerState<_StreakSettingsSheet> createState() => _StreakSettingsSheetState();
}

class _StreakSettingsSheetState extends ConsumerState<_StreakSettingsSheet> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final notificationService = ref.read(dailyNotificationServiceProvider);
    _selectedTime = TimeOfDay(
      hour: notificationService.getHour(),
      minute: notificationService.getMinute(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streakService = ref.read(learningStreakServiceProvider);
    final currentStreak = streakService.currentStreak();
    final longestStreak = streakService.longestStreak();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'Streak Reminder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Current stats
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.local_fire_department,
                  value: '$currentStreak',
                  label: 'Current',
                  color: Colors.orange.shade700,
                ),
                Container(width: 1, height: 40, color: AppColors.lightBorder),
                _StatColumn(
                  icon: Icons.emoji_events,
                  value: '$longestStreak',
                  label: 'Longest',
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Time picker
          const Text(
            'Thời gian nhắc nhở',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _pickTime(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightBorder),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Info text
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentSubtleLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Bạn sẽ nhận thông báo nhắc nhở luyện tập vào thời gian đã chọn mỗi ngày.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Close button
          SizedBox(
            width: double.infinity,
            child: _PrimaryButton(
              onPressed: () => Navigator.pop(context),
              label: 'Đóng',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      final notificationService = ref.read(dailyNotificationServiceProvider);
      if (notificationService.isEnabled()) {
        await notificationService.updateTime(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SwitchSettingsItem extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingsItem({
    required this.icon,
    this.iconBgColor,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = iconBgColor ?? AppColors.accentSubtleLight;
    final fgColor = iconColor ?? AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _LanguageSettingsItem extends ConsumerWidget {
  final WidgetRef ref;

  const _LanguageSettingsItem({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isVi = locale.languageCode == 'vi';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.language, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ngôn ngữ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      isVi ? 'Tiếng Việt' : 'English',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  isVi ? 'VI' : 'EN',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSettingsItem extends ConsumerWidget {
  final WidgetRef ref;

  const _ThemeSettingsItem({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giao diện',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      isDark ? 'Tối' : 'Sáng',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  isDark ? 'Dark' : 'Light',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
