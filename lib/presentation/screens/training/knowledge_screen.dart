import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../../knowledge/knowledge_models.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

/// Tông của một mức độ khó trong thư viện kiến thức.
///
/// BỘ ANH EM ĐƯỢC MÃ HOÁ BẰNG MÀU, và nó là cái bẫy mà dự án này đã sập hai
/// lần. Bản cũ là success(160°) / accent(217°) / warning(38°) / error(0°).
/// Ánh xạ máy móc `accent` -> `primary` đặt bậc "Trung bình" vào 157–163°, tức
/// cách bậc "Cơ bản" (`success`, 160°) đúng 3° — hai bậc cạnh nhau trở thành
/// cùng một màu xanh trong mắt người dùng.
///
/// Lời giải là dùng lại ĐÚNG thang bốn bậc mà `drill_detail_screen` đã dùng,
/// vì đây cũng chính là chiều "độ khó": easy/medium/hard/expert ->
/// success / warning / error / difficultyExpert. Bốn hue 160° / 38° / 0° /
/// 262°, cách nhau tối thiểu 38° ở CẢ HAI chế độ, và một mức độ khó nay không
/// đổi màu khi người dùng đi từ màn bài tập sang màn kiến thức.
Color _difficultyTone(DifficultyLevel level, Brightness brightness) {
  switch (level) {
    case DifficultyLevel.beginner:
      return AppColors.success;
    case DifficultyLevel.intermediate:
      return AppColors.warning;
    case DifficultyLevel.advanced:
      return AppColors.error;
    case DifficultyLevel.expert:
      return AppColors.difficultyExpert(brightness);
  }
}

class KnowledgeScreen extends ConsumerStatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  ConsumerState<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends ConsumerState<KnowledgeScreen> {
  String? _selectedCategoryId;
  DifficultyLevel? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final knowledgeState = ref.watch(knowledgeProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Kiến thức'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: SoftBackground(
        child: Column(
          children: [
            // Categories
            _buildCategoryTabs(knowledgeState.categories),

            // Difficulty filter
            _buildDifficultyFilter(),

            // Content
            Expanded(
              child: _buildContent(knowledgeState, brightness),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<KnowledgeCategory> categories) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      width: double.infinity,
      child: Wrap(
        spacing: 0,
        runSpacing: AppSpacing.sm,
        children: [
          _CategoryChip(
            label: 'Tất cả',
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          ...categories.map((category) => _CategoryChip(
                label: category.nameVi ?? category.name,
                isSelected: _selectedCategoryId == category.id,
                onTap: () => setState(() => _selectedCategoryId = category.id),
              )),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      width: double.infinity,
      child: Wrap(
        spacing: 0,
        runSpacing: AppSpacing.sm,
        children: [
          _CategoryChip(
            label: 'Tất cả',
            isSelected: _selectedDifficulty == null,
            onTap: () => setState(() => _selectedDifficulty = null),
          ),
          ...DifficultyLevel.values.map((diff) => _CategoryChip(
                label: diff.label,
                isSelected: _selectedDifficulty == diff,
                onTap: () => setState(() => _selectedDifficulty = diff),
              )),
        ],
      ),
    );
  }

  Widget _buildContent(KnowledgeState state, Brightness brightness) {
    var knowledge = state.allKnowledge;

    if (_selectedCategoryId != null) {
      knowledge = knowledge
          .where((k) => k.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_selectedDifficulty != null) {
      knowledge = knowledge
          .where((k) => k.difficulty == _selectedDifficulty)
          .toList();
    }

    if (knowledge.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 64, color: AppColors.textTertiary(brightness)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không có bài viết',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: knowledge.length,
      itemBuilder: (context, index) {
        final item = knowledge[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _KnowledgeCard(
            knowledge: item,
            onTap: () => context.push('/training/knowledge/${item.slug}'),
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _KnowledgeSearchDelegate(ref),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor:
            AppColors.primary(brightness).withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary(brightness),
        labelStyle: TextStyle(
          color: isSelected
              ? AppColors.primary(brightness)
              : AppColors.textSecondary(brightness),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final KnowledgeItem knowledge;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.knowledge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      onTap: onTap,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            knowledge.titleVi ?? knowledge.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Preview
          Text(
            _getPreview(knowledge.content),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tags
          Row(
            children: [
              _DifficultyBadge(difficulty: knowledge.difficulty),
              const Spacer(),
              if (knowledge.relatedDrillCodes.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.fitness_center,
                        size: 14,
                        color: AppColors.textTertiary(brightness)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${knowledge.relatedDrillCodes.length} drills',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPreview(String content) {
    return content
        .replaceAll(RegExp(r'#{1,3}\s'), '')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll('\n', ' ')
        .trim();
  }
}

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = _difficultyTone(difficulty, brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _KnowledgeSearchDelegate extends SearchDelegate<KnowledgeItem?> {
  final WidgetRef ref;
  Timer? _debounce;
  String _lastQueried = '';

  _KnowledgeSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          _debounce?.cancel();
          _lastQueried = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _debounce?.cancel();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(Theme.of(context).brightness);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query != _lastQueried) {
        _lastQueried = query;
        (context as Element).markNeedsBuild();
      }
    });
    return _buildSearchResults(Theme.of(context).brightness);
  }

  // Không có `BuildContext` ở đây, nên `Brightness` đi vào bằng tham số do hai
  // hàm gọi ở trên truyền xuống.
  Widget _buildSearchResults(Brightness brightness) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Nhập từ khóa để tìm kiếm',
          style: TextStyle(color: AppColors.textSecondary(brightness)),
        ),
      );
    }

    if (query != _lastQueried) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final results = ref.watch(knowledgeSearchProvider(query));

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: AppColors.textTertiary(brightness)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _KnowledgeCard(
            knowledge: item,
            onTap: () {
              _debounce?.cancel();
              close(context, item);
              context.push('/training/knowledge/${item.slug}');
            },
          ),
        );
      },
    );
  }

  @override
  void close(BuildContext context, KnowledgeItem? result) {
    _debounce?.cancel();
    super.close(context, result);
  }
}
