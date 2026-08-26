import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../core/providers/dashboard_provider.dart';
import '../../../core/services/coach_service.dart';
import '../../../core/services/coach_types.dart';
import '../../../knowledge/drill_code_bridge.dart';

/// AI Home - Dashboard chính
/// Trả lời: "Hôm nay tôi nên làm gì?"
/// Context thay đổi theo hành động người dùng
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final learningPathAsync = ref.watch(learningPathProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // Context-based content
              _buildContextContent(context, ref, dashboardState, learningPathAsync),
              const SizedBox(height: 24),

              // Today's Goal - Luôn hiển thị
              _buildTodayGoalSection(context, ref),
              const SizedBox(height: 24),

              // Progress - Luôn hiển thị
              _buildProgressSection(context, ref),
              const SizedBox(height: 24),

              // Strength/Weakness Analysis - Mới
              _buildStrengthWeaknessSection(context, ref),
              const SizedBox(height: 24),

              // Recent Activity Feed - Mới
              _buildRecentActivitySection(context, ref),
              const SizedBox(height: 24),

              // Quick Actions - Luôn hiển thị
              _buildQuickActionsSection(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PoolOS',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
              ),
            ],
          ),
        ),
        // Avatar - Tap to go to Profile
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildContextContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState dashboardState,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
  ) {
    switch (dashboardState.context) {
      case DashboardContext.afterMatch:
        return _buildAfterMatchCard(context, ref, dashboardState);
      case DashboardContext.afterDrill:
        return _buildAfterDrillCard(context, ref, dashboardState);
      case DashboardContext.afterKnowledge:
        return _buildAfterKnowledgeCard(context, ref, dashboardState);
      case DashboardContext.streakWarning:
        return _buildStreakWarningCard(context, ref);
      case DashboardContext.normal:
      default:
        return _buildAICoachSection(context, ref, learningPathAsync);
    }
  }

  /// AI Coach - Context mặc định
  Widget _buildAICoachSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<LearningPathItem>> learningPathAsync,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Coach header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Coach',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Greeting message
          Text(
            _getCoachGreeting(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations
          learningPathAsync.when(
            data: (path) {
              if (path.isEmpty) {
                return _buildEmptyRecommendations();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hôm nay nên tập:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...path.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_right,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.drillNameVi}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => _buildEmptyRecommendations(),
          ),

          const SizedBox(height: 20),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final path = learningPathAsync.valueOrNull;
                if (path != null && path.isNotEmpty) {
                  final first = path.first;
                  // Sprint-18 Part 1: Resolve V1 drill codes (e.g., STRAIGHT_POT)
                  // to V2 DrillLibrary codes (e.g., STRAIGHT_NEAR) before
                  // navigating to the session screen.
                  final resolvedCode = resolveDrillCode(first.drillCode) ?? first.drillCode;
                  // Sprint-18 Part 3: Pass level and target params so
                  // _tryAutoStart() auto-starts the session and recording
                  // UI (THÀNH CÔNG/TRƯỢT buttons) appears. Level=1 is the
                  // default level; target=10 is the default rep count for
                  // level 1 drills (matching DrillDetailScreen defaults).
                  context.push(
                    '/training/session/new?drill=$resolvedCode&level=1&target=10',
                  );
                } else {
                  context.go('/training');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bắt đầu ngay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  /// Context: Sau khi chơi Match
  Widget _buildAfterMatchCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    final missAnalysis = state.missAnalysis ?? {};
    final totalMisses = missAnalysis.values.fold(0, (a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_cricket, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Phân tích sau trận',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text(
            'Hôm nay bạn miss $totalMisses cú.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Miss breakdown
          if (missAnalysis.isNotEmpty) ...[
            Text(
              'Trong đó:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...missAnalysis.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.white70, size: 8),
                      const SizedBox(width: 8),
                      Text(
                        '${_getCategoryName(e.key)}: ${e.value} cú',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 16),

          Text(
            'AI đề xuất:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // AI recommendation based on miss analysis
          if (missAnalysis.containsKey('position'))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, color: Colors.white70),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Position Recovery Lv2',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(dashboardProvider.notifier).reset();
                context.push('/training/session/new?drill=position_recovery&level=2');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tiếp tục',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  /// Context: Sau khi hoàn thành Drill
  Widget _buildAfterDrillCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.celebration, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Chúc mừng!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Bạn đã hoàn thành',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          Text(
            'Position Lv2',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Tiếp theo:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, color: Colors.white70),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Position Lv3',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(dashboardProvider.notifier).reset();
                context.push('/training/session/new?drill=position&level=3');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tiếp tục Lv3',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  /// Context: Sau khi hoàn thành Knowledge
  Widget _buildAfterKnowledgeCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade700,
            Colors.purple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tuyệt vời!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Bạn vừa học:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const Text(
            'Cue Ball Control',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Hãy luyện:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, color: Colors.white70),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Drill 21, Drill 25',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(dashboardProvider.notifier).reset();
                context.go('/training');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đi luyện tập',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  /// Context: Cảnh báo Streak
  Widget _buildStreakWarningCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade700,
            Colors.orange.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cảnh báo Streak',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Bạn đã bỏ tập 4 ngày.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Hãy quay lại với bài Follow Shot Lv1 để không mất streak.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(dashboardProvider.notifier).reset();
                context.push('/training/session/new?drill=follow&level=1');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quay lại tập',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.school, color: Colors.white70, size: 32),
          SizedBox(height: 8),
          Text(
            'Tập bài đầu tiên để nhận đề xuất từ Coach',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayGoalSection(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(todayGoalsProvider);
    final learningPathAsync = ref.watch(learningPathProvider);

    // Sprint-18 Part 3: Navigation handlers for actionable goals.
    void goToTraining() {
      final path = learningPathAsync.valueOrNull;
      if (path != null && path.isNotEmpty) {
        final first = path.first;
        final resolvedCode = resolveDrillCode(first.drillCode) ?? first.drillCode;
        context.push('/training/session/new?drill=$resolvedCode&level=1&target=10');
      } else {
        context.go('/training/drills');
      }
    }

    final goalItems = [
      _GoalItem(
        icon: Icons.fitness_center,
        label: '${goals.drillsCompleted}/${goals.drillsTarget} drills',
        isDone: goals.drillsCompleted >= goals.drillsTarget,
        onTap: goals.drillsCompleted < goals.drillsTarget ? goToTraining : null,
      ),
      _GoalItem(
        icon: Icons.article,
        label: 'Đọc bài kiến thức',
        isDone: goals.knowledgeRead,
        onTap: goals.knowledgeRead ? null : () => context.push('/training/knowledge'),
      ),
      _GoalItem(
        icon: Icons.quiz,
        label: 'Pass Level Test',
        isDone: goals.testPassed,
        isSpecial: true,
        onTap: goals.testPassed ? null : () => context.push('/training/assessment'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Today's Goal",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: goals.allCompleted
                    ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goals.allCompleted ? '✓ Hoàn thành!' : 'Hôm nay',
                style: TextStyle(
                  color: goals.allCompleted
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: goalItems.asMap().entries.map((entry) {
              final index = entry.key;
              final goal = entry.value;
              final isLast = index == goalItems.length - 1;

              return Column(
                children: [
                  _GoalRow(goal: goal),
                  if (!isLast) const Divider(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildProgressSection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final skillAsync = ref.watch(skillAnalysisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ của bạn',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: statsAsync.when(
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _ProgressItem(
                    label: 'Trận đấu',
                    value: '${stats.totalMatches}',
                    sublabel: 'Tổng',
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _ProgressItem(
                    label: 'Thắng',
                    value: '${(stats.winRate * 100).toInt()}%',
                    sublabel: 'Tỷ lệ',
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: _ProgressItem(
                    label: 'Drill',
                    value: '${stats.drillsCompleted}',
                    sublabel: 'Hoàn thành',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Không thể tải dữ liệu'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Progress Ring - Skill Level
        skillAsync.when(
          data: (analysis) {
            final avgScore = analysis.strengths.isNotEmpty
                ? analysis.strengths.map((s) => s.score).reduce((a, b) => a + b) /
                    analysis.strengths.length
                : 0.0;
            return _buildProgressRing(context, avgScore);
          },
          loading: () => _buildProgressRing(context, 0.0, isLoading: true),
          error: (_, __) => _buildProgressRing(context, 0.0),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildProgressRing(BuildContext context, double progress, {bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: progress,
                      color: AppTheme.primaryGreen,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skill Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress > 0
                      ? 'Bạn đang tiến bộ!'
                      : 'Bắt đầu luyện tập để nâng cao skill',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthWeaknessSection(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(skillAnalysisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân tích kỹ năng',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        analysisAsync.when(
          data: (analysis) => Column(
            children: [
              // Strengths
              if (analysis.strengths.isNotEmpty) ...[
                _buildSkillList(
                  context,
                  'Điểm mạnh',
                  analysis.strengths,
                  Colors.green,
                  Icons.trending_up,
                ),
                const SizedBox(height: 12),
              ],
              // Weaknesses
              if (analysis.weaknesses.isNotEmpty)
                _buildSkillList(
                  context,
                  'Cần cải thiện',
                  analysis.weaknesses,
                  Colors.orange,
                  Icons.trending_down,
                ),
              if (analysis.strengths.isEmpty && analysis.weaknesses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Chưa có dữ liệu',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Hoàn thành bài tập để xem phân tích',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Không thể tải phân tích'),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSkillList(
    BuildContext context,
    String title,
    List<SkillItem> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nameVi,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(item.score * 100).toInt()}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Chưa có hoạt động',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.all(16),
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
                children: activities
                    .take(5)
                    .map((activity) => _buildActivityItem(activity))
                    .toList(),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Không thể tải hoạt động'),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildActivityItem(RecentActivity activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'match':
        icon = Icons.sports_cricket;
        color = Colors.blue;
        break;
      case 'drill':
        icon = Icons.fitness_center;
        color = AppTheme.primaryGreen;
        break;
      case 'knowledge':
        icon = Icons.auto_stories;
        color = Colors.purple;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (activity.subtitle.isNotEmpty)
                  Text(
                    activity.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            activity.timeAgo,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.fitness_center,
                label: 'Training',
                color: AppTheme.primaryGreen,
                onTap: () => context.go('/training'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.emoji_events,
                label: 'Thi đấu',
                color: Colors.blue,
                onTap: () => context.go('/play'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.people,
                label: 'Cộng đồng',
                color: Colors.purple,
                onTap: () => context.push('/community'),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  String _getCoachGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng! Hãy bắt đầu ngày mới với những bài tập phù hợp nhất cho bạn.';
    } else if (hour < 17) {
      return 'Chiều rồi! Đây là thời điểm tốt để luyện tập. Mình đã chọn những bài phù hợp với bạn.';
    } else {
      return 'Tối nay vẫn còn thời gian để tập. Hoàn thành mục tiêu hôm nay nhé!';
    }
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'position':
        return 'Position';
      case 'stop':
        return 'Stop Shot';
      case 'follow':
        return 'Follow';
      default:
        return 'Khác';
    }
  }
}

class _GoalItem {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isSpecial;
  final VoidCallback? onTap;

  _GoalItem({
    required this.icon,
    required this.label,
    required this.isDone,
    this.isSpecial = false,
    this.onTap,
  });
}

class _GoalRow extends StatelessWidget {
  final _GoalItem goal;

  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: goal.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: goal.isDone
                ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            goal.isDone ? Icons.check : goal.icon,
            color: goal.isDone ? AppTheme.primaryGreen : Colors.grey.shade400,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            goal.label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: goal.isDone ? Colors.grey.shade600 : Colors.black,
              decoration: goal.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (goal.isSpecial && !goal.isDone)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Gợi ý',
              style: TextStyle(
                color: Colors.amber.shade800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else if (goal.isDone)
          Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)
        else
          const SizedBox(width: 20),
        // Trailing arrow for clickable incomplete goals
        if (!goal.isDone && goal.onTap != null)
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;

  const _ProgressItem({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: color,
          ),
        ),
        Text(
          sublabel,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress Ring Custom Painter
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 8.0;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
