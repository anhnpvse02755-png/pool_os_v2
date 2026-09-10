import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

class DrillRecordingPreparationScreen extends StatefulWidget {
  final String drillCode;
  final int level;

  const DrillRecordingPreparationScreen({
    super.key,
    required this.drillCode,
    required this.level,
  });

  @override
  State<DrillRecordingPreparationScreen> createState() =>
      _DrillRecordingPreparationScreenState();
}

class _DrillRecordingPreparationScreenState
    extends State<DrillRecordingPreparationScreen> {
  bool _isReady = false;
  Drill? _drill;
  DrillLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadDrill();
  }

  void _loadDrill() {
    final drill = DrillLibrary.getDrill(widget.drillCode);
    if (drill != null) {
      final level = drill.levels
          .where((l) => l.level == widget.level)
          .firstOrNull;
      setState(() {
        _drill = drill;
        _selectedLevel = level ?? drill.levels.first;
      });
    }
  }

  void _startRecording() {
    if (!_isReady) return;
    context.push(
      '/training/session/new?drill=${widget.drillCode}&level=${widget.level}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final drill = _drill;
    final level = _selectedLevel;

    if (drill == null) {
      return Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          title: const Text('Lỗi'),
          backgroundColor: AppColors.surface(brightness),
          foregroundColor: AppColors.textPrimary(brightness),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SoftBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Không tìm thấy bài tập này',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(brightness),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Bai tap voi ma "${widget.drillCode}" khong ton tai.',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _PrimaryButton(
                    onPressed: () => context.go('/training/drills'),
                    label: 'Quay về thư viện bài tập',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Chuẩn bị ghi'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SoftBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DrillLevelHeader(
                      drillName: drill.nameVi,
                      level: level?.level ?? widget.level,
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: AppSpacing.xxl),

                    _ObjectiveCard(
                      criteriaText: level?.criteriaText ?? drill.goal,
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: AppSpacing.lg),

                    _SetupInstructions(
                      setup: drill.setup,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: AppSpacing.lg),

                    _StepsSummary(
                      steps: drill.steps,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: AppSpacing.xxl),

                    _ReadinessCheckbox(
                      isReady: _isReady,
                      onChanged: (value) =>
                          setState(() => _isReady = value ?? false),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),

            _BottomCTA(
              isReady: _isReady,
              onStartRecording: _startRecording,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillLevelHeader extends StatelessWidget {
  final String drillName;
  final int level;

  const _DrillLevelHeader({
    required this.drillName,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Cả khối này nằm trên dải chuyển sắc `primary(brightness)` — nền ĐỔI theo
    // chế độ, nên CHỮ phải dùng `onPrimary(brightness)` chứ không phải trắng
    // cứng: chế độ tối primary là #34A97C, trắng đặt lên chỉ còn ~2.5:1.
    //
    // Nhưng các ô mờ (scrim) thì KHÔNG theo quy tắc đó — xem chú thích tại
    // chỗ khai báo màu của chúng bên dưới.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(brightness),
            // Đuôi dải KHÔNG được nhạt quá: nó pha xuống nền màn hình và kéo
            // tương phản của chữ đặt lên. Ở 0,8 đuôi tối là #2D8C67, chữ
            // `onPrimary(dark)` trên đó chỉ 4,10:1 — mà `titleLarge` bộ này là
            // 16px (đậm vẫn dưới ngưỡng 18,66px của "chữ lớn"), nên sàn là
            // 4,5:1 chứ không phải 3:1. 0,86 là mức thấp nhất còn qua sàn:
            // đuôi #2F956E, chữ 4,56:1; đồng thời kéo ô mờ bản sáng từ
            // 4,15:1 lên 4,71:1.
            AppColors.primary(brightness).withValues(alpha: 0.86),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // Scrim làm SÁNG nền gradient, nên phải là mực sáng ở CẢ HAI chế
              // độ — onPrimary lật theo chế độ nên ở chế độ tối nó tối gần bằng
              // chữ đặt lên, kéo tương phản xuống 3,10–4,20:1. Đây là cùng lý do
              // với các nền hằng bất biến: nền không đổi theo chế độ thì mực
              // trên nó cũng không được đổi.
              color: AppColors.onPrimary(Brightness.light).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.onPrimary(brightness),
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drillName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onPrimary(brightness),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    // Cùng lý do với ô 60px ở trên: scrim là mực sáng cố định.
                    // Chữ 'Level' 14px đậm — dưới ngưỡng "chữ lớn" nên cần
                    // 4,5:1. Với scrim cũ, bản tối chỉ 3,10–4,20:1.
                    color: AppColors.onPrimary(Brightness.light).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Level $level',
                    style: TextStyle(
                      color: AppColors.onPrimary(brightness),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectiveCard extends StatelessWidget {
  final String criteriaText;

  const _ObjectiveCard({required this.criteriaText});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes,
            color: AppColors.gold,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mục tiêu Level',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  criteriaText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary(brightness),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupInstructions extends StatelessWidget {
  final String setup;

  const _SetupInstructions({required this.setup});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppSpacing.radiusLg,
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            color: AppColors.textSecondary(brightness),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cach setup ban / camera',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(brightness),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  setup,
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsSummary extends StatelessWidget {
  final List<String> steps;

  const _StepsSummary({required this.steps});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      padding: EdgeInsets.zero,
      radius: AppSpacing.radiusLg,
      child: ExpansionTile(
        leading: Icon(
          Icons.list_alt_outlined,
          color: AppColors.textSecondary(brightness),
        ),
        title: Text(
          'Các bước thực hiện',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(brightness),
              ),
        ),
        subtitle: Text(
          '${steps.length} buoc',
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 12,
          ),
        ),
        children: steps.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.pastelFor(0, brightness),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        color: AppColors.primary(brightness),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(brightness),
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReadinessCheckbox extends StatelessWidget {
  final bool isReady;
  final ValueChanged<bool?> onChanged;

  const _ReadinessCheckbox({
    required this.isReady,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: () => onChanged(!isReady),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isReady
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.background(brightness),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isReady
                ? AppColors.success
                : AppColors.border(brightness),
            width: isReady ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isReady ? Icons.check_circle : Icons.circle_outlined,
              color:
                  isReady ? AppColors.success : AppColors.textTertiary(brightness),
              size: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tôi đã sẵn sàng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isReady
                              ? AppColors.success
                              : AppColors.textPrimary(brightness),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bàn đã setup đúng, camera sẵn sàng, tôi tập trung.',
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCTA extends StatelessWidget {
  final bool isReady;
  final VoidCallback onStartRecording;

  const _BottomCTA({
    required this.isReady,
    required this.onStartRecording,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        // Thanh đáy hắt bóng LÊN TRÊN, nên phải lật dấu offset của shadow mềm.
        boxShadow: AppShadows.soft(brightness)
            .map((s) => BoxShadow(
                  color: s.color,
                  blurRadius: s.blurRadius,
                  offset: Offset(0, -s.offset.dy / 2),
                ))
            .toList(),
        border: Border(top: BorderSide(color: AppColors.border(brightness))),
      ),
      child: SafeArea(
        child: _PrimaryButton(
          onPressed: isReady ? onStartRecording : null,
          label: isReady ? 'Bắt đầu ghi' : 'Xác nhận sẵn sàng',
          icon: isReady ? Icons.videocam : Icons.videocam_off,
        ),
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
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            // Cả hai nhánh nền đều đổi theo chế độ, nên chữ dùng
            // `onPrimary(brightness)`.
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: AppColors.onPrimary(brightness), size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary(brightness)),
                  textAlign: TextAlign.center),
            ],
          )),
      ),
    );
  }
}
