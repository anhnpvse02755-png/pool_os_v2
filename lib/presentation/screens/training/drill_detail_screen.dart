import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/utils/drills_library.dart';
import '../../../data/content/drill_content_vi.dart';

class DrillDetailScreen extends StatefulWidget {
  final String drillCode;

  const DrillDetailScreen({super.key, required this.drillCode});

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  int _selectedLevel = 1;

  @override
  Widget build(BuildContext context) {
    final drill = DrillLibrary.getDrill(widget.drillCode);

    debugPrint('DrillDetailScreen: Looking for drill code: ${widget.drillCode}');
    debugPrint('DrillDetailScreen: Found drill: $drill');

    if (drill == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Loi'),
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 56,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Khong tim thay bai tap nay',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bai tap voi ma "${widget.drillCode}" khong ton tai.',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: _PrimaryButton(
                    onPressed: () => context.go('/training/drills'),
                    label: 'Quay ve thu vien bai tap',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.lightSurface,
            foregroundColor: AppColors.lightTextPrimary,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                drill.nameVi,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDifficultyColor(drill.difficulty),
                      _getDifficultyColor(drill.difficulty).withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Chia se bai tap - Tinh nang dang phat trien'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  _buildDifficultyBadge(drill.difficulty),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  Text(
                    drill.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Levels Section
                  _buildSectionTitle(context, 'Cac cap do'),
                  const SizedBox(height: AppSpacing.md),
                  _buildLevelsList(drill),
                  const SizedBox(height: AppSpacing.xxl),

                  // Setup
                  _buildSectionTitle(context, 'Setup'),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: AppColors.lightTextSecondary, size: 22),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(drill.setup, style: TextStyle(color: AppColors.lightTextPrimary))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Steps
                  _buildSectionTitle(context, 'Cac buoc'),
                  const SizedBox(height: AppSpacing.md),
                  ...drill.steps.asMap().entries.map((entry) {
                    return _buildStep(entry.key + 1, entry.value);
                  }),
                  const SizedBox(height: AppSpacing.xxl),

                  // Goal
                  _buildSectionTitle(context, 'Muc tieu'),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: AppColors.success, size: 22),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(drill.goal, style: TextStyle(color: AppColors.lightTextPrimary))),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Common Mistakes
                  _buildSectionTitle(context, 'Loi thuong gap'),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCommonMistakes(drill.code),
                  const SizedBox(height: AppSpacing.xxl),

                  // Detailed Vietnamese content sections
                  _buildContentSections(drill.code),
                  const SizedBox(height: AppSpacing.xxl),

                  // Knowledge Link
                  _buildSectionTitle(context, 'Kien thuc lien quan'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Kien thuc khong bi khoa. Ban co the hoc bat ky luc nao.',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildKnowledgeList(drill.knowledgeIds),
                  const SizedBox(height: AppSpacing.xxl),

                  // Related Drills
                  _buildSectionTitle(context, 'Bai tap lien quan'),
                  const SizedBox(height: AppSpacing.md),
                  _buildRelatedDrills(drill.code),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStartButton(drill),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: _getDifficultyColor(difficulty).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt,
            size: 16,
            color: _getDifficultyColor(difficulty),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _getDifficultyLabel(difficulty),
            style: TextStyle(
              color: _getDifficultyColor(difficulty),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      case 'expert':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'expert':
        return 'Expert';
      default:
        return difficulty;
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
    );
  }

