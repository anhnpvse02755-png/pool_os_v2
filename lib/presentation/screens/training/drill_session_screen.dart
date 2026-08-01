import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';

class DrillSessionScreen extends StatefulWidget {
  final String drillCode;

  const DrillSessionScreen({super.key, required this.drillCode});

  @override
  State<DrillSessionScreen> createState() => _DrillSessionScreenState();
}

class _DrillSessionScreenState extends State<DrillSessionScreen> {
  late Drill drill;
  int currentRep = 0;
  int successCount = 0;
  bool isSessionActive = false;
  bool showResultDialog = false;

  // Shot recording
  ShotResult? lastShotResult;

  @override
  void initState() {
    super.initState();
    drill = DrillLibrary.getDrill(widget.drillCode) ?? DrillLibrary.categories.first.drills.first;
  }

  void _startSession() {
    setState(() {
      isSessionActive = true;
      currentRep = 0;
      successCount = 0;
    });
  }

  void _recordShot(ShotResult result) {
    setState(() {
      currentRep++;
      if (result == ShotResult.success) {
        successCount++;
      }
      lastShotResult = result;
    });
  }

  void _finishSession() {
    setState(() {
      isSessionActive = false;
      showResultDialog = true;
    });
  }

  double get successRate => currentRep > 0 ? (successCount / currentRep) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drill.nameVi),
        actions: [
          if (isSessionActive)
            TextButton.icon(
              onPressed: _finishSession,
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
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Bắt đầu'),
            )
          : null,
      bottomNavigationBar: isSessionActive ? _buildRecordingBar() : null,
    );
  }

  Widget _buildInstructions() {
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

          // Instructions
          Text(
            'Hướng dẫn',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...drill.instructions.asMap().entries.map((entry) {
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
                      '${drill.targetReps} lần thành công',
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
                total: '/ ${drill.targetReps}',
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
