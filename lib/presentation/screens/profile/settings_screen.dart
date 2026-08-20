import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/test_logging_service.dart';
import '../../../core/providers/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('Tài khoản'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.person_outline,
                title: 'Chỉnh sửa thông tin',
                onTap: () => context.push('/profile/edit'),
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () => _showFeatureComingSoon(context, 'Đổi mật khẩu'),
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                title: 'Đổi email',
                onTap: () => _showFeatureComingSoon(context, 'Đổi email'),
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Thông báo'),
            _buildSettingsCard([
              const _NotificationSettingsItem(),
              const _DailyReminderSettingsItem(),
              _SwitchSettingsItem(
                icon: Icons.emoji_events_outlined,
                title: 'Thông báo giải đấu',
                subtitle: 'Nhận thông báo về giải đấu mới',
                value: true,
                onChanged: (value) {},
              ),
            ]),
            const SizedBox(height: 24),

            // Training Section
            _buildSectionTitle('Luyện tập'),
            _buildSettingsCard([
              _SwitchSettingsItem(
                icon: Icons.auto_awesome,
                title: 'Đề xuất AI',
                subtitle: 'Nhận đề xuất từ AI Coach',
                value: true,
                onChanged: (value) {},
              ),
              _SettingsItem(
                icon: Icons.timer_outlined,
                title: 'Mục tiêu hàng ngày',
                subtitle: '2 drills / ngày',
                onTap: () => _showFeatureComingSoon(context, 'Mục tiêu hàng ngày'),
              ),
            ]),
            const SizedBox(height: 24),

            // App Section
            _buildSectionTitle('Ứng dụng'),
            _buildSettingsCard([
              _LanguageSettingsItem(ref: ref),
              _ThemeSettingsItem(ref: ref),
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'Giới thiệu PoolOS',
                onTap: () => _showAboutDialog(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Black Box Section
            _buildSectionTitle('PoolOS Black Box'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.analytics_outlined,
                iconColor: const Color(0xFF2E7D32),
                title: 'Export Coach Package',
                subtitle: 'Share data for analysis',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'v2.0',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                onTap: () => context.push('/settings/black-box'),
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
                onTap: () => _showFeatureComingSoon(context, 'Trung tâm trợ giúp'),
              ),
              _SettingsItem(
                icon: Icons.feedback_outlined,
                title: 'Gửi phản hồi',
                onTap: () => _showFeatureComingSoon(context, 'Gửi phản hồi'),
              ),
              _SettingsItem(
                icon: Icons.star_outline,
                title: 'Đánh giá ứng dụng',
                onTap: () => _showFeatureComingSoon(context, 'Đánh giá ứng dụng'),
              ),
            ]),
            const SizedBox(height: 24),

            // Test Logs Section - For testers
            _buildSectionTitle('Test Logs'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.bug_report_outlined,
                iconColor: Colors.orange,
                title: 'Export Test Logs (JSON)',
                subtitle: '${testLogger.logCount} actions logged',
                onTap: () => _exportLogs(context, asJson: true),
              ),
              _SettingsItem(
                icon: Icons.table_chart_outlined,
                iconColor: Colors.blue,
                title: 'Export Test Logs (CSV)',
                subtitle: 'For spreadsheet analysis',
                onTap: () => _exportLogs(context, asJson: false),
              ),
              _SettingsItem(
                icon: Icons.play_arrow_outlined,
                iconColor: Colors.green,
                title: 'Start Test Session',
                subtitle: 'Clear logs & begin recording',
                onTap: () => _startTestSession(context),
              ),
              _SettingsItem(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: 'Clear Test Logs',
                subtitle: 'Remove all logged actions',
                onTap: () => _clearLogs(context),
              ),
            ]),
            const SizedBox(height: 24),

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
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
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
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < items.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: (100 * 0).ms);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Đăng xuất'),
              content: const Text('Bạn có chắc muốn đăng xuất không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/auth/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(color: Colors.red),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pool, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('PoolOS'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phiên bản: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'PoolOS là ứng dụng luyện tập billiards thông minh, '
              'sử dụng AI để cá nhân hóa lộ trình học tập cho người chơi.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Tính năng đang phát triển'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Export test logs as JSON or CSV
  Future<void> _exportLogs(BuildContext context, {required bool asJson}) async {
    try {
      if (testLogger.logCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No logs to export. Start a test session first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Export and share
      await testLogger.shareLogs(asJson: asJson);

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${testLogger.logCount} actions'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Start a new test session
  void _startTestSession(BuildContext context) {
    testLogger.startSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test session started - logging all actions'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Clear all test logs
  void _clearLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all test logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              testLogger.clearLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs cleared'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primaryGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daily notification settings - Sprint-10B
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhắc lịch tập',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnabled ? 'Hàng ngày lúc $timeStr' : 'Thông báo nhắc tập hàng ngày',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) => _toggleDailyReminder(context, ref, isEnabled),
                activeColor: AppTheme.primaryGreen,
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
      // Disable
      await notificationService.disable();
      ref.invalidate(dailyNotificationServiceProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tắt nhắc nhở hàng ngày'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } else {
      // Enable
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
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    }
  }
}

/// Streak reminder settings - Sprint-10B
class _NotificationSettingsItem extends ConsumerWidget {
  const _NotificationSettingsItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showStreakSettings(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông báo streak',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nhắc nhở khi sắp mất streak',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      padding: const EdgeInsets.all(24),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Streak Reminder',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Current stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
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
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _StatColumn(
                  icon: Icons.emoji_events,
                  value: '$longestStreak',
                  label: 'Longest',
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Time picker
          const Text(
            'Thời gian nhắc nhở',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn sẽ nhận thông báo nhắc nhở luyện tập vào thời gian đã chọn mỗi ngày.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
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
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      // Update notification time
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
        const SizedBox(height: 4),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _SwitchSettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

/// Language settings - switch between EN/VI
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.language, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ngôn ngữ', style: TextStyle(fontSize: 15)),
                    Text(
                      isVi ? 'Tiếng Việt' : 'English',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isVi ? 'VI' : 'EN',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme settings - switch between Light/Dark
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giao diện', style: TextStyle(fontSize: 15)),
                    Text(
                      isDark ? 'Tối' : 'Sáng',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDark ? '🌙' : '☀️',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
