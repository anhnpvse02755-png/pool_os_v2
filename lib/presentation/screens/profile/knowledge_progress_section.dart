import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
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
    final brightness = Theme.of(context).brightness;

    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LinearProgressIndicator(
          color: AppColors.primary(brightness),
          backgroundColor: AppColors.border(brightness),
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
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
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
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.menu_book, color: AppColors.primary(brightness), size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Knowledge Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pastelFor(0, brightness),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '$readCount articles',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary(brightness),
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
                color: AppColors.background(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textTertiary(brightness),
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Bạn chưa đọc bài viết nào. Hãy khám phá Knowledge!',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
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
                      color: AppColors.background(brightness),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border(brightness)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.successSubtle(brightness),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(brightness),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Read at ${_format((_progress[id] as Map)['readAt'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(brightness),
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
