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

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
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

      // Trigger Coach refresh
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
          SnackBar(
            content: Text('Đã ghi nhận trận đấu!'),
            backgroundColor: AppColors.success,
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
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Required: Opponent
            TextFormField(
              controller: _opponentController,
              decoration: InputDecoration(
                labelText: 'Đối thủ *',
                hintText: 'Tên đối thủ',
                prefixIcon: Icon(Icons.person, color: AppColors.accent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên đối thủ';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),

            // Required: Win/Lose
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kết quả *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultButton(
                          label: 'THẮNG',
                          icon: Icons.emoji_events,
                          color: AppColors.success,
                          selected: _won,
                          onTap: () => setState(() => _won = true),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ResultButton(
                          label: 'THUA',
                          icon: Icons.close,
                          color: AppColors.error,
                          selected: !_won,
                          onTap: () => setState(() => _won = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Optional: Scores
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _playerScoreController,
                    decoration: InputDecoration(
                      labelText: 'Điểm của bạn',
                      prefixIcon: Icon(Icons.sports_score, color: AppColors.accent),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _opponentScoreController,
                    decoration: InputDecoration(
                      labelText: 'Điểm đối thủ',
                      prefixIcon: Icon(Icons.sports_score, color: AppColors.accent),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Optional: Duration
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'Thời gian (phút)',
                hintText: 'VD: 45',
                prefixIcon: Icon(Icons.timer, color: AppColors.accent),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.lg),

            // Optional: Venue
            TextFormField(
              controller: _venueController,
              decoration: InputDecoration(
                labelText: 'Địa điểm',
                hintText: 'VD: CLB Billiards A',
                prefixIcon: Icon(Icons.location_on, color: AppColors.accent),
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Optional: Mistakes
            Text(
              'Lỗi thường gặp (tùy chọn)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _commonMistakes.map((mistake) {
                final selected = _selectedMistakes.contains(mistake);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedMistakes.remove(mistake);
                      } else {
                        _selectedMistakes.add(mistake);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent.withValues(alpha: 0.12) : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: selected ? AppColors.accent : AppColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      _formatMistake(mistake),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        color: selected ? AppColors.accent : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.xxl),

            // Error message
            if (logState.error != null)
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Lỗi: ${logState.error}',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // Save button
            _SaveButton(
              onPressed: logState.isLoading ? null : _save,
              isLoading: logState.isLoading,
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

class _ResultButton extends StatefulWidget {
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
  State<_ResultButton> createState() => _ResultButtonState();
}

class _ResultButtonState extends State<_ResultButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.selected ? widget.color.withValues(alpha: 0.12) : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.selected ? widget.color : AppColors.lightBorder,
              width: widget.selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.selected ? widget.color : AppColors.lightTextSecondary, size: 32),
              SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.selected ? widget.color : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SaveButton({required this.onPressed, required this.isLoading});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'LƯU TRẬN ĐẤU',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
