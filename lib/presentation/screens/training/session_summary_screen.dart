import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/active_session_provider.dart';
import '../../widgets/soft_background.dart';

/// Tổng kết cuối một buổi tập nhiều bài.
///
/// Nhận [SessionSummary] qua `extra` của GoRouter. Buổi tập đã bị xoá khỏi
/// [activeSessionProvider] trước khi tới đây, nên màn này chỉ đọc dữ liệu
/// tĩnh được truyền vào — mở lại bằng URL trực tiếp sẽ không có gì để hiện.
class SessionSummaryScreen extends ConsumerWidget {
  final SessionSummary summary;

  const SessionSummaryScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final results = summary.results;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Tổng kết buổi tập'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SoftBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),

                Icon(
                  summary.finishedEarly
                      ? Icons.flag_outlined
                      : Icons.emoji_events_outlined,
                  size: 64,
                  color: AppColors.primary(brightness),
                ).animate().fadeIn(duration: 300.ms).scale(
                      begin: const Offset(0.9, 0.9),
                    ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  summary.finishedEarly
                      ? 'Đã kết thúc sớm'
                      : 'Hoàn thành buổi tập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(brightness),
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Xong ${summary.completedCount}/${summary.plannedCount} bài',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(brightness),
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: AppSpacing.xl),

                Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Thời gian',
                        value: '${summary.totalMinutes}',
                        unit: 'phút',
                        brightness: brightness,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Chính xác',
                        value: summary.accuracy.toStringAsFixed(0),
                        unit: '%',
                        brightness: brightness,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Vào bi',
                        value: '${summary.totalMade}',
                        unit: '/ ${summary.totalMade + summary.totalMissed}',
                        brightness: brightness,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.xl),

                if (results.isEmpty)
                  Text(
                    'Chưa bài nào được ghi nhận trong buổi này.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(brightness),
                    ),
                  )
                else ...[
                  Text(
                    'TỪNG BÀI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...results.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ResultRow(result: r, brightness: brightness),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(brightness),
                    foregroundColor: AppColors.onPrimary(brightness),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Về trang chủ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/training/session/today'),
                  child: Text(
                    'Xem lại buổi tập hôm nay',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Brightness brightness;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(brightness),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final SessionResult result;
  final Brightness brightness;

  const _ResultRow({required this.result, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.drillName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${result.made}/${result.attempts} cú · ${result.minutes} phút',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.accuracy.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary(brightness),
            ),
          ),
        ],
      ),
    );
  }
}
