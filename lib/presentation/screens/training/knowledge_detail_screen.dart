import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
        appBar: AppBar(),
        body: const Center(
          child: Text('Không tìm thấy bài viết'),
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
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                knowledge.titleVi ?? knowledge.title,
                style: const TextStyle(fontSize: 16),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen,
                      AppTheme.primaryGreen.withValues(alpha: 0.7),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info
                  _buildMetaInfo(knowledge, category),
                  const SizedBox(height: 24),

                  // Main content
                  _buildContent(knowledge),
                  const SizedBox(height: 24),

                  // Related Drills
                  if (relatedDrills.isNotEmpty) ...[
                    _buildRelatedDrills(context, relatedDrills),
                    const SizedBox(height: 24),
                  ],

                  // Related Knowledge
                  if (relatedKnowledge.isNotEmpty) ...[
                    _buildRelatedKnowledge(context, relatedKnowledge),
                    const SizedBox(height: 24),
                  ],

                  // Tags
                  if (knowledge.tagIds.isNotEmpty) ...[
                    _buildTags(context, knowledge.tagIds, ref),
                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Difficulty
          _MetaBadge(
            icon: Icons.signal_cellular_alt,
            label: knowledge.difficulty.label,
            color: _getDifficultyColor(knowledge.difficulty),
          ),
          const SizedBox(width: 12),

          // Category
          if (category != null)
            _MetaBadge(
              icon: _getCategoryIcon(category.icon),
              label: category.nameVi ?? category.name,
              color: AppTheme.primaryGreen,
            ),

          const Spacer(),

          // Related drills count
          if (knowledge.relatedDrillCodes.isNotEmpty)
            Row(
              children: [
                Icon(Icons.fitness_center, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${knowledge.relatedDrillCodes.length} drills',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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

    // Parse markdown-like content
    final sections = _parseContent(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;

        if (section['type'] == 'header') {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              section['text']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ).animate().fadeIn(delay: (index * 50).ms);
        } else if (section['type'] == 'list') {
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (section['items'] as List).asMap().entries.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
            padding: const EdgeInsets.only(bottom: 8),
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
        // Flush previous list
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
        // Flush previous list
        if (currentList != null) {
          sections.add({'type': 'list', 'items': currentList});
          currentList = null;
        }
        sections.add({'type': 'text', 'text': line});
      }
    }

    // Flush final list
    if (currentList != null) {
      sections.add({'type': 'list', 'items': currentList});
    }

    return sections;
  }

  Widget _parseInlineText(String text) {
    // Simple bold parsing
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
        style: const TextStyle(fontSize: 15, height: 1.6),
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
            Icon(Icons.fitness_center, size: 20, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Bài tập liên quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: drills.map((drill) {
            return ActionChip(
              avatar: Icon(Icons.play_arrow, size: 18, color: AppTheme.primaryGreen),
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
            Icon(Icons.link, size: 20, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Bài viết liên quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...related.map((k) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.article, color: Colors.grey.shade600),
              title: Text(k.titleVi ?? k.title),
              trailing: const Icon(Icons.chevron_right),
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
            Icon(Icons.label, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            const Text(
              'Tags',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tagIds.map((tagId) {
            final tag = notifier.getTagById(tagId);
            return Chip(
              label: Text(tag?.nameVi ?? tag?.name ?? tagId),
              backgroundColor: tag?.color != null
                  ? Color(int.parse(tag!.color!.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBottomBar(BuildContext context, KnowledgeItem knowledge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                      content: Text('Đã lưu vào bookmark'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_outline),
                label: const Text('Lưu'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final v2code = resolveDrillCodes(knowledge.relatedDrillCodes).firstOrNull;
                  if (v2code != null) {
                    context.push('/training/session/new?drill=$v2code');
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Luyện tập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
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
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
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