  Widget _buildLevelsList(Drill drill) {
    return Column(
      children: drill.levels.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        final isUnlocked = drill.isLevelUnlocked(level.level);
        final isSelected = _selectedLevel == level.level;
        final isCompleted = level.level < drill.currentLevel;

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUnlocked
                  ? () => setState(() => _selectedLevel = level.level)
                  : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : isCompleted
                          ? AppColors.success.withValues(alpha: 0.05)
                          : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accent
                        : isCompleted
                            ? AppColors.success.withValues(alpha: 0.5)
                            : isUnlocked
                                ? AppColors.lightBorder
                                : AppColors.lightBorderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Level indicator
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: !isUnlocked
                            ? AppColors.lightTextTertiary
                            : isCompleted
                                ? AppColors.success
                                : AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 22)
                            : !isUnlocked
                                ? const Icon(Icons.lock, color: Colors.white, size: 20)
                                : Text(
                                    '${level.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // Level info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Level ${level.level}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: !isUnlocked
                                      ? AppColors.lightTextTertiary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            level.criteriaText,
                            style: TextStyle(
                              fontSize: 13,
                              color: !isUnlocked
                                  ? AppColors.lightTextTertiary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Icon(Icons.lock, color: AppColors.lightTextTertiary, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms);
      }).toList(),
    );
  }

  Widget _buildStep(int number, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(step, style: TextStyle(color: AppColors.lightTextPrimary, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakes(String drillCode) {
    final content = drillContentVi[drillCode];
    final mistakes = content?.commonMistakes ?? _genericMistakes;

    return Column(
      children: mistakes.map((mistake) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(mistake, style: TextStyle(color: AppColors.lightTextPrimary, height: 1.4))),
            ],
          ),
        );
      }).toList(),
    );
  }

  static const _genericMistakes = [
    'Danh qua manh hoac qua nhe',
    'Tu the khong vung',
    'Khong follow through day du',
  ];

  Widget _buildContentSections(String drillCode) {
    final content = drillContentVi[drillCode];
    if (content == null) {
      return _buildComingSoonCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.equipment.isNotEmpty) ...[
          _buildSectionTitle(context, 'Dung cu can thiet'),
          const SizedBox(height: AppSpacing.sm),
          _buildBulletList(content.equipment, Icons.sports_baseball),
          const SizedBox(height: AppSpacing.lg),
        ],

        _buildSectionTitle(context, 'Tu the dung'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextCard(content.stance),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionTitle(context, 'Cau tay'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextCard(content.bridge),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionTitle(context, 'Ky thuat ra co'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextCard(content.stroke),
        const SizedBox(height: AppSpacing.lg),

        _buildSectionTitle(context, 'He thong ngam'),
        const SizedBox(height: AppSpacing.sm),
        _buildTextCard(content.aiming),
        const SizedBox(height: AppSpacing.lg),

        if (content.keyPoints.isNotEmpty) ...[
          _buildSectionTitle(context, 'Diem can nho'),
          const SizedBox(height: AppSpacing.sm),
          _buildBulletList(content.keyPoints, Icons.check_circle_outline),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (content.proTips.isNotEmpty) ...[
          _buildSectionTitle(context, 'Meo tu pro'),
          const SizedBox(height: AppSpacing.sm),
          _buildBulletList(content.proTips, Icons.star, color: AppColors.gold),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }

  Widget _buildBulletList(
    List<String> items,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(item, style: TextStyle(color: AppColors.lightTextPrimary, height: 1.4))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextCard(String text) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.construction, color: AppColors.warning, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dang cap nhat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Huong dan chi tiet cho bai tap nay sap ra mat.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeList(List<String> knowledgeIds) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: knowledgeIds.map((id) {
        return ActionChip(
          label: Text(_getKnowledgeName(id), style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500)),
          avatar: Icon(Icons.menu_book, size: 18, color: AppColors.accent),
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
          onPressed: () {
            context.push('/training/knowledge/$id');
          },
        );
      }).toList(),
    );
  }

  String _getKnowledgeName(String id) {
    final names = {
      'aiming': 'Aiming',
      'bridge': 'Bridge',
      'stroke': 'Stroke',
      'draw': 'Draw',
      'follow': 'Follow',
      'stop_ball': 'Stop Ball',
      'position_play': 'Position Play',
      'cut_shots': 'Cut Shots',
      'bank': 'Bank',
      'kick': 'Kick',
      'jump': 'Jump',
      'masse': 'Masse',
      'safety': 'Safety',
      'break': 'Break',
    };
    return names[id] ?? id;
  }

  Widget _buildRelatedDrills(String currentCode) {
    final currentDrill = DrillLibrary.getDrill(currentCode);
    if (currentDrill == null) return const SizedBox();

    final relatedDrills = DrillLibrary.getDrillsByCategory(currentDrill.category)
        .where((d) => d.code != currentCode)
        .take(3)
        .toList();

    if (relatedDrills.isEmpty) {
      return Text(
        'Khong co bai tap lien quan',
        style: TextStyle(color: AppColors.lightTextSecondary),
      );
    }

    return Column(
      children: relatedDrills.map((drill) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/training/drill/${drill.code}'),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(drill.difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          drill.nameVi.substring(0, 1),
                          style: TextStyle(
                            color: _getDifficultyColor(drill.difficulty),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drill.nameVi,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.lightTextPrimary),
                          ),
                          Text(
                            drill.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.lightTextSecondary,
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
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(Drill drill) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: _PrimaryButton(
          onPressed: () => _onStartPressed(drill),
          label: 'Bat dau nhap lieu - Level $_selectedLevel',
        ),
      ),
    );
  }

  Future<void> _onStartPressed(Drill drill) async {
    print('[SPRINT17_FLOW] DRILL_DETAIL: _onStartPressed entered');
    final defaultAttempts = drill.levels.first.attempts;

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => _RepetitionsDialog(
        defaultAttempts: defaultAttempts,
      ),
    );
    if (picked == null) return;

    if (!mounted) return;
    context.push(
      '/training/session/new?drill=${drill.code}&level=$_selectedLevel&target=$picked',
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  const _PrimaryButton({required this.onPressed, required this.label});
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
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
          ),
          child: Text(widget.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center)),
      ),
    );
  }
}

