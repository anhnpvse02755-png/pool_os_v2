import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentQuestion = 0;
  int _totalScore = 0;
  bool _assessmentComplete = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Khi thực hiện Stop Shot, bạn đánh vào vị trí nào của bi cái?',
      'options': [
        {'text': 'Trên tâm bi cái', 'score': 0},
        {'text': 'Dưới tâm bi cái', 'score': 0},
        {'text': 'Tâm bi cái', 'score': 2},
        {'text': 'Không chắc', 'score': 1},
      ],
      'category': 'shotmaking',
    },
    {
      'question': 'Khi nào nên sử dụng Draw Shot?',
      'options': [
        {'text': 'Khi cần bi cái quay ngược lại', 'score': 2},
        {'text': 'Khi cần bi cái đi xa hơn', 'score': 0},
        {'text': 'Khi đánh bi vào lỗ', 'score': 0},
        {'text': 'Khi chơi safety', 'score': 1},
      ],
      'category': 'shotmaking',
    },
    {
      'question': 'Khoảng cách tối ưu để quan sát đường ngắm là bao nhiêu?',
      'options': [
        {'text': '30-40cm tu mui cue den bi cai', 'score': 0},
        {'text': '15-20cm tu mui cue den bi cai', 'score': 2},
        {'text': 'Càng gần càng tốt', 'score': 1},
        {'text': 'Không quan trọng', 'score': 0},
      ],
      'category': 'fundamentals',
    },
    {
      'question': 'Phương pháp Ghost Ball dùng để làm gì?',
      'options': [
        {'text': 'Xác định điểm ngắm chính xác', 'score': 2},
        {'text': 'Tăng lực đánh', 'score': 0},
        {'text': 'Cải thiện tư thế', 'score': 0},
        {'text': 'Kiểm soát bi cái', 'score': 1},
      ],
      'category': 'aiming',
    },
    {
      'question': 'Yếu tố nào quan trọng nhất trong Position Play?',
      'options': [
        {'text': 'Kiểm soát lực', 'score': 2},
        {'text': 'Đánh mạnh', 'score': 0},
        {'text': 'Chọn góc đẹp', 'score': 1},
        {'text': 'Đánh nhanh', 'score': 0},
      ],
      'category': 'positioning',
    },
    {
      'question': 'Khi nào nên chơi Safety thay vì đánh ghi điểm?',
      'options': [
        {'text': 'Khi không có đường ngắm rõ ràng', 'score': 2},
        {'text': 'Luôn luôn', 'score': 0},
        {'text': 'Khi thắng rồi', 'score': 0},
        {'text': 'Không bao giờ', 'score': 1},
      ],
      'category': 'strategy',
    },
    {
      'question': 'Tư thế đứng khi đánh billiards là?',
      'options': [
        {'text': 'Thẳng đứng', 'score': 0},
        {'text': 'Hơi nghiêng về phía trước', 'score': 2},
        {'text': 'Ngồi xổm', 'score': 0},
        {'text': 'Nghiêng ra sau', 'score': 0},
      ],
      'category': 'fundamentals',
    },
    {
      'question': 'Loi "Scratch" trong billiards la gi?',
      'options': [
        {'text': 'Đánh bi cái ra ngoài bàn', 'score': 2},
        {'text': 'Đánh không trúng bi đích', 'score': 0},
        {'text': 'Đánh bi vào lỗ sai', 'score': 1},
        {'text': 'Đánh chậm quá', 'score': 0},
      ],
      'category': 'rules',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_assessmentComplete) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Đánh giá kỹ năng'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                '${_currentQuestion + 1}/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_questions[_currentQuestion]['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      _getCategoryName(_questions[_currentQuestion]['category']),
                      style: TextStyle(
                        color: _getCategoryColor(_questions[_currentQuestion]['category']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.xxl),

                  // Question Text
                  Text(
                    _questions[_currentQuestion]['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      color: AppColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Options
                  ...(_questions[_currentQuestion]['options'] as List).asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _OptionCard(
                        text: option['text'] as String,
                        index: index,
                        onTap: () => _selectAnswer(index, option['score'] as int),
                      ).animate().fadeIn(delay: (150 + index * 50).ms),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final maxScore = _questions.length * 2;
    final percentage = (_totalScore / maxScore * 100).round();
    final level = _getLevel(percentage);
    final strengths = _getStrengths();
    final weaknesses = _getWeaknesses();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kết quả đánh giá'),
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Score Circle
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getLevelColor(level),
                    _getLevelColor(level).withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Điểm: $_totalScore/$maxScore',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: AppSpacing.xxl),

            // Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: _getLevelColor(level).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: _getLevelColor(level)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getLevelIcon(level), color: _getLevelColor(level)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    level,
                    style: TextStyle(
                      color: _getLevelColor(level),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Strengths
            if (strengths.isNotEmpty) ...[
              _buildSection(
                'Điểm mạnh',
                Icons.thumb_up,
                AppColors.success,
                strengths,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Weaknesses
            if (weaknesses.isNotEmpty) ...[
              _buildSection(
                'Cần cải thiện',
                Icons.trending_up,
                AppColors.warning,
                weaknesses,
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Recommended Actions
            _buildRecommendedActions(level).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartAssessment,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      side: BorderSide(color: AppColors.accent),
                      foregroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: const Text('Làm lại'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PrimaryButton(
                    onPressed: () => Navigator.pop(context),
                    label: 'Bắt đầu tập',
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(String level) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Đề xuất từ AI Coach',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getRecommendation(level),
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int index, int score) {
    setState(() {
      _totalScore += score;
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _assessmentComplete = true;
      }
    });
  }

  void _restartAssessment() {
    setState(() {
      _currentQuestion = 0;
      _totalScore = 0;
      _assessmentComplete = false;
    });
  }

  String _getLevel(int percentage) {
    if (percentage >= 90) return 'Chuyên gia';
    if (percentage >= 75) return 'Nâng cao';
    if (percentage >= 50) return 'Trung bình';
    return 'Sơ cấp';
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Chuyên gia':
        return const Color(0xFF8B5CF6);
      case 'Nâng cao':
        return AppColors.accent;
      case 'Trung bình':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'Chuyên gia':
        return Icons.emoji_events;
      case 'Nâng cao':
        return Icons.star;
      case 'Trung bình':
        return Icons.trending_up;
      default:
        return Icons.school;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'shotmaking':
        return AppColors.warning;
      case 'aiming':
        return AppColors.accent;
      case 'positioning':
        return const Color(0xFF14B8A6);
      case 'strategy':
        return const Color(0xFF8B5CF6);
      case 'fundamentals':
        return AppColors.success;
      case 'rules':
        return AppColors.error;
      default:
        return AppColors.lightTextSecondary;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'shotmaking':
        return 'Kỹ thuật đánh';
      case 'aiming':
        return 'Ngắm bàn';
      case 'positioning':
        return 'Vị trí';
      case 'strategy':
        return 'Chiến lược';
      case 'fundamentals':
        return 'Nền tảng';
      case 'rules':
        return 'Luật chơi';
      default:
        return category;
    }
  }

  List<String> _getStrengths() {
    final strengths = <String>[];
    if (_totalScore >= 12) strengths.add('Kiến thức kỹ thuật đánh tốt');
    if (_totalScore >= 10) strengths.add('Hiểu biết về ngắm bàn');
    if (_totalScore >= 8) strengths.add('Nắm vững nền tảng cơ bản');
    return strengths;
  }

  List<String> _getWeaknesses() {
    final weaknesses = <String>[];
    if (_totalScore < 12) weaknesses.add('Cần cải thiện kỹ thuật đánh');
    if (_totalScore < 10) weaknesses.add('Nên học thêm về ngắm bàn');
    if (_totalScore < 8) weaknesses.add('Cần ôn lại nền tảng');
    return weaknesses;
  }

  String _getRecommendation(String level) {
    switch (level) {
      case 'Chuyên gia':
        return 'Ban da co nen tang rat tot! Hay tap trung vao cac bai tap nang cao nhu Position Play phuc tap va cac cu bank shot kho.';
      case 'Nâng cao':
        return 'Kien thuc kha vung. Hay tap trung vao Position Play va cac tinh huong chien thuat de nang cao trinh do thi dau.';
      case 'Trung bình':
        return 'Ban co nen tang co ban. Hay bat dau voi cac bai tap Stop Shot, Draw Shot va Follow Shot de cai thien kiem soat bi cai.';
      default:
        return 'Ban moi bat dau. Hay tap trung vao cac bai tap co ban: tu the, cach cam cue, va cac cu danh don gian truoc.';
    }
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D'];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letters[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, color: AppColors.lightTextPrimary),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
          ],
        ),
      ),
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
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.accent : AppColors.lightTextTertiary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
