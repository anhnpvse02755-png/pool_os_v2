import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../domain/services/monthly_report_generator.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  late final MonthlyReportGenerator _generator;
  MonthlyReport? _report;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generator = MonthlyReportGenerator(ref.read(matchRepositoryProvider));
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final r = await _generator.generate(year: now.year, month: now.month);
    if (!mounted) return;
    setState(() {
      _report = r;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? const Center(child: Text('No data.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(
                          DateTime(_report!.year, _report!.month)),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_report!.narrative,
                            style: const TextStyle(fontSize: 14, height: 1.4)),
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2,
                      children: [
                        _kpi('Matches', '${_report!.matchesPlayed}'),
                        _kpi('Win %',
                            '${_report!.winRate.toStringAsFixed(0)}%'),
                        _kpi('Racks', '${_report!.racksPlayed}'),
                        _kpi('Break & Run', '${_report!.breakAndRun}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_report!.suggestedDrills.isNotEmpty) ...[
                      const Text('Suggested drills',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._report!.suggestedDrills.map((d) => ListTile(
                            leading: Icon(Icons.sports, color: AppTheme.primary),
                            title: Text(d),
                          )),
                    ],
                  ],
                ),
    );
  }

  Widget _kpi(String label, String value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
}