import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/spacing.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/utils/drills_library.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/training_provider.dart';
import '../../../data/models/drill_session.dart';
import '../../../data/models/drill_progress.dart';
import '../../../data/models/personal_best.dart';
import '../../../data/repositories/personal_best_repository.dart';
import '../../../domain/services/drill_session_recovery_service.dart';

/// PoolOS Drill Session Screen - Redesigned with Minimalist Luxury
/// Recording interface for training drills
class DrillSessionScreen extends ConsumerStatefulWidget {
  final String drillCode;

  const DrillSessionScreen({super.key, required this.drillCode});

  @override
  ConsumerState<DrillSessionScreen> createState() => _DrillSessionScreenState();
}

class _DrillSessionScreenState extends ConsumerState<DrillSessionScreen> {
  int currentRep = 0;
  int successCount = 0;
  bool isSessionActive = false;
  String? _error;
  Drill? _drill;

  // Sprint 7B: custom target
  late int targetReps;

  // Shot recording
  ShotResult? lastShotResult;

  // Sprint 3A Task 1: persistence layer state.
  DrillSession? _session;
  late final DrillSessionRecoveryService _recovery;

  // Sprint-17 Part 3: Track auto-start state
  bool _autoStarted = false;
  bool _isInitialized = false;

  @override
  void initState() {
    print('[SPRINT17_STORAGE] SESSION_SCREEN_INIT_START');
    super.initState();
    _recovery = DrillSessionRecoveryService(ref.read(drillSessionRepositoryProvider));
    print('[SPRINT17_STORAGE] SESSION_SCREEN_INIT: recovery service created');
    _loadDrill();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryAutoStart();
  }

