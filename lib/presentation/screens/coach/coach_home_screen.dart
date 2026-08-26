// ============================================================================
// COACH HOME SCREEN - Phase 7B.1 / Phase 8
// ONE Priority Coach Home - The App Dashboard
// Redesigned with Minimalist Luxury Design System
//
// Principle: ONE Priority Only. Everything else is secondary.
// Coach Voice: Natural, like a real coach, not AI.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
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
    final coachState = ref.watch(coachStateProvider);
    final coachVoice = CoachVoiceService();
    final brightness = Theme.of(context).brightness;

    if (coachState.isLoading || _isLoading) {
      return const CoachLoadingState();
    }

    if (coachState.error != null || _error != null) {
      return CoachErrorState(
        onRetry: _loadData,
        error: coachState.error ?? _error!,
      );
    }

    return _buildCoachHome(context, coachState, coachVoice, brightness);
  }

  Widget _buildCoachHome(BuildContext context, CoachState coachState, CoachVoiceService coachVoice, Brightness brightness) {
    final playerAsync = ref.watch(player.playerProvider);
    final playerName = playerAsync.whenOrNull(
      data: (player) => player?.name,
    );

    final recommendation = coachState.currentRecommendation;
    final hasEnoughData = coachState.playerIntelligence.practicePatterns.totalSessions > 0;
    final interruptedSession = _checkInterruptedSession();
    final matchAnalysis = ref.watch(latestMatchAnalysisProvider);
    final matchInsight = ref.watch(coachMatchInsightProvider);

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(context, playerName, brightness),
                const SizedBox(height: AppSpacing.xxl),

                if (matchAnalysis != null) ...[
                  _buildMatchAnalysisSection(context, matchAnalysis, matchInsight, brightness),
                  const SizedBox(height: AppSpacing.xxl),
                ],

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

                const SizedBox(height: AppSpacing.xxl),
                _buildQuickActions(context, brightness),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String? name, Brightness brightness) {
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
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(brightness),
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 4),
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary(brightness),
          ),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoặc',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(brightness),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.sports,
                label: 'Đấu trận',
                onTap: () => context.push('/play/recording'),
                brightness: brightness,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Hỏi Coach',
                onTap: () => context.push('/coach/chat'),
                brightness: brightness,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.history,
                label: 'Lịch sử',
                onTap: () => context.push('/training/timeline'),
                brightness: brightness,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchAnalysisSection(BuildContext context, MatchRackAnalysis analysis, String? insight, Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.md(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: AppColors.accentColor(brightness), size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Từ trận đấu gần nhất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentColor(brightness),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (insight != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor(brightness).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 20, color: AppColors.accentColor(brightness)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            insight,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary(brightness),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Win Rate',
                        '${analysis.winRate.toStringAsFixed(0)}%',
                        Icons.emoji_events,
                        analysis.winRate >= 50 ? AppColors.success : AppColors.warning,
                        brightness,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Long Run',
                        '${analysis.longestRun} bi',
                        Icons.trending_up,
                        AppColors.accentColor(brightness),
                        brightness,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Tổng bi',
                        '${analysis.totalBallsPotted}',
                        Icons.circle,
                        Colors.blue,
                        brightness,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Racks',
                        '${analysis.totalRacks}',
                        Icons.layers,
                        Colors.purple,
                        brightness,
                      ),
                    ),
                  ],
                ),

                if (analysis.strengths.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Điểm mạnh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: analysis.strengths.map<Widget>((s) {
                      return Chip(
                        avatar: Icon(Icons.check_circle, size: 16, color: AppColors.success),
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.success.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                if (analysis.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Cần cải thiện',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: analysis.commonMistakes.map<Widget>((m) {
                      return Chip(
                        avatar: Icon(Icons.warning, size: 16, color: AppColors.warning),
                        label: Text(m, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/coach/analysis'),
                    icon: Icon(Icons.lightbulb_outline, color: AppColors.accentColor(brightness)),
                    label: Text('Xem đề xuất từ Coach', style: TextStyle(color: AppColors.accentColor(brightness))),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentColor(brightness),
                      side: BorderSide(color: AppColors.accentColor(brightness)),
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
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

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(brightness),
            ),
          ),
        ],
      ),
    );
  }

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
  final Brightness brightness;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accentColor(brightness)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(brightness),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