class _RepetitionsDialog extends StatefulWidget {
  final int defaultAttempts;
  const _RepetitionsDialog({required this.defaultAttempts});
  @override
  State<_RepetitionsDialog> createState() => _RepetitionsDialogState();
}

class _RepetitionsDialogState extends State<_RepetitionsDialog> {
  static const _presets = [10, 25, 50, 100, 200];
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.defaultAttempts;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: const Text('Chon so lan tap'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mac dinh cho level nay: ${widget.defaultAttempts} lan',
              style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.lg),

            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _presets.map((preset) {
                final isSelected = _selected == preset && preset != widget.defaultAttempts;
                return ChoiceChip(
                  label: Text('$preset lan', style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
                  selected: isSelected,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.lightBackground,
                  onSelected: (_) => setState(() => _selected = preset),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            ChoiceChip(
              label: Text('Mac dinh (${widget.defaultAttempts})', style: TextStyle(
                color: _selected == widget.defaultAttempts ? Colors.white : AppColors.lightTextPrimary,
                fontWeight: _selected == widget.defaultAttempts ? FontWeight.w600 : FontWeight.normal,
              )),
              selected: _selected == widget.defaultAttempts,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.lightBackground,
              onSelected: (_) => setState(() => _selected = widget.defaultAttempts),
            ),

            const SizedBox(height: AppSpacing.xxl),

            const Text(
              'Hoac nhap so lan tuy chinh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: '$_selected',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                hintText: 'VD: 150',
                suffixText: 'lan',
              ),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null && n > 0) {
                  setState(() => _selected = n);
                }
              },
            ),

            const SizedBox(height: AppSpacing.sm),
            Text(
              'So lan lon giup tang do chinh xac',
              style: TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Huy', style: TextStyle(color: AppColors.lightTextSecondary)),
        ),
        _DialogButton(
          onPressed: () {
            if (_selected <= 0) return;
            Navigator.of(context).pop(_selected);
          },
          label: 'Bat dau $_selected lan',
        ),
      ],
    );
  }
}

class _DialogButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const _DialogButton({required this.onPressed, required this.label});
  @override
  State<_DialogButton> createState() => _DialogButtonState();
}
class _DialogButtonState extends State<_DialogButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
