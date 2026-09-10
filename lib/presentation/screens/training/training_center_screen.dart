import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/utils/drills_library.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

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
      body: SoftBackground(
        child: SafeArea(
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
        color: AppColors.surface(brightness),
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

        // Hai thẻ này là một BỘ ANH EM: màu của chúng dùng để phân biệt nhau.
        // Cặp cũ (`accent`, `gold`) tô thẳng vào icon trên nền thẻ trắng —
        // `gold` #F59E0B chỉ đạt 2.15:1 ở đó, dưới sàn 3:1 cho một đối tượng
        // đồ hoạ. Chuyển sang ô pastel giữ nguyên khoảng cách giữa hai thẻ
        // (mint vs butter) mà icon lại nằm trên nền nhạt nên đọc rõ.
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.fitness_center,
                title: 'All Drills',
                subtitle: '$drillsCount exercises',
                toneIndex: 0,
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
                toneIndex: 4,
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
  final int toneIndex;
  final Brightness brightness;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.toneIndex,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PoolCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, toneIndex: toneIndex, size: 36),
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

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space2),
            child: _CategoryTile(
              title: category.nameVi,
              subtitle: '${category.drills.length} drills',
              toneIndex: _toneFor(category.id),
              brightness: brightness,
              onTap: () => context.push('/training/drills/${category.id}'),
            ),
          ).animate().fadeIn(delay: (200 + index * 50).ms);
        }),
      ],
    );
  }

  /// Tông pastel của một nhóm bài, gán theo ID.
  ///
  /// Bảng cũ là năm màu ĐẶC lấy theo vị trí trong danh sách và nó hỏng hai
  /// lần cùng lúc. Thứ nhất, sau khi `accent` -> `primary` thì phần tử 0
  /// (hue 157/163) và phần tử 3 (`success`, hue 160) cách nhau 3° — hai nhóm
  /// bài cạnh nhau trông y hệt; hai phần tử còn lại là tím và hồng lấy thẳng
  /// từ bảng Material, vừa phạm luật vừa không đổi theo chế độ.
  /// Bảng màu duy nhất trong hệ có ĐỦ năm sắc phân biệt là năm ô pastel.
  /// Thứ hai, gán theo index nghĩa là thêm/bớt một nhóm sẽ đổi màu mọi nhóm
  /// sau nó.
  ///
  /// Bảng này CỐ Ý trùng khớp `_toneFor` của `drill_list_screen.dart`: cùng
  /// một nhóm bài phải cùng tông ở cả hai màn, nếu không người dùng không học
  /// được màu. Không gộp được thành một hàm chung vì đợt này chỉ được sửa bốn
  /// file màn hình.
  int _toneFor(String categoryId) {
    switch (categoryId) {
      case 'aiming':
        return 0;
      case 'cueball':
        return 1;
      case 'position':
        return 2;
      case 'safety':
        return 3;
      case 'special':
        return 4;
      case 'break':
        return 2;
      case 'spin':
        return 1;
      case 'pattern':
        return 3;
      case 'fundamentals':
        return 0;
      case 'mental':
        return 4;
      case 'situations':
        return 1;
      default:
        return 0;
    }
  }
}

/// Category Tile
class _CategoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int toneIndex;
  final Brightness brightness;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.title,
    required this.subtitle,
    required this.toneIndex,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PoolCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        children: [
          IconTile(icon: Icons.category, toneIndex: toneIndex, size: 40),
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
    );
  }
}
