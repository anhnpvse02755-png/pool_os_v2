import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/drill_session.dart';
import '../../../data/models/drill_progress.dart';
import '../../../data/models/personal_best.dart';
// ignore: unused_import — used via ref.read(drillRepositoryProvider) and toTrainingSession()
import '../../../data/repositories/drill_repository.dart';
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

  // Shot recording
  ShotResult? lastShotResult;

  // Sprint 3A Task 1: persistence layer state.
  DrillSession? _session;
  late final DrillSessionRecoveryService _recovery;

  @override
  void initState() {
    super.initState();
    // Sprint 3A housekeeping: injected via provider (task #27).
    _recovery = DrillSessionRecoveryService(ref.read(drillSessionRepositoryProvider));
    _loadDrill();
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
        _error = null;
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
  Future<void> _syncToTrainingHistory(DrillSession completed) async {
    final drillRepo = ref.read(drillRepositoryProvider);

    // Save to training history.
    final trainingSession = completed.toTrainingSession();
    await drillRepo.saveTrainingSession(trainingSession);

    // Update drill progress for Coach AI to read skill progression.
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

    // Show loading if drill not loaded yet
    if (_drill == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
      body: !isSessionActive
          ? _buildInstructions()
          : _buildActiveSession(),
      floatingActionButton: !isSessionActive
          ? FloatingActionButton.extended(
              onPressed: () => _startSession(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Bắt đầu'),
            )
          : null,
      bottomNavigationBar: isSessionActive ? _buildRecordingBar() : null,
    );
  }

  Widget _buildInstructions() {
    final drill = _drill!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drill Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  drill.nameVi,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  drill.description,
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          // Steps
          Text(
            'Các bước',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...drill.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(entry.value),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (entry.key * 100).ms);
          }),

          const SizedBox(height: 24),

          // Target
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: AppTheme.accentGold),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mục tiêu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${drill.levels.first.attempts} lần thành công',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildActiveSession() {
    final drill = _drill!;
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
                total: '/ ${drill.levels.first.attempts}',
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

        // Visual feedback
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
      ],
    );
  }

  Widget _buildRecordingBar() {
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
        child: Row(
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
