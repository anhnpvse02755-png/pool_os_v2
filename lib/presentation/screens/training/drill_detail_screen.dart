import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/drills_library.dart';
import '../../../data/content/drill_content_vi.dart';

class DrillDetailScreen extends StatefulWidget {
  final String drillCode;

  const DrillDetailScreen({super.key, required this.drillCode});

  @override
  State<DrillDetailScreen> createState() => _DrillDetailScreenState();
}

class _DrillDetailScreenState extends State<DrillDetailScreen> {
  int _selectedLevel = 1; // Default to level 1

  @override
  Widget build(BuildContext context) {
    final drill = DrillLibrary.getDrill(widget.drillCode);

    // DEBUG: Log the drill code
    debugPrint('DrillDetailScreen: Looking for drill code: ${widget.drillCode}');
    debugPrint('DrillDetailScreen: Found drill: $drill');

    if (drill == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'Không tìm thấy bài tập này',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bài tập với mã "${widget.drillCode}" không tồn tại hoặc đã bị xóa.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/training/drills'),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Quay về thư viện bài tập'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(drill.nameVi),
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
                    const SnackBar(
                      content: Text('Chia sẻ bài tập - Tính năng đang phát triển'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  _buildDifficultyBadge(drill.difficulty),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    drill.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Levels Section
                  _buildSectionTitle(context, 'Các cấp độ'),
                  const SizedBox(height: 12),
                  _buildLevelsList(drill),
                  const SizedBox(height: 24),

                  // Setup
                  _buildSectionTitle(context, 'Setup'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(child: Text(drill.setup)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Steps
                  _buildSectionTitle(context, 'Các bước'),
                  const SizedBox(height: 12),
                  ...drill.steps.asMap().entries.map((entry) {
                    return _buildStep(entry.key + 1, entry.value);
                  }),
                  const SizedBox(height: 24),

                  // Goal
                  _buildSectionTitle(context, 'Mục tiêu'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(child: Text(drill.goal)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Common Mistakes
                  _buildSectionTitle(context, 'Lỗi thường gặp'),
                  const SizedBox(height: 8),
                  _buildCommonMistakes(drill.code),
                  const SizedBox(height: 24),

                  // Detailed Vietnamese content sections (if available)
                  _buildContentSections(drill.code),
                  const SizedBox(height: 24),

                  // Knowledge Link
                  _buildSectionTitle(context, '📚 Kiến thức liên quan'),
                  const SizedBox(height: 8),
                  Text(
                    'Knowledge không bị khóa. Bạn có thể học bất kỳ lúc nào.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildKnowledgeList(drill.knowledgeIds),
                  const SizedBox(height: 24),

                  // Related Drills
                  _buildSectionTitle(context, '🔗 Bài tập liên quan'),
                  const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
          const SizedBox(width: 4),
          Text(
            _getDifficultyLabel(difficulty),
            style: TextStyle(
              color: _getDifficultyColor(difficulty),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
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
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUnlocked
                  ? () => setState(() => _selectedLevel = level.level)
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                      : isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : isCompleted
                            ? Colors.green
                            : isUnlocked
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Level indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: !isUnlocked
                            ? Colors.grey.shade300
                            : isCompleted
                                ? Colors.green
                                : AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : !isUnlocked
                                ? const Icon(Icons.lock, color: Colors.white, size: 18)
                                : Text(
                                    '${level.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                  color: !isUnlocked
                                      ? Colors.grey
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
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
                          const SizedBox(height: 4),
                          Text(
                            level.criteriaText,
                            style: TextStyle(
                              fontSize: 12,
                              color: !isUnlocked
                                  ? Colors.grey
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      Icon(Icons.lock, color: Colors.grey.shade400, size: 20),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(step),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakes(String drillCode) {
    // Load from drillContentVi — Vietnamese content per drill.
    final content = drillContentVi[drillCode];
    final mistakes = content?.commonMistakes ?? _genericMistakes;

    return Column(
      children: mistakes.map((mistake) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(mistake)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Fallback generic mistakes for drills without custom content.
  static const _genericMistakes = [
    'Đánh quá mạnh hoặc quá nhẹ',
    'Tư thế không vững',
    'Không follow through đầy đủ',
  ];

  Widget _buildContentSections(String drillCode) {
    final content = drillContentVi[drillCode];
    if (content == null) {
      return _buildComingSoonCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Equipment
        if (content.equipment.isNotEmpty) ...[
          _buildSectionTitle(context, '🎯 Dụng cụ cần thiết'),
          const SizedBox(height: 8),
          _buildBulletList(content.equipment, Icons.sports_baseball),
          const SizedBox(height: 16),
        ],

        // Stance
        _buildSectionTitle(context, '🦶 Tư thế đứng'),
        const SizedBox(height: 8),
        _buildTextCard(content.stance),
        const SizedBox(height: 16),

        // Bridge
        _buildSectionTitle(context, '🤚 Cầu tay'),
        const SizedBox(height: 8),
        _buildTextCard(content.bridge),
        const SizedBox(height: 16),

        // Stroke
        _buildSectionTitle(context, '⚡ Kỹ thuật ra cơ'),
        const SizedBox(height: 8),
        _buildTextCard(content.stroke),
        const SizedBox(height: 16),

        // Aiming
        _buildSectionTitle(context, '👁️ Hệ thống ngắm'),
        const SizedBox(height: 8),
        _buildTextCard(content.aiming),
        const SizedBox(height: 16),

        // Key Points
        if (content.keyPoints.isNotEmpty) ...[
          _buildSectionTitle(context, '🔑 Điểm cần nhớ'),
          const SizedBox(height: 8),
          _buildBulletList(content.keyPoints, Icons.check_circle_outline),
          const SizedBox(height: 16),
        ],

        // Pro Tips
        if (content.proTips.isNotEmpty) ...[
          _buildSectionTitle(context, '⭐ Mẹo từ pro'),
          const SizedBox(height: 8),
          _buildBulletList(content.proTips, Icons.star, color: AppTheme.accentGold),
          const SizedBox(height: 16),
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
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color ?? Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(item)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.construction, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang cập nhật',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hướng dẫn chi tiết cho bài tập này sắp ra mắt. Vui lòng tham khảo các bài tập tương tự ở trên.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
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
    // Placeholder - sẽ lấy từ database
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: knowledgeIds.map((id) {
        return ActionChip(
          label: Text(_getKnowledgeName(id)),
          avatar: const Icon(Icons.menu_book, size: 16),
          onPressed: () {
            // Navigate to knowledge detail
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
    // Get drills from same category
    final currentDrill = DrillLibrary.getDrill(currentCode);
    if (currentDrill == null) return const SizedBox();

    final relatedDrills = DrillLibrary.getDrillsByCategory(currentDrill.category)
        .where((d) => d.code != currentCode)
        .take(3)
        .toList();

    if (relatedDrills.isEmpty) {
      return Text(
        'Không có bài tập liên quan',
        style: TextStyle(color: AppTheme.textSecondary),
      );
    }

    return Column(
      children: relatedDrills.map((drill) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/training/drill/${drill.code}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(drill.difficulty).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          drill.nameVi.substring(0, 1),
                          style: TextStyle(
                            color: _getDifficultyColor(drill.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drill.nameVi,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            drill.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
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
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(Drill drill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _onStartPressed(drill),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note),
              const SizedBox(width: 8),
              Text(
                'Bắt đầu nhập liệu — Level $_selectedLevel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStartPressed(Drill drill) async {
    print('[SPRINT17_FLOW] DRILL_DETAIL: _onStartPressed entered');
    final defaultAttempts = drill.levels.first.attempts;

    // Show dialog so the player can pick a target — preset or custom.
    // Sprint 7B: custom attempts to support heavy practice (e.g., 100 reps).
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => _RepetitionsDialog(
        defaultAttempts: defaultAttempts,
      ),
    );
    if (picked == null) return; // user cancelled

    if (!mounted) return;
    context.push(
      '/training/session/new?drill=${drill.code}&level=$_selectedLevel&target=$picked',
    );
  }
}

/// Dialog chọn số lần tập — preset + tuỳ chỉnh.
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
      title: const Text('Chọn số lần tập'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mặc định cho level này: ${widget.defaultAttempts} lần',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Preset chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((preset) {
                final isSelected = _selected == preset &&
                    preset != widget.defaultAttempts;
                return ChoiceChip(
                  label: Text('$preset lần'),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selected = preset),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Default option
            ChoiceChip(
              label: Text('Mặc định (${widget.defaultAttempts})'),
              selected: _selected == widget.defaultAttempts,
              onSelected: (_) =>
                  setState(() => _selected = widget.defaultAttempts),
            ),

            const SizedBox(height: 20),

            // Custom input
            const Text(
              'Hoặc nhập số lần tuỳ chỉnh:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '$_selected',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'VD: 150',
                suffixText: 'lần',
              ),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null && n > 0) {
                  setState(() => _selected = n);
                }
              },
            ),

            const SizedBox(height: 8),
            Text(
              'Số lần lớn giúp tăng độ chính xác và sức chịu đựng',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selected <= 0) return;
            Navigator.of(context).pop(_selected);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: Text('Bắt đầu $_selected lần'),
        ),
      ],
    );
  }
}
