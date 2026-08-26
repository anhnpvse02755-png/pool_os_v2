// ============================================================================
// WEEKLY REPORT SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/repository_providers.dart';
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
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bao cao Tuan',
          style: TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
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
                'Chua co tran dau tuan nay',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Hay ghi them tran dau trong tuan nay de thay bao cao chi tiet.',
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

  Widget _content(WeeklyReport r) {
    final fmt = DateFormat('dd/MM');
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.accent),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Tuan ${fmt.format(r.weekStart)} - ${fmt.format(r.weekEnd)}',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _kpiGrid(r),
        SizedBox(height: AppSpacing.xl),
        _SectionCard(
          title: 'Diem manh noi bat',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
          items: r.topStrengths,
          emptyText: 'Chua du du lieu de tong hop.',
          bulletColor: AppColors.success,
        ),
        SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: 'Diem yeu can cai thien',
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.orange,
          items: r.topWeaknesses,
          emptyText: 'Chua co diem yeu nao duoc AI phat hien.',
          bulletColor: Colors.orange,
        ),
        SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: 'Drill de goi y',
          icon: Icons.sports_outlined,
          iconColor: AppColors.accent,
          items: r.suggestedDrills,
          emptyText: 'AI chua goi y drill tuan nay.',
          bulletColor: AppColors.accent,
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _kpiGrid(WeeklyReport r) {
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
          _KpiCard(label: 'Ty le thang', value: '${r.winRate.toStringAsFixed(1)}%', icon: Icons.emoji_events_outlined),
          _KpiCard(label: 'Racks', value: '${r.racksPlayed}', icon: Icons.grid_view_outlined),
          _KpiCard(label: 'Break & Run', value: '${r.totalBreakAndRun}', icon: Icons.bolt_outlined),
          _KpiCard(label: 'Run Outs', value: '${r.totalRunOuts}', icon: Icons.trending_up_outlined),
          _KpiCard(label: 'Fouls', value: '${r.totalFouls}', icon: Icons.gpp_bad_outlined),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.emptyText,
    required this.bulletColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> items;
  final String emptyText;
  final Color bulletColor;

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
              Icon(icon, size: 20, color: iconColor),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Text(
              emptyText,
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items.map((item) => _BulletItem(text: item, bulletColor: bulletColor)),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text, required this.bulletColor});

  final String text;
  final Color bulletColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: bulletColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
