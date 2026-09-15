// ============================================================================
// COACH SUGGESTION CHIPS - Phase 7B.2
// Quick suggestions for new users
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';


/// Coach Suggestion Chips
class CoachSuggestionChips extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const CoachSuggestionChips({
    super.key,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Hôm nay nên tập gì?',
      'Tại sao tôi đánh kém?',
      'Tôi nên cải thiện gì?',
    ];

    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary(brightness),
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.asMap().entries.map((entry) {
              return _SuggestionChip(
                text: entry.value,
                onTap: () => onSuggestionTap(entry.value),
              ).animate().fadeIn(delay: Duration(milliseconds: 600 + entry.key * 100));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            // Chữ dùng `primary` chứ không `accentLabel`: trên nền 10% cùng
            // tông, primary đạt 9.77 sáng / 4.71 tối, còn accentLabel chỉ 4.47
            // ở bản sáng.
            color: AppColors.primary(brightness).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary(brightness).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primary(brightness),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
