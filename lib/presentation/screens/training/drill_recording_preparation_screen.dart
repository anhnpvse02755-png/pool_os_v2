import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';

/// Sprint 3A Task Fix — Recording Preparation Screen.
///
/// Sits between DrillDetailScreen and DrillSessionScreen.
/// Its sole responsibility is to prepare the player for the session:
/// - Confirm drill + level
/// - Show objective / setup
/// - Let player verify readiness
///
/// Does NOT record. Does NOT start the session. Only confirms readiness
/// and hands off to DrillSessionScreen.
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

    // Error state: drill not found
    if (drill == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Không tìm thấy bài tập này',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bài tập với mã "${widget.drillCode}" không tồn tại hoặc đã bị xóa.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/training/drills'),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Quay về thư viện bài tập'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuẩn bị ghi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drill & Level Header
                  _DrillLevelHeader(
                    drillName: drill.nameVi,
                    level: level?.level ?? widget.level,
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Objective Card
                  _ObjectiveCard(
                    criteriaText: level?.criteriaText ?? drill.goal,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Setup Instructions
                  _SetupInstructions(
                    setup: drill.setup,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Steps Summary
                  _StepsSummary(
                    steps: drill.steps,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Readiness Checkbox
                  _ReadinessCheckbox(
                    isReady: _isReady,
                    onChanged: (value) => setState(() => _isReady = value ?? false),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),

          // Bottom CTA
          _BottomCTA(
            isReady: _isReady,
            onStartRecording: _startRecording,
          ),
        ],
      ),
    );
  }
}

/// Shows drill name and selected level.
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
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

/// Shows the level's objective / criteria.
class _ObjectiveCard extends StatelessWidget {
  final String criteriaText;

  const _ObjectiveCard({required this.criteriaText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.track_changes,
            color: AppTheme.accentGold,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mục tiêu Level',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
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

/// Shows table/camera setup instructions.
class _SetupInstructions extends StatelessWidget {
  final String setup;

  const _SetupInstructions({required this.setup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cách setup bàn / camera',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  setup,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
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

/// Shows a brief steps summary with expandable option.
class _StepsSummary extends StatelessWidget {
  final List<String> steps;

  const _StepsSummary({required this.steps});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        Icons.list_alt_outlined,
        color: AppTheme.textSecondary,
      ),
      title: Text(
        'Các bước thực hiện',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        '${steps.length} bước',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      children: steps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
    );
  }
}

/// Readiness confirmation checkbox.
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isReady
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReady
                ? AppTheme.primaryGreen
                : Colors.grey.shade300,
            width: isReady ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isReady ? Icons.check_circle : Icons.circle_outlined,
              color: isReady ? AppTheme.primaryGreen : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tôi đã sẵn sàng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isReady
                              ? AppTheme.primaryGreen
                              : AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bàn đã setup đúng, camera sẵn sàng, tôi tập trung.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
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

/// Bottom CTA bar with "Bắt đầu ghi" button.
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isReady ? onStartRecording : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isReady ? Icons.videocam : Icons.videocam_off),
              const SizedBox(width: 8),
              Text(
                isReady ? 'Bắt đầu ghi' : 'Xác nhận sẵn sàng',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
