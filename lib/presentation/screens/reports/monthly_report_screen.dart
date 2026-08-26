// ============================================================================
// MONTHLY REPORT SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
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
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bao cao Thang',
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.lightTextPrimary),
            onPressed: () => _onShare(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _report == null || _report!.matchesPlayed == 0
              ? _empty()
              : _content(_report!),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart, size: 48, color: AppColors.accent.withValues(alpha: 0.5)),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Chua co du lieu thang nay',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Hay ghi them tran dau trong thang nay de xem bao cao chi tiet.',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _content(MonthlyReport r) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.accent),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('MMMM yyyy', 'vi').format(DateTime(r.year, r.month)),
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  r.narrative,
                  style: TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _kpiGrid(r),
        SizedBox(height: AppSpacing.lg),
        if (r.suggestedDrills.isNotEmpty)
          _DrillsSection(drills: r.suggestedDrills),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _kpiGrid(MonthlyReport r) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.8,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        children: [
          _KpiCard(label: 'Tran dau', value: '${r.matchesPlayed}', icon: Icons.sports_score_outlined),
          _KpiCard(label: 'Ty le thang', value: '${r.winRate.toStringAsFixed(0)}%', icon: Icons.emoji_events_outlined),
          _KpiCard(label: 'Racks', value: '${r.racksPlayed}', icon: Icons.grid_view_outlined),
          _KpiCard(label: 'Break & Run', value: '${r.breakAndRun}', icon: Icons.bolt_outlined),
        ],
      ),
    );
  }

  void _onShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia se bao cao (dang phat trien)'),
        backgroundColor: AppColors.lightTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.accent),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrillsSection extends StatelessWidget {
  const _DrillsSection({required this.drills});

  final List<String> drills;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_outlined, size: 20, color: AppColors.accent),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Drill de goi y',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ...drills.map((drill) => _DrillItem(drill: drill)),
        ],
      ),
    );
  }
}

class _DrillItem extends StatelessWidget {
  const _DrillItem({required this.drill});

  final String drill;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fitness_center, size: 18, color: AppColors.accent),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              drill,
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
