import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class DrillListScreen extends StatefulWidget {
  final String categoryId;

  const DrillListScreen({super.key, required this.categoryId});

  @override
  State<DrillListScreen> createState() => _DrillListScreenState();
}

class _DrillListScreenState extends State<DrillListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Drill> get _categoryDrills {
    return DrillLibrary.getDrillsByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: Text(_getCategoryName()),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.background(brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: TabBar(
                  controller: _tabController,
                  onTap: (_) => setState(() {}),
                  indicator: BoxDecoration(
                    color: AppColors.primary(brightness),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  labelColor: AppColors.onPrimary(brightness),
                  unselectedLabelColor: AppColors.textSecondary(brightness),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Recommended'),
                    Tab(text: 'All Drills'),
                  ],
                ),
              ),
              // Filters Row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // Search
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface(brightness),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.border(brightness)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: TextStyle(fontSize: 14, color: AppColors.textPrimary(brightness)),
                          decoration: InputDecoration(
                            hintText: 'Search drills...',
                            hintStyle: TextStyle(color: AppColors.textTertiary(brightness), fontSize: 14),
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary(brightness)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Difficulty Filter
                    PopupMenuButton<String?>(
                      initialValue: _selectedDifficulty,
                      onSelected: (value) =>
                          setState(() => _selectedDifficulty = value),
                      offset: const Offset(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: null,
                          child: Text('All', style: TextStyle(
                            color: _selectedDifficulty == null ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                            fontWeight: _selectedDifficulty == null ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'easy',
                          child: Text('Easy', style: TextStyle(
                            color: _selectedDifficulty == 'easy' ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                            fontWeight: _selectedDifficulty == 'easy' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'medium',
                          child: Text('Medium', style: TextStyle(
                            color: _selectedDifficulty == 'medium' ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                            fontWeight: _selectedDifficulty == 'medium' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'hard',
                          child: Text('Hard', style: TextStyle(
                            color: _selectedDifficulty == 'hard' ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                            fontWeight: _selectedDifficulty == 'hard' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                        PopupMenuItem(
                          value: 'expert',
                          child: Text('Expert', style: TextStyle(
                            color: _selectedDifficulty == 'expert' ? AppColors.primary(brightness) : AppColors.textPrimary(brightness),
                            fontWeight: _selectedDifficulty == 'expert' ? FontWeight.w600 : FontWeight.normal,
                          )),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface(brightness),
                          border: Border.all(color: _selectedDifficulty != null ? AppColors.primary(brightness) : AppColors.border(brightness)),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 18,
                              color: _selectedDifficulty != null
                                  ? AppColors.primary(brightness)
                                  : AppColors.textSecondary(brightness),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _selectedDifficulty != null
                                  ? _selectedDifficulty!.toUpperCase()
                                  : 'Filter',
                              style: TextStyle(
                                color: _selectedDifficulty != null
                                    ? AppColors.primary(brightness)
                                    : AppColors.textSecondary(brightness),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Recommended Tab
          _buildDrillList(
            _categoryDrills.take(5).toList(),
            showReason: false,
          ),
          // All Drills Tab
          _buildDrillList(_categoryDrills),
        ],
      ),
    );
  }

  String _getCategoryName() {
    for (final cat in DrillLibrary.categories) {
      if (cat.id == widget.categoryId) {
        return cat.nameVi;
      }
    }
    return 'Drill Library';
  }

  Widget _buildDrillList(List<Drill> drills, {bool showReason = false}) {
    final brightness = Theme.of(context).brightness;

    if (drills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.background(brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 40, color: AppColors.textTertiary(brightness)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No drills found',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Apply filters
    var filteredDrills = drills;
    if (_selectedDifficulty != null) {
      filteredDrills = filteredDrills
          .where((d) => d.difficulty == _selectedDifficulty)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredDrills = DrillLibrary.searchDrills(_searchQuery);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: filteredDrills.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final drill = filteredDrills[index];
        return _DrillCard(
          drill: drill,
          showReason: showReason,
          onTap: () => context.push('/training/drill/${drill.code}'),
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }
}

class _DrillCard extends StatelessWidget {
  final Drill drill;
  final bool showReason;
  final VoidCallback onTap;

  const _DrillCard({
    required this.drill,
    this.showReason = false,
    required this.onTap,
  });

  Color _getDifficultyColor(Brightness brightness) {
    switch (drill.difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      case 'expert':
        return AppColors.primary(brightness);
      default:
        return AppColors.textSecondary(brightness);
    }
  }

  String _getDifficultyLabel() {
    switch (drill.difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'expert':
        return 'Expert';
      default:
        return drill.difficulty;
    }
  }

  String _getLevelProgress() {
    final current = drill.currentLevel;
    final total = drill.levels.length;
    return 'Lv.$current/$total';
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border(brightness).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Level indicator
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(brightness).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          drill.nameVi.substring(0, 1),
                          style: TextStyle(
                            color: _getDifficultyColor(brightness),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _getLevelProgress(),
                          style: TextStyle(
                            color: _getDifficultyColor(brightness),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                              drill.nameVi,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary(brightness),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(brightness).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _getDifficultyLabel(),
                              style: TextStyle(
                                color: _getDifficultyColor(brightness),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        drill.description,
                        style: TextStyle(
                          color: AppColors.textSecondary(brightness),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: AppColors.textTertiary(brightness), size: 24),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Level progress
            Row(
              children: List.generate(drill.levels.length, (index) {
                final level = index + 1;
                final isUnlocked = drill.isLevelUnlocked(level);
                final isCompleted = level <= drill.currentLevel - 1;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < drill.levels.length - 1 ? AppSpacing.xs : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: !isUnlocked
                          ? AppColors.border(brightness)
                          : isCompleted
                              ? AppColors.success
                              : AppColors.success.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// Drill Categories Overview
class DrillCategoriesScreen extends StatelessWidget {
  const DrillCategoriesScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'circle':
        return Icons.circle_outlined;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'shield':
        return Icons.shield;
      case 'flash_on':
        return Icons.flash_on;
      case 'star':
        return Icons.star;
      default:
        return Icons.fitness_center;
    }
  }

  /// Tông pastel của nhóm bài, gán CỐ ĐỊNH theo id — KHÔNG theo vị trí trong
  /// danh sách. Người dùng học được màu, nên thêm hoặc sắp xếp lại một nhóm
  /// không được làm đổi màu các nhóm khác.
  ///
  /// 11 nhóm trên 5 tông thì có lặp; spec đã lường điều đó. Cái không chấp
  /// nhận được là màu ĐỔI khi danh sách đổi.
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Drill Library'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SoftBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: DrillLibrary.categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final category = DrillLibrary.categories[index];
            final tone = _toneFor(category.id);

            return PoolCard(
              onTap: () => context.push('/training/drills/${category.id}'),
              radius: AppSpacing.radiusLg,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconTile(
                    icon: _getIcon(category.icon),
                    toneIndex: tone,
                    size: 56,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.nameVi,
                          style: TextStyle(
                            color: AppColors.textPrimary(brightness),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${category.drills.length} drills',
                          style: TextStyle(
                            color: AppColors.textSecondary(brightness),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: AppColors.textTertiary(brightness), size: 18),
                ],
              ),
            ).animate().fadeIn(delay: (index * 100).ms);
          },
        ),
      ),
    );
  }
}
