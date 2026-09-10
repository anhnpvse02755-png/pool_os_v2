import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/models/certification.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/pool_card.dart';
import '../../widgets/soft_background.dart';

/// Ô pastel của một danh mục certification.
///
/// Năm danh mục vượt quá bốn hue tách bạch của hệ (`error` 0°, `warning` 38°,
/// họ xanh rêu 157–163°, `difficultyExpert` 262°), nên cả BỘ chuyển sang bảng
/// pastel 5 tông thay vì ép hai thành viên vào cùng một dải hue.
///
/// Khoá theo ID danh mục chứ KHÔNG theo vị trí trong danh sách: người dùng học
/// được màu, nên 'safety' phải luôn là ô bạc hà dù thư viện có sắp xếp lại.
int _toneForCategory(String category) {
  /// Mỗi tông chọn theo hue GẦN NHẤT với hằng Material mà nó thay, để người
  /// dùng cũ không phải học lại bảng màu.
  switch (category) {
    case 'cueball':
      return 1; // xanh dương (216°/213°) thay hằng lam 207°
    case 'potting':
      return 2; // đào (24°/22°) thay hằng cam 36°
    case 'position':
      return 3; // tử đinh hương (261°/258°) thay hằng tím 291°
    case 'safety':
      return 0; // bạc hà (148°/163°) thay hằng lục 122°
    default:
      return 4; // bơ (43°/51°) — tông còn lại, thay hằng xám
  }
}

class CertificationListScreen extends StatelessWidget {
  const CertificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final certifications = CertificationLibrary.certifications;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        title: const Text('Skill Certification'),
        backgroundColor: AppColors.surface(brightness),
        foregroundColor: AppColors.textPrimary(brightness),
        elevation: 0,
      ),
      body: SoftBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              //
              // LOANG, không phải tô đặc — cùng cái bẫy và cùng cách sửa như
              // header của `drill_detail_screen` và thẻ tỉ lệ của
              // `drill_result_screen`.
              //
              // Bản cũ tô đặc hằng chàm Material -> chàm@0.8 rồi đặt ba lớp
              // chữ trắng lên. Đuôi gradient mới là chỗ hỏng: ở chế độ sáng nó
              // hoà xuống nền trang, nên chữ trắng 18px chỉ còn 4.46:1, dòng
              // 13px (trắng@0.9) còn 3.96:1 và dòng 12px (trắng@0.8) còn
              // 3.49:1 — cả ba đều dưới sàn 4.5:1, vì `titleLarge` của theme
              // này là 16px w600 chứ không phải 22px của Material nên KHÔNG có
              // dòng nào được tính là "chữ lớn". Đuôi alpha 0.8 cũng dưới sàn
              // 0.86 mà lô anh em vừa đo ra.
              //
              // Loang 0.18 -> 0.10 trên `background` xoá cả hai vấn đề: nền hết
              // bão hoà nên chữ về `textPrimary` và đạt 8.84–13.83:1 ở cả hai
              // chế độ, và không còn đuôi gradient nào để phải cân alpha.
              //
              // `withValues` trên nền Container là hợp lệ: luật cấm alpha chỉ
              // áp cho MÀU CHỮ.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary(brightness).withValues(alpha: 0.18),
                      AppColors.primary(brightness).withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified,
                            color: AppColors.primary(brightness)),
                        const SizedBox(width: 8),
                        Text(
                          'Skill Certification',
                          style: TextStyle(
                            color: AppColors.textPrimary(brightness),
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
                        color: AppColors.textPrimary(brightness),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Glyph cảnh báo dạng emoji ở đầu chuỗi cũ nay là một
                    // Material icon; CHỮ giữ nguyên từng từ. Emoji hiển thị
                    // khác nhau giữa các hệ điều hành và trình đọc màn hình đọc
                    // TÊN nó nghe lạc lõng — đúng lý do `IconTile` được viết
                    // ra, và là luật vệ sinh token số 4.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.textPrimary(brightness),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Certification không mở khóa Drill hay Level',
                            style: TextStyle(
                              color: AppColors.textPrimary(brightness),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
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
                    onTap: () =>
                        context.push('/training/certification/${cert.id}'),
                  ).animate().fadeIn(delay: (index * 100).ms),
                );
              }),
            ],
          ),
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
    final brightness = Theme.of(context).brightness;

    return PoolCard(
      onTap: onTap,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconTile(
            icon: _getCategoryIcon(),
            toneIndex: _toneForCategory(certification.category),
            size: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.nameVi,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  certification.description,
                  style: TextStyle(
                    color: AppColors.textSecondary(brightness),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.quiz,
                        size: 14,
                        color: AppColors.textSecondary(brightness)),
                    const SizedBox(width: 4),
                    Text(
                      '${certification.tests.length} bài kiểm tra',
                      style: TextStyle(
                        color: AppColors.textSecondary(brightness),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: AppColors.textTertiary(brightness)),
        ],
      ),
    );
  }
}