  void _tryAutoStart() {
    if (!mounted) return;
    if (_autoStarted) return;
    if (isSessionActive) return;
    if (_drill == null) return;

    final goState = GoRouterState.of(context);
    final level = goState.uri.queryParameters['level'];
    if (level == null) return;

    final targetParam = goState.uri.queryParameters['target'];
    if (targetParam != null) {
      final t = int.tryParse(targetParam);
      if (t != null && t > 0) {
        targetReps = t;
      }
    }

    _autoStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSession();
    });
  }

  void _loadDrill() {
    print('[SPRINT17_FLOW] LOAD_DRILL_START: drillCode=${widget.drillCode}');
    final drill = DrillLibrary.getDrill(widget.drillCode);
    print('[SPRINT17_FLOW] LOAD_DRILL: drill=${drill != null ? "found" : "null"}');

    if (drill == null) {
      setState(() {
        _error = 'Bài tập với mã "${widget.drillCode}" không tồn tại.';
        _drill = null;
      });
    } else {
      setState(() {
        _drill = drill;
        if (!_isInitialized) {
          targetReps = drill.levels.first.attempts;
          print('[SPRINT17_FLOW] LOAD_DRILL: set targetReps=$targetReps');
          _isInitialized = true;
        }
        _error = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoStart();
      });
      print('[SPRINT17_FLOW] LOAD_DRILL_COMPLETE');
    }
  }

  Future<void> _startSession() async {
    print('[SPRINT17_FLOW] START_SESSION: creating DrillSession');
    final drill = _drill;
    if (drill == null) return;

    final player = await ref.read(currentPlayerProvider.future);
    print('[SPRINT17_FLOW] START_SESSION: player=${player?.id ?? "null"}');
    if (player == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần hoàn tất hồ sơ trước khi tập.')),
      );
      return;
    }

    final session = DrillSession(
      id: 'session-${DateTime.now().microsecondsSinceEpoch}',
      playerId: player.id,
      title: drill.nameVi,
      startedAt: DateTime.now(),
    );

    print('[SPRINT17_STORAGE] START_SESSION: recovery.pause ENTER');
    await _recovery.pause(session);
    print('[SPRINT17_STORAGE] START_SESSION: recovery.pause COMPLETE');
    if (!mounted) return;

    setState(() {
      _session = session;
      isSessionActive = true;
      currentRep = 0;
      successCount = 0;
      lastShotResult = null;
    });
    print('[SPRINT17_FLOW] START_SESSION: COMPLETE - isSessionActive=$isSessionActive');
  }

  Future<void> _recordShot(ShotResult result) async {
    final session = _session;
    if (session == null) return;
    final made = result == ShotResult.success;
    final updated = await _recovery.recordAttempt(
      session,
      drillCode: widget.drillCode,
      attemptNumber: currentRep + 1,
      made: made,
    );
    if (!mounted) return;
    setState(() {
      _session = updated;
      currentRep = updated.attempts.length;
      successCount = updated.totalShotsMade;
      lastShotResult = result;
    });

    if (currentRep >= targetReps) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      await _finishSession();
    }
  }

  Future<void> _finishSession() async {
    final session = _session;
    if (session == null) return;
    final completed = await _recovery.complete(session);
    if (!mounted) return;
    await _commitPersonalBest(completed);
    await _syncToTrainingHistory(completed);
    if (!mounted) return;
    context.push(
      '/training/session/complete?drill=${widget.drillCode}',
      extra: completed,
    );
    if (!mounted) return;
    setState(() {
      _session = completed;
      isSessionActive = false;
    });
  }

  Future<void> _commitPersonalBest(DrillSession completed) async {
    final player = await ref.read(currentPlayerProvider.future);
    if (player == null) return;
    final pbRepo = LocalPersonalBestRepository();
    final pbs = await pbRepo.getForDrill(player.id, widget.drillCode);
    final existing = pbs
        .where((p) => p.metric == PbMetric.highestAccuracy)
        .cast<PersonalBest?>()
        .firstWhere((_) => true, orElse: () => null);
    final accuracy = completed.accuracy;
    if (existing == null) {
      await pbRepo.save(PersonalBest(
        playerId: player.id,
        drillCode: widget.drillCode,
        metric: PbMetric.highestAccuracy,
        value: accuracy,
        level: 1,
        achievedAt: DateTime.now(),
      ));
      return;
    }
    if (accuracy > existing.value) {
      await pbRepo.save(existing.copyWith(
        value: accuracy,
        achievedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _syncToTrainingHistory(DrillSession completed) async {
    final drillRepo = ref.read(drillRepositoryProvider);
    final trainingNotifier = ref.read(trainingNotifierProvider.notifier);

    final trainingSessionMap = completed.toTrainingSessionMap();
    final trainingSession = TrainingSession.fromJson(trainingSessionMap);
    await trainingNotifier.addSession(trainingSession);

    final progressList = await drillRepo.getUserProgress();
    final existingProgress = progressList
        .where((p) => p.drillCode == widget.drillCode)
        .firstOrNull;

    final updatedProgress = DrillProgress(
      playerId: completed.playerId,
      drillCode: widget.drillCode,
      currentLevel: existingProgress?.currentLevel ?? 1,
      bestScore: completed.accuracy > (existingProgress?.bestScore ?? 0)
          ? completed.accuracy.round()
          : existingProgress?.bestScore ?? 0,
      attempts: (existingProgress?.attempts ?? 0) + 1,
      lastAttemptAt: DateTime.now(),
    );
    await drillRepo.updateDrillProgress(updatedProgress);
  }

  double get successRate => currentRep > 0 ? (successCount / currentRep) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // Show error screen if drill not found
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          backgroundColor: AppColors.background(brightness),
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.space6),
                Text(
                  'Drill not found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  _error!,
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading if drill not loaded yet
    if (_drill == null) {
      return Scaffold(
        backgroundColor: AppColors.background(brightness),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Active session UI
    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _SessionHeader(
              drillName: _drill!.nameVi,
              isActive: isSessionActive,
              onStop: _finishSession,
              brightness: brightness,
            ),

            // Main content
            Expanded(
              child: _buildActiveSession(brightness),
            ),

            // Recording bar
            if (isSessionActive)
              _RecordingBar(
                onSuccess: () => _recordShot(ShotResult.success),
                onMiss: () => _recordShot(ShotResult.miss),
                brightness: brightness,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSession(Brightness brightness) {
    final accentColor = AppColors.accentColor(brightness);

    return Column(
      children: [
        // Progress stats
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          margin: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatDisplay(
                value: '$currentRep/$targetReps',
                label: 'Reps',
                brightness: brightness,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border(brightness),
              ),
              _StatDisplay(
                value: '${successRate.toStringAsFixed(0)}%',
                label: 'Accuracy',
                brightness: brightness,
                valueColor: successRate >= 70
                    ? AppColors.success
                    : successRate >= 50
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ],
          ),
        ).animate().fadeIn(),

        // Visual feedback area
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Last result feedback
                if (lastShotResult != null)
                  _LastResultFeedback(
                    result: lastShotResult!,
                    brightness: brightness,
                  ).animate().scale(duration: 200.ms),

                const SizedBox(height: AppSpacing.space6),

                // Status text
                Text(
                  lastShotResult != null
                      ? (lastShotResult == ShotResult.success ? 'Success!' : 'Miss')
                      : 'Ready to start!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),

                const SizedBox(height: AppSpacing.space2),

                Text(
                  'Tap buttons below after each shot',
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Session Header
class _SessionHeader extends StatelessWidget {
  final String drillName;
  final bool isActive;
  final VoidCallback onStop;
  final Brightness brightness;

  const _SessionHeader({
    required this.drillName,
    required this.isActive,
    required this.onStop,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary(brightness),
            ),
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              drillName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isActive)
            TextButton.icon(
              onPressed: onStop,
              icon: Icon(Icons.stop, color: AppColors.error, size: 18),
              label: Text(
                'Stop',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}

/// Stat Display Widget
class _StatDisplay extends StatelessWidget {
  final String value;
  final String label;
  final Brightness brightness;
  final Color? valueColor;

  const _StatDisplay({
    required this.value,
    required this.label,
    required this.brightness,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary(brightness),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(brightness),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Last Result Feedback Widget
class _LastResultFeedback extends StatelessWidget {
  final ShotResult result;
  final Brightness brightness;

  const _LastResultFeedback({
    required this.result,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = result == ShotResult.success;
    final color = isSuccess ? AppColors.success : AppColors.error;
    final bgColor = isSuccess ? AppColors.successSubtleLight : AppColors.errorSubtleLight;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSuccess ? Icons.check_circle : Icons.cancel,
        size: 80,
        color: color,
      ),
    );
  }
}

/// Recording Bar with Success/Miss buttons
class _RecordingBar extends StatelessWidget {
  final VoidCallback onSuccess;
  final VoidCallback onMiss;
  final Brightness brightness;

  const _RecordingBar({
    required this.onSuccess,
    required this.onMiss,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0x0D000000)
                : const Color(0x26000000),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Success button
            Expanded(
              child: _ActionButton(
                icon: Icons.check,
                label: 'SUCCESS',
                color: AppColors.success,
                brightness: brightness,
                onTap: onSuccess,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // Miss button
            Expanded(
              child: _ActionButton(
                icon: Icons.close,
                label: 'MISS',
                color: AppColors.error,
                brightness: brightness,
                onTap: onMiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action Button Widget
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Brightness brightness;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.brightness,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.space2),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ShotResult { success, miss }
