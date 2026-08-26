import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/match.dart';
import '../../../data/models/match_analysis.dart';
import '../../../data/repositories/match_repository.dart';

/// Player State screen with Minimalist Luxury design.
class PlayerStateScreen extends ConsumerStatefulWidget {
  const PlayerStateScreen({super.key});

  @override
  ConsumerState<PlayerStateScreen> createState() => _PlayerStateScreenState();
}

class _PlayerStateScreenState extends ConsumerState<PlayerStateScreen> {
  late final IMatchRepository _matchRepo;
  List<PlayerStateSnapshot> _states = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _matchRepo = ref.read(matchRepositoryProvider);
    _load();
  }

  Future<void> _load() async {
    final matches = await _matchRepo.getAllMatches();
    final all = <PlayerStateSnapshot>[];
    for (final m in matches) {
      final s = await _matchRepo.getPlayerState(m.id);
      if (s != null) all.add(s);
    }
    if (!mounted) return;
    setState(() {
      _states = all;
      _loading = false;
    });
  }

  Map<String, double> get _averages {
    if (_states.isEmpty) return {};
    final n = _states.length;
    return {
      'confidence':
          _states.fold(0, (a, s) => a + s.confidence) / n,
      'focus': _states.fold(0, (a, s) => a + s.focus) / n,
      'pressure':
          _states.fold(0, (a, s) => a + s.pressure) / n,
      'tilt': _states.fold(0, (a, s) => a + s.tilt) / n,
      if (_states.any((s) => s.sleep != null))
        'sleep': _states
                .where((s) => s.sleep != null)
                .fold(0, (a, s) => a + s.sleep!) /
            _states.where((s) => s.sleep != null).length,
    };
  }

  Map<String, double> get _physicalAverages {
    if (_states.isEmpty) return {};
    final wFatigue = _states.where((s) => s.fatigue != null).toList();
    final wEnergy = _states.where((s) => s.energy != null).toList();
    final wEye = _states.where((s) => s.eyeCondition != null).toList();
    return {
      if (wFatigue.isNotEmpty)
        'fatigue':
            wFatigue.fold(0, (a, s) => a + s.fatigue!) / wFatigue.length,
      if (wEnergy.isNotEmpty)
        'energy':
            wEnergy.fold(0, (a, s) => a + s.energy!) / wEnergy.length,
      if (wEye.isNotEmpty)
        'eyeCondition': wEye.fold(0, (a, s) => a + s.eyeCondition!) / wEye.length,
    };
  }

  Widget _buildBar(String label, double value) {
    Color barColor;
    if (value <= 2) {
      barColor = AppColors.error;
    } else if (value <= 3) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Text(
                value.toStringAsFixed(1) + '/5',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: (value / 5).clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'Player State',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _states.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _sectionTitle('Mental (trung bình ${_states.length} trận)'),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          for (final entry in _averages.entries)
                            if (!['sleep'].contains(entry.key))
                              _buildBar(_labelize(entry.key), entry.value),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionTitle('Physical'),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          for (final entry in _physicalAverages.entries)
                            _buildBar(_labelize(entry.key), entry.value),
                          if (_averages['sleep'] != null)
                            _buildBar('Sleep (giờ/đêm)',
                                (_averages['sleep'] ?? 7) / 2.4),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                    const SizedBox(height: AppSpacing.lg),
                    _sectionTitle('Trận gần đây'),
                    const SizedBox(height: AppSpacing.md),
                    ..._states.reversed.take(5).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.lightBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _colorFor(s.confidence),
                                child: Text(
                                  '${s.confidence}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Match ${s.matchId.substring(0, s.matchId.length.clamp(0, 10))}…',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Focus ${s.focus}/5  •  Pressure ${s.pressure}/5  •  Tilt ${s.tilt}/5',
                                style: const TextStyle(
                                  color: AppColors.lightTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                _date(s.capturedAt),
                                style: const TextStyle(
                                  color: AppColors.lightTextTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.accentSubtleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 64,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text(
              'Chưa có dữ liệu Player State',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Hoàn thành trận đấu đầu tiên để bắt đầu ghi nhận trạng thái tinh thần và thể chất.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String s) => Row(children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          s,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ]);

  String _labelize(String key) {
    return key.replaceAllMapped(RegExp(r'([A-Z])'),
        (m) => ' ${m.group(1)!.toLowerCase()}');
  }

  Color _colorFor(int confidence) {
    if (confidence <= 2) return AppColors.error;
    if (confidence <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
