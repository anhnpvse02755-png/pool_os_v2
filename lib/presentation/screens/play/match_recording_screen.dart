import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/services/match_analysis_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';

class MatchRecordingScreen extends ConsumerStatefulWidget {
  const MatchRecordingScreen({super.key});

  @override
  ConsumerState<MatchRecordingScreen> createState() => _MatchRecordingScreenState();
}

class _MatchRecordingScreenState extends ConsumerState<MatchRecordingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();

  int _raceTo = 1;
  String _matchType = 'friendly';
  String? _opponentLevel;
  String _tableCondition = 'familiar';
  String _environment = 'club';

  Match? _currentMatch;
  int _currentRack = 1;
  int _playerScore = 0;
  int _opponentScore = 0;
  List<Rack> _racks = [];

  @override
  void dispose() {
    _opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show setup form if no match started
    if (_currentMatch == null) {
      return _buildSetupForm();
    }

    // Show match recording UI
    return _buildMatchUI();
  }

  Widget _buildSetupForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi nhận trận đấu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match type
              Text('Loại trận', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Giao lưu'),
                    selected: _matchType == 'friendly',
                    onSelected: (_) => setState(() => _matchType = 'friendly'),
                  ),
                  ChoiceChip(
                    label: const Text('Tập luyện'),
                    selected: _matchType == 'practice',
                    onSelected: (_) => setState(() => _matchType = 'practice'),
                  ),
                  ChoiceChip(
                    label: const Text('Thi đấu'),
                    selected: _matchType == 'tournament',
                    onSelected: (_) => setState(() => _matchType = 'tournament'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Race to
              Text('Đấu đến', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 3, 5, 7].map((value) {
                  return ChoiceChip(
                    label: Text('FT $value'),
                    selected: _raceTo == value,
                    onSelected: (_) => setState(() => _raceTo = value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Opponent
              TextField(
                controller: _opponentController,
                decoration: const InputDecoration(
                  labelText: 'Tên đối thủ (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Start match button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('BẮT ĐẦU TRẬN ĐẤU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang đấu'),
        actions: [
          TextButton(
            onPressed: _endMatchEarly,
            child: const Text('Kết thúc'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreBox('Bạn', _playerScore, Colors.green),
                const Text('vs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                _buildScoreBox('Đối thủ', _opponentScore, Colors.red),
              ],
            ),
          ),

          // Rack history
          _buildRackHistory(),

          const Spacer(),

          // WIN/LOSE buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _recordRackResult('lose'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('THUA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _recordRackResult('win'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('THẮNG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startMatch() async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    final m = Match(
      id: id,
      gameType: _matchType == 'friendly'
          ? MatchTypes.raceTo
          : _matchType == 'practice'
              ? MatchTypes.practiceMatch
              : MatchTypes.tournamentMatch,
      raceTo: _raceTo,
      opponent: _opponentController.text.isNotEmpty ? _opponentController.text : null,
      opponentName: _opponentController.text.isNotEmpty ? _opponentController.text : null,
      opponentLevel: _opponentLevel,
      table: _tableCondition == 'familiar' ? 'Home' : 'Away',
      venue: _environment == 'home' ? 'Home' : 'Club',
      result: 'in_progress',
      startTime: now,
      createdAt: now,
      updatedAt: now,
    );
    setState(() {
      _currentMatch = m;
      _currentRack = 1;
      _playerScore = 0;
      _opponentScore = 0;
      _racks = [];
    });
    await ref.read(matchRepositoryProvider).saveMatch(m);

    // Sprint-8: Clear previous match analysis when starting new match
    ref.read(coachStateProvider.notifier).clearMatchAnalysis();
  }

  void _recordRackResult(String result) {
    _showRackDataSheet(result);
  }

  void _showRackDataSheet(String result) {
    // Full rack data state
    int ballsPottedOnBreak = 0;
    int totalBallsPotted = 0;
    int longestRun = 0;
    int easyMissCount = 0;
    int hardMissCount = 0;
    int fouls = 0;
    int scratchErrorCount = 0;
    int positionErrorCount = 0;
    int safetyErrorCount = 0;
    int kickErrorCount = 0;
    int jumpErrorCount = 0;
    int bankShotCount = 0;
    int comboShotCount = 0;
    int caromShotCount = 0;
    bool winOnBreak = false;
    bool breakScratch = false;
    String? howWon;
    String biggestMistake = '';
    String biggestStrength = '';
    final String rackResult = result; // capture as final

    bool isBreakRack = _racks.isEmpty;
    int secondsRemaining = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          // Countdown timer inside StatefulBuilder
          Timer? countdownTimer;

          // Start countdown once when sheet opens
          WidgetsBinding.instance.addPostFrameCallback((_) {
            countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsRemaining > 0) {
                setSheetState(() {
                  secondsRemaining--;
                });
              } else {
                timer.cancel();
                if (mounted) {
                  Navigator.pop(ctx);
                  _commitRackResult(
                    rackResult,
                    ballsPottedOnBreak: ballsPottedOnBreak,
                    totalBallsPotted: totalBallsPotted,
                    longestRun: longestRun,
                    easyMissCount: easyMissCount,
                    hardMissCount: hardMissCount,
                    fouls: fouls,
                    scratchErrorCount: scratchErrorCount,
                    positionErrorCount: positionErrorCount,
                    safetyErrorCount: safetyErrorCount,
                    kickErrorCount: kickErrorCount,
                    jumpErrorCount: jumpErrorCount,
                    bankShotCount: bankShotCount,
                    comboShotCount: comboShotCount,
                    caromShotCount: caromShotCount,
                    winOnBreak: winOnBreak,
                    breakScratch: breakScratch,
                    howWon: howWon,
                    biggestMistake: biggestMistake,
                    biggestStrength: biggestStrength,
                    isBreakRack: isBreakRack,
                  );
                }
              }
            });
          });

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) {
                countdownTimer?.cancel();
                Navigator.pop(ctx);
                _commitRackResult(
                  rackResult,
                  ballsPottedOnBreak: ballsPottedOnBreak,
                  totalBallsPotted: totalBallsPotted,
                  longestRun: longestRun,
                  easyMissCount: easyMissCount,
                  hardMissCount: hardMissCount,
                  fouls: fouls,
                  scratchErrorCount: scratchErrorCount,
                  positionErrorCount: positionErrorCount,
                  safetyErrorCount: safetyErrorCount,
                  kickErrorCount: kickErrorCount,
                  jumpErrorCount: jumpErrorCount,
                  bankShotCount: bankShotCount,
                  comboShotCount: comboShotCount,
                  caromShotCount: caromShotCount,
                  winOnBreak: winOnBreak,
                  breakScratch: breakScratch,
                  howWon: howWon,
                  biggestMistake: biggestMistake,
                  biggestStrength: biggestStrength,
                  isBreakRack: isBreakRack,
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rack $_currentRack — Ghi nhận',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: secondsRemaining <= 10 ? Colors.red.shade100 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: secondsRemaining <= 10 ? Colors.red : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${secondsRemaining}s',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: secondsRemaining <= 10 ? Colors.red : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ghi nhận kết quả rack trước khi xếp bi mới.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Break Rack Section
                    if (isBreakRack) ...[
                      _buildSectionTitle('🎯 Break Rack'),
                      _buildToggleRow(
                        'Win on break',
                        'Thắng ngay từ break',
                        winOnBreak,
                        onChanged: (v) => setSheetState(() => winOnBreak = v ?? false),
                      ),
                      _buildCounterRow(
                        'Bi vào từ break',
                        ballsPottedOnBreak,
                        (v) => setSheetState(() => ballsPottedOnBreak = v),
                        Icons.sports_cricket,
                      ),
                      _buildToggleRow(
                        'Break scratch',
                        'Scratch khi break',
                        breakScratch,
                        onChanged: (v) => setSheetState(() => breakScratch = v ?? false),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Shot Results Section
                    _buildSectionTitle('📊 Kết quả đánh'),
                    _buildCounterRow(
                      'Tổng bi vào',
                      totalBallsPotted,
                      (v) => setSheetState(() => totalBallsPotted = v),
                      Icons.check_circle,
                    ),
                    _buildCounterRow(
                      'Run dài nhất',
                      longestRun,
                      (v) => setSheetState(() => longestRun = v),
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 16),

                    // Errors Section
                    _buildSectionTitle('❌ Sai sót'),
                    _buildCounterRow(
                      'Miss dễ',
                      easyMissCount,
                      (v) => setSheetState(() => easyMissCount = v),
                      Icons.close,
                    ),
                    _buildCounterRow(
                      'Miss khó',
                      hardMissCount,
                      (v) => setSheetState(() => hardMissCount = v),
                      Icons.warning,
                    ),
                    _buildCounterRow(
                      'Scratch',
                      scratchErrorCount,
                      (v) => setSheetState(() => scratchErrorCount = v),
                      Icons.error_outline,
                    ),
                    _buildCounterRow(
                      'Lỗi position',
                      positionErrorCount,
                      (v) => setSheetState(() => positionErrorCount = v),
                      Icons.location_off,
                    ),
                    _buildCounterRow(
                      'Lỗi safety',
                      safetyErrorCount,
                      (v) => setSheetState(() => safetyErrorCount = v),
                      Icons.shield_outlined,
                    ),
                    _buildCounterRow(
                      'Lỗi kick',
                      kickErrorCount,
                      (v) => setSheetState(() => kickErrorCount = v),
                      Icons.turn_right,
                    ),
                    _buildCounterRow(
                      'Cue nhảy',
                      jumpErrorCount,
                      (v) => setSheetState(() => jumpErrorCount = v),
                      Icons.height,
                    ),
                    _buildCounterRow(
                      'Fouls',
                      fouls,
                      (v) => setSheetState(() => fouls = v),
                      Icons.warning_amber,
                    ),
                    const SizedBox(height: 16),

                    // Shot Types Section
                    _buildSectionTitle('🎯 Loại cú đánh'),
                    _buildCounterRow(
                      'Bank shots',
                      bankShotCount,
                      (v) => setSheetState(() => bankShotCount = v),
                      Icons.swap_horiz,
                    ),
                    _buildCounterRow(
                      'Combo',
                      comboShotCount,
                      (v) => setSheetState(() => comboShotCount = v),
                      Icons.linear_scale,
                    ),
                    _buildCounterRow(
                      'Carom',
                      caromShotCount,
                      (v) => setSheetState(() => caromShotCount = v),
                      Icons.circle_outlined,
                    ),
                    const SizedBox(height: 16),

                    // How Won Section
                    if (rackResult == 'win') ...[
                      _buildSectionTitle('💡 Cách thắng'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChoiceChip('Thắng sạch', howWon == 'clean', () => setSheetState(() => howWon = 'clean')),
                          _buildChoiceChip('Đối miss', howWon == 'opponent_miss', () => setSheetState(() => howWon = 'opponent_miss')),
                          _buildChoiceChip('Safety win', howWon == 'safety', () => setSheetState(() => howWon = 'safety')),
                          _buildChoiceChip('Đối lỗi', howWon == 'foul', () => setSheetState(() => howWon = 'foul')),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Quick Notes
                    _buildSectionTitle('📝 Ghi chú nhanh'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Lỗi lớn nhất (VD: Miss cú dễ)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) => biggestMistake = v,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Điểm mạnh (VD: Draw tốt)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (v) => biggestStrength = v,
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              countdownTimer?.cancel();
                              Navigator.pop(ctx);
                              _commitRackResult(
                                rackResult,
                                ballsPottedOnBreak: 0,
                                totalBallsPotted: 0,
                                longestRun: 0,
                                easyMissCount: 0,
                                hardMissCount: 0,
                                fouls: 0,
                                scratchErrorCount: 0,
                                positionErrorCount: 0,
                                safetyErrorCount: 0,
                                kickErrorCount: 0,
                                jumpErrorCount: 0,
                                bankShotCount: 0,
                                comboShotCount: 0,
                                caromShotCount: 0,
                                winOnBreak: false,
                                breakScratch: false,
                                howWon: null,
                                biggestMistake: '',
                                biggestStrength: '',
                                isBreakRack: isBreakRack,
                              );
                            },
                            child: const Text('Bỏ qua'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              countdownTimer?.cancel();
                              Navigator.pop(ctx);
                              _commitRackResult(
                                rackResult,
                                ballsPottedOnBreak: ballsPottedOnBreak,
                                totalBallsPotted: totalBallsPotted,
                                longestRun: longestRun,
                                easyMissCount: easyMissCount,
                                hardMissCount: hardMissCount,
                                fouls: fouls,
                                scratchErrorCount: scratchErrorCount,
                                positionErrorCount: positionErrorCount,
                                safetyErrorCount: safetyErrorCount,
                                kickErrorCount: kickErrorCount,
                                jumpErrorCount: jumpErrorCount,
                                bankShotCount: bankShotCount,
                                comboShotCount: comboShotCount,
                                caromShotCount: caromShotCount,
                                winOnBreak: winOnBreak,
                                breakScratch: breakScratch,
                                howWon: howWon,
                                biggestMistake: biggestMistake,
                                biggestStrength: biggestStrength,
                                isBreakRack: isBreakRack,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: const Text('💾 Lưu'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _commitRackResult(
    String result, {
    // Guard: Don't add rack if match is already over
    required int ballsPottedOnBreak,
    required int totalBallsPotted,
    required int longestRun,
    required int easyMissCount,
    required int hardMissCount,
    required int fouls,
    required int scratchErrorCount,
    required int positionErrorCount,
    required int safetyErrorCount,
    required int kickErrorCount,
    required int jumpErrorCount,
    required int bankShotCount,
    required int comboShotCount,
    required int caromShotCount,
    required bool winOnBreak,
    required bool breakScratch,
    String? howWon,
    String biggestMistake = '',
    String biggestStrength = '',
    required bool isBreakRack,
  }) {
    // Guard: Don't add rack if match is already over
    if (_playerScore >= _raceTo || _opponentScore >= _raceTo) {
      return; // Match already ended, ignore
    }

    final rack = Rack(
      id: const Uuid().v4(),
      rackNumber: _currentRack,
      result: result,
      resultBool: result == 'win',
      breakShot: isBreakRack,
      breakSuccess: result == 'win' && isBreakRack ? true : null,
      breakScratch: breakScratch,
      breakFoul: false,
      ballsPottedOnBreak: ballsPottedOnBreak,
      longestRun: longestRun,
      totalBallsPotted: totalBallsPotted,
      safetyPlays: 0,
      fouls: fouls,
      easyMissCount: easyMissCount,
      hardMissCount: hardMissCount,
      scratchErrorCount: scratchErrorCount,
      positionErrorCount: positionErrorCount,
      safetyErrorCount: safetyErrorCount,
      kickErrorCount: kickErrorCount,
      jumpErrorCount: jumpErrorCount,
      bankShotCount: bankShotCount,
      comboShotCount: comboShotCount,
      caromShotCount: caromShotCount,
      howWon: howWon,
      biggestMistake: biggestMistake.isEmpty ? null : biggestMistake,
      biggestStrength: biggestStrength.isEmpty ? null : biggestStrength,
      createdAt: DateTime.now(),
    );

    setState(() {
      _racks.add(rack);
      if (result == 'win') {
        _playerScore++;
      } else {
        _opponentScore++;
      }

      // Check if match is over
      if (_playerScore >= _raceTo || _opponentScore >= _raceTo) {
        _endMatch();
      } else {
        _currentRack++;
      }
    });
  }

  void _endMatchEarly() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết thúc sớm?'),
        content: const Text('Bạn có muốn kết thúc trận đấu không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endMatch();
            },
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
  }

  void _endMatch() {
    final winner = _playerScore >= _raceTo ? 'player' : 'opponent';
    final matchResult = _playerScore >= _raceTo ? 'win' : 'lose';

    // Update match with results
    if (_currentMatch != null) {
      final updatedMatch = _currentMatch!.copyWith(
        result: matchResult,
        winner: winner,
        playerScore: _playerScore,
        opponentScore: _opponentScore,
        racks: _racks,
        endTime: DateTime.now(),
      );
      ref.read(matchRepositoryProvider).saveMatch(updatedMatch);

      // PHASE 8: Analyze match and feed to Coach AI
      _analyzeAndFeedToCoach(updatedMatch);

      // Show match end dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                _playerScore >= _raceTo ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: _playerScore >= _raceTo ? Colors.amber : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(_playerScore >= _raceTo ? 'Chiến thắng!' : 'Trận đấu kết thúc'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_playerScore - $_opponentScore',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _playerScore >= _raceTo
                    ? 'Bạn đã thắng $_playerScore - $_opponentScore'
                    : 'Bạn đã thua $_playerScore - $_opponentScore',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Tổng ${_racks.length} racks',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _resetMatch();
              },
              child: const Text('Trận mới'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Navigate to match summary
                context.push('/play/summary/${_currentMatch!.id}');
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text('Xem chi tiết'),
            ),
          ],
        ),
      );
    }
  }

  /// PHASE 8: Analyze match data and feed to Coach AI
  Future<void> _analyzeAndFeedToCoach(Match match) async {
    if (match.racks.isEmpty) return;

    try {
      // 1. Analyze the racks
      final analysisService = MatchAnalysisService();
      final analysis = analysisService.analyzeRacks(match.id, match.racks);

      // 2. Update Coach state with the analysis
      ref.read(latestMatchAnalysisProvider.notifier).state = analysis;

      // 3. Update Coach Brain with match analysis
      final coachNotifier = ref.read(coachStateProvider.notifier);
      await coachNotifier.updateWithMatchAnalysis(analysis);

      // 4. Get recommendations for feedback
      final recommendations = analysisService.getRecommendations(analysis);

      // Show brief feedback toast if there are recommendations
      if (recommendations.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coach đã phân tích trận đấu!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Xem',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to Coach
                context.push('/coach');
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Silently fail - match recording is more important
      debugPrint('Failed to analyze match for Coach: $e');
    }
  }

  void _resetMatch() {
    setState(() {
      _currentMatch = null;
      _currentRack = 1;
      _playerScore = 0;
      _opponentScore = 0;
      _racks = [];
    });
    // Sprint-8: Clear match analysis when resetting
    ref.read(coachStateProvider.notifier).clearMatchAnalysis();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            iconSize: 20,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, String subtitle, bool value, {required Function(bool?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Rest of the MatchRecordingScreen remains the same
  // (Setup form, match UI, etc.)

  // ==========================================================================
  // RACK HISTORY - Expandable with Edit
  // ==========================================================================

  Widget _buildRackHistory() {
    if (_racks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: const Icon(Icons.history, color: AppTheme.primaryGreen),
        title: Text(
          'Lịch sử Rack (${_racks.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$_playerScore Win - $_opponentScore Lose',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        children: _racks.asMap().entries.map((entry) {
          final index = entry.key;
          final rack = entry.value;
          return _buildRackHistoryItem(rack, index);
        }).toList(),
      ),
    );
  }

  Widget _buildRackHistoryItem(Rack rack, int index) {
    final isWin = rack.resultBool;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isWin ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWin ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isWin ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${rack.rackNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(
              isWin ? Icons.check_circle : Icons.cancel,
              color: isWin ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isWin ? 'WIN' : 'LOSE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWin ? Colors.green : Colors.red,
              ),
            ),
            if (rack.breakShot) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BREAK',
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
        subtitle: _buildRackStats(rack),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => _editRack(rack, index),
        ),
        onTap: () => _showRackDetail(rack),
      ),
    );
  }

  Widget _buildRackStats(Rack rack) {
    final stats = <String>[];
    if (rack.totalBallsPotted > 0) stats.add('${rack.totalBallsPotted} balls');
    if (rack.longestRun > 0) stats.add('Run: ${rack.longestRun}');
    if (rack.fouls > 0) stats.add('Fouls: ${rack.fouls}');
    if (rack.easyMissCount > 0) stats.add('Miss: ${rack.easyMissCount}');
    if (rack.bankShotCount > 0) stats.add('Bank: ${rack.bankShotCount}');

    return Text(
      stats.isEmpty ? 'Không có data' : stats.join(' • '),
      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
    );
  }

  void _editRack(Rack rack, int index) {
    // Show edit sheet with current rack data
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _RackEditSheet(
        rack: rack,
        onSave: (updatedRack) {
          setState(() {
            _racks[index] = updatedRack;
            // Recalculate scores
            _playerScore = _racks.where((r) => r.resultBool).length;
            _opponentScore = _racks.where((r) => !r.resultBool).length;
          });
        },
        onDelete: () {
          setState(() {
            _racks.removeAt(index);
            _playerScore = _racks.where((r) => r.resultBool).length;
            _opponentScore = _racks.where((r) => !r.resultBool).length;
          });
        },
      ),
    );
  }

  void _showRackDetail(Rack rack) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text('Rack ${rack.rackNumber}'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: rack.resultBool ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rack.resultBool ? 'WIN' : 'LOSE',
                style: TextStyle(
                  color: rack.resultBool ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rack.breakShot) _buildDetailRow('Break', rack.breakSuccess == true ? 'Win' : 'Lose'),
              _buildDetailRow('Tổng bi vào', '${rack.totalBallsPotted}'),
              _buildDetailRow('Bi từ break', '${rack.ballsPottedOnBreak}'),
              _buildDetailRow('Run dài nhất', '${rack.longestRun}'),
              const Divider(),
              _buildDetailRow('Miss dễ', '${rack.easyMissCount}'),
              _buildDetailRow('Miss khó', '${rack.hardMissCount}'),
              _buildDetailRow('Scratch', '${rack.scratchErrorCount}'),
              _buildDetailRow('Lỗi position', '${rack.positionErrorCount}'),
              _buildDetailRow('Lỗi safety', '${rack.safetyErrorCount}'),
              _buildDetailRow('Lỗi kick', '${rack.kickErrorCount}'),
              _buildDetailRow('Cue nhảy', '${rack.jumpErrorCount}'),
              _buildDetailRow('Fouls', '${rack.fouls}'),
              const Divider(),
              _buildDetailRow('Bank shots', '${rack.bankShotCount}'),
              _buildDetailRow('Combo', '${rack.comboShotCount}'),
              _buildDetailRow('Carom', '${rack.caromShotCount}'),
              if (rack.howWon != null) _buildDetailRow('Cách thắng', rack.howWon!),
              if (rack.biggestMistake != null && rack.biggestMistake!.isNotEmpty)
                _buildDetailRow('Lỗi lớn', rack.biggestMistake!),
              if (rack.biggestStrength != null && rack.biggestStrength!.isNotEmpty)
                _buildDetailRow('Điểm mạnh', rack.biggestStrength!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================================================
// RACK EDIT SHEET
// ==========================================================================

class _RackEditSheet extends StatefulWidget {
  final Rack rack;
  final Function(Rack) onSave;
  final VoidCallback onDelete;

  const _RackEditSheet({
    required this.rack,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_RackEditSheet> createState() => _RackEditSheetState();
}

class _RackEditSheetState extends State<_RackEditSheet> {
  late int _totalBallsPotted;
  late int _longestRun;
  late int _easyMissCount;
  late int _hardMissCount;
  late int _fouls;
  late int _scratchErrorCount;
  late int _positionErrorCount;
  late int _safetyErrorCount;
  late int _kickErrorCount;
  late int _jumpErrorCount;
  late int _bankShotCount;
  late int _comboShotCount;
  late int _caromShotCount;
  late bool _resultBool;

  @override
  void initState() {
    super.initState();
    _totalBallsPotted = widget.rack.totalBallsPotted;
    _longestRun = widget.rack.longestRun;
    _easyMissCount = widget.rack.easyMissCount;
    _hardMissCount = widget.rack.hardMissCount;
    _fouls = widget.rack.fouls;
    _scratchErrorCount = widget.rack.scratchErrorCount;
    _positionErrorCount = widget.rack.positionErrorCount;
    _safetyErrorCount = widget.rack.safetyErrorCount;
    _kickErrorCount = widget.rack.kickErrorCount;
    _jumpErrorCount = widget.rack.jumpErrorCount;
    _bankShotCount = widget.rack.bankShotCount;
    _comboShotCount = widget.rack.comboShotCount;
    _caromShotCount = widget.rack.caromShotCount;
    _resultBool = widget.rack.resultBool;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Sửa Rack',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Result toggle
            Row(
              children: [
                const Text('Kết quả:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('WIN'),
                  selected: _resultBool,
                  selectedColor: Colors.green.shade200,
                  onSelected: (v) => setState(() => _resultBool = v),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('LOSE'),
                  selected: !_resultBool,
                  selectedColor: Colors.red.shade200,
                  onSelected: (v) => setState(() => _resultBool = !v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats counters
            _buildCounterRow('Tổng bi vào', _totalBallsPotted, (v) => setState(() => _totalBallsPotted = v)),
            _buildCounterRow('Run dài nhất', _longestRun, (v) => setState(() => _longestRun = v)),
            _buildCounterRow('Miss dễ', _easyMissCount, (v) => setState(() => _easyMissCount = v)),
            _buildCounterRow('Miss khó', _hardMissCount, (v) => setState(() => _hardMissCount = v)),
            _buildCounterRow('Scratch', _scratchErrorCount, (v) => setState(() => _scratchErrorCount = v)),
            _buildCounterRow('Lỗi position', _positionErrorCount, (v) => setState(() => _positionErrorCount = v)),
            _buildCounterRow('Lỗi safety', _safetyErrorCount, (v) => setState(() => _safetyErrorCount = v)),
            _buildCounterRow('Lỗi kick', _kickErrorCount, (v) => setState(() => _kickErrorCount = v)),
            _buildCounterRow('Fouls', _fouls, (v) => setState(() => _fouls = v)),
            _buildCounterRow('Bank shots', _bankShotCount, (v) => setState(() => _bankShotCount = v)),
            _buildCounterRow('Combo', _comboShotCount, (v) => setState(() => _comboShotCount = v)),
            _buildCounterRow('Carom', _caromShotCount, (v) => setState(() => _caromShotCount = v)),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final updatedRack = widget.rack.copyWith(
                        resultBool: _resultBool,
                        totalBallsPotted: _totalBallsPotted,
                        longestRun: _longestRun,
                        easyMissCount: _easyMissCount,
                        hardMissCount: _hardMissCount,
                        fouls: _fouls,
                        scratchErrorCount: _scratchErrorCount,
                        positionErrorCount: _positionErrorCount,
                        safetyErrorCount: _safetyErrorCount,
                        kickErrorCount: _kickErrorCount,
                        jumpErrorCount: _jumpErrorCount,
                        bankShotCount: _bankShotCount,
                        comboShotCount: _comboShotCount,
                        caromShotCount: _caromShotCount,
                        result: _resultBool ? 'win' : 'lose',
                      );
                      Navigator.pop(context);
                      widget.onSave(updatedRack);
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
