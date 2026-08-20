// ============================================================================
// COACH HOME SCREEN - Phase 7B.1 / Phase 8
// ONE Priority Coach Home - The App Dashboard
//
// Principle: ONE Priority Only. Everything else is secondary.
// Coach Voice: Natural, like a real coach, not AI.
// Phase 8: Added "Từ trận đấu gần nhất" section
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/player_provider.dart' as player;
import '../../../core/services/coach_voice_service.dart';
import '../../../core/models/match_stats.dart';
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

    // PHASE 8: Get match analysis
    final matchAnalysis = ref.watch(latestMatchAnalysisProvider);
    final matchInsight = ref.watch(coachMatchInsightProvider);

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

                // PHASE 8: Match Analysis Section
                if (matchAnalysis != null) ...[
                  _buildMatchAnalysisSection(context, matchAnalysis, matchInsight),
                  const SizedBox(height: 24),
                ],

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
                onTap: () => context.push('/play/recording'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Hỏi Coach',
                onTap: () => context.push('/coach/chat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: 'Lịch sử',
                onTap: () => context.push('/training/timeline'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // PHASE 8: MATCH ANALYSIS SECTION
  // ==========================================================================

  /// Build the "Từ trận đấu gần nhất" section
  Widget _buildMatchAnalysisSection(BuildContext context, MatchAnalysis analysis, String? insight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Từ trận đấu gần nhất',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coach Insight
                if (insight != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 20, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Win Rate',
                        '${analysis.winRate.toStringAsFixed(0)}%',
                        Icons.emoji_events,
                        analysis.winRate >= 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Long Run',
                        '${analysis.longestRun} bi',
                        Icons.trending_up,
                        AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tổng bi',
                        '${analysis.totalBallsPotted}',
                        Icons.circle,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Racks',
                        '${analysis.totalRacks}',
                        Icons.layers,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                // Strengths
                if (analysis.strengths.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Điểm mạnh',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: analysis.strengths.map<Widget>((s) {
                      return Chip(
                        avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green.shade50,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                // Weaknesses
                if (analysis.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Cần cải thiện',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: analysis.commonMistakes.map<Widget>((m) {
                      return Chip(
                        avatar: const Icon(Icons.warning, size: 16, color: Colors.orange),
                        label: Text(m, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange.shade50,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                // Recommendations
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/coach/analysis'),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Xem đề xuất từ Coach'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
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
