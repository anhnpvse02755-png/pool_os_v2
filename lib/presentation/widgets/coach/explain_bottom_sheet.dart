// ============================================================================
// EXPLAIN BOTTOM SHEET - Phase 7B.2
// Global Explain Capability
//
// "Tại sao?" can be asked from anywhere
// Coach explains with data and reasoning
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

/// Explain Bottom Sheet - Global capability
class ExplainBottomSheet extends StatelessWidget {
  final String drillCode;
  final String explanation;
  final VoidCallback? onStartDrill;

  const ExplainBottomSheet({
    super.key,
    required this.drillCode,
    required this.explanation,
    this.onStartDrill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TẠI SAO?',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDrillDisplayName(drillCode),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coach Voice intro
                  Text(
                    'Mình khuyên $drillCode vì:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // Explanation content
                  _buildExplanationContent(context, explanation),

                  const SizedBox(height: 24),

                  // Confidence
                  _buildConfidenceSection(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hiểu rồi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onStartDrill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BẮT ĐẦU ${drillCode.toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildExplanationContent(BuildContext context, String explanation) {
    // Parse and display explanation sections
    final lines = explanation.split('\n');
    final widgets = <Widget>[];

    int sectionNumber = 0;
    String? currentSection;
    final currentItems = <String>[];

    for (final line in lines) {
      if (line.endsWith(':')) {
        // Save previous section
        if (currentSection != null && currentItems.isNotEmpty) {
          widgets.add(_buildSection(context, currentSection, currentItems, sectionNumber));
          sectionNumber++;
        }
        currentSection = line;
        currentItems.clear();
      } else if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        currentItems.add(line.trim().substring(1).trim());
      } else if (line.trim().isNotEmpty) {
        currentItems.add(line.trim());
      }
    }

    // Save last section
    if (currentSection != null && currentItems.isNotEmpty) {
      widgets.add(_buildSection(context, currentSection, currentItems, sectionNumber));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<String> items,
    int index,
  ) {
    final icons = ['1️⃣', '2️⃣', '3️⃣', '4️⃣'];
    final emoji = index < icons.length ? icons[index] : '${index + 1}.';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildConfidenceSection(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.verified_outlined, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          'Confidence: 75%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }

  String _getDrillDisplayName(String code) {
    // Simple display name mapping
    final names = {
      'straight_shot': 'Straight Shot',
      'stop_ball': 'Stop Ball',
      'follow_shot': 'Follow Shot',
      'draw_shot': 'Draw Shot',
      'speed_control': 'Speed Control',
      'position_play': 'Position Play',
      'bank_shot': 'Bank Shot',
      'safety_play': 'Safety Play',
      'break_shot': 'Break Shot',
      'long_shot': 'Long Shot',
    };
    return names[code] ?? code;
  }
}
