import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/coach_provider.dart';
import '../../../knowledge/knowledge_graph_service.dart';
import '../../../knowledge/drill_node.dart';
import '../../../knowledge/drill_code_bridge.dart';
import '../../providers/coach_survey_provider.dart';

/// Coach Screen - Rule-based Coach với Recommendations
/// Redesigned with Minimalist Luxury Design System
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
    if (!_surveyChecked) {
      _surveyChecked = true;
      _checkAndShowSurvey();
    }
  }

  void _checkAndShowSurvey() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final needsSurvey = ref.read(needsCoachSurveyProvider);
      if (needsSurvey && mounted) {
        context.go('/coach/survey');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.background(brightness),
        elevation: 0,
        title: Text(
          'Coach AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.lightTextSecondary),
            onPressed: () {
              ref.read(coachStateProvider.notifier).refreshCoachPlan();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đang cập nhật dữ liệu...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.accentColor(brightness),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayRecommendation(context, ref, brightness),
            const SizedBox(height: AppSpacing.xxl),
            _buildWeaknessesSection(context, ref, brightness),
            const SizedBox(height: AppSpacing.xxl),
            _buildRecommendedDrills(context, ref, brightness),
            const SizedBox(height: AppSpacing.xxl),
            _buildCoachFeatures(context, brightness),
            const SizedBox(height: AppSpacing.xxl),
            _buildGettingStartedTips(context, brightness),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayRecommendation(BuildContext context, WidgetRef ref, Brightness brightness) {
    final coachState = ref.watch(coachStateProvider);
    final recommendation = coachState.currentRecommendation;
    final accentColor = AppColors.accentColor(brightness);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
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
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Hôm nay nên tập',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (coachState.isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (recommendation != null) ...[
            Text(
              recommendation.drillName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              recommendation.reason,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '~${recommendation.estimatedMinutes} phút',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(Icons.trending_up, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    recommendation.outcomes.isNotEmpty ? recommendation.outcomes.first : 'Cải thiện kỹ năng',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PrimaryButton(
              onPressed: () => _startDrill(context, recommendation.drillCode),
              label: 'Bắt đầu ngay',
              icon: Icons.arrow_forward,
            ),
          ] else ...[
            Text(
              'Straight Shot',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Drill cơ bản nhất, nên thành thạo trước khi chuyển sang các bài khó hơn.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PrimaryButton(
              onPressed: () => _startDrill(context, 'straight_shot'),
              label: 'Bắt đầu',
              icon: Icons.arrow_forward,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildWeaknessesSection(BuildContext context, WidgetRef ref, Brightness brightness) {
    final coachState = ref.watch(coachStateProvider);
    final playerIntelligence = coachState.playerIntelligence;
    final skillProfile = playerIntelligence.skillProfile;
    final hasRealData = skillProfile.mostPracticedSkills.isNotEmpty;

    if (!hasRealData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm cần cải thiện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: AppShadows.sm(brightness),
            ),
            child: Column(
              children: [
                Icon(Icons.psychology, size: 40, color: AppColors.lightTextTertiary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Chưa có dữ liệu để phân tích',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tập ít nhất 1-2 bài tập để Coach phân tích điểm cần cải thiện của bạn.',
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final kg = KnowledgeGraphService.instance;
    final mistakes = kg.getAllMistakes().take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Điểm cần cải thiện',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...mistakes.map((mistake) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface(brightness),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              boxShadow: AppShadows.sm(brightness),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mistake.nameVi,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary(brightness)),
                      ),
                      if (mistake.description != null)
                        Text(
                          mistake.description!,
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
              ],
            ),
          ),
        )),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildRecommendedDrills(BuildContext context, WidgetRef ref, Brightness brightness) {
    final kg = KnowledgeGraphService.instance;
    final drills = kg.getAllDrills().take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bài tập gợi ý',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: drills.map((drill) => _DrillCard(
            drill: drill,
            onTap: () => _startDrill(context, drill.code),
            brightness: brightness,
          )).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildCoachFeatures(BuildContext context, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coach làm gì?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CoachFeatureCard(
          icon: Icons.analytics,
          title: 'Phân tích lối chơi',
          description: 'Tìm ra điểm mạnh, điểm yếu từ dữ liệu thực tế',
          brightness: brightness,
        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: AppSpacing.sm),
        _CoachFeatureCard(
          icon: Icons.route,
          title: 'Lộ trình học cá nhân',
          description: 'Tạo kế hoạch luyện tập dựa trên trình độ của bạn',
          brightness: brightness,
        ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: AppSpacing.sm),
        _CoachFeatureCard(
          icon: Icons.lightbulb,
          title: 'Gợi ý thông minh',
          description: 'Đề xuất bài tập phù hợp với từng giai đoạn',
          brightness: brightness,
        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
        const SizedBox(height: AppSpacing.sm),
        _CoachFeatureCard(
          icon: Icons.trending_up,
          title: 'Theo dõi tiến bộ',
          description: 'Đo lường sự tiến bộ qua thời gian với số liệu cụ thể',
          brightness: brightness,
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildGettingStartedTips(BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.accentColor(brightness)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Bắt đầu như thế nào?',
                style: TextStyle(
                  color: AppColors.accentColor(brightness),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _TipItem(number: '1', text: 'Chọn bài tập từ gợi ý của Coach', brightness: brightness),
          _TipItem(number: '2', text: 'Hoàn thành bài tập và ghi lại kết quả', brightness: brightness),
          _TipItem(number: '3', text: 'Xem phân tích từ Coach AI', brightness: brightness),
          _TipItem(number: '4', text: 'Tiếp tục với bài tập tiếp theo', brightness: brightness),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0);
  }

  void _startDrill(BuildContext context, String drillCode) {
    final resolvedCode = resolveDrillCode(drillCode) ?? drillCode;
    context.push(
      '/training/session/new?drill=$resolvedCode&level=1&target=10',
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const _PrimaryButton({required this.onPressed, required this.label, this.icon});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? Colors.white : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: Offset(0, 4))
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.onPressed != null ? AppColors.accentColor(Theme.of(context).brightness) : Colors.white,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(widget.icon, size: 18, color: widget.onPressed != null ? AppColors.accentColor(Theme.of(context).brightness) : Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  final DrillNode drill;
  final VoidCallback onTap;
  final Brightness brightness;

  const _DrillCard({
    required this.drill,
    required this.onTap,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(brightness),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border(brightness)),
            boxShadow: AppShadows.sm(brightness),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  _getDrillIcon(drill.code),
                  color: AppColors.accentColor(brightness),
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                drill.nameVi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary(brightness),
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
        return AppColors.success;
      case DrillDifficulty.intermediate:
        return AppColors.warning;
      case DrillDifficulty.advanced:
        return AppColors.error;
      case DrillDifficulty.expert:
        return Colors.purple;
    }
  }
}

class _CoachFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Brightness brightness;

  const _CoachFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(brightness),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm(brightness),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: AppColors.accentColor(brightness)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
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
  final Brightness brightness;

  const _TipItem({required this.number, required this.text, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentColor(brightness),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary(brightness)),
          ),
        ],
      ),
    );
  }
}
