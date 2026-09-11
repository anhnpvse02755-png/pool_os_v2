import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/models/match.dart';

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
  final Set<String> _selectedMatches = {};

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
      racks: [],
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

    final totalScore = _matches.fold<int>(0, (sum, m) => sum + m.playerScore);
    final avgScore = totalScore ~/ _matches.length;

    final totalDuration = _matches.fold<int>(0, (sum, m) => sum + (m.duration ?? 0));
    final avgDuration = _matches.where((m) => m.duration != null && m.duration! > 0).isNotEmpty
        ? totalDuration ~/ _matches.where((m) => m.duration != null && m.duration! > 0).length
        : 0;

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
    final brightness = Theme.of(context).brightness;

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
                        Divider(height: 1, color: AppColors.border(brightness)),
                        Expanded(child: _buildList()),
                      ],
                    ),
                    if (_selectedMatches.length == 2)
                      Positioned(
                        bottom: AppSpacing.md,
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        child: _CompareButton(
                          onPressed: () => _showComparison(),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) => _MatchComparisonSheet(match1: matches[0], match2: matches[1]),
    );
  }

  Widget _buildEmpty() {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history, size: 40, color: AppColors.primary(brightness).withValues(alpha: 0.5)),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Chưa có trận đấu nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Bắt đầu một trận đấu hoặc seed dữ liệu mẫu để thử nghiệm.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(brightness)),
            ),
            SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _StartMatchButton(
                  onPressed: () => context.push('/play/recording'),
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
    final brightness = Theme.of(context).brightness;

    final agg = _aggregates;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary(brightness), AppColors.primary(brightness).withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tổng', '${agg['total']}', Icons.sports),
              _buildStatItem('Thắng', '${agg['wins']}', Icons.emoji_events),
              _buildStatItem('Thua', '${agg['losses']}', Icons.cancel_outlined),
              _buildStatItem('Win Rate', '${agg['winRate']}%', Icons.percent),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Avg Score', '${agg['avgScore']}', Icons.score),
              _buildStatItem('Avg Time', '${agg['avgDuration']}m', Icons.timer),
              _buildStatItem('Win Streak', '${agg['longestWinStreak']}', Icons.trending_up),
              _buildStatItem('Loss Streak', '${agg['longestLossStreak']}', Icons.trending_down),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final brightness = Theme.of(context).brightness;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onPrimary(brightness), size: 18),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: AppColors.onPrimary(brightness), fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(label, style: TextStyle(color: AppColors.onPrimary(brightness).withValues(alpha: 0.70), fontSize: 10)),
      ],
    );
  }

  Widget _buildList() {
    final brightness = Theme.of(context).brightness;

    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            'Không có trận đấu ${_selectedFilter == 'win' ? 'thắng' : 'thua'}.',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary(brightness)),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.sm),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildMatchCard(filtered[i]),
    );
  }

  Widget _buildMatchCard(Match m) {
    final brightness = Theme.of(context).brightness;

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final color = m.isWin
        ? AppColors.success
        : (m.isLoss ? AppColors.error : AppColors.warning);
    final icon = m.isWin
        ? Icons.emoji_events
        : (m.isLoss ? Icons.cancel : Icons.balance);
    final isSelected = _selectedMatches.contains(m.id);

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary(brightness).withValues(alpha: 0.08) : AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isSelected ? Border.all(color: AppColors.primary(brightness), width: 2) : null,
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary(brightness)
                  : color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isSelected
                  ? Icon(Icons.check, color: AppColors.onPrimary(brightness), size: 20)
                  : Icon(icon, color: color, size: 20),
            ),
          ),
          title: Text(
            'vs ${m.opponentName ?? m.opponent ?? 'Unknown'}',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                '${MatchTypes.labels[m.gameType] ?? m.gameType} • ${m.resultSummary ?? '${m.playerScore}-${m.opponentScore}'}',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary(brightness)),
              ),
              SizedBox(height: 2),
              Text(
                fmt.format(m.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary(brightness)),
              ),
            ],
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: AppColors.primary(brightness))
              : Icon(Icons.chevron_right, color: AppColors.textTertiary(brightness)),
          onTap: () {
            if (_selectedMatches.isNotEmpty) {
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
            setState(() {
              _selectedMatches.add(m.id);
            });
          },
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.05);
  }
}

class _StartMatchButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _StartMatchButton({required this.onPressed});

  @override
  State<_StartMatchButton> createState() => _StartMatchButtonState();
}

class _StartMatchButtonState extends State<_StartMatchButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports, color: AppColors.onPrimary(brightness), size: 20),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Bắt đầu trận',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompareButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CompareButton({required this.onPressed});

  @override
  State<_CompareButton> createState() => _CompareButtonState();
}

class _CompareButtonState extends State<_CompareButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary(brightness).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.compare_arrows, color: AppColors.onPrimary(brightness)),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'So sánh 2 trận đấu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchComparisonSheet extends StatelessWidget {
  final Match match1;
  final Match match2;

  const _MatchComparisonSheet({required this.match1, required this.match2});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final agg1 = _computeAggregates(match1);
    final agg2 = _computeAggregates(match2);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'So sánh trận đấu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(child: _buildMatchHeader(match1, agg1)),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _buildMatchHeader(match2, agg2)),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.border(brightness)),
          SizedBox(height: AppSpacing.sm),

          _buildComparisonRow('Kết quả', match1.result, match2.result, brightness),
          _buildComparisonRow('Tỷ số', match1.resultSummary ?? '-', match2.resultSummary ?? '-', brightness),
          _buildComparisonRow('Thời lượng', '${agg1['duration']} phút', '${agg2['duration']} phút', brightness),
          _buildComparisonRow('Tổng Fouls', '${agg1['fouls']}', '${agg2['fouls']}', brightness),
          _buildComparisonRow('Safety plays', '${agg1['safety']}', '${agg2['safety']}', brightness),
          _buildComparisonRow('Longest run', '${agg1['longestRun']}', '${agg2['longestRun']}', brightness),
          _buildComparisonRow('Win rate', '${agg1['winRate']}%', '${agg2['winRate']}%', brightness),

          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(Match m, Map<String, dynamic> agg) {
    final color = m.isWin ? AppColors.success : (m.isLoss ? AppColors.error : AppColors.warning);
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            m.isWin ? 'Thắng' : (m.isLoss ? 'Thua' : 'Hòa'),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4),
          Text(
            m.opponentName ?? m.opponent ?? 'Unknown',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String val1, String val2, Brightness brightness) {
    final isBetter1 = _isBetterFor(label, val1, val2);
    final isBetter2 = _isBetterFor(label, val2, val1);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              val1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isBetter1 ? AppColors.success : null,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(brightness), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              val2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isBetter2 ? AppColors.success : null,
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
