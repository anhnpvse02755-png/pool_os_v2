// ============================================================================
// WEEKLY REPORT SCREEN - Sprint-19 Redesign
// Minimalist Luxury Design System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
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
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bao cao Tuan',
          style: TextStyle(
            color: AppColors.textPrimary(brightness),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textPrimary(brightness)),
            onPressed: () => _onShare(),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary(brightness)))
          : _report == null || _report!.matchesPlayed == 0
              ? _empty(brightness)
              : _content(_report!, brightness),
    );
  }

  Widget _empty(Brightness brightness) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primary(brightness).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart, size: 48, color: AppColors.primary(brightness).withValues(alpha: 0.5)),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Chua co tran dau tuan nay',
                style: TextStyle(
                  color: AppColors.textPrimary(brightness),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Hay ghi them tran dau trong tuan nay de thay bao cao chi tiet.',
                style: TextStyle(
                  color: AppColors.textSecondary(brightness),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _content(WeeklyReport r, Brightness brightness) {
    final fmt = DateFormat('dd/MM');
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary(brightness)),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Tuan ${fmt.format(r.weekStart)} - ${fmt.format(r.weekEnd)}',
                style: TextStyle(
                  color: AppColors.textSecondary(brightness),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        _kpiGrid(r, brightness),
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
          iconColor: AppColors.warning,
          items: r.topWeaknesses,
          emptyText: 'Chua co diem yeu nao duoc AI phat hien.',
          bulletColor: AppColors.warning,
        ),
        SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: 'Drill de goi y',
          icon: Icons.sports_outlined,
          iconColor: AppColors.primary(brightness),
          items: r.suggestedDrills,
          emptyText: 'AI chua goi y drill tuan nay.',
          bulletColor: AppColors.primary(brightness),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _kpiGrid(WeeklyReport r, Brightness brightness) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft(brightness),
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
    final brightness = Theme.of(context).brightness;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chia se bao cao (dang phat trien)'),
        backgroundColor: AppColors.textPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary(brightness)),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
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
              color: AppColors.textPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft(brightness),
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
                  color: AppColors.textPrimary(brightness),
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
                color: AppColors.textSecondary(brightness),
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
    final brightness = Theme.of(context).brightness;

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
                color: AppColors.textPrimary(brightness),
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
