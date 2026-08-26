import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../../knowledge/knowledge_models.dart';

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
    final knowledgeState = ref.watch(knowledgeProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kien thuc'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          _buildCategoryTabs(knowledgeState.categories),

          // Difficulty filter
          _buildDifficultyFilter(),

          // Content
          Expanded(
            child: _buildContent(knowledgeState),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(List<KnowledgeCategory> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'Tat ca',
              isSelected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            );
          }

          final category = categories[index - 1];
          return _CategoryChip(
            label: category.nameVi ?? category.name,
            isSelected: _selectedCategoryId == category.id,
            onTap: () => setState(() => _selectedCategoryId = category.id),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: DifficultyLevel.values.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'Tat ca',
              isSelected: _selectedDifficulty == null,
              onTap: () => setState(() => _selectedDifficulty = null),
            );
          }

          final diff = DifficultyLevel.values[index - 1];
          return _CategoryChip(
            label: diff.label,
            isSelected: _selectedDifficulty == diff,
            onTap: () => setState(() => _selectedDifficulty = diff),
          );
        },
      ),
    );
  }

  Widget _buildContent(KnowledgeState state) {
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
            Icon(Icons.article_outlined, size: 64, color: AppColors.lightTextTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Khong co bai viet',
              style: TextStyle(color: AppColors.lightTextSecondary),
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
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.2),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.lightTextSecondary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              knowledge.titleVi ?? knowledge.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Preview
            Text(
              _getPreview(knowledge.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
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
                      Icon(Icons.fitness_center, size: 14, color: AppColors.lightTextTertiary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${knowledge.relatedDrillCodes.length} drills',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
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
    Color color;
    switch (difficulty) {
      case DifficultyLevel.beginner:
        color = AppColors.success;
        break;
      case DifficultyLevel.intermediate:
        color = AppColors.accent;
        break;
      case DifficultyLevel.advanced:
        color = AppColors.warning;
        break;
      case DifficultyLevel.expert:
        color = AppColors.error;
        break;
    }

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
    return _buildSearchResults();
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
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text(
          'Nhap tu khoa de tim kiem',
          style: TextStyle(color: AppColors.lightTextSecondary),
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
            Icon(Icons.search_off, size: 64, color: AppColors.lightTextTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Khong tim thay ket qua',
              style: TextStyle(color: AppColors.lightTextSecondary),
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
