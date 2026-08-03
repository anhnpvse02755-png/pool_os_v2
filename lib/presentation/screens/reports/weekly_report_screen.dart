import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/shot_repository.dart';
import '../../../domain/services/match_statistics_service.dart';
import '../../../domain/services/weekly_report_generator.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  late final MatchStatisticsService _statsService;
  late final WeeklyReportGenerator _generator;
  WeeklyReport? _report;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _statsService = MatchStatisticsService(
      ref.read(matchRepositoryProvider),
      LocalShotRepository(),
    );
    _generator = WeeklyReportGenerator(
      ref.read(matchRepositoryProvider),
      _statsService,
    );
    _load();
  }

  Future<void> _load() async {
    final r = await _generator.generate();
    if (!mounted) return;
    setState(() {
      _report = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _onShare(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null || _report!.matchesPlayed == 0
              ? _empty()
              : _content(_report!),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart,
                  size: 64, color: AppTheme.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              const Text('No matches this week',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Hãy ghi thêm trận đấu trong tuần này để thấy báo cáo chi tiết.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _content(WeeklyReport r) {
    final fmt = DateFormat('dd/MM');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tuần ${fmt.format(r.weekStart)} – ${fmt.format(r.weekEnd)}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _kpiGrid(r),
        const SizedBox(height: 16),
        _sectionTitle('Top strengths'),
        ...r.topStrengths.isEmpty
            ? [const Text('Chưa đủ dữ liệu để tổng hợp.')]
            : r.topStrengths.map((s) => _bullet(s, Icons.check, Colors.green)),
        const SizedBox(height: 12),
        _sectionTitle('Top weaknesses'),
        ...r.topWeaknesses.isEmpty
            ? [const Text('Chưa có điểm yếu nào được AI phát hiện.')]
            : r.topWeaknesses.map((s) => _bullet(s, Icons.warning, Colors.orange)),
        const SizedBox(height: 12),
        _sectionTitle('Suggested drills'),
        ...r.suggestedDrills.isEmpty
            ? [const Text('AI chưa gợi ý drill tuần này.')]
            : r.suggestedDrills
                .map((d) => _bullet(d, Icons.sports, AppTheme.primary)),
      ],
    ).animate().fadeIn();
  }

  Widget _kpiGrid(WeeklyReport r) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      children: [
        _kpi('Matches', '${r.matchesPlayed}'),
        _kpi('Win rate', '${r.winRate.toStringAsFixed(1)}%'),
        _kpi('Racks', '${r.racksPlayed}'),
        _kpi('Break & Run', '${r.totalBreakAndRun}'),
        _kpi('Run Outs', '${r.totalRunOuts}'),
        _kpi('Fouls', '${r.totalFouls}'),
      ],
    );
  }

  Widget _kpi(String label, String value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share sheet opened (stub).')),
    );
  }
}
