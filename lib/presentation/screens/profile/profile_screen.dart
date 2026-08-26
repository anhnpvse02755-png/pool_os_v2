import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/providers/repository_providers.dart';

/// PoolOS Profile Screen - Redesigned with Minimalist Luxury
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final playerAsync = ref.watch(currentPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: playerAsync.when(
          data: (player) => player != null
              ? _buildLoadedContent(context, ref, player, brightness)
              : _buildNoPlayerContent(context, brightness),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => _buildNoPlayerContent(context, brightness),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    WidgetRef ref,
    dynamic player,
    Brightness brightness,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _ProfileHeader(
            player: player,
            brightness: brightness,
          ),
          const SizedBox(height: AppSpacing.space6),

          // Settings Section
          _SettingsSection(brightness: brightness),
          const SizedBox(height: AppSpacing.space6),

          // Support Section
          _SupportSection(brightness: brightness),
          const SizedBox(height: AppSpacing.space6),

          // Sign Out
          _SignOutButton(brightness: brightness),
          const SizedBox(height: 100), // Bottom nav spacing
        ],
      ),
    );
  }

  Widget _buildNoPlayerContent(BuildContext context, Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textTertiary(brightness),
            ),
            const SizedBox(height: AppSpacing.space6),
            Text(
              'Complete onboarding to view your profile',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Header
class _ProfileHeader extends StatelessWidget {
  final dynamic player;
  final Brightness brightness;

  const _ProfileHeader({
    required this.player,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle(brightness),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: accentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.space4),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name ?? 'Player',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${player.level ?? 1}',
                      style: TextStyle(
                        fontSize: 13,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary(brightness),
            ),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

/// Settings Section
class _SettingsSection extends StatelessWidget {
  final Brightness brightness;

  const _SettingsSection({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              // Equipment
              _SettingsItem(
                icon: Icons.sports,
                label: 'Equipment',
                brightness: brightness,
                onTap: () => context.push('/profile/equipment'),
              ),
              Divider(
                height: 1,
                color: AppColors.border(brightness),
              ),

              // Dark Mode Toggle
              _SettingsToggle(
                icon: Icons.dark_mode,
                label: 'Dark Mode',
                brightness: brightness,
              ),
              Divider(
                height: 1,
                color: AppColors.border(brightness),
              ),

              // Notifications
              _SettingsToggle(
                icon: Icons.notifications,
                label: 'Notifications',
                brightness: brightness,
              ),
              Divider(
                height: 1,
                color: AppColors.border(brightness),
              ),

              // Sound Effects
              _SettingsToggle(
                icon: Icons.volume_up,
                label: 'Sound Effects',
                brightness: brightness,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }
}

/// Settings Item
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Brightness brightness;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary(brightness),
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings Toggle
class _SettingsToggle extends StatefulWidget {
  final IconData icon;
  final String label;
  final Brightness brightness;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.brightness,
  });

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(widget.brightness);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: accentColor, size: 22),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(widget.brightness),
              ),
            ),
          ),
          Switch(
            value: _value,
            onChanged: (value) => setState(() => _value = value),
            activeColor: accentColor,
          ),
        ],
      ),
    );
  }
}

/// Support Section
class _SupportSection extends StatelessWidget {
  final Brightness brightness;

  const _SupportSection({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUPPORT',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              _SettingsItem(
                icon: Icons.help_outline,
                label: 'Help & FAQ',
                brightness: brightness,
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: AppColors.border(brightness),
              ),
              _SettingsItem(
                icon: Icons.email_outlined,
                label: 'Contact Us',
                brightness: brightness,
                onTap: () {},
              ),
              Divider(
                height: 1,
                color: AppColors.border(brightness),
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                brightness: brightness,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}

/// Sign Out Button
class _SignOutButton extends StatelessWidget {
  final Brightness brightness;

  const _SignOutButton({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Handle sign out
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
        ),
        child: const Text('Sign Out'),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
