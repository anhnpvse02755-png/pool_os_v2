import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/models/warmup_models.dart';
import '../../../core/providers/warmup_provider.dart';

/// Màn hình Khởi động 5 phút
/// Dac-Ta-Che-Do-Khoi-Dong.md
///
/// Luồng:
///   [Phase 1] → [Phase 2] → [Phase 3] → [Màn hình kết thúc: Buổi tập / Trận đấu / Đóng]
class WarmupScreen extends ConsumerStatefulWidget {
  const WarmupScreen({super.key});

  @override
  ConsumerState<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends ConsumerState<WarmupScreen> {
  int _currentPhase = 0;
  DateTime? _startTime;
  final List<int> _completedPhases = [];
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final phase = WarmupPhases.all[_currentPhase];
    _secondsRemaining = phase.suggestedMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _nextPhase() {
    if (!_completedPhases.contains(_currentPhase + 1)) {
      _completedPhases.add(_currentPhase + 1);
    }
    if (_currentPhase < 2) {
      setState(() {
        _currentPhase++;
        _startTimer();
      });
    } else {
      _showCompletion();
    }
  }

  void _skip() async {
    await _logAndNavigate(skipped: true);
  }

  void _showCompletion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _WarmupCompletionSheet(
        onSession: () => _logAndNavigate(ledTo: 'buoi_tap'),
        onMatch: () => _logAndNavigate(ledTo: 'tran_dau'),
        onClose: () => _logAndNavigate(ledTo: 'tu_do'),
      ),
    );
  }

  Future<void> _logAndNavigate({
    bool skipped = false,
    String ledTo = 'tu_do',
  }) async {
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds / 60.0
        : 0.0;

    await logWarmup(
      didWarmup: !skipped,
      durationActualMinutes: duration,
      ledTo: ledTo,
      phasesCompleted: _completedPhases,
    );

    if (!mounted) return;

    switch (ledTo) {
      case 'buoi_tap':
        Navigator.of(context).pop();
        context.push('/training/session/today?warmed=1');
        break;
      case 'tran_dau':
        Navigator.of(context).pop();
        context.push('/play/match/record?warmed=1');
        break;
      case 'tu_do':
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final phase = WarmupPhases.all[_currentPhase];

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary(brightness),
                    ),
                    onPressed: _skip,
                    tooltip: 'Bỏ qua khởi động',
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        'Giai đoạn ${_currentPhase + 1}/3',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(brightness),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Soft timer — chỉ tham khảo, không bắt buộc
                      Text(
                        _formatTimer(_secondsRemaining),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _secondsRemaining <= 30
                              ? AppColors.warning
                              : AppColors.textTertiary(brightness),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),

            // Phase indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(3, (i) {
                  final isCompleted = i < _currentPhase;
                  final isCurrent = i == _currentPhase;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isCompleted
                            ? AppColors.primary(brightness)
                            : isCurrent
                                ? AppColors.primary(brightness).withValues(alpha: 0.4)
                                : AppColors.border(brightness),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Phase content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phase name
                    Text(
                      phase.nameVi,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      phase.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary(brightness),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Instruction card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface(brightness),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                            color: AppColors.border(brightness)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hướng dẫn',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(brightness),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            phase.instructionVi,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.textPrimary(brightness),
                            ),
                          ),
                          if (phase.relatedKnowledgeSlugs.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tham khảo: ${phase.relatedKnowledgeSlugs.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary(brightness),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const Spacer(),

                    // Mindset reminder
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary(brightness).withValues(alpha: 0.05),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.primary(brightness).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.spa_outlined,
                            size: 18,
                            color: AppColors.primary(brightness),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cứ để cơ thể tự tìm lại cảm giác. Không phải luyện tập, chỉ là chơi thôi.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(brightness),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: AppSpacing.lg),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skip,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              side: BorderSide(
                                  color: AppColors.border(brightness)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                              ),
                            ),
                            child: Text(
                              'Bỏ qua',
                              style: TextStyle(
                                color: AppColors.textSecondary(brightness),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextPhase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary(brightness),
                              foregroundColor: AppColors.onPrimary(brightness),
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPhase < 2
                                      ? 'Xong giai đoạn này'
                                      : 'Hoàn thành',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPhase < 2
                                      ? Icons.arrow_forward
                                      : Icons.check,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimer(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

// ── Warmup Completion Sheet ───────────────────────────────────────────────

class _WarmupCompletionSheet extends StatelessWidget {
  final VoidCallback onSession;
  final VoidCallback onMatch;
  final VoidCallback onClose;

  const _WarmupCompletionSheet({
    required this.onSession,
    required this.onMatch,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(brightness),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary(brightness),
                  size: 40,
                ),
              ).animate().scale(delay: 100.ms),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Bạn đã sẵn sàng!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(brightness),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Cơ thể đã ấm lên. Bây giờ bạn muốn làm gì?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(brightness),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              _OptionCard(
                icon: Icons.fitness_center,
                title: 'Vào Buổi tập hôm nay',
                subtitle: 'Luyện kỹ năng theo đề xuất',
                color: AppColors.primary(brightness),
                onTap: onSession,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppSpacing.md),

              _OptionCard(
                icon: Icons.sports_score,
                title: 'Ghi nhận trận đấu thật',
                subtitle: 'Đo hiệu quả luyện tập ngoài đời',
                color: AppColors.primaryDeep(brightness),
                onTap: onMatch,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppSpacing.md),

              _OptionCard(
                icon: Icons.sports,
                title: 'Chơi tự do',
                subtitle: 'Không ghi nhận, chỉ chơi thôi',
                color: AppColors.textSecondary(brightness),
                onTap: onClose,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: 2),
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
      ),
    );
  }
}
