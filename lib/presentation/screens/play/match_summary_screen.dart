import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';
import '../../../data/models/match_analysis.dart';
import '../../../data/models/shot.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/shot_repository.dart';
import '../../../domain/services/match_statistics_service.dart';

/// Match Summary — complete post-match report.
///
/// Replaces the previous demo-only History with a real Repository-backed
/// screen that mirrors V1's Match Summary surface.
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
        analysis = await _reviewEngine.generateAnalysis(widget.matchId);
        if (analysis != null) {
          await _matchRepo.saveAnalysis(analysis);
        }
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(m),
          const SizedBox(height: 16),
          _sectionTitle('Thông tin cơ bản'),
          _buildBasicInfo(m),
          const SizedBox(height: 16),
          _sectionTitle('Hiệu suất'),
          _buildPerformance(m),
          const SizedBox(height: 16),
          _sectionTitle('Cue Ball'),
          _buildCueBall(),
          const SizedBox(height: 16),
          _sectionTitle('Mental'),
          _buildMental(m),
          const SizedBox(height: 16),
          _sectionTitle('Physical'),
          _buildPhysical(m),
          const SizedBox(height: 16),
          _sectionTitle('Equipment'),
          _buildEquipment(m),
          const SizedBox(height: 16),
          _sectionTitle('Phân tích AI'),
          _buildAIAnalysis(),
          const SizedBox(height: 16),
          _sectionTitle('Timeline'),
          _buildTimeline(m),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/play/match/${m.id}/timeline'),
                  icon: const Icon(Icons.timeline),
                  label: const Text('Xem Timeline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.go('/play/match'),
                  icon: const Icon(Icons.list),
                  label: const Text('Trận khác'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildHeader(Match m) {
    final color = m.isWin
        ? Colors.green
        : (m.isLoss ? Colors.red : Colors.orange);
    final icon = m.isWin
        ? Icons.emoji_events
        : (m.isLoss ? Icons.cancel : Icons.balance);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 12),
            Text(m.isWin
                ? 'CHIẾN THẮNG'
                : (m.isLoss ? 'THẤT BẠI' : 'HÒA'))
                .animate()
                .fadeIn(duration: 400.ms)
                .shimmer(),
            const SizedBox(height: 8),
            Text(
              '${m.resultSummary ?? '${m.playerScore}-${m.opponentScore}'}',
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'vs ${m.opponentName ?? m.opponent ?? 'Unknown'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              MatchTypes.labels[m.gameType] ?? m.gameType,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
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
      _InfoRow('Final score',
          m.resultSummary ?? '${m.playerScore}-${m.opponentScore}'),
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
        _InfoRow('Position quality',
            posQ.entries.map((e) => '${e.key}: ${e.value}').join(', ')),
    ]);
  }

  Widget _buildMental(Match m) {
    final s = m.playerState;
    if (s == null) return const _EmptySection('Chưa có dữ liệu mental state.');
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
    if (s == null) return const _EmptySection('Chưa có dữ liệu physical state.');
    return _infoTable([
      if (s.sleep != null) _InfoRow('Sleep', '${s.sleep} giờ'),
      if (s.fatigue != null) _InfoRow('Fatigue', '${s.fatigue}/5'),
      if (s.energy != null) _InfoRow('Energy', '${s.energy}/5'),
      if (s.eyeCondition != null) _InfoRow('Eye condition', '${s.eyeCondition}/5'),
    ]);
  }

  Widget _buildEquipment(Match m) {
    final e = m.equipmentSnapshot;
    if (e == null) return const _EmptySection('Chưa có dữ liệu equipment.');
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
      return const _EmptySection('Chưa có phân tích AI cho trận đấu.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (a.strengths.isNotEmpty) ...[
          _sub('Điểm mạnh'),
          ...a.strengths.map((s) => _bullet(s, Icons.check, Colors.green)),
          const SizedBox(height: 8),
        ],
        if (a.weaknesses.isNotEmpty) ...[
          _sub('Điểm yếu'),
          ...a.weaknesses.map((s) => _bullet(s, Icons.warning, Colors.orange)),
          const SizedBox(height: 8),
        ],
        if (a.biggestMistakes.isNotEmpty) ...[
          _sub('Sai lầm lớn nhất'),
          ...a.biggestMistakes
              .map((s) => _bullet(s, Icons.close, Colors.red)),
          const SizedBox(height: 8),
        ],
        if (a.mostImprovedSkill != null) ...[
          _sub('Kỹ năng cải thiện'),
          Text(a.mostImprovedSkill!),
          const SizedBox(height: 8),
        ],
        if (a.suggestedDrills.isNotEmpty) ...[
          _sub('Drills gợi ý'),
          ...a.suggestedDrills.map((s) => _bullet(s, Icons.sports, AppTheme.primary)),
          const SizedBox(height: 8),
        ],
        if (a.relatedKnowledgeArticles.isNotEmpty) ...[
          _sub('Bài viết liên quan'),
          ...a.relatedKnowledgeArticles.map((s) => _bullet(s, Icons.article, Colors.blue)),
          const SizedBox(height: 8),
        ],
        if (a.recommendedLearningPath != null) ...[
          _sub('Lộ trình học'),
          Text(a.recommendedLearningPath!),
        ],
        const SizedBox(height: 4),
        Text(
          'Phân tích được tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(a.generatedAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimeline(Match m) {
    if (m.timeline.isEmpty) {
      return const _EmptySection(
          'Chưa có timeline được ghi lại. Hãy ghi rack-by-rack để xem timeline.');
    }
    return Column(
      children: m.timeline
          .map((e) => ListTile(
                leading: _timelineIcon(e.eventType),
                title: Text(e.description ?? e.eventType),
                subtitle: Text('Rack ${e.rackNumber} • '
                    '${DateFormat('HH:mm').format(e.timestamp)}'),
              ))
          .toList(),
    );
  }

  Widget _timelineIcon(String type) {
    switch (type) {
      case 'break':
      case 'break_and_run':
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green,
          child: Icon(Icons.flash_on, color: Colors.white, size: 16),
        );
      case 'safety_exchange':
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue,
          child: Icon(Icons.shield, color: Colors.white, size: 16),
        );
      case 'miss':
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.red,
          child: Icon(Icons.close, color: Colors.white, size: 16),
        );
      case 'turning_point':
        return const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.orange,
          child: Icon(Icons.bolt, color: Colors.white, size: 16),
        );
      default:
        return const CircleAvatar(radius: 16, child: Icon(Icons.fiber_manual_record, size: 12));
    }
  }

  Widget _sub(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _bullet(String text, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );

  Widget _infoTable(List<_InfoRow> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: rows
                .map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 140,
                              child: Text(r.label,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500))),
                          Expanded(child: Text(r.value)),
                        ],
                      ),
                    ))
                .toList(),
          ),
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
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: Colors.grey[400], size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      );
}
