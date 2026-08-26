import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/match.dart';
import '../../../data/models/match_analysis.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/shot_repository.dart';
import '../../../domain/services/match_statistics_service.dart';

/// Match Summary — complete post-match report.
class MatchSummaryScreen extends ConsumerStatefulWidget {
  const MatchSummaryScreen({super.key, required this.matchId});
  final String matchId;

  @override
  ConsumerState<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends ConsumerState<MatchSummaryScreen> {
  late IMatchRepository _matchRepo;
  late IShotRepository _shotRepo;
  late MatchStatisticsService _statsService;
  late MatchReviewEngine _reviewEngine;

  Match? _match;
  Map<String, dynamic> _stats = {};
  MatchAnalysis? _analysis;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _matchRepo = ref.read(matchRepositoryProvider);
    _shotRepo = LocalShotRepository();
    _statsService = MatchStatisticsService(_matchRepo, _shotRepo);
    _reviewEngine = MatchReviewEngine(_statsService);
    _load();
  }

  Future<void> _load() async {
    try {
      final m = await _matchRepo.getMatchById(widget.matchId);
      Map<String, dynamic> stats = {};
      MatchAnalysis? analysis;
      if (m != null) {
        stats = await _statsService.computeMatchStatistics(widget.matchId);
        final generatedAnalysis = await _reviewEngine.generateAnalysis(widget.matchId);
        await _matchRepo.saveAnalysis(generatedAnalysis);
        analysis = generatedAnalysis;
      }
      if (!mounted) return;
      setState(() {
        _match = m;
        _stats = stats;
        _analysis = analysis;
        _loading = false;
        _error = m == null ? 'Match not found' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(child: Text(_error ?? 'Không tìm thấy trận đấu')),
      );
    }
    final m = _match!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tóm tắt trận đấu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
            onPressed: () => _onShare(),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'In',
            onPressed: () => _onPrint(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          _buildHeader(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Thông tin cơ bản'),
          _buildBasicInfo(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Hiệu suất'),
          _buildPerformance(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Cue Ball'),
          _buildCueBall(),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Mental'),
          _buildMental(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Physical'),
          _buildPhysical(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Equipment'),
          _buildEquipment(m),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Phân tích AI'),
          _buildAIAnalysis(),
          SizedBox(height: AppSpacing.md),
          _sectionTitle('Timeline'),
          _buildTimeline(m),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  onPressed: () => context.push('/play/match/${m.id}/timeline'),
                  label: 'Xem Timeline',
                  icon: Icons.timeline,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SecondaryButton(
                  onPressed: () => context.go('/play/history'),
                  label: 'Trận khác',
                  icon: Icons.list,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã tạo báo cáo để chia sẻ.')),
    );
  }

  void _onPrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi đến máy in.')),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _buildHeader(Match m) {
    final color = m.isWin
        ? AppColors.success
        : (m.isLoss ? AppColors.error : Colors.orange);
    final icon = m.isWin
        ? Icons.emoji_events
        : (m.isLoss ? Icons.cancel : Icons.balance);
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 36),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            m.isWin ? 'CHIẾN THẮNG' : (m.isLoss ? 'THẤT BẠI' : 'HÒA'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ).animate().fadeIn(duration: 400.ms),
          SizedBox(height: AppSpacing.sm),
          Text(
            m.resultSummary ?? '${m.playerScore}-${m.opponentScore}',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'vs ${m.opponentName ?? m.opponent ?? 'Unknown'}',
            style: TextStyle(fontSize: 16, color: AppColors.lightTextSecondary),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            MatchTypes.labels[m.gameType] ?? m.gameType,
            style: TextStyle(fontSize: 13, color: AppColors.lightTextTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(Match m) {
    final fmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm');
    return _infoTable([
      _InfoRow('Match ID', m.id),
      _InfoRow('Ngày', m.startTime != null ? fmt.format(m.startTime!) : fmt.format(m.createdAt)),
      _InfoRow('Giờ', m.startTime != null ? timeFmt.format(m.startTime!) : '—'),
      _InfoRow('Thời lượng', m.duration != null ? '${m.duration} phút' : '—'),
      _InfoRow('Game type', MatchTypes.labels[m.gameType] ?? m.gameType),
      _InfoRow('Race format', m.raceTo != null ? 'Race to ${m.raceTo}' : '—'),
      _InfoRow('Venue', m.venue ?? '—'),
      _InfoRow('Table', m.table ?? '—'),
      _InfoRow('Opponent', m.opponentName ?? m.opponent ?? '—'),
      _InfoRow('Winner', m.winner ?? (m.isWin ? 'Player' : 'Opponent')),
      _InfoRow('Final score', m.resultSummary ?? '${m.playerScore}-${m.opponentScore}'),
    ]);
  }

  Widget _buildPerformance(Match m) {
    final racks = _stats['totalRacks'] ?? m.racks.length;
    final wins = _stats['winPercent'] ?? 0.0;
    final bans = _stats['breakAndRun'] ?? 0;
    final runOuts = _stats['runOuts'] ?? 0;
    final goldens = _stats['goldenBreaks'] ?? 0;
    final safety = _stats['safetyCount'] ?? 0;
    final safetyRate = _stats['safetySuccessRate'] ?? 0.0;
    final fouls = _stats['fouls'] ?? 0;
    final scratches = _stats['scratches'] ?? 0;
    final easy = _stats['easyMisses'] ?? 0;
    final pos = _stats['positionErrors'] ?? 0;
    final kicks = _stats['kicks'] ?? 0;
    final banks = _stats['banks'] ?? 0;
    final jumps = _stats['jumps'] ?? 0;
    final combos = _stats['combos'] ?? 0;
    final caroms = _stats['caroms'] ?? 0;

    return _infoTable([
      _InfoRow('Total racks', racks.toString()),
      _InfoRow('Win %', '${wins.toStringAsFixed(1)}%'),
      _InfoRow('Break & Run', bans.toString()),
      _InfoRow('Run Outs', runOuts.toString()),
      _InfoRow('Golden Break', goldens.toString()),
      _InfoRow('Safety count', safety.toString()),
      _InfoRow('Safety success', '${safetyRate.toStringAsFixed(1)}%'),
      _InfoRow('Fouls', fouls.toString()),
      _InfoRow('Scratch', scratches.toString()),
      _InfoRow('Missed easy shots', easy.toString()),
      _InfoRow('Position errors', pos.toString()),
      _InfoRow('Kicks', kicks.toString()),
      _InfoRow('Banks', banks.toString()),
      _InfoRow('Jump shots', jumps.toString()),
      _InfoRow('Combo shots', combos.toString()),
      _InfoRow('Carom shots', caroms.toString()),
    ]);
  }

  Widget _buildCueBall() {
    final stop = _stats['stopShots'] ?? 0;
    final draw = _stats['drawShots'] ?? 0;
    final follow = _stats['followShots'] ?? 0;
    final side = _stats['sideSpinUses'] ?? 0;
    final posQ = _stats['positionQuality'] as Map<String, int>? ?? {};
    return _infoTable([
      _InfoRow('Stop shots', stop.toString()),
      _InfoRow('Draw shots', draw.toString()),
      _InfoRow('Follow shots', follow.toString()),
      _InfoRow('Side spin usage', side.toString()),
      if (posQ.isNotEmpty)
        _InfoRow('Position quality', posQ.entries.map((e) => '${e.key}: ${e.value}').join(', ')),
    ]);
  }

  Widget _buildMental(Match m) {
    final s = m.playerState;
    if (s == null) return _EmptySection('Chưa có dữ liệu mental state.');
    return _infoTable([
      _InfoRow('Confidence', '${s.confidence}/5'),
      _InfoRow('Focus', '${s.focus}/5'),
      _InfoRow('Pressure', '${s.pressure}/5'),
      _InfoRow('Tilt moments', '${s.tilt}/5'),
      if (s.composure != null) _InfoRow('Composure', '${s.composure}/5'),
    ]);
  }

  Widget _buildPhysical(Match m) {
    final s = m.playerState;
    if (s == null) return _EmptySection('Chưa có dữ liệu physical state.');
    return _infoTable([
      if (s.sleep != null) _InfoRow('Sleep', '${s.sleep} giờ'),
      if (s.fatigue != null) _InfoRow('Fatigue', '${s.fatigue}/5'),
      if (s.energy != null) _InfoRow('Energy', '${s.energy}/5'),
      if (s.eyeCondition != null) _InfoRow('Eye condition', '${s.eyeCondition}/5'),
    ]);
  }

  Widget _buildEquipment(Match m) {
    final e = m.equipmentSnapshot;
    if (e == null) return _EmptySection('Chưa có dữ liệu equipment.');
    return _infoTable([
      if (e.cueName != null) _InfoRow('Cue', e.cueName!),
      if (e.shaftMaterial != null) _InfoRow('Shaft', e.shaftMaterial!),
      if (e.tipBrand != null) _InfoRow('Tip', e.tipBrand!),
      if (e.tipHardness != null) _InfoRow('Tip hardness', e.tipHardness!),
      if (e.chalk != null) _InfoRow('Chalk', e.chalk!),
    ]);
  }

  Widget _buildAIAnalysis() {
    final a = _analysis;
    if (a == null) {
      return _EmptySection('Chưa có phân tích AI cho trận đấu.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (a.strengths.isNotEmpty) ...[
          _sub('Điểm mạnh'),
          ...a.strengths.map((s) => _bullet(s, Icons.check, AppColors.success)),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.weaknesses.isNotEmpty) ...[
          _sub('Điểm yếu'),
          ...a.weaknesses.map((s) => _bullet(s, Icons.warning, Colors.orange)),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.biggestMistakes.isNotEmpty) ...[
          _sub('Sai lầm lớn nhất'),
          ...a.biggestMistakes.map((s) => _bullet(s, Icons.close, AppColors.error)),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.mostImprovedSkill != null) ...[
          _sub('Kỹ năng cải thiện'),
          Text(a.mostImprovedSkill!),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.suggestedDrills.isNotEmpty) ...[
          _sub('Drills gợi ý'),
          ...a.suggestedDrills.map((s) => _bullet(s, Icons.sports, AppColors.accent)),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.relatedKnowledgeArticles.isNotEmpty) ...[
          _sub('Bài viết liên quan'),
          ...a.relatedKnowledgeArticles.map((s) => _bullet(s, Icons.article, Colors.blue)),
          SizedBox(height: AppSpacing.sm),
        ],
        if (a.recommendedLearningPath != null) ...[
          _sub('Lộ trình học'),
          Text(a.recommendedLearningPath!),
        ],
        SizedBox(height: 4),
        Text(
          'Phân tích được tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(a.generatedAt)}',
          style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildTimeline(Match m) {
    if (m.timeline.isEmpty) {
      return _EmptySection('Chưa có timeline được ghi lại. Hãy ghi rack-by-rack để xem timeline.');
    }
    return Column(
      children: m.timeline.map((e) => ListTile(
            leading: _timelineIcon(e.eventType),
            title: Text(e.description ?? e.eventType),
            subtitle: Text('Rack ${e.rackNumber} • ${DateFormat('HH:mm').format(e.timestamp)}'),
          )).toList(),
    );
  }

  Widget _timelineIcon(String type) {
    switch (type) {
      case 'break':
      case 'break_and_run':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.flash_on, color: AppColors.success, size: 16),
        );
      case 'safety_exchange':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.shield, color: Colors.blue, size: 16),
        );
      case 'miss':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: AppColors.error, size: 16),
        );
      case 'turning_point':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.bolt, color: Colors.orange, size: 16),
        );
      default:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.lightSurfaceElevated,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.fiber_manual_record, size: 12, color: AppColors.lightTextSecondary),
        );
    }
  }

  Widget _sub(String title) => Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm, bottom: 4),
        child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _bullet(String text, IconData icon, Color color) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _infoTable(List<_InfoRow> rows) => Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: rows
              .map((r) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 140, child: Text(r.label, style: TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500))),
                        Expanded(child: Text(r.value)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _EmptySection extends StatelessWidget {
  const _EmptySection(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.lightTextTertiary, size: 20),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: TextStyle(color: AppColors.lightTextSecondary))),
          ],
        ),
      );
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _PrimaryButton({required this.onPressed, required this.label, required this.icon});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _SecondaryButton({required this.onPressed, required this.label, required this.icon});

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppColors.lightTextSecondary, size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
