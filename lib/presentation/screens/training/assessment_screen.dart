import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

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
        {'text': '30-40cm từ mũi cue đến bi cái', 'score': 0},
        {'text': '15-20cm từ mũi cue đến bi cái', 'score': 2},
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
      'question': 'Tư thế đứng đúng khi đánh billiards là?',
      'options': [
        {'text': 'Thẳng đứng', 'score': 0},
        {'text': 'Hơi nghiêng về phía trước', 'score': 2},
        {'text': 'Ngồi xổm', 'score': 0},
        {'text': 'Nghiêng ra sau', 'score': 0},
      ],
      'category': 'fundamentals',
    },
    {
      'question': 'Lỗi "Scratch" trong billiards là gì?',
      'options': [
        {'text': 'Đánh bi cái ra khỏi bàn', 'score': 2},
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
      appBar: AppBar(
        title: const Text('Đánh giá kỹ năng'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(_questions[_currentQuestion]['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
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

                  const SizedBox(height: 20),

                  // Question Text
                  Text(
                    _questions[_currentQuestion]['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // Options
                  ...(_questions[_currentQuestion]['options'] as List).asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
      appBar: AppBar(
        title: const Text('Kết quả đánh giá'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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

            const SizedBox(height: 24),

            // Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _getLevelColor(level).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _getLevelColor(level)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getLevelIcon(level), color: _getLevelColor(level)),
                  const SizedBox(width: 8),
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

            const SizedBox(height: 32),

            // Strengths
            if (strengths.isNotEmpty) ...[
              _buildSection(
                'Điểm mạnh',
                Icons.thumb_up,
                Colors.green,
                strengths,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
            ],

            // Weaknesses
            if (weaknesses.isNotEmpty) ...[
              _buildSection(
                'Cần cải thiện',
                Icons.trending_up,
                Colors.orange,
                weaknesses,
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 20),
            ],

            // Recommended Actions
            _buildRecommendedActions(level).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartAssessment,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Làm lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Bắt đầu tập'),
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
              Icon(icon, color: color, size: 20),
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
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 16),
                    const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              const Text(
                'Đề xuất từ AI Coach',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getRecommendation(level),
            style: TextStyle(
              color: Colors.grey.shade700,
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
        return Colors.purple;
      case 'Nâng cao':
        return Colors.blue;
      case 'Trung bình':
        return Colors.orange;
      default:
        return Colors.red;
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
        return Colors.orange;
      case 'aiming':
        return Colors.blue;
      case 'positioning':
        return Colors.teal;
      case 'strategy':
        return Colors.purple;
      case 'fundamentals':
        return Colors.green;
      case 'rules':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'shotmaking':
        return 'Kỹ thuật đánh';
      case 'aiming':
        return 'Ngắm bắn';
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
    if (_totalScore >= 10) strengths.add('Hiểu biết về ngắm bắn');
    if (_totalScore >= 8) strengths.add('Nắm vững nền tảng cơ bản');
    return strengths;
  }

  List<String> _getWeaknesses() {
    final weaknesses = <String>[];
    if (_totalScore < 12) weaknesses.add('Cần cải thiện kỹ thuật đánh');
    if (_totalScore < 10) weaknesses.add('Nên học thêm về ngắm bắn');
    if (_totalScore < 8) weaknesses.add('Cần ôn lại nền tảng');
    return weaknesses;
  }

  String _getRecommendation(String level) {
    switch (level) {
      case 'Chuyên gia':
        return 'Bạn đã có nền tảng rất tốt! Hãy tập trung vào các bài tập nâng cao như Position Play phức tạp và các cú bank shot khó.';
      case 'Nâng cao':
        return 'Kiến thức khá vững. Hãy tập trung vào Position Play và các tình huống chiến thuật để nâng cao trình độ thi đấu.';
      case 'Trung bình':
        return 'Bạn có nền tảng cơ bản. Hãy bắt đầu với các bài tập Stop Shot, Draw Shot và Follow Shot để cải thiện kiểm soát bi cái.';
      default:
        return 'Bạn mới bắt đầu. Hãy tập trung vào các bài tập cơ bản: tư thế, cách cầm cue, và các cú đánh đơn giản trước.';
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letters[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
