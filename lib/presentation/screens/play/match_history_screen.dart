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

  Map<String, int> get _aggregates {
    final wins = _matches.where((m) => m.isWin).length;
    final losses = _matches.where((m) => m.isLoss).length;
    final draws = _matches.where((m) => m.isDraw).length;
    return {
      'total': _matches.length,
      'wins': wins,
      'losses': losses,
      'draws': draws,
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
            onPressed: () => context.push('/play/match/new'),
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
              : Column(
                  children: [
                    _buildStatsSummary(),
                    const Divider(height: 1),
                    Expanded(child: _buildList()),
                  ],
                ),
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
                  onPressed: () => context.push('/play/match/new'),
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

  Widget _buildStatsSummary() {
    final agg = _aggregates;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tổng', agg['total'] ?? 0, Icons.sports),
          _buildStatItem('Thắng', agg['wins'] ?? 0, Icons.emoji_events,
              color: Colors.greenAccent),
          _buildStatItem('Thua', agg['losses'] ?? 0, Icons.cancel,
              color: Colors.redAccent),
          _buildStatItem('Hòa', agg['draws'] ?? 0, Icons.balance),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatItem(
      String label, int value, IconData icon, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/play/match/${m.id}/summary'),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }
}
