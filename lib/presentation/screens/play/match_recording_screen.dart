import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/match.dart';

class MatchRecordingScreen extends StatefulWidget {
  const MatchRecordingScreen({super.key});

  @override
  State<MatchRecordingScreen> createState() => _MatchRecordingScreenState();
}

class _MatchRecordingScreenState extends State<MatchRecordingScreen> {
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

  void _startMatch() {
    setState(() {
      _currentMatch = Match(
        id: const Uuid().v4(),
        opponent: _opponentController.text.isNotEmpty ? _opponentController.text : null,
        raceTo: _raceTo,
        result: 'in_progress',
        matchType: _matchType,
        opponentLevel: _opponentLevel,
        tableCondition: _tableCondition,
        environment: _environment,
        startTime: DateTime.now(),
        createdAt: DateTime.now(),
      );
      _currentRack = 1;
      _playerScore = 0;
      _opponentScore = 0;
      _racks = [];
    });
  }

  void _recordRackResult(String result) {
    setState(() {
      final rack = Rack(
        rackNumber: _currentRack,
        result: result,
        totalBallsPotted: result == 'win' ? 8 : 0, // Simplified
      );
      _racks.add(rack);

      if (result == 'win') {
        _playerScore++;
      } else {
        _opponentScore++;
      }

      // Check if match ended
      if (_playerScore >= _raceTo || _opponentScore >= _raceTo) {
        _endMatch();
      } else {
        _currentRack++;
      }
    });
  }

  void _endMatch() {
    if (_currentMatch == null) return;

    setState(() {
      _currentMatch = _currentMatch!.copyWith(
        endTime: DateTime.now(),
        playerScore: _playerScore,
        opponentScore: _opponentScore,
        result: _playerScore > _opponentScore
            ? 'win'
            : _playerScore < _opponentScore
                ? 'lose'
                : 'draw',
        racks: _racks,
      );
    });

    _showMatchSummary();
  }

  void _showMatchSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MatchSummarySheet(
        match: _currentMatch!,
        onSave: () {
          Navigator.pop(context);
          _resetMatch();
        },
        onDiscard: () {
          Navigator.pop(context);
          _resetMatch();
        },
      ),
    );
  }

  void _resetMatch() {
    setState(() {
      _currentMatch = null;
      _currentRack = 1;
      _playerScore = 0;
      _opponentScore = 0;
      _racks = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMatch == null) {
      return _buildSetupScreen();
    }
    return _buildRecordingScreen();
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Match'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blue.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sports_cricket, color: Colors.white, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Match Recording',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Ghi lại trận đấu của bạn',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 24),

              // Opponent
              TextFormField(
                controller: _opponentController,
                decoration: InputDecoration(
                  labelText: 'Đối thủ (tùy chọn)',
                  hintText: 'Nhập tên đối thủ',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Race to
              Text(
                'Race to',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 3, 5, 7].map((value) {
                  return ChoiceChip(
                    label: Text('$value'),
                    selected: _raceTo == value,
                    onSelected: (selected) {
                      if (selected) setState(() => _raceTo = value);
                    },
                  );
                }).toList(),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // Match type
              Text(
                'Loại trận đấu',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ('friendly', 'Friendly'),
                  ('practice', 'Practice'),
                  ('tournament', 'Tournament'),
                ].map((item) {
                  return ChoiceChip(
                    label: Text(item.$2),
                    selected: _matchType == item.$1,
                    onSelected: (selected) {
                      if (selected) setState(() => _matchType = item.$1);
                    },
                  );
                }).toList(),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // Table condition
              Text(
                'Điều kiện bàn',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ('familiar', 'Quen thuộc'),
                  ('unfamiliar', 'Lạ'),
                ].map((item) {
                  return ChoiceChip(
                    label: Text(item.$2),
                    selected: _tableCondition == item.$1,
                    onSelected: (selected) {
                      if (selected) setState(() => _tableCondition = item.$1);
                    },
                  );
                }).toList(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              // Environment
              Text(
                'Môi trường',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ('home', 'Nhà'),
                  ('club', 'CLB'),
                  ('tournament', 'Giải đấu'),
                ].map((item) {
                  return ChoiceChip(
                    label: Text(item.$2),
                    selected: _environment == item.$1,
                    onSelected: (selected) {
                      if (selected) setState(() => _environment = item.$1);
                    },
                  );
                }).toList(),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 32),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startMatch,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Bắt đầu (Race to $_raceTo)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kết thúc trận đấu?'),
                  content: const Text('Bạn có muốn kết thúc trận đấu không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _endMatch();
                      },
                      child: const Text('Kết thúc'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('End'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Player score
                      Column(
                        children: [
                          Text(
                            'BẠN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_playerScore',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'vs',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      // Opponent score
                      Column(
                        children: [
                          Text(
                            _opponentController.text.isNotEmpty
                                ? _opponentController.text.toUpperCase()
                                : 'ĐỐI THỦ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_opponentScore',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rack $_currentRack • Race to $_raceTo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 32),

            // Instruction
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sau khi hoàn thành rack, chọn kết quả:',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            // Result buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordRackResult('win'),
                    icon: const Icon(Icons.emoji_events),
                    label: const Column(
                      children: [
                        Text('WIN', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Thắng rack', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _recordRackResult('lose'),
                    icon: const Icon(Icons.sentiment_dissatisfied),
                    label: const Column(
                      children: [
                        Text('LOSE', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Thua rack', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const Spacer(),

            // Rack history
            if (_racks.isNotEmpty) ...[
              Text(
                'Lịch sử Rack',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _racks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final rack = _racks[index];
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: rack.result == 'win'
                            ? AppTheme.primaryGreen
                            : Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MatchSummarySheet extends StatelessWidget {
  final Match match;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const _MatchSummarySheet({
    required this.match,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = match.result == 'win';
    final duration = match.duration;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result
          Icon(
            isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 64,
            color: isWin ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isWin ? 'Chiến thắng!' : 'Thất bại',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isWin ? AppTheme.primaryGreen : Colors.grey,
                ),
          ),
          const SizedBox(height: 24),

          // Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${match.playerScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isWin ? AppTheme.primaryGreen : Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Text(
                '${match.opponentScore}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isWin ? Colors.grey : Colors.red.shade400,
                ),
              ),
            ],
          ),

          if (match.opponent != null) ...[
            const SizedBox(height: 8),
            Text(
              'vs ${match.opponent}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],

          const SizedBox(height: 24),

          // Stats
          if (duration != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${duration.inMinutes} phút',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDiscard,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Xóa'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
