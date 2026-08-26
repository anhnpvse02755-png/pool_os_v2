import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';

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
    final drill = _drill;
    final level = _selectedLevel;

    if (drill == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Loi'),
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
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
                  'Khong tim thay bai tap nay',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bai tap voi ma "${widget.drillCode}" khong ton tai.',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _PrimaryButton(
                  onPressed: () => context.go('/training/drills'),
                  label: 'Quay ve thu vien bai tap',
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Chuan bi ghi'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
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
                    onChanged: (value) => setState(() => _isReady = value ?? false),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accent.withValues(alpha: 0.8),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
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
                        color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'Level $level',
                    style: const TextStyle(
                      color: Colors.white,
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
                  'Muc tieu Level',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  criteriaText,
                  style: Theme.of(context).textTheme.bodyMedium,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            color: AppColors.lightTextSecondary,
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
                        color: AppColors.lightTextPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  setup,
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: ExpansionTile(
        leading: Icon(
          Icons.list_alt_outlined,
          color: AppColors.lightTextSecondary,
        ),
        title: Text(
          'Cac buoc thuc hien',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
        ),
        subtitle: Text(
          '${steps.length} buoc',
          style: TextStyle(
            color: AppColors.lightTextSecondary,
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
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        color: AppColors.accent,
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
                    style: Theme.of(context).textTheme.bodySmall,
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
    return InkWell(
      onTap: () => onChanged(!isReady),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isReady
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isReady
                ? AppColors.success
                : AppColors.lightBorder,
            width: isReady ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isReady ? Icons.check_circle : Icons.circle_outlined,
              color: isReady ? AppColors.success : AppColors.lightTextTertiary,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toi da san sang',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isReady
                              ? AppColors.success
                              : AppColors.lightTextPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Ban da setup dung, camera san sang, toi tap trung.',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
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
        child: _PrimaryButton(
          onPressed: isReady ? onStartRecording : null,
          label: isReady ? 'Bat dau ghi' : 'Xac nhan san sang',
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
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
            ],
          )),
      ),
    );
  }
}
