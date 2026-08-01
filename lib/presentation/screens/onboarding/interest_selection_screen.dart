import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class InterestSelectionScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const InterestSelectionScreen({super.key, this.onComplete});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final Set<String> _selectedInterests = {};

  final List<InterestOption> _interests = [
    InterestOption(
      id: 'draw',
      name: 'Draw Shot',
      nameVi: 'Draw Shot',
      icon: Icons.arrow_back,
      color: Colors.orange,
      description: 'Bi cái quay ngược lại sau khi chạm',
    ),
    InterestOption(
      id: 'position',
      name: 'Position Control',
      nameVi: 'Kiểm soát vị trí',
      icon: Icons.gps_fixed,
      color: Colors.blue,
      description: 'Điều bi cái đến vị trí mong muốn',
    ),
    InterestOption(
      id: 'bank',
      name: 'Bank Shot',
      nameVi: 'Bank',
      icon: Icons.change_history,
      color: Colors.purple,
      description: 'Đánh chạm băng trước khi vào lỗ',
    ),
    InterestOption(
      id: 'kick',
      name: 'Kick Shot',
      nameVi: 'Kick',
      icon: Icons.turn_right,
      color: Colors.teal,
      description: 'Đá từ băng vào bi mục tiêu',
    ),
    InterestOption(
      id: 'jump',
      name: 'Jump Shot',
      nameVi: 'Jump',
      icon: Icons.arrow_upward,
      color: Colors.red,
      description: 'Bi cái nhảy qua chướng ngại vật',
    ),
    InterestOption(
      id: 'masse',
      name: 'Masse',
      nameVi: 'Masse',
      icon: Icons.rotate_right,
      color: Colors.pink,
      description: 'Đánh xoáy ngược với độ cong lớn',
    ),
    InterestOption(
      id: 'safety',
      name: 'Safety Play',
      nameVi: 'An toàn',
      icon: Icons.shield,
      color: Colors.green,
      description: 'Đánh an toàn, không để đối thủ dễ đánh',
    ),
    InterestOption(
      id: '3cushion',
      name: '3 Cushion',
      nameVi: '3 Băng',
      icon: Icons.view_in_ar,
      color: Colors.indigo,
      description: 'Đánh chạm 3 băng trước khi đánh bi mục tiêu',
    ),
    InterestOption(
      id: 'trickshot',
      name: 'Trickshot',
      nameVi: 'Trickshot',
      icon: Icons.auto_awesome,
      color: Colors.amber,
      description: 'Những cú đánh đặc biệt, ảo diệu',
    ),
    InterestOption(
      id: 'break',
      name: 'Break Shot',
      nameVi: 'Khai cuộc',
      icon: Icons.flash_on,
      color: Colors.deepOrange,
      description: 'Cú phá bi, tạo cơ hội ghi điểm',
    ),
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

  void _continue() {
    // TODO: Save to user profile
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn thích học gì?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 8),
                  Text(
                    'Chọn những gì bạn muốn cải thiện. Điều này giúp AI đề xuất bài tập phù hợp với bạn.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppTheme.accentGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bạn có thể chọn nhiều hoặc bỏ trống. Tất cả bài tập đều mở cho bạn.',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),

            // Interest Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest.id);

                  return _InterestCard(
                    interest: interest,
                    isSelected: isSelected,
                    onTap: () => _toggleInterest(interest.id),
                  ).animate().fadeIn(delay: (300 + index * 50).ms);
                },
              ),
            ),

            // Selection count & Continue
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${_selectedInterests.length} sở thích đã chọn',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedInterests.isNotEmpty ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade200,
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterestOption {
  final String id;
  final String name;
  final String nameVi;
  final IconData icon;
  final Color color;
  final String description;

  const InterestOption({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _InterestCard extends StatelessWidget {
  final InterestOption interest;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestCard({
    required this.interest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? interest.color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? interest.color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: interest.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? interest.color.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                interest.icon,
                color: isSelected ? interest.color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              interest.nameVi,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? interest.color : AppTheme.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: interest.color,
                size: 18,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey.shade300,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
