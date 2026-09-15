import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/warmup_provider.dart';
import '../../../core/providers/active_session_provider.dart';
import '../../../core/providers/training_provider.dart';
import '../../../knowledge/knowledge_graph_service.dart' as kg;
import '../../../core/models/session_item.dart';
import '../../../domain/services/session_builder_service.dart';

/// Màn hình "Buổi tập hôm nay"
/// Dac-Ta-Man-Hinh-Buoi-Tap-Hom-Nay.md
///
/// Route: /training/session/today?warmed=1 (khi đến từ warmup)
///
/// Luồng: chọn thời gian → xem đề xuất → bắt đầu / bỏ qua bài / tự chọn
class TodaysSessionScreen extends ConsumerStatefulWidget {
  const TodaysSessionScreen({super.key});

  @override
  ConsumerState<TodaysSessionScreen> createState() => _TodaysSessionScreenState();
}

class _TodaysSessionScreenState extends ConsumerState<TodaysSessionScreen> {
  /// Các items đã chọn (ban đầu = toàn bộ đề xuất)
  List<SessionItem> _selectedItems = [];
  bool _warmedUp = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selectedItems khi provider data sẵn sàng, đồng thời đọc cờ
    // ?warmed=1 do màn khởi động truyền sang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goState = GoRouterState.of(context);
      setState(() {
        _warmedUp = goState.uri.queryParameters['warmed'] == '1';
      });
      _syncSelected();
    });
  }

  void _syncSelected() {
    final session = ref.read(proposedSessionProvider);
    setState(() {
      _selectedItems = List.from(session.items);
    });
  }

  void _skipItem(SessionItem item) {
    final duration = ref.read(selectedSessionDurationProvider);
    final trainingState = ref.read(trainingNotifierProvider);
    final completedCodes = ref.read(completedDrillCodesProvider);

    final service = ref.read(_sessionBuilderServiceProvider);
    final newItems = service.skipItem(
      currentItems: _selectedItems,
      drillCodeToSkip: item.drillCode,
      availableMinutes: duration,
      trainingHistory: trainingState.sessions,
      completedDrillCodes: completedCodes,
    );
    setState(() {
      _selectedItems = newItems;
    });
  }

  void _showReason(SessionItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(Theme.of(context).brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => _ReasonSheet(item: item),
    );
  }

  void _startSession() {
    if (_selectedItems.isEmpty) return;

    final notifier = ref.read(activeSessionProvider.notifier);
    notifier.start(_selectedItems);
    final first = ref.read(activeSessionProvider).current;

    if (first == null) {
      // Mọi bài đề xuất đều không có bài tập tương ứng. Nói thẳng thay vì
      // đẩy người dùng sang màn lỗi khó hiểu.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có bài tập cho các nội dung được đề xuất.'),
        ),
      );
      return;
    }

    // `level` là BẮT BUỘC: màn tập chỉ tự khởi động phiên khi thấy tham số
    // này. Thiếu nó thì màn đứng ở trạng thái chờ và không có nút ghi nhận.
    context.push('/training/session/new?drill=${first.drillCode}&level=1');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final duration = ref.watch(selectedSessionDurationProvider);
    final proposed = ref.watch(proposedSessionProvider);
    final trainingState = ref.watch(trainingNotifierProvider);

    // Sync on provider change
    ref.listen(proposedSessionProvider, (_, next) {
      if (_selectedItems.isEmpty) {
        setState(() {
          _selectedItems = List.from(next.items);
        });
      }
    });

    final hasHistory = trainingState.sessions.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Buổi tập hôm nay',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary(brightness)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header greeting
            _buildHeader(brightness, warmedUp: _warmedUp),
            const SizedBox(height: AppSpacing.lg),

            // Warmup prompt (chỉ hiện nếu chưa warmup hôm nay)
            ref.watch(warmupDoneTodayProvider).whenOrNull(
              data: (warmupDone) {
                if (warmupDone) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _WarmupPromptBanner(
                    onStartWarmup: () => context.push('/training/session/warmup'),
                    onSkip: () {},
                  ).animate().fadeIn(duration: 300.ms),
                );
              },
            ) ?? const SizedBox.shrink(),

            // Retest banner
            if (proposed.retestCount > 0) ...[
              _RetestBanner(count: proposed.retestCount)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Time selector (only show if not yet selected or still choosing)
            if (_selectedItems.isEmpty || proposed.items.isNotEmpty) ...[
              _TimeSelector(
                selectedMinutes: duration,
                onSelected: (mins) {
                  ref.read(selectedSessionDurationProvider.notifier).state = mins;
                  // Reset selection
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _syncSelected();
                  });
                },
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Proposed session (after selecting time)
            if (proposed.items.isNotEmpty) ...[
              _buildSessionList(
                  brightness, proposed, hasHistory),
            ] else ...[
              _buildEmptyState(brightness),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Brightness brightness, {bool warmedUp = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(brightness),
            AppColors.primaryDeep(brightness),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(brightness).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary(brightness).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.schedule,
                    color: AppColors.onPrimary(brightness), size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _greeting(),
                            style: TextStyle(
                              color: AppColors.onPrimary(brightness),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (warmedUp) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary(brightness).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.onPrimary(brightness),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Đã khởi động',
                                  style: TextStyle(
                                    color: AppColors.onPrimary(brightness),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hãy chọn thời gian để bắt đầu',
                      style: TextStyle(
                        color: AppColors.onPrimary(brightness).withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Chào buổi sáng!';
    if (h < 17) return 'Chào buổi chiều!';
    return 'Chào buổi tối!';
  }

  Widget _buildSessionList(
      Brightness brightness, ProposedSession proposed, bool hasHistory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(Icons.checklist,
                  color: AppColors.primary(brightness), size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Buổi tập đề xuất',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const Spacer(),
            Text(
              '~${_selectedItems.fold(0, (s, i) => s + i.estimatedMinutes)} phút',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Session items
        ..._selectedItems.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SessionItemCard(
              item: item,
              index: index + 1,
              onSkip: () => _skipItem(item),
              onShowReason: () => _showReason(item),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms),
          );
        }),

        const SizedBox(height: AppSpacing.lg),

        // Stats row
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border(brightness)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip(
                  Icons.replay, '${proposed.retestCount}', 'Ôn lại', brightness),
              _statChip(Icons.warning_amber,
                  '${proposed.weaknessCount}', 'Điểm yếu', brightness),
              _statChip(
                  Icons.trending_up, '${proposed.pathCount}', 'Lộ trình', brightness),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

        const SizedBox(height: AppSpacing.xl),

        // Action buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedItems.isNotEmpty ? _startSession : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(brightness),
              foregroundColor: AppColors.onPrimary(brightness),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Bắt đầu buổi tập (${_selectedItems.length} bài)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: TextButton(
            onPressed: () => context.push('/training/drills'),
            child: Text(
              'Tự chọn bài khác',
              style: TextStyle(
                color: AppColors.primary(brightness),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statChip(
      IconData icon, String value, String label, Brightness brightness) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary(brightness)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary(brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.pastelFor(0, brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.primary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Không có bài tập đề xuất',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bạn đang có đủ dữ liệu để tự chọn bài tập.',
              style: TextStyle(
                color: AppColors.textSecondary(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Time Selector ───────────────────────────────────────────────────────────

class _TimeSelector extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const _TimeSelector({
    required this.selectedMinutes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hôm nay bạn có bao nhiêu thời gian?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _TimeChip(
              label: '15 phút',
              minutes: 15,
              selected: selectedMinutes == 15,
              onTap: () => onSelected(15),
            ),
            const SizedBox(width: AppSpacing.sm),
            _TimeChip(
              label: '30 phút',
              minutes: 30,
              selected: selectedMinutes == 30,
              onTap: () => onSelected(30),
            ),
            const SizedBox(width: AppSpacing.sm),
            _TimeChip(
              label: '60 phút',
              minutes: 60,
              selected: selectedMinutes == 60,
              onTap: () => onSelected(60),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary(brightness)
                : AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected
                  ? AppColors.primary(brightness)
                  : AppColors.border(brightness),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.onPrimary(brightness)
                      : AppColors.textPrimary(brightness),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Session Item Card ─────────────────────────────────────────────────────

class _SessionItemCard extends StatelessWidget {
  final SessionItem item;
  final int index;
  final VoidCallback onSkip;
  final VoidCallback onShowReason;

  const _SessionItemCard({
    required this.item,
    required this.index,
    required this.onSkip,
    required this.onShowReason,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = _priorityColor(item.priority, brightness);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary(brightness).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary(brightness),
                      ),
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
                              item.drillName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary(brightness),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.priorityLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 12,
                              color: AppColors.textSecondary(brightness)),
                          const SizedBox(width: 4),
                          Text(
                            '~${item.estimatedMinutes} phút',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(brightness),
                            ),
                          ),
                          if (item.daysSinceLastPractice != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Icon(Icons.replay,
                                size: 12,
                                color: AppColors.textSecondary(brightness)),
                            const SizedBox(width: 4),
                            Text(
                              '${item.daysSinceLastPractice} ngày trước',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(brightness),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Skip button
                IconButton(
                  onPressed: onSkip,
                  icon: Icon(Icons.close,
                      color: AppColors.textTertiary(brightness), size: 20),
                  tooltip: 'Bỏ qua',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          // Reason button
          InkWell(
            onTap: onShowReason,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm, horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background(brightness),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.radiusMd)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 14,
                      color: AppColors.textSecondary(brightness)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.reason,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(brightness),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 16,
                      color: AppColors.textTertiary(brightness)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(SessionPriority p, Brightness brightness) {
    switch (p) {
      case SessionPriority.retest:
        return AppColors.warning;
      case SessionPriority.weakness:
        return AppColors.error;
      case SessionPriority.path:
        return AppColors.primary(brightness);
    }
  }
}

// ── Reason Bottom Sheet ──────────────────────────────────────────────────

class _ReasonSheet extends StatelessWidget {
  final SessionItem item;

  const _ReasonSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = _priorityColor(item.priority, brightness);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.lightbulb, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tại sao đề xuất bài này?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(brightness),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.drillName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.priorityLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border(brightness)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: AppColors.textSecondary(brightness)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.reason,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(SessionPriority p, Brightness brightness) {
    switch (p) {
      case SessionPriority.retest:
        return AppColors.warning;
      case SessionPriority.weakness:
        return AppColors.error;
      case SessionPriority.path:
        return AppColors.primary(brightness);
    }
  }
}

// ── Warmup Prompt Banner ────────────────────────────────────────────────

class _WarmupPromptBanner extends StatelessWidget {
  final VoidCallback onStartWarmup;
  final VoidCallback onSkip;

  const _WarmupPromptBanner({
    required this.onStartWarmup,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khởi động 5 phút?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cơ thể ấm lên giúp kết quả luyện tập chính xác hơn.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onStartWarmup,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
              'Bắt đầu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Retest Banner ───────────────────────────────────────────────────────

class _RetestBanner extends StatelessWidget {
  final int count;

  const _RetestBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warningSubtle(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
            color: AppColors.warningOnTint(brightness).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.replay,
              color: AppColors.warningOnTint(brightness), size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$count kỹ năng lâu chưa ôn — nên kiểm tra lại',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.warningOnTint(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────

/// Service wrapper for UI layer — resolves the kg aliasing issue
class _SessionBuilderWrapper {
  _SessionBuilderWrapper(this._kg);
  final kg.KnowledgeGraphService _kg;

  List<SessionItem> skipItem({
    required List<SessionItem> currentItems,
    required String drillCodeToSkip,
    required int availableMinutes,
    required List<TrainingSession> trainingHistory,
    required List<String> completedDrillCodes,
  }) {
    final service = SessionBuilderService(kg: _kg);
    return service.skipItem(
      currentItems: currentItems,
      drillCodeToSkip: drillCodeToSkip,
      availableMinutes: availableMinutes,
      trainingHistory: trainingHistory,
      completedDrillCodes: completedDrillCodes,
    );
  }
}

final _sessionBuilderServiceProvider = Provider<_SessionBuilderWrapper>((ref) {
  final graph = ref.watch(knowledgeGraphProvider);
  return _SessionBuilderWrapper(graph);
});
