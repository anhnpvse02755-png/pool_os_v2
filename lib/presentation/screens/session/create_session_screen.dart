import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  String _selectedType = 'practice';
  int _energyLevel = 3;
  int _focusLevel = 3;
  int _confidenceLevel = 3;
  bool _isLoading = false;

  void _startSession() async {
    setState(() => _isLoading = true);

    // TODO: Call API to create session
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to active session
      context.go('/sessions');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo buổi chơi!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buổi chơi mới'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Type
            Text(
              'Loại buổi chơi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TypeCard(
                    icon: Icons.fitness_center,
                    label: 'Luyện tập',
                    isSelected: _selectedType == 'practice',
                    onTap: () => setState(() => _selectedType = 'practice'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    icon: Icons.emoji_events,
                    label: 'Giải đấu',
                    isSelected: _selectedType == 'tournament',
                    onTap: () => setState(() => _selectedType = 'tournament'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeCard(
                    icon: Icons.people,
                    label: 'Chơi vui',
                    isSelected: _selectedType == 'casual',
                    onTap: () => setState(() => _selectedType = 'casual'),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Readiness Section
            Text(
              'Tình trạng hiện tại',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Đánh giá tình trạng của bạn trước khi bắt đầu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Energy Level
            _ReadinessSlider(
              icon: Icons.bolt,
              label: 'Năng lượng',
              value: _energyLevel,
              labels: ['Thấp', 'Trung bình', 'Cao'],
              onChanged: (v) => setState(() => _energyLevel = v),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),

            // Focus Level
            _ReadinessSlider(
              icon: Icons.center_focus_strong,
              label: 'Tập trung',
              value: _focusLevel,
              labels: ['Mất tập trung', 'Bình thường', 'Rất tập trung'],
              onChanged: (v) => setState(() => _focusLevel = v),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),

            // Confidence Level
            _ReadinessSlider(
              icon: Icons.psychology,
              label: 'Sự tự tin',
              value: _confidenceLevel,
              labels: ['Không chắc', 'Bình thường', 'Rất tự tin'],
              onChanged: (v) => setState(() => _confidenceLevel = v),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),

            // Coach Insight Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.accentGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mẹo từ Coach',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Năng lượng thấp? Có thể ảnh hưởng đến độ chính xác của cú đánh. Cân nhắc khởi động kỹ hơn.',
                          style: TextStyle(
                            color: AppTheme.accentGold.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startSession,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Bắt đầu buổi chơi'),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _ReadinessSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              labels[value - 1],
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final isSelected = index < value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
