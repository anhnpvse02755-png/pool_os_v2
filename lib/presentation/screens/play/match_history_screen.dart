import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';
import '../../../data/repositories/match_repository.dart';

class MatchHistoryScreen extends ConsumerStatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  ConsumerState<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends ConsumerState<MatchHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  List<Match> _matches = [];
  bool _loading = true;
  final Set<String> _selectedMatches = {}; // Sprint 4B Task 16: match comparison

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Day 2A.5: use Riverpod provider instead of LocalMatchRepository().
    final repo = ref.read(matchRepositoryProvider);
    final ms = await repo.getAllMatches();
    if (!mounted) return;
    setState(() {
      _matches = ms;
      _loading = false;
    });
  }

  Future<void> _seedDemo() async {
    final repo = ref.read(matchRepositoryProvider);
    final now = DateTime.now();
    final demo = Match(
      id: 'demo-1',
      gameType: 'race_to_5',
      raceTo: 5,
      opponent: 'Nguyễn Văn A',
      opponentName: 'Nguyễn Văn A',
      opponentLevel: 'intermediate',
      venue: 'Billiards Club Q1',
      table: 'Bàn 3',
      result: 'win',
      winner: 'player',
      resultSummary: '5-3',
      playerScore: 5,
      opponentScore: 3,
      duration: 45,
      notes: 'Demo seeded match.',
      racks: const [],
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );
    await repo.saveMatch(demo);
    await _load();
  }

  List<Match> get _filtered {
    if (_selectedFilter == 'all') return _matches;
    return _matches.where((m) => m.result == _selectedFilter).toList();
  }

  /// Sprint 4B Task 17: Enhanced aggregates for Coach AI
  Map<String, dynamic> get _aggregates {
    if (_matches.isEmpty) {
      return {
        'total': 0, 'wins': 0, 'losses': 0, 'draws': 0,
        'winRate': 0, 'avgScore': 0, 'avgDuration': 0,
        'currentStreak': 0, 'longestWinStreak': 0, 'longestLossStreak': 0,
      };
    }

    final wins = _matches.where((m) => m.isWin).length;
    final losses = _matches.where((m) => m.isLoss).length;
    final draws = _matches.where((m) => m.isDraw).length;
    final winRate = (wins * 100 / _matches.length).round();

    // Average score
    final totalScore = _matches.fold<int>(0, (sum, m) => sum + m.playerScore);
    final avgScore = totalScore ~/ _matches.length;

    // Average duration
    final totalDuration = _matches.fold<int>(0, (sum, m) => sum + (m.duration ?? 0));
    final avgDuration = _matches.where((m) => m.duration != null && m.duration! > 0).isNotEmpty
        ? totalDuration ~/ _matches.where((m) => m.duration != null && m.duration! > 0).length
        : 0;

    // Streaks (most recent first)
    final sorted = List<Match>.from(_matches)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int currentStreak = 0;
    int longestWinStreak = 0;
    int longestLossStreak = 0;
    int tempWinStreak = 0;
    int tempLossStreak = 0;

    for (final m in sorted) {
      if (m.isWin) {
        tempWinStreak++;
        tempLossStreak = 0;
        if (tempWinStreak > longestWinStreak) longestWinStreak = tempWinStreak;
      } else if (m.isLoss) {
        tempLossStreak++;
        tempWinStreak = 0;
        if (tempLossStreak > longestLossStreak) longestLossStreak = tempLossStreak;
      }
    }

    // Current streak from most recent
    for (final m in sorted) {
      if (m.isWin || m.isLoss) {
        currentStreak = m.isWin ? 1 : -1;
        break;
      }
    }

    return {
      'total': _matches.length,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': winRate,
      'avgScore': avgScore,
      'avgDuration': avgDuration,
      'currentStreak': currentStreak,
      'longestWinStreak': longestWinStreak,
      'longestLossStreak': longestLossStreak,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đấu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Bắt đầu trận đấu',
            onPressed: () => context.push('/play/recording'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (i) {
            setState(() => _selectedFilter =
                i == 0 ? 'all' : (i == 1 ? 'win' : 'lose'));
          },
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Thắng'),
            Tab(text: 'Thua'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? _buildEmpty()
              : Stack(
                  children: [
                    Column(
                      children: [
                        _buildStatsSummary(),
                        const Divider(height: 1),
                        Expanded(child: _buildList()),
                      ],
                    ),
                    if (_selectedMatches.length == 2)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: FilledButton.icon(
                          onPressed: () => _showComparison(),
                          icon: const Icon(Icons.compare_arrows),
                          label: const Text('So sánh 2 trận đấu'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  void _showComparison() {
    if (_selectedMatches.length != 2) return;
    final matches = _matches.where((m) => _selectedMatches.contains(m.id)).toList();
    if (matches.length != 2) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MatchComparisonSheet(match1: matches[0], match2: matches[1]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 64, color: AppTheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'Chưa có trận đấu nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bắt đầu một trận đấu hoặc seed dữ liệu mẫu để thử nghiệm.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/play/recording'),
                  icon: const Icon(Icons.sports),
                  label: const Text('Bắt đầu trận'),
                ),
                OutlinedButton.icon(
                  onPressed: _seedDemo,
                  icon: const Icon(Icons.science),
                  label: const Text('Seed dữ liệu mẫu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Sprint 4B Task 17: Enhanced stats display for Coach AI
  Widget _buildStatsSummary() {
    final agg = _aggregates;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        children: [
          // Primary stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tổng', '${agg['total']}', Icons.sports),
              _buildStatItem('Thắng', '${agg['wins']}', Icons.emoji_events,
                  color: Colors.greenAccent),
              _buildStatItem('Thua', '${agg['losses']}', Icons.cancel,
                  color: Colors.redAccent),
              _buildStatItem('Win Rate', '${agg['winRate']}%', Icons.percent),
            ],
          ),
          const SizedBox(height: 12),
          // Secondary stats row for Coach AI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Avg Score', '${agg['avgScore']}', Icons.score),
              _buildStatItem('Avg Time', '${agg['avgDuration']}m', Icons.timer),
              _buildStatItem('Win Streak', '${agg['longestWinStreak']}', Icons.trending_up,
                  color: Colors.greenAccent),
              _buildStatItem('Loss Streak', '${agg['longestLossStreak']}', Icons.trending_down,
                  color: Colors.redAccent),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildList() {
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Không có trận đấu ${_selectedFilter == 'win' ? 'thắng' : 'thua'}.',
              style: const TextStyle(fontSize: 16)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildMatchCard(filtered[i]),
    );
  }

  Widget _buildMatchCard(Match m) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final color = m.isWin
        ? Colors.green
        : (m.isLoss ? Colors.red : Colors.orange);
    final icon = m.isWin
        ? Icons.emoji_events
        : (m.isLoss ? Icons.cancel : Icons.balance);
    final isSelected = _selectedMatches.contains(m.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected
              ? AppTheme.primaryGreen
              : color.withValues(alpha: 0.15),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white)
              : Icon(icon, color: color),
        ),
        title: Text(
          'vs ${m.opponentName ?? m.opponent ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
                '${MatchTypes.labels[m.gameType] ?? m.gameType} • ${m.resultSummary ?? '${m.playerScore}-${m.opponentScore}'}'),
            Text(fmt.format(m.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
            : const Icon(Icons.chevron_right),
        onTap: () {
          if (_selectedMatches.isNotEmpty) {
            // Selection mode: toggle selection
            setState(() {
              if (isSelected) {
                _selectedMatches.remove(m.id);
              } else if (_selectedMatches.length < 2) {
                _selectedMatches.add(m.id);
              }
            });
          } else {
            context.push('/play/match/${m.id}/summary');
          }
        },
        onLongPress: () {
          // Enter selection mode
          setState(() {
            _selectedMatches.add(m.id);
          });
        },
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }
}

/// Sprint 4B Task 16: Match Comparison Sheet
class _MatchComparisonSheet extends StatelessWidget {
  final Match match1;
  final Match match2;

  const _MatchComparisonSheet({required this.match1, required this.match2});

  @override
  Widget build(BuildContext context) {
    // Compute aggregates for each match
    final agg1 = _computeAggregates(match1);
    final agg2 = _computeAggregates(match2);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'So sánh trận đấu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Match headers
          Row(
            children: [
              Expanded(child: _buildMatchHeader(match1, agg1)),
              const SizedBox(width: 16),
              Expanded(child: _buildMatchHeader(match2, agg2)),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Comparison rows
          _buildComparisonRow('Kết quả', match1.result, match2.result),
          _buildComparisonRow('Tỷ số', match1.resultSummary ?? '-', match2.resultSummary ?? '-'),
          _buildComparisonRow('Thời lượng', '${agg1['duration']} phút', '${agg2['duration']} phút'),
          _buildComparisonRow('Tổng Fouls', '${agg1['fouls']}', '${agg2['fouls']}'),
          _buildComparisonRow('Safety plays', '${agg1['safety']}', '${agg2['safety']}'),
          _buildComparisonRow('Longest run', '${agg1['longestRun']}', '${agg2['longestRun']}'),
          _buildComparisonRow('Win rate', '${agg1['winRate']}%', '${agg2['winRate']}%'),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(Match m, Map<String, dynamic> agg) {
    final color = m.isWin ? Colors.green : (m.isLoss ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            m.isWin ? 'Thắng' : (m.isLoss ? 'Thua' : 'Hòa'),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '${m.opponentName ?? m.opponent ?? 'Unknown'}',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String val1, String val2) {
    final isBetter1 = _isBetterFor(label, val1, val2);
    final isBetter2 = _isBetterFor(label, val2, val1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBetter1 ? Colors.green : null,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBetter2 ? Colors.green : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isBetterFor(String label, String val1, String val2) {
    if (label.contains('Foul') || label.contains('Thua')) {
      final n1 = int.tryParse(val1.toString().replaceAll(RegExp(r'\D'), '')) ?? 0;
      final n2 = int.tryParse(val2.toString().replaceAll(RegExp(r'\D'), '')) ?? 0;
      return n1 < n2;
    }
    final n1 = int.tryParse(val1.toString().replaceAll(RegExp(r'\D'), '')) ?? 0;
    final n2 = int.tryParse(val2.toString().replaceAll(RegExp(r'\D'), '')) ?? 0;
    return n1 > n2;
  }

  Map<String, dynamic> _computeAggregates(Match m) {
    int totalFouls = 0;
    int totalSafety = 0;
    int longestRun = 0;

    for (final rack in m.racks) {
      totalFouls += rack.fouls;
      totalSafety += rack.safetyPlays;
      if (rack.longestRun > longestRun) longestRun = rack.longestRun;
    }

    final winRate = m.racks.isNotEmpty
        ? (m.racks.where((r) => r.resultBool).length * 100 / m.racks.length).round()
        : 0;

    return {
      'fouls': totalFouls,
      'safety': totalSafety,
      'longestRun': longestRun,
      'winRate': winRate,
      'duration': m.duration ?? 0,
    };
  }
}
