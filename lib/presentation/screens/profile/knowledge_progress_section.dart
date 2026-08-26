import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';

/// Knowledge progress section with Minimalist Luxury design.
class KnowledgeProgressSection extends StatefulWidget {
  const KnowledgeProgressSection({super.key});

  @override
  State<KnowledgeProgressSection> createState() =>
      _KnowledgeProgressSectionState();
}

class _KnowledgeProgressSectionState extends State<KnowledgeProgressSection> {
  Map<String, dynamic> _progress = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cache = ProviderScope.containerOf(context, listen: false)
        .read(cacheRepositoryProvider);
    _progress = await cache.getKnowledgeProgress();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const LinearProgressIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.lightBorder,
        ),
      );
    }
    final readIds = _progress.entries
        .where((e) => (e.value as Map)['read'] == true)
        .map((e) => e.key)
        .toList();
    final readCount = readIds.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.menu_book, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Knowledge Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtleLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$readCount articles',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (readIds.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.lightTextTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Bạn chưa đọc bài viết nào. Hãy khám phá Knowledge!',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...readIds.take(5).map((id) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.successSubtleLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightTextPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Read at ${_format((_progress[id] as Map)['readAt'])}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  String _format(dynamic v) => v == null ? '—' : v.toString().substring(0, 10);
}
