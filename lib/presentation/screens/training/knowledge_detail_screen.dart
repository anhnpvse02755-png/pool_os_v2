import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../knowledge/knowledge_provider.dart';
import '../../../knowledge/knowledge_models.dart';
import '../../../knowledge/drill_code_bridge.dart';
import '../../widgets/soft_background.dart';

class KnowledgeDetailScreen extends ConsumerWidget {
  final String slug;

  const KnowledgeDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final knowledge = ref.read(knowledgeProvider.notifier).getBySlug(slug);

    if (knowledge == null) {
      return Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          title: const Text('Lỗi'),
          backgroundColor: AppColors.surface(brightness),
          foregroundColor: AppColors.textPrimary(brightness),
          elevation: 0,
        ),
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
      backgroundColor: AppColors.background(brightness),
      body: SoftBackground(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.surface(brightness),
              foregroundColor: AppColors.textPrimary(brightness),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  knowledge.titleVi ?? knowledge.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    // LOANG, không phải tô đặc — y hệt header của
                    // `drill_detail_screen`, cùng hình dạng và cùng cách sửa.
                    // `foregroundColor` ở trên vẽ nút back và tiêu đề bằng
                    // `textPrimary(brightness)` ngay TRÊN nền này.
                    //
                    // Bản cũ tô đặc `accent` rồi cho đuôi tụt xuống alpha 0.7.
                    // Đuôi đó dưới sàn 0.86 mà lô anh em vừa đo, và nó cũng
                    // khoá sáng vì `accent` là hằng bất biến. Loang 0.18 -> 0.10
                    // trên `surface` (nền thật ở đây là `backgroundColor` của
                    // `SliverAppBar`, vì `flexibleSpace` nằm trong `Material`
                    // của nó) đưa chrome về 9.65–12.19:1 ở cả hai chế độ.
                    //
                    // `withValues` trên nền Container là hợp lệ: luật cấm alpha
                    // chỉ áp cho MÀU CHỮ.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary(brightness)
                            .withValues(alpha: 0.18),
                        AppColors.primary(brightness)
                            .withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                  child: Center(
                    // Nền đã HẾT bão hoà nên trắng ở đây là lựa chọn sai —
                    // glyph phải sẫm ở chế độ sáng và sáng ở chế độ tối, đúng
                    // định nghĩa `textPrimary(brightness)`. GIỮ alpha: đây là
                    // hoa văn trang trí cỡ 64 nằm sau nội dung, không phải chữ
                    // để đọc, nên luật "không alpha trên màu chữ" không áp.
                    child: Icon(
                      _getCategoryIcon(category?.icon),
                      size: 64,
                      color: AppColors.textPrimary(brightness)
                          .withValues(alpha: 0.25),
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
                    _buildMetaInfo(knowledge, category, brightness),
                    const SizedBox(height: AppSpacing.xxl),

                    // Main content
                    _buildContent(knowledge, brightness),
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
      ),
      bottomNavigationBar: _buildBottomBar(context, knowledge),
    );
  }

