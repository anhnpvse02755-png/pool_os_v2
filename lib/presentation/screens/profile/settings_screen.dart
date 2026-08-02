import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

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
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                title: 'Đổi email',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Thông báo'),
            _buildSettingsCard([
              _SwitchSettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo streak',
                subtitle: 'Nhắc nhở khi sắp mất streak',
                value: true,
                onChanged: (value) {},
              ),
              _SwitchSettingsItem(
                icon: Icons.calendar_today_outlined,
                title: 'Nhắc lịch tập',
                subtitle: 'Thông báo nhắc tập hàng ngày',
                value: false,
                onChanged: (value) {},
              ),
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
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // App Section
            _buildSectionTitle('Ứng dụng'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Giao diện',
                subtitle: 'Sáng',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'Giới thiệu PoolOS',
                onTap: () => _showAboutDialog(context),
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle('Hỗ trợ'),
            _buildSettingsCard([
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Trung tâm trợ giúp',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.feedback_outlined,
                title: 'Gửi phản hồi',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.star_outline,
                title: 'Đánh giá ứng dụng',
                onTap: () {},
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
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
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
