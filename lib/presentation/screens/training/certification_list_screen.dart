import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/certification.dart';

class CertificationListScreen extends StatelessWidget {
  const CertificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final certifications = CertificationLibrary.certifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Certification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo,
                    Colors.indigo.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Skill Certification',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kiểm tra kỹ năng của bạn và nhận chứng nhận. '
                    'Kết quả giúp bạn theo dõi tiến bộ.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ Certification không mở khóa Drill hay Level',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Certifications list
            ...certifications.asMap().entries.map((entry) {
              final index = entry.key;
              final cert = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CertificationCard(
                  certification: cert,
                  onTap: () => context.push('/training/certification/${cert.id}'),
                ).animate().fadeIn(delay: (index * 100).ms),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final SkillCertification certification;
  final VoidCallback onTap;

  const _CertificationCard({
    required this.certification,
    required this.onTap,
  });

  Color _getCategoryColor() {
    switch (certification.category) {
      case 'cueball':
        return Colors.blue;
      case 'potting':
        return Colors.orange;
      case 'position':
        return Colors.purple;
      case 'safety':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (certification.category) {
      case 'cueball':
        return Icons.circle_outlined;
      case 'potting':
        return Icons.center_focus_strong;
      case 'position':
        return Icons.gps_fixed;
      case 'safety':
        return Icons.shield;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certification.nameVi,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    certification.description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.quiz, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${certification.tests.length} bài kiểm tra',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
