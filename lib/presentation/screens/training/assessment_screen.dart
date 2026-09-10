import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

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
    final brightness = Theme.of(context).brightness;

    if (_assessmentComplete) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Đánh giá kỹ năng'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
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
      body: SoftBackground(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: AppColors.border(brightness),
              valueColor:
                  AlwaysStoppedAnimation(AppColors.primary(brightness)),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag
                    //
                    // Sáu danh mục nhưng hệ chỉ có BỐN hue tách bạch (`error`
                    // 0°, `warning` 38°, họ xanh rêu 157-163°,
                    // `difficultyExpert` 262°) — bảng cũ vì thế vừa quá tải vừa
                    // đụng nhau: `accent` -> `primary` rơi vào 157/163 ngay
                    // cạnh `success` 160, và teal thô #14B8A6 ở 173 cũng nằm
                    // trong họ xanh đó. Bảng màu duy nhất có đủ sắc phân biệt
                    // để mã hoá danh mục là năm ô pastel, nên nhãn đổi sang
                    // nền pastel + chữ `primary` — đúng ngôn ngữ của `IconTile`.
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.pastelFor(
                            _toneFor(_questions[_currentQuestion]['category']),
                            brightness),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      // Chữ dùng `textPrimary` chứ KHÔNG dùng `primary` như
                      // `IconTile`: đây là chữ 12px nên sàn là 4.5:1, còn thứ
                      // IconTile vẽ là icon nên sàn là 3:1. `primary` bản tối
                      // trên ô pastel tối chỉ được 4.29:1 — đủ cho icon, thiếu
                      // cho chữ.
                      child: Text(
                        _getCategoryName(_questions[_currentQuestion]['category']),
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: AppSpacing.xxl),

                    // Question Text
                    Text(
                      _questions[_currentQuestion]['question'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.textPrimary(brightness),
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
      ),
    );
  }

  Widget _buildResultScreen() {
    final brightness = Theme.of(context).brightness;
    final maxScore = _questions.length * 2;
    final percentage = (_totalScore / maxScore * 100).round();
    final level = _getLevel(percentage);
    final strengths = _getStrengths();
    final weaknesses = _getWeaknesses();

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Kết quả đánh giá'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SoftBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Score Circle
              //
              // LOANG, không phải tô đặc — cùng cái bẫy và cùng cách sửa như
              // header của `drill_detail_screen` và thẻ tỉ lệ của
              // `drill_result_screen`. Tô đặc thì chữ trắng KHÔNG đọc được ở
              // hai trong bốn bậc, ngay tại chế độ sáng là chế độ duy nhất đang
              // phát hành: `warning` 2.15:1 và `error` 3.76:1 (chữ 14px của
              // dòng điểm cần 4.5:1). Đổi hue không cứu được vì lỗi nằm ở ĐỘ
              // ĐẬM của nền. Loang 0.18 -> 0.10 đưa cả bốn bậc lên trên 8.7:1
              // với `textPrimary`, ở cả hai chế độ.
              //
              // `withValues` trên nền Container là hợp lệ: luật cấm alpha chỉ
              // áp cho MÀU CHỮ.
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(level, brightness)
                          .withValues(alpha: 0.18),
                      _getLevelColor(level, brightness)
                          .withValues(alpha: 0.10),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(brightness),
                        ),
                      ),
                      // KHÔNG hạ dòng điểm xuống `textSecondary`: bậc "Nâng
                      // cao" dùng `primary(light)` #0F4032 rất thẫm nên ngay ở
                      // alpha 0.18 nền đã đủ tối để `textSecondary` tụt dưới
                      // 4.5:1. Thứ bậc đã do cỡ chữ 48 vs 14 lo.
                      Text(
                        'Điểm: $_totalScore/$maxScore',
                        style: TextStyle(
                          color: AppColors.textPrimary(brightness),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: AppSpacing.xxl),

              // Level Badge
              //
              // Nền + viền vẫn mang tông của bậc, nhưng chữ và icon thì không:
              // trên nền loang cùng hue, `tone` đặc chỉ còn ~1.9:1.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _getLevelColor(level, brightness)
                      .withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border:
                      Border.all(color: _getLevelColor(level, brightness)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getLevelIcon(level),
                        color: AppColors.textPrimary(brightness)),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      level,
                      style: TextStyle(
                        color: AppColors.textPrimary(brightness),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Strengths / Weaknesses là một BỘ ANH EM hai phần tử:
              // `success` 160° và `warning` 38°, cách nhau xa.
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
                        side: BorderSide(color: AppColors.primary(brightness)),
                        foregroundColor: AppColors.primary(brightness),
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
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<String> items) {
    final brightness = Theme.of(context).brightness;

    // Tiêu đề dùng token chữ chứ không dùng `color`: `success` #10B981 đặt trên
    // `surface` trắng chỉ đạt 2.48:1. Tông của mục vẫn còn ở icon.
    return PoolCard(
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                  color: AppColors.textPrimary(brightness),
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
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                            color: AppColors.textPrimary(brightness)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions(String level) {
    final brightness = Theme.of(context).brightness;

    // `primary` là token DUY NHẤT ở đây nên không có bộ anh em nào để đụng, và
    // vì primary bản sáng rất thẫm (#0F4032) nên nó vẫn đọc tốt làm chữ trên
    // chính nền loang 0.1 của mình.
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary(brightness).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
            color: AppColors.primary(brightness).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.primary(brightness)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Đề xuất từ AI Coach',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getRecommendation(level),
            style: TextStyle(
              color: AppColors.textSecondary(brightness),
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

  /// Tông của bốn bậc trình độ.
  ///
  /// BỘ ANH EM bốn phần tử và nó dùng ĐÚNG cả bốn hue tách bạch mà hệ có:
  /// `difficultyExpert` 262° / họ xanh rêu 157-163° / `warning` 38° /
  /// `error` 0°. Không cặp nào dưới 20°. `Chuyên gia` KHÔNG được gộp vào
  /// `primary`: chế độ tối `primary` #34A97C lệch 3° so với `success`, và ở
  /// đây nó sẽ trùng luôn với bậc `Nâng cao` ngay bên cạnh.
  Color _getLevelColor(String level, Brightness brightness) {
    switch (level) {
      case 'Chuyên gia':
        return AppColors.difficultyExpert(brightness);
      case 'Nâng cao':
        return AppColors.primary(brightness);
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

  /// Tông pastel của một danh mục câu hỏi, gán theo ID.
  ///
  /// Sáu danh mục vượt quá bốn hue tách bạch của hệ, nên chúng chuyển sang
  /// bảng năm ô pastel — bảng duy nhất trong hệ đủ sắc để mã hoá danh mục, và
  /// là cùng bảng mà `IconTile` với `drill_list_screen` đang dùng. `rules` lặp
  /// lại tông 0 giống cách `_toneFor` bên `drill_list_screen` lặn vòng.
  int _toneFor(String category) {
    switch (category) {
      case 'shotmaking':
        return 0;
      case 'aiming':
        return 1;
      case 'positioning':
        return 2;
      case 'strategy':
        return 3;
      case 'fundamentals':
        return 4;
      case 'rules':
        return 0;
      default:
        return 0;
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
    final brightness = Theme.of(context).brightness;
    final letters = ['A', 'B', 'C', 'D'];

    return PoolCard(
      onTap: onTap,
      radius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceRecessed(brightness),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letters[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(brightness),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 15, color: AppColors.textPrimary(brightness)),
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.textTertiary(brightness)),
        ],
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
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(scale: _scale, duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            // Cả hai nhánh nền đều đổi theo chế độ, nên chữ dùng
            // `onPrimary(brightness)`.
            color: widget.onPressed != null
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Text(widget.label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary(brightness)),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
