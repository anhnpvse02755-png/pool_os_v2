import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
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
    final brightness = Theme.of(context).brightness;

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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary(brightness),
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
              backgroundColor: AppColors.border(brightness),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Player State',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary(brightness)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary(brightness)),
            )
          : _states.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    _sectionTitle('Mental (trung bình ${_states.length} trận)', brightness),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(brightness),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.border(brightness)),
                        boxShadow: AppShadows.soft(brightness),
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
                    _sectionTitle('Physical', brightness),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface(brightness),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.border(brightness)),
                        boxShadow: AppShadows.soft(brightness),
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
                    _sectionTitle('Trận gần đây', brightness),
                    const SizedBox(height: AppSpacing.md),
                    ..._states.reversed.take(5).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface(brightness),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.border(brightness)),
                              boxShadow: AppShadows.soft(brightness),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _colorFor(s.confidence),
                                child: Text(
                                  '${s.confidence}',
                                  style: TextStyle(
                                    color: AppColors.onPrimary(brightness),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Match ${s.matchId.substring(0, s.matchId.length.clamp(0, 10))}…',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(brightness),
                                ),
                              ),
                              subtitle: Text(
                                'Focus ${s.focus}/5  •  Pressure ${s.pressure}/5  •  Tilt ${s.tilt}/5',
                                style: TextStyle(
                                  color: AppColors.textSecondary(brightness),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                _date(s.capturedAt),
                                style: TextStyle(
                                  color: AppColors.textTertiary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.pastelFor(0, brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 64,
                color: AppColors.primary(brightness).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Chưa có dữ liệu Player State',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hoàn thành trận đấu đầu tiên để bắt đầu ghi nhận trạng thái tinh thần và thể chất.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String s, Brightness brightness) => Row(children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary(brightness),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          s,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
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
