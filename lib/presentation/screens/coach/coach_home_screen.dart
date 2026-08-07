// ============================================================================
// COACH HOME SCREEN - Phase 7B.1
// ONE Priority Coach Home - The App Dashboard
//
// Principle: ONE Priority Only. Everything else is secondary.
// Coach Voice: Natural, like a real coach, not AI.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/player_provider.dart' as player;
import '../../../core/services/coach_voice_service.dart';
import '../../widgets/coach/recommendation_card.dart';
import '../../widgets/coach/continue_session_card.dart';
import '../../widgets/coach/coach_empty_state.dart';
import '../../widgets/coach/coach_loading_state.dart';
import '../../widgets/coach/coach_error_state.dart';
import '../training/drill_detail_screen.dart';

/// Coach Home Screen - App Dashboard
/// ONE Priority Only: User opens app and knows what to do in 5 seconds.
class CoachHomeScreen extends ConsumerStatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  ConsumerState<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends ConsumerState<CoachHomeScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load data from providers
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch Coach State from Brain
    final coachState = ref.watch(coachStateProvider);
    final coachVoice = CoachVoiceService();

    // Loading state
    if (coachState.isLoading || _isLoading) {
      return const CoachLoadingState();
    }

    // Error state
    if (coachState.error != null || _error != null) {
      return CoachErrorState(
        onRetry: _loadData,
        error: coachState.error ?? _error!,
      );
    }

    return _buildCoachHome(context, coachState, coachVoice);
  }

  Widget _buildCoachHome(BuildContext context, CoachState coachState, CoachVoiceService coachVoice) {
    // Get player name from provider
    final playerAsync = ref.watch(player.playerProvider);
    final playerName = playerAsync.whenOrNull(
      data: (player) => player?.name,
    );

    // Get real recommendation from Coach Brain
    final recommendation = coachState.currentRecommendation;

    // Check data sufficiency from PlayerIntelligence
    final hasEnoughData = coachState.playerIntelligence.practicePatterns.totalSessions > 0;

    // Check for interrupted session
    final interruptedSession = _checkInterruptedSession();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                _buildGreeting(context, playerName),
                const SizedBox(height: 24),

                // MAIN CONTENT: ONE Priority Only (from Coach Brain)
                if (!hasEnoughData)
                  CoachEmptyState(
                    onStartDrill: () => _navigateToDrill(context, 'straight_shot'),
                  )
                else if (interruptedSession != null)
                  ContinueSessionCard(
                    session: interruptedSession,
                    coachVoice: coachVoice,
                    onContinue: () => _navigateToSession(context, interruptedSession),
                    onStartNew: () => _navigateToDrill(context, recommendation?.drillCode ?? 'straight_shot'),
                  )
                else if (recommendation != null)
                  RecommendationCard(
                    recommendation: recommendation,
                    coachVoice: coachVoice,
                    onStart: () => _navigateToDrill(context, recommendation.drillCode),
                  ),

                const SizedBox(height: 32),

                // Secondary: Quick Actions
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String? name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buổi sáng tốt lành';
    } else if (hour < 17) {
      greeting = 'Buổi chiều vui vẻ';
    } else {
      greeting = 'Buổi tối tốt lành';
    }

    final displayName = name ?? 'bạn';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xin chào $displayName!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 4),
        Text(
          greeting,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoặc',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.sports,
                label: 'Đấu trận',
                onTap: () {
                  // Navigate to match recording
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Hỏi Coach',
                onTap: () {
                  // Navigate to coach chat
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: 'Lịch sử',
                onTap: () {
                  // Navigate to timeline
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Check if there's an interrupted session (from Coach Brain)
  Map<String, dynamic>? _checkInterruptedSession() {
    final coachNotifier = ref.read(coachStateProvider.notifier);
    final sessionMemory = coachNotifier.sessionMemory;
    final memory = sessionMemory;

    if (memory.hasInterruptedSession && memory.activeDrillCode != null) {
      return {
        'drillCode': memory.activeDrillCode,
        'drillName': memory.activeDrillName ?? memory.activeDrillCode,
        'progress': memory.progress ?? 0,
        'lastScore': memory.lastScore,
        'lastSessionDate': memory.lastSessionDate,
      };
    }
    return null;
  }

  void _navigateToDrill(BuildContext context, String drillCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrillDetailScreen(drillCode: drillCode),
      ),
    );
  }

  void _navigateToSession(BuildContext context, Map<String, dynamic> session) {
    final drillCode = session['drillCode'] as String?;
    if (drillCode == null) return;

    // Navigate to continue the drill
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrillDetailScreen(drillCode: drillCode),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
