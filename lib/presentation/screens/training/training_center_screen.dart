import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/utils/drills_library.dart';
import '../../../knowledge/knowledge_provider.dart';

/// PoolOS Training Center Screen - Redesigned with Minimalist Luxury
class TrainingCenterScreen extends ConsumerWidget {
  const TrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final knowledgeState = ref.watch(knowledgeProvider);
    final knowledgeCount = knowledgeState.allKnowledge.length;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background(brightness),
              elevation: 0,
              title: Text(
                'Train',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.history,
                    color: AppColors.textSecondary(brightness),
                  ),
                  onPressed: () => context.push('/training/history'),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search bar
                  _SearchBar(brightness: brightness),
                  const SizedBox(height: AppSpacing.space6),

                  // Quick Actions
                  _QuickActionsSection(
                    drillsCount: DrillLibrary.getAllDrills().length,
                    knowledgeCount: knowledgeCount,
                    brightness: brightness,
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Categories
                  _CategoriesSection(brightness: brightness),
                  const SizedBox(height: 100), // Bottom nav spacing
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final Brightness brightness;

  const _SearchBar({required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: TextField(
        readOnly: true,
        onTap: () => context.push('/training/drills'),
        decoration: InputDecoration(
          hintText: 'Search drills...',
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textTertiary(brightness),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}

/// Quick Actions Section
class _QuickActionsSection extends StatelessWidget {
  final int drillsCount;
  final int knowledgeCount;
  final Brightness brightness;

  const _QuickActionsSection({
    required this.drillsCount,
    required this.knowledgeCount,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accentColor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK START',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.fitness_center,
                title: 'All Drills',
                subtitle: '$drillsCount exercises',
                color: accentColor,
                brightness: brightness,
                onTap: () => context.push('/training/drills'),
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.menu_book,
                title: 'Knowledge',
                subtitle: '$knowledgeCount articles',
                color: AppColors.gold,
                brightness: brightness,
                onTap: () => context.push('/training/knowledge'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }
}

/// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Brightness brightness;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppShadows.sm(brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Categories Section
class _CategoriesSection extends StatelessWidget {
  final Brightness brightness;

  const _CategoriesSection({required this.brightness});

  @override
  Widget build(BuildContext context) {
    final categories = DrillLibrary.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),

        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final color = _getCategoryColor(index, brightness);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: _CategoryTile(
              title: category.nameVi,
              subtitle: '${category.drills.length} drills',
              color: color,
              brightness: brightness,
              onTap: () => context.push('/training/drills/${category.id}'),
            ),
          ).animate().fadeIn(delay: (200 + index * 50).ms);
        }),
      ],
    );
  }

  Color _getCategoryColor(int index, Brightness brightness) {
    final colors = [
      AppColors.accentColor(brightness),
      AppColors.warning,
      Colors.purple,
      AppColors.success,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}

/// Category Tile
class _CategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Brightness brightness;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppShadows.sm(brightness),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                Icons.category,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                ],
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
