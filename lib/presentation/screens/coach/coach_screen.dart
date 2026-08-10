import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../knowledge/knowledge_graph_service.dart';
import '../../../knowledge/drill_node.dart';
import '../../providers/coach_survey_provider.dart';

/// Coach Screen - Rule-based Coach với Recommendations
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  bool _surveyChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check survey on first build
    if (!_surveyChecked) {
      _surveyChecked = true;
      _checkAndShowSurvey();
    }
  }

  void _checkAndShowSurvey() {
    // Delay to allow widget to build first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final needsSurvey = ref.read(needsCoachSurveyProvider);
      if (needsSurvey && mounted) {
        context.go('/coach/survey');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh coach data
              ref.read(coachStateProvider.notifier).refreshCoachPlan();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang cập nhật dữ liệu...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Recommendation Section
            _buildTodayRecommendation(context, ref),
            const SizedBox(height: 24),

            // Weaknesses Section
            _buildWeaknessesSection(context, ref),
            const SizedBox(height: 24),

            // Drills to Practice
            _buildRecommendedDrills(context, ref),
            const SizedBox(height: 24),

            // Coach Features
            _buildCoachFeatures(context),
            const SizedBox(height: 32),

            // Getting Started Tips
            _buildGettingStartedTips(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayRecommendation(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(coachStateProvider);
    final recommendation = coachState.currentRecommendation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hôm nay nên tập',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (coachState.isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (recommendation != null) ...[
            Text(
              recommendation.drillName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.reason,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '~${recommendation.estimatedMinutes} phút',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.trending_up, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recommendation.outcomes.isNotEmpty ? recommendation.outcomes.first : 'Cải thiện kỹ năng',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startDrill(context, recommendation.drillCode),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ] else ...[
            // No recommendation - show default drills
            Text(
              'Straight Shot',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drill cơ bản nhất, nên thành thạo trước khi chuyển sang các bài khó hơn.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startDrill(context, 'straight_shot'),
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
                      'Bắt đầu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildWeaknessesSection(BuildContext context, WidgetRef ref) {
    // Check if user has real training data by looking at skill profile
    final coachState = ref.watch(coachStateProvider);
    final playerIntelligence = coachState.playerIntelligence;

    // Check if any skill has been practiced (totalSessions > 0)
    final skillProfile = playerIntelligence.skillProfile;
    final hasRealData = skillProfile.mostPracticedSkills.isNotEmpty;

    // Only show weaknesses if user has real training data
    if (!hasRealData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm cần cải thiện',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'Chưa có dữ liệu để phân tích',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tập ít nhất 1-2 bài tập để Coach phân tích điểm cần cải thiện của bạn.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // User has real data - show their weaknesses
    final kg = KnowledgeGraphService.instance;
    final mistakes = kg.getAllMistakes().take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Điểm cần cải thiện',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...mistakes.map((mistake) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mistake.nameVi,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (mistake.description != null)
                              Text(
                                mistake.description!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              )),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildRecommendedDrills(BuildContext context, WidgetRef ref) {
    final kg = KnowledgeGraphService.instance;
    final drills = kg.getAllDrills().take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bài tập gợi ý',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: drills.map((drill) => _DrillCard(
            drill: drill,
            onTap: () => _startDrill(context, drill.code),
          )).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCoachFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coach làm gì?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _CoachFeatureCard(
          icon: Icons.analytics,
          title: 'Phân tích lối chơi',
          description: 'Tìm ra điểm mạnh, điểm yếu từ dữ liệu thực tế',
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        _CoachFeatureCard(
          icon: Icons.route,
          title: 'Lộ trình học cá nhân',
          description: 'Tạo kế hoạch luyện tập dựa trên trình độ của bạn',
        ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        _CoachFeatureCard(
          icon: Icons.lightbulb,
          title: 'Gợi ý thông minh',
          description: 'Đề xuất bài tập phù hợp với từng giai đoạn',
        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: 8),
        _CoachFeatureCard(
          icon: Icons.trending_up,
          title: 'Theo dõi tiến bộ',
          description: 'Đo lường sự tiến bộ qua thời gian với số liệu cụ thể',
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildGettingStartedTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Bắt đầu như thế nào?',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TipItem(number: '1', text: 'Chọn bài tập từ gợi ý của Coach'),
          _TipItem(number: '2', text: 'Hoàn thành bài tập và ghi lại kết quả'),
          _TipItem(number: '3', text: 'Xem phân tích từ Coach AI'),
          _TipItem(number: '4', text: 'Tiếp tục với bài tập tiếp theo'),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0);
  }

  void _startDrill(BuildContext context, String drillCode) {
    context.push('/training/session/new?drill=$drillCode');
  }
}

class _DrillCard extends StatelessWidget {
  final DrillNode drill;
  final VoidCallback onTap;

  const _DrillCard({
    required this.drill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDrillIcon(drill.code),
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                drill.nameVi,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getDifficultyLabel(drill.difficulty),
                style: TextStyle(
                  color: _getDifficultyColor(drill.difficulty),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDrillIcon(String code) {
    switch (code) {
      case 'straight_shot':
        return Icons.linear_scale;
      case 'stop_shot':
        return Icons.stop_circle_outlined;
      case 'position_play':
        return Icons.location_on;
      case 'follow_shot':
        return Icons.arrow_forward;
      default:
        return Icons.fitness_center;
    }
  }

  String _getDifficultyLabel(DrillDifficulty difficulty) {
    return difficulty.label;
  }

  Color _getDifficultyColor(DrillDifficulty difficulty) {
    switch (difficulty) {
      case DrillDifficulty.beginner:
        return Colors.green;
      case DrillDifficulty.intermediate:
        return Colors.orange;
      case DrillDifficulty.advanced:
        return Colors.red;
      case DrillDifficulty.expert:
        return Colors.purple;
    }
  }
}

class _CoachFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CoachFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
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
}

class _TipItem extends StatelessWidget {
  final String number;
  final String text;

  const _TipItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