  Widget _buildMetaInfo(KnowledgeItem knowledge, KnowledgeCategory? category,
      Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          _MetaBadge(
            icon: Icons.signal_cellular_alt,
            label: knowledge.difficulty.label,
            color: _getDifficultyColor(knowledge.difficulty, brightness),
          ),
          const SizedBox(width: AppSpacing.md),

          // Ô DANH MỤC ĐÃ BỎ MÀU, có chủ đích.
          //
          // Nó đứng NGAY CẠNH ô độ khó, và hai ô dùng chung một hình dạng
          // `_MetaBadge`. Bản cũ tô `accent` (217°) nên hai ô tách bạch. Ánh xạ
          // máy móc `accent` -> `primary` đưa nó về 157–163°, tức trùng dải với
          // bậc "Cơ bản" (`success`, 160°) — gặp bài Cơ bản là hai ô cạnh nhau
          // thành cùng một màu xanh.
          //
          // Danh mục không phải một thang có thứ bậc và nhãn của nó đã là TÊN
          // danh mục, nên nó không cần mang nghĩa bằng màu. Bỏ màu cho nó là
          // cách rẻ nhất trả lại sự phân biệt cho ô độ khó bên cạnh.
          if (category != null)
            _MetaBadge(
              icon: _getCategoryIcon(category.icon),
              label: category.nameVi ?? category.name,
              color: AppColors.textSecondary(brightness),
            ),

          const Spacer(),

          if (knowledge.relatedDrillCodes.isNotEmpty)
            Row(
              children: [
                Icon(Icons.fitness_center,
                    size: 16, color: AppColors.textSecondary(brightness)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${knowledge.relatedDrillCodes.length} drills',
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildContent(KnowledgeItem knowledge, Brightness brightness) {
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary(brightness),
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
                        child: _parseInlineText(item.value, brightness),
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
            child: _parseInlineText(section['text']!, brightness),
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

  // Không có `BuildContext` ở đây — `Brightness` đi vào bằng tham số do
  // `_buildContent` truyền xuống.
  Widget _parseInlineText(String text, Brightness brightness) {
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
        style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textPrimary(brightness)),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }

  Widget _buildRelatedDrills(BuildContext context, List<KnowledgeItem> drills) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center,
                size: 20, color: AppColors.primary(brightness)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bài tập liên quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary(brightness),
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
              avatar: Icon(Icons.play_arrow,
                  size: 18, color: AppColors.primary(brightness)),
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
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, size: 20, color: AppColors.primary(brightness)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bài viết liên quan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary(brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...related.map((k) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(brightness)),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            // `SoftBackground` đặt một `DecoratedBox` CÓ MÀU giữa `ListTile` và
            // `Material` gần nhất, nên vệt ripple của nó sẽ bị che. Bọc bằng
            // `Material` trong suốt là cách sửa mà framework chỉ ra, và cũng là
            // cách `match_history_screen.dart` đang dùng.
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: Icon(Icons.article,
                    color: AppColors.textSecondary(brightness)),
                title: Text(k.titleVi ?? k.title,
                    style:
                        TextStyle(color: AppColors.textPrimary(brightness))),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textTertiary(brightness)),
                onTap: () {
                  context.push('/training/knowledge/${k.slug}');
                },
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildTags(BuildContext context, List<String> tagIds, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final notifier = ref.read(knowledgeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label,
                size: 20, color: AppColors.textSecondary(brightness)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Tags',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary(brightness),
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
            // Nhánh `tag.color` là màu ĐẾN TỪ DỮ LIỆU lúc chạy, không phải một
            // hằng màu trong mã, nên nó không thuộc phạm vi đổi token và được
            // giữ nguyên. Chỉ nhánh dự phòng đổi sang accessor theo chế độ.
            return Chip(
              label: Text(tag?.nameVi ?? tag?.name ?? tagId),
              backgroundColor: tag?.color != null
                  ? Color(int.parse(tag!.color!.replaceFirst('#', '0xFF')))
                      .withValues(alpha: 0.1)
                  : AppColors.background(brightness),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBottomBar(BuildContext context, KnowledgeItem knowledge) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        // Thanh đáy hắt bóng LÊN TRÊN, nên lật dấu offset của bóng mềm chung
        // thay vì giữ một hằng bóng khoá sáng. Nền tối nuốt bóng nên thêm viền
        // trên để vẫn thấy được mép thanh.
        boxShadow: AppShadows.soft(brightness)
            .map((s) => BoxShadow(
                  color: s.color,
                  blurRadius: s.blurRadius,
                  offset: Offset(0, -s.offset.dy / 2),
                ))
            .toList(),
        border: Border(
            top: BorderSide(color: AppColors.border(brightness))),
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
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary(brightness)),
                  foregroundColor: AppColors.primary(brightness),
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
                label: 'Luyện tập',
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

  /// Tông của một mức độ khó.
  ///
  /// BỘ ANH EM ĐƯỢC MÃ HOÁ BẰNG MÀU. Bản cũ là success(160°) / accent(217°) /
  /// warning(38°) / error(0°). Ánh xạ máy móc `accent` -> `primary` đặt bậc
  /// "Trung bình" vào 157–163°, cách bậc "Cơ bản" (`success`, 160°) đúng 3° —
  /// hai bậc cạnh nhau thành cùng một màu xanh.
  ///
  /// Dùng lại ĐÚNG thang bốn bậc của `drill_detail_screen` và của
  /// `knowledge_screen`: success / warning / error / difficultyExpert, tức
  /// 160° / 38° / 0° / 262°, cách nhau tối thiểu 38° ở cả hai chế độ.
  Color _getDifficultyColor(DifficultyLevel level, Brightness brightness) {
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
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                        color: AppColors.primary(brightness)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          // Nút TÔ ĐẶC `primary`, tức nền đổi theo chế độ — chữ và icon dùng
          // `onPrimary(brightness)` ở độ đặc đầy đủ.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: AppColors.onPrimary(brightness), size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary(brightness))),
            ],
          ),
        ),
      ),
    );
  }
}
