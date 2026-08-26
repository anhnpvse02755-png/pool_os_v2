import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../../knowledge/knowledge_models.dart';
import '../../../knowledge/drill_code_bridge.dart';

class KnowledgeDetailScreen extends ConsumerWidget {
  final String slug;

  const KnowledgeDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knowledge = ref.read(knowledgeProvider.notifier).getBySlug(slug);

    if (knowledge == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Loi'),
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Khong tim thay bai viet'),
        ),
      );
    }

    final category = ref.read(knowledgeProvider.notifier).getCategoryById(knowledge.categoryId);
    final relatedKnowledge = knowledge.relatedKnowledgeIds
        .map((id) => ref.read(knowledgeProvider.notifier).getById(id))
        .where((k) => k != null)
        .cast<KnowledgeItem>()
        .toList();

    final relatedDrills = ref.read(knowledgeProvider.notifier).getKnowledgeForDrill(knowledge.id);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.lightSurface,
            foregroundColor: AppColors.lightTextPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                knowledge.titleVi ?? knowledge.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category?.icon),
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info
                  _buildMetaInfo(knowledge, category),
                  const SizedBox(height: AppSpacing.xxl),

                  // Main content
                  _buildContent(knowledge),
                  const SizedBox(height: AppSpacing.xxl),

                  // Related Drills
                  if (relatedDrills.isNotEmpty) ...[
                    _buildRelatedDrills(context, relatedDrills),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Related Knowledge
                  if (relatedKnowledge.isNotEmpty) ...[
                    _buildRelatedKnowledge(context, relatedKnowledge),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Tags
                  if (knowledge.tagIds.isNotEmpty) ...[
                    _buildTags(context, knowledge.tagIds, ref),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, knowledge),
    );
  }

  Widget _buildMetaInfo(KnowledgeItem knowledge, KnowledgeCategory? category) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          _MetaBadge(
            icon: Icons.signal_cellular_alt,
            label: knowledge.difficulty.label,
            color: _getDifficultyColor(knowledge.difficulty),
          ),
          const SizedBox(width: AppSpacing.md),

          if (category != null)
            _MetaBadge(
              icon: _getCategoryIcon(category.icon),
              label: category.nameVi ?? category.name,
              color: AppColors.accent,
            ),

          const Spacer(),

          if (knowledge.relatedDrillCodes.isNotEmpty)
            Row(
              children: [
                Icon(Icons.fitness_center, size: 16, color: AppColors.lightTextSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${knowledge.relatedDrillCodes.length} drills',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildContent(KnowledgeItem knowledge) {
    final content = knowledge.contentVi ?? knowledge.content;
    final sections = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;

        if (section['type'] == 'header') {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
            child: Text(
              section['text']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ).animate().fadeIn(delay: (index * 50).ms);
        } else if (section['type'] == 'list') {
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (section['items'] as List).asMap().entries.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: _parseInlineText(item.value),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: (index * 50).ms);
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _parseInlineText(section['text']!),
          ).animate().fadeIn(delay: (index * 50).ms);
        }
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _parseContent(String content) {
    final sections = <Map<String, dynamic>>[];
    final lines = content.split('\n');

    List<String>? currentList;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('## ')) {
        if (currentList != null) {
          sections.add({'type': 'list', 'items': currentList});
          currentList = null;
        }
        sections.add({'type': 'header', 'text': line.substring(3)});
      } else if (line.startsWith('- ')) {
        currentList ??= [];
        currentList.add(line.substring(2));
      } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        currentList ??= [];
        currentList.add(line.replaceFirst(RegExp(r'^\d+\.\s'), ''));
      } else {
        if (currentList != null) {
          sections.add({'type': 'list', 'items': currentList});
          currentList = null;
        }
        sections.add({'type': 'text', 'text': line});
      }
    }

    if (currentList != null) {
      sections.add({'type': 'list', 'items': currentList});
    }

    return sections;
  }

  Widget _parseInlineText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    var lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.lightTextPrimary),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }

  Widget _buildRelatedDrills(BuildContext context, List<KnowledgeItem> drills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center, size: 20, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Bai tap lien quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: drills.map((drill) {
            return ActionChip(
              avatar: Icon(Icons.play_arrow, size: 18, color: AppColors.accent),
              label: Text(drill.titleVi ?? drill.title),
              onPressed: () {
                final v2code = resolveDrillCodes(drill.relatedDrillCodes).firstOrNull;
                if (v2code != null) {
                  context.push('/training/session/new?drill=$v2code');
                }
              },
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildRelatedKnowledge(BuildContext context, List<KnowledgeItem> related) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Bai viet lien quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...related.map((k) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightBorder),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: ListTile(
              leading: Icon(Icons.article, color: AppColors.lightTextSecondary),
              title: Text(k.titleVi ?? k.title, style: const TextStyle(color: AppColors.lightTextPrimary)),
              trailing: Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
              onTap: () {
                context.push('/training/knowledge/${k.slug}');
              },
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildTags(BuildContext context, List<String> tagIds, WidgetRef ref) {
    final notifier = ref.read(knowledgeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label, size: 20, color: AppColors.lightTextSecondary),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Tags',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: tagIds.map((tagId) {
            final tag = notifier.getTagById(tagId);
            return Chip(
              label: Text(tag?.nameVi ?? tag?.name ?? tagId),
              backgroundColor: tag?.color != null
                  ? Color(int.parse(tag!.color!.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1)
                  : AppColors.lightBackground,
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBottomBar(BuildContext context, KnowledgeItem knowledge) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Da luu vao bookmark'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_outline),
                label: const Text('Luu'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accent),
                  foregroundColor: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _PrimaryButton(
                onPressed: () {
                  final v2code = resolveDrillCodes(knowledge.relatedDrillCodes).firstOrNull;
                  if (v2code != null) {
                    context.push('/training/session/new?drill=$v2code');
                  }
                },
                label: 'Luyen tap',
                icon: Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? icon) {
    switch (icon) {
      case 'school':
        return Icons.school;
      case 'sports_cricket':
        return Icons.sports_cricket;
      case 'gps_fixed':
        return Icons.gps_fixed;
      case 'timeline':
        return Icons.timeline;
      case 'psychology':
        return Icons.psychology;
      case 'build':
        return Icons.build;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'rule':
        return Icons.rule;
      default:
        return Icons.article;
    }
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.accent;
      case DifficultyLevel.advanced:
        return AppColors.warning;
      case DifficultyLevel.expert:
        return AppColors.error;
    }
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
  final IconData? icon;
  const _PrimaryButton({required this.onPressed, required this.label, this.icon});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
