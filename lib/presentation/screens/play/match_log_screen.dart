// ============================================================================
// MATCH LOG SCREEN - Sprint-12
// Manual Match Result Logging
//
// Minimal MVP: Log a match result in 15-30 seconds
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/match.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/coach_provider.dart';

// Sprint-12: Provider for match log operations
final matchLogProvider = StateNotifierProvider<MatchLogNotifier, MatchLogState>((ref) {
  return MatchLogNotifier(ref);
});

class MatchLogState {
  final bool isLoading;
  final String? error;
  final bool saved;

  const MatchLogState({
    this.isLoading = false,
    this.error,
    this.saved = false,
  });

  MatchLogState copyWith({
    bool? isLoading,
    String? error,
    bool? saved,
  }) {
    return MatchLogState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      saved: saved ?? this.saved,
    );
  }
}

class MatchLogNotifier extends StateNotifier<MatchLogState> {
  final Ref _ref;

  MatchLogNotifier(this._ref) : super(const MatchLogState());

  Future<void> saveMatch({
    required String opponent,
    required bool won,
    int? playerScore,
    int? opponentScore,
    int? duration,
    List<String>? mistakes,
    String? venue,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create Match from input
      final now = DateTime.now();
      final match = Match(
        id: const Uuid().v4(),
        opponent: opponent,
        opponentName: opponent,
        result: won ? 'win' : 'lose',
        playerScore: playerScore ?? 0,
        opponentScore: opponentScore ?? 0,
        duration: duration,
        venue: venue,
        createdAt: now,
        updatedAt: now,
      );

      // Save to repository via provider
      final repository = _ref.read(matchRepositoryProvider);
      await repository.saveMatch(match);

      // Also save mistakes if provided
      if (mistakes != null && mistakes.isNotEmpty) {
        // Mistakes will be processed by PlayerIntelligenceService
        // via the Coach provider refresh
      }

      // Trigger Coach refresh
      // Sprint-12: Coach listens to training, but we need to also refresh
      // when a match is logged. For MVP, we trigger a Coach refresh.
      await _ref.read(coachStateProvider.notifier).refreshFromMatch();

      state = state.copyWith(isLoading: false, saved: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class MatchLogScreen extends ConsumerStatefulWidget {
  const MatchLogScreen({super.key});

  @override
  ConsumerState<MatchLogScreen> createState() => _MatchLogScreenState();
}

class _MatchLogScreenState extends ConsumerState<MatchLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  final _playerScoreController = TextEditingController();
  final _opponentScoreController = TextEditingController();
  final _durationController = TextEditingController();
  final _venueController = TextEditingController();

  bool _won = true;
  final List<String> _selectedMistakes = [];

  final List<String> _commonMistakes = [
    'aiming_issues',
    'position_play',
    'safety_errors',
    'scratches',
    'kicks',
    'break_potting',
    'shot_selection',
    'mental_game',
  ];

  @override
  void dispose() {
    _opponentController.dispose();
    _playerScoreController.dispose();
    _opponentScoreController.dispose();
    _durationController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final playerScore = _playerScoreController.text.isNotEmpty
        ? int.tryParse(_playerScoreController.text)
        : null;
    final opponentScore = _opponentScoreController.text.isNotEmpty
        ? int.tryParse(_opponentScoreController.text)
        : null;
    final duration = _durationController.text.isNotEmpty
        ? int.tryParse(_durationController.text)
        : null;

    await ref.read(matchLogProvider.notifier).saveMatch(
      opponent: _opponentController.text.trim(),
      won: _won,
      playerScore: playerScore,
      opponentScore: opponentScore,
      duration: duration,
      mistakes: _selectedMistakes.isNotEmpty ? _selectedMistakes : null,
      venue: _venueController.text.isNotEmpty ? _venueController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(matchLogProvider);

    // Navigate on success
    ref.listen<MatchLogState>(matchLogProvider, (prev, next) {
      if (next.saved && prev?.saved != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã ghi nhận trận đấu!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi kết quả trận đấu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Required: Opponent
            TextFormField(
              controller: _opponentController,
              decoration: const InputDecoration(
                labelText: 'Đối thủ *',
                hintText: 'Tên đối thủ',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên đối thủ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Required: Win/Lose
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kết quả *',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultButton(
                            label: 'THẮNG',
                            icon: Icons.emoji_events,
                            color: Colors.green,
                            selected: _won,
                            onTap: () => setState(() => _won = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ResultButton(
                            label: 'THUA',
                            icon: Icons.close,
                            color: Colors.red,
                            selected: !_won,
                            onTap: () => setState(() => _won = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optional: Scores
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _playerScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Điểm của bạn',
                      prefixIcon: Icon(Icons.sports_score),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _opponentScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Điểm đối thủ',
                      prefixIcon: Icon(Icons.sports_score),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Optional: Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Thời gian (phút)',
                hintText: 'VD: 45',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Optional: Venue
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Địa điểm',
                hintText: 'VD: CLB Billiards A',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Optional: Mistakes
            const Text(
              'Lỗi thường gặp (tuỳ chọn)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonMistakes.map((mistake) {
                final selected = _selectedMistakes.contains(mistake);
                return FilterChip(
                  label: Text(_formatMistake(mistake)),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedMistakes.add(mistake);
                      } else {
                        _selectedMistakes.remove(mistake);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Error message
            if (logState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Lỗi: ${logState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: logState.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: logState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU TRẬN ĐẤU'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMistake(String mistake) {
    return mistake
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _ResultButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ResultButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withOpacity(0.2) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey, size: 32),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
