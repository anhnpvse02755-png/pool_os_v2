import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/services/trend_engine.dart';

/// Sprint 4C Task 20 — Trend Dashboard
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
      appBar: AppBar(
        title: const Text('Xu hướng'),
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
              ? Center(child: Text('Lỗi: $_error'))
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
          Icon(Icons.analytics, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Chưa có đủ dữ liệu'),
          const SizedBox(height: 8),
          Text(
            'Cần ít nhất 2 buổi tập để xem xu hướng.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final s = _summary!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall status
        _buildOverallStatus(s),
        const SizedBox(height: 16),

        // Training trend
        _buildTrendCard(
          'Xu hướng tập luyện',
          s.trainingTrend,
          Icons.fitness_center,
          Colors.blue,
        ),
        const SizedBox(height: 12),

        // Match trend
        _buildTrendCard(
          'Xu hướng thi đấu',
          s.matchTrend,
          Icons.sports,
          Colors.purple,
        ),
        const SizedBox(height: 12),

        // Consistency
        _buildConsistencyCard(s.consistencyScore),
        const SizedBox(height: 12),

        // Streaks
        Row(
          children: [
            Expanded(child: _buildStreakCard('Win streak', s.currentWinStreak, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStreakCard('Loss streak', s.currentLossStreak, Colors.red)),
          ],
        ),
        const SizedBox(height: 24),

        // Drill trends
        if (s.drillTrends.isNotEmpty) ...[
          const Text(
            'Xu hướng theo bài tập',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...s.drillTrends.values.map((t) => _buildDrillTrendCard(t)),
        ],

        // Summary stats
        const SizedBox(height: 24),
        _buildSummaryStats(s),
      ],
    );
  }

  Widget _buildOverallStatus(TrendSummary s) {
    final isGood = (s.trainingTrend == TrendResult.improving || s.trainingTrend == TrendResult.stable) &&
        (s.matchTrend == TrendResult.improving || s.matchTrend == TrendResult.stable);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGood
              ? [Colors.green, Colors.green.shade400]
              : [Colors.orange, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.trending_up : Icons.trending_down,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? 'Xu hướng tích cực' : 'Cần cải thiện',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGood
                      ? 'Bạn đang tiến bộ hoặc duy trì phong độ'
                      : 'Cần tập trung vào những điểm yếu',
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
      TrendResult.improving => ('Đang tiến bộ', Icons.trending_up, Colors.green),
      TrendResult.stable => ('Ổn định', Icons.trending_flat, Colors.blue),
      TrendResult.declining => ('Cần cải thiện', Icons.trending_down, Colors.orange),
      TrendResult.insufficient => ('Chưa đủ dữ liệu', Icons.help_outline, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    final color = score >= 70 ? Colors.green : (score >= 40 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Độ ổn định', style: TextStyle(fontWeight: FontWeight.w500)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
      TrendResult.improving => ('Tiến bộ', Icons.trending_up, Colors.green),
      TrendResult.stable => ('Ổn định', Icons.trending_flat, Colors.blue),
      TrendResult.declining => ('Cần cải thiện', Icons.trending_down, Colors.orange),
      TrendResult.insufficient => ('Chưa đủ dữ liệu', Icons.help_outline, Colors.grey),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(t.drillName),
        subtitle: Text('$label • ${t.sessionCount} sessions'),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng kết',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Tổng buổi tập: ${s.totalSessions}'),
          Text('Tổng trận đấu: ${s.totalMatches}'),
          Text('Bài tập đã tập: ${s.drillTrends.length}'),
        ],
      ),
    );
  }
}
