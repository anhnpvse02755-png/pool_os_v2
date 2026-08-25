import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/training_provider.dart';
import '../../../data/models/drill_session.dart';
import '../../../data/models/drill_progress.dart';
import '../../../data/models/personal_best.dart';
import '../../../data/repositories/personal_best_repository.dart';
import '../../../domain/services/drill_session_recovery_service.dart';

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

  // Sprint 7B: custom target — user picks how many reps to do.
  // Defaults to the level's default attempts if not provided via query param.
  late int targetReps;

  // Shot recording
  ShotResult? lastShotResult;

  // Sprint 3A Task 1: persistence layer state.
  DrillSession? _session;
  late final DrillSessionRecoveryService _recovery;

  // Sprint-17 Part 3: Track whether auto-start has been triggered.
  // Prevents duplicate session creation on rebuild.
  bool _autoStarted = false;

  // Sprint-17 Part 3: Track initialization state.
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Sprint 3A housekeeping: injected via provider (task #27).
    _recovery = DrillSessionRecoveryService(ref.read(drillSessionRepositoryProvider));
    _loadDrill();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sprint-17 Part 3: Extract auto-start logic into helper.
    // Read query params and trigger auto-start if conditions met.
    _tryAutoStart();
  }

  /// Sprint-17 Part 3: Helper to auto-start session when navigating from drill detail.
  /// Called from:
  /// 1. didChangeDependencies() — when widget is first built
  /// 2. _loadDrill() completion — when drill async load finishes
  ///
  /// Guards against:
  /// - Duplicate auto-start (tracked via _autoStarted)
  /// - Starting while session already active
  /// - Starting if drill not yet loaded
  /// - Starting if no 'level' query param (not from drill detail)
  /// - Starting after widget disposed
  void _tryAutoStart() {
    if (!mounted) return;
    if (_autoStarted) return;
    if (isSessionActive) return;
    if (_drill == null) return;

    final goState = GoRouterState.of(context);
    final level = goState.uri.queryParameters['level'];
    if (level == null) return; // Not from drill detail — don't auto-start

    // Sprint 7B: read custom target reps from query param.
    final targetParam = goState.uri.queryParameters['target'];
    if (targetParam != null) {
      final t = int.tryParse(targetParam);
      if (t != null && t > 0) {
        targetReps = t;
      }
    }

    // Mark as started BEFORE async call to prevent race conditions
    _autoStarted = true;

    // Defer to post-frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSession();
    });
  }

  void _loadDrill() {
    final drill = DrillLibrary.getDrill(widget.drillCode);
    if (drill == null) {
      setState(() {
        _error = 'Bài tập với mã "${widget.drillCode}" không tồn tại.';
        _drill = null;
      });
    } else {
      setState(() {
        _drill = drill;
        // Initialize target to level default if not yet set via query param.
        if (!_isInitialized) {
          targetReps = drill.levels.first.attempts;
          _isInitialized = true;
        }
        _error = null;
      });

      // Sprint-17 Part 3: Trigger auto-start after drill loads.
      // This fixes the race condition where didChangeDependencies()
      // fired before _drill was set.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoStart();
      });
    }
  }

  Future<void> _startSession() async {
    final drill = _drill;
    if (drill == null) return;

    final player = await ref.read(currentPlayerProvider.future);
    if (player == null) {
      // No player profile — cannot persist. Surface failure cleanly.
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
    await _recovery.pause(session); // creates the active session row.
    if (!mounted) return;
    setState(() {
      _session = session;
      isSessionActive = true;
      currentRep = 0;
      successCount = 0;
      lastShotResult = null;
    });
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

    // Sprint 7B: auto-finish when user reaches their target reps.
    if (currentRep >= targetReps) {
      // Small delay so the success/miss feedback animation plays first.
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
    // Sprint 3A Task 3: commit PersonalBest at the completion boundary.
    // Completion Experience remains a read-only View — it must not
    // mutate business data so re-entry / refresh / deep-link stay
    // side-effect free.
    await _commitPersonalBest(completed);
    // Sprint 4A Task 10: sync to TrainingSession for history display.
    await _syncToTrainingHistory(completed);
    if (!mounted) return;
    // Sprint 3A Task 2: navigate to the dedicated Completion Experience
    // surface instead of falling back to the instructions view.
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

  /// Sprint 4A Task 10: sync completed session to TrainingSession for history.
  /// Sprint 4A Task 13: update DrillProgress for Coach AI.
  /// Sprint-10C P0: Wire to TrainingNotifier so Coach AI receives updates.
  Future<void> _syncToTrainingHistory(DrillSession completed) async {
    final drillRepo = ref.read(drillRepositoryProvider);
    final trainingNotifier = ref.read(trainingNotifierProvider.notifier);

    // Save to TrainingNotifier (what Coach listens to)
    final trainingSessionMap = completed.toTrainingSessionMap();
    final trainingSession = TrainingSession.fromJson(trainingSessionMap);
    await trainingNotifier.addSession(trainingSession);

    // Also save to drill repository for progress tracking.
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
    // Show error screen if drill not found
    if (_error != null) {
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
                  _error!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
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

    // Show loading if drill not loaded yet
    if (_drill == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Sprint-17 Part 6: Show active session UI directly.
    // Instructions screen removed — user goes straight to recording.
    // Auto-start initializes session on mount.
    return Scaffold(
      appBar: AppBar(
        title: Text(_drill!.nameVi),
        actions: [
          if (isSessionActive)
            TextButton.icon(
              onPressed: () => _finishSession(),
              icon: const Icon(Icons.stop, color: Colors.red),
              label: const Text('Kết thúc', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      // Sprint-17 Part 8/9: Recording bar is now part of body for reliable web visibility.
      // Recording bar is rendered INSIDE _buildActiveSession() to avoid Column flex conflicts.
      body: Column(
        children: [
          Expanded(child: _buildActiveSession()),
        ],
      ),
      // Removed bottomNavigationBar - now using Column for reliability
    );
  }

  Widget _buildActiveSession() {
    return Column(
      children: [
        // Progress
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Lần',
                value: '$currentRep',
                total: '/ $targetReps',
              ),
              _StatItem(
                label: 'Thành công',
                value: '$successCount',
              ),
              _StatItem(
                label: 'Tỷ lệ',
                value: '${successRate.toStringAsFixed(0)}%',
                color: successRate >= 70 ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ),

        // Visual feedback - takes remaining space but NOT all
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Last result feedback
                if (lastShotResult != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: lastShotResult == ShotResult.success
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      lastShotResult == ShotResult.success
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 80,
                      color: lastShotResult == ShotResult.success
                          ? Colors.green
                          : Colors.red,
                    ),
                  ).animate().scale(duration: 200.ms),

                const SizedBox(height: 32),

                Text(
                  lastShotResult != null
                      ? (lastShotResult == ShotResult.success ? 'Thành công!' : 'Chưa được')
                      : 'Bạn đã sẵn sàng!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 8),

                Text(
                  'Ấn nút bên dưới sau mỗi lần đánh',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // Sprint-17 Part 9: Recording bar moved INSIDE _buildActiveSession()
        // to avoid Column flex constraint conflicts where parent Expanded
        // causes inner Expanded to consume all available height.
        if (isSessionActive)
          _buildRecordingBar(),
      ],
    );
  }

  Widget _buildRecordingBar() {
    // Sprint-17 Part 9: Recording controls - simplified for reliable visibility
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
        top: false, // Only safe area at bottom
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Success button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordShot(ShotResult.success),
                    icon: const Icon(Icons.check),
                    label: const Text('Thành công'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Miss button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordShot(ShotResult.miss),
                    icon: const Icon(Icons.close),
                    label: const Text('Trượt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // End session button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _finishSession(),
                icon: const Icon(Icons.stop, color: Colors.red),
                label: const Text('Kết thúc', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String? total;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: color ?? AppTheme.primaryGreen,
              ),
            ),
            if (total != null)
              Text(
                total!,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum ShotResult { success, miss }
