import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../domain/services/trend_engine.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

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

  /// Bộ bốn trạng thái xu hướng, dùng chung cho thẻ tổng và thẻ từng bài.
  ///
  /// BỘ MÀU ANH EM: bốn nhánh này phải phân biệt được với nhau. `stable`
  /// trước đây là `accent` xanh điện (hue 217°); ánh xạ thẳng sang `primary`
  /// sẽ đưa nó về hue 157–158°, chỉ cách `success` của nhánh `improving`
  /// đúng 2–3° — hai trạng thái trái nghĩa nhau trông y hệt. `stable` không
  /// mang phán quyết tốt/xấu nên nó là thành viên TRUNG TÍNH của bộ: hạ về
  /// `textSecondary`. `insufficient` (chưa có dữ liệu) còn trung tính hơn
  /// nữa nên xuống `textTertiary`, tách khỏi `stable` bằng độ sáng, và tách
  /// thêm bằng icon (`trending_flat` vs `help_outline`) lẫn nhãn chữ.
  ///
  /// Kết quả bốn hue: 160° / trung tính / 38° / trung tính-nhạt.
  Color _trendColor(TrendResult trend, Brightness brightness) {
    return switch (trend) {
      TrendResult.improving => AppColors.success,
      TrendResult.stable => AppColors.textSecondary(brightness),
      TrendResult.declining => AppColors.warning,
      TrendResult.insufficient => AppColors.textTertiary(brightness),
    };
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Xu hướng'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
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
      body: SoftBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Lỗi: $_error'))
                : _summary == null
                    ? _buildEmpty()
                    : _buildDashboard(),
      ),
    );
  }

  Widget _buildEmpty() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: AppColors.textTertiary(brightness)),
          const SizedBox(height: AppSpacing.lg),
          const Text('Chưa có đủ dữ liệu'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cần ít nhất 2 buổi tập để xem xu hướng.',
            style: TextStyle(color: AppColors.textSecondary(brightness)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final brightness = Theme.of(context).brightness;
    final s = _summary!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Overall status
        _buildOverallStatus(s),
        const SizedBox(height: AppSpacing.lg),

        // Training trend
        //
        // BỘ MÀU ANH EM (kênh "lĩnh vực"): tập luyện vs thi đấu. `primary`
        // hue 158° và `difficultyExpert` hue 262° cách nhau 104°, phân biệt
        // được ở cả hai chế độ.
        _buildTrendCard(
          'Xu hướng tập luyện',
          s.trainingTrend,
          Icons.fitness_center,
          AppColors.primary(brightness),
        ),
        const SizedBox(height: AppSpacing.md),

        // Match trend
        _buildTrendCard(
          'Xu hướng thi đấu',
          s.matchTrend,
          Icons.sports,
          AppColors.difficultyExpert(brightness),
        ),
        const SizedBox(height: AppSpacing.md),

        // Consistency
        _buildConsistencyCard(s.consistencyScore),
        const SizedBox(height: AppSpacing.md),

        // Streaks
        //
        // BỘ MÀU ANH EM: success 160° vs error 0° — giữ nguyên, đã tách xa.
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
            'Xu hướng theo bài tập',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(brightness),
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
    final brightness = Theme.of(context).brightness;
    final isGood = (s.trainingTrend == TrendResult.improving || s.trainingTrend == TrendResult.stable) &&
        (s.matchTrend == TrendResult.improving || s.matchTrend == TrendResult.stable);

    final tone = isGood ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        // NỀN BÃO HOÀ + MỰC SÁNG: bản cũ tô đặc `success`/`warning` rồi đặt
        // chữ trắng lên — 2.56:1 và 2.15:1, hỏng ở chính chế độ sáng là chế
        // độ duy nhất đang phát hành. Loang mờ về 0.18→0.10 rồi dùng
        // `textPrimary` đưa cả hai lên 10.33:1 và 10.79:1 (bản sáng),
        // 11.88:1 (bản tối). Nền hết bão hoà nên không còn phải cân
        // `onPrimary`, và đuôi loang cũ ở alpha 0.7 cũng biến mất luôn.
        //
        // Phân biệt tốt/xấu chuyển sang icon (`trending_up`/`trending_down`)
        // và chính câu tiêu đề, cộng với sắc nền nhạt còn lại.
        gradient: LinearGradient(
          colors: [
            tone.withValues(alpha: 0.18),
            tone.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.trending_up : Icons.trending_down,
            color: AppColors.textPrimary(brightness),
            size: 48,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? 'Xu hướng tích cực' : 'Cần cải thiện',
                  style: TextStyle(
                    color: AppColors.textPrimary(brightness),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isGood
                      ? 'Bạn đang tiến bộ hoặc duy trì phong độ'
                      : 'Cần tập trung vào những điểm yếu',
                  // Nhãn phụ 13px trên nền nhạt: `textSecondary` sẽ tụt sát
                  // sàn, nên giữ `textPrimary`. Thứ bậc do cỡ chữ 18 vs 13 lo.
                  style: TextStyle(
                      color: AppColors.textPrimary(brightness), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, TrendResult trend, IconData icon, Color color) {
    final brightness = Theme.of(context).brightness;
    final (label, trendIcon, trendColor) = switch (trend) {
      TrendResult.improving => ('Đang tiến bộ', Icons.trending_up, _trendColor(trend, brightness)),
      TrendResult.stable => ('Ổn định', Icons.trending_flat, _trendColor(trend, brightness)),
      TrendResult.declining => ('Cần cải thiện', Icons.trending_down, _trendColor(trend, brightness)),
      TrendResult.insufficient => ('Chưa đủ dữ liệu', Icons.help_outline, _trendColor(trend, brightness)),
    };

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary(brightness))),
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
    final brightness = Theme.of(context).brightness;
    // Ba bậc ngữ nghĩa: 160° / 38° / 0°. Không bậc nào rơi vào họ xanh của
    // `primary`, nên bộ này giữ nguyên.
    final color = score >= 70 ? AppColors.success : (score >= 40 ? AppColors.warning : AppColors.error);

    return PoolCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                Text('Độ ổn định', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary(brightness))),
                Text(
                  score >= 70 ? 'Tốt' : (score >= 40 ? 'Trung bình' : 'Cần cải thiện'),
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
    final brightness = Theme.of(context).brightness;
    final (label, icon, color) = switch (t.trend) {
      TrendResult.improving => ('Tiến bộ', Icons.trending_up, _trendColor(t.trend, brightness)),
      TrendResult.stable => ('Ổn định', Icons.trending_flat, _trendColor(t.trend, brightness)),
      TrendResult.declining => ('Cần cải thiện', Icons.trending_down, _trendColor(t.trend, brightness)),
      TrendResult.insufficient => ('Chưa đủ dữ liệu', Icons.help_outline, _trendColor(t.trend, brightness)),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(t.drillName, style: TextStyle(color: AppColors.textPrimary(brightness))),
        subtitle: Text('$label - ${t.sessionCount} sessions', style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 12)),
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
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng kết',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Tong buoi tap: ${s.totalSessions}', style: TextStyle(color: AppColors.textSecondary(brightness))),
          Text('Tong tran dau: ${s.totalMatches}', style: TextStyle(color: AppColors.textSecondary(brightness))),
          Text('Bai tap da tap: ${s.drillTrends.length}', style: TextStyle(color: AppColors.textSecondary(brightness))),
        ],
      ),
    );
  }
}
