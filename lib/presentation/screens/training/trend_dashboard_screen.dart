import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/services/trend_engine.dart';

/// Sprint 4C Task 20 - Trend Dashboard
///
/// Displays computed trends from TrendEngine.
/// Coach AI reads this data for pattern detection.
class TrendDashboardScreen extends ConsumerStatefulWidget {
  const TrendDashboardScreen({super.key});

  @override
  ConsumerState<TrendDashboardScreen> createState() => _TrendDashboardScreenState();
}

class _TrendDashboardScreenState extends ConsumerState<TrendDashboardScreen> {
  bool _loading = true;
  TrendSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trainingHistory = await ref.read(trainingHistoryProvider.future);
      final matchRepo = ref.read(matchRepositoryProvider);
      final matches = await matchRepo.getAllMatches();

      final engine = TrendEngine(
        trainingHistory: trainingHistory,
        matchHistory: matches,
      );

      if (!mounted) return;
      setState(() {
        _summary = engine.summary;
        _loading = false;
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Xu huong'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Loi: $_error'))
              : _summary == null
                  ? _buildEmpty()
                  : _buildDashboard(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: AppColors.lightTextTertiary),
          const SizedBox(height: AppSpacing.lg),
          const Text('Chua co du du lieu'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Can it nhat 2 buoi tap de xem xu huong.',
            style: TextStyle(color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final s = _summary!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Overall status
        _buildOverallStatus(s),
        const SizedBox(height: AppSpacing.lg),

        // Training trend
        _buildTrendCard(
          'Xu huong tap luyen',
          s.trainingTrend,
          Icons.fitness_center,
          AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.md),

        // Match trend
        _buildTrendCard(
          'Xu huong thi dau',
          s.matchTrend,
          Icons.sports,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: AppSpacing.md),

        // Consistency
        _buildConsistencyCard(s.consistencyScore),
        const SizedBox(height: AppSpacing.md),

        // Streaks
        Row(
          children: [
            Expanded(child: _buildStreakCard('Win streak', s.currentWinStreak, AppColors.success)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildStreakCard('Loss streak', s.currentLossStreak, AppColors.error)),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Drill trends
        if (s.drillTrends.isNotEmpty) ...[
          Text(
            'Xu huong theo bai tap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...s.drillTrends.values.map((t) => _buildDrillTrendCard(t)),
        ],

        // Summary stats
        const SizedBox(height: AppSpacing.xxl),
        _buildSummaryStats(s),
      ],
    );
  }

  Widget _buildOverallStatus(TrendSummary s) {
    final isGood = (s.trainingTrend == TrendResult.improving || s.trainingTrend == TrendResult.stable) &&
        (s.matchTrend == TrendResult.improving || s.matchTrend == TrendResult.stable);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood
              ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
              : [AppColors.warning, AppColors.warning.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? 'Xu huong tich cuc' : 'Can cai thien',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isGood
                      ? 'Ban dang tien bo hoac duy tri phong do'
                      : 'Can tap trung vao nhung diem yeu',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, TrendResult trend, IconData icon, Color color) {
    final (label, trendIcon, trendColor) = switch (trend) {
      TrendResult.improving => ('Dang tien bo', Icons.trending_up, AppColors.success),
      TrendResult.stable => ('On dinh', Icons.trending_flat, AppColors.accent),
      TrendResult.declining => ('Can cai thien', Icons.trending_down, AppColors.warning),
      TrendResult.insufficient => ('Chua du du lieu', Icons.help_outline, AppColors.lightTextSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.lightTextPrimary)),
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: trendColor),
                ),
              ],
            ),
          ),
          Icon(trendIcon, color: trendColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(int score) {
    final color = score >= 70 ? AppColors.success : (score >= 40 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.speed, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Do on dinh', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.lightTextPrimary)),
                Text(
                  score >= 70 ? 'Tot' : (score >= 40 ? 'Trung binh' : 'Can cai thien'),
                  style: TextStyle(fontSize: 13, color: color),
                ),
              ],
            ),
          ),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillTrendCard(DrillTrend t) {
    final (label, icon, color) = switch (t.trend) {
      TrendResult.improving => ('Tien bo', Icons.trending_up, AppColors.success),
      TrendResult.stable => ('On dinh', Icons.trending_flat, AppColors.accent),
      TrendResult.declining => ('Can cai thien', Icons.trending_down, AppColors.warning),
      TrendResult.insufficient => ('Chua du du lieu', Icons.help_outline, AppColors.lightTextSecondary),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(t.drillName, style: TextStyle(color: AppColors.lightTextPrimary)),
        subtitle: Text('$label - ${t.sessionCount} sessions', style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
        trailing: t.trend != TrendResult.insufficient
            ? Text(
                '${t.delta > 0 ? '+' : ''}${t.delta.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSummaryStats(TrendSummary s) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tong ket',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Tong buoi tap: ${s.totalSessions}', style: TextStyle(color: AppColors.lightTextSecondary)),
          Text('Tong tran dau: ${s.totalMatches}', style: TextStyle(color: AppColors.lightTextSecondary)),
          Text('Bai tap da tap: ${s.drillTrends.length}', style: TextStyle(color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}
