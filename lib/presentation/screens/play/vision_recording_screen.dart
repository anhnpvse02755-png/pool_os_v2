import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class VisionRecordingScreen extends ConsumerStatefulWidget {
  const VisionRecordingScreen({super.key});

  @override
  ConsumerState<VisionRecordingScreen> createState() => _VisionRecordingScreenState();
}

class _VisionRecordingScreenState extends ConsumerState<VisionRecordingScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Recording'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(),
            const SizedBox(height: 32),

            // Features
            _buildFeaturesSection(),
            const SizedBox(height: 32),

            // How it works
            _buildHowItWorksSection(),
            const SizedBox(height: 32),

            // Beta signup
            _buildBetaSignupSection(),
            const SizedBox(height: 32),

            // Equipment requirements
            _buildRequirementsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Camera animation placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fiber_manual_record,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms),

          const SizedBox(height: 24),

          const Text(
            'Vision Auto Recording',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Ghi lại trận đấu tự động bằng AI',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, color: Colors.black87, size: 18),
                SizedBox(width: 8),
                Text(
                  'Sắp ra mắt',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.circle_outlined,
        'title': 'Ball Detection',
        'description': 'Nhận diện vị trí tất cả các bi trên bàn',
        'color': Colors.blue,
      },
      {
        'icon': Icons.route,
        'title': 'Shot Tracking',
        'description': 'Theo dõi đường đi của từng bi',
        'color': Colors.green,
      },
      {
        'icon': Icons.analytics,
        'title': 'Auto Scoring',
        'description': 'Tính điểm tự động chính xác',
        'color': Colors.orange,
      },
      {
        'icon': Icons.psychology,
        'title': 'AI Analysis',
        'description': 'Phân tích cú đánh và đưa ra gợi ý',
        'color': Colors.purple,
      },
      {
        'icon': Icons.share,
        'title': 'Share Highlights',
        'description': 'Chia sẻ khoảnh khắc đẹp lên mạng xã hội',
        'color': Colors.red,
      },
      {
        'icon': Icons.history,
        'title': 'Match History',
        'description': 'Lưu trữ và xem lại tất cả các trận đấu',
        'color': Colors.teal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tính năng',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 100).ms);
          },
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    final steps = [
      {
        'number': '1',
        'title': 'Đặt Camera',
        'description': 'Đặt camera phía trên bàn và căn chỉnh',
      },
      {
        'number': '2',
        'title': 'Calibrate',
        'description': 'Quét mã QR trên bàn để AI nhận diện',
      },
      {
        'number': '3',
        'title': 'Bắt đầu',
        'description': 'AI tự động ghi lại trận đấu',
      },
      {
        'number': '4',
        'title': 'Xem & Chia sẻ',
        'description': 'Xem lại, phân tích và chia sẻ',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cách hoạt động',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step['number'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: (index * 150).ms);
        }),
      ],
    );
  }

  Widget _buildBetaSignupSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đăng ký Beta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Trở thành người dùng đầu tiên trải nghiệm',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email input
          TextField(
            decoration: InputDecoration(
              hintText: 'Nhập email của bạn',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.email, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 12),

          // Notify toggle
          SwitchListTile(
            title: const Text(
              'Nhận thông báo khi có bản beta',
              style: TextStyle(fontSize: 14),
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeColor: AppTheme.primaryGreen,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn! Chúng tôi sẽ liên hệ khi có bản beta.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng ký Beta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRequirementsSection() {
    final requirements = [
      {'icon': Icons.phone_android, 'text': 'Android 10+ hoặc iOS 15+'},
      {'icon': Icons.camera_alt, 'text': 'Camera có độ phân giải tối thiểu 1080p'},
      {'icon': Icons.wifi, 'text': 'Kết nối internet ổn định'},
      {'icon': Icons.table_restaurant, 'text': 'Bàn billiards tiêu chuẩn 9ft hoặc 12ft'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu cầu',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        Container(
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
            children: requirements.asMap().entries.map((entry) {
              final index = entry.key;
              final req = entry.value;
              final isLast = index == requirements.length - 1;

              return Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        req['icon'] as IconData,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          req['text'] as String,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                    ],
                  ),
                  if (!isLast) const Divider(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Về Vision Recording'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vision Recording sử dụng công nghệ AI và Computer Vision để tự động ghi lại và phân tích trận đấu billiards của bạn.',
            ),
            SizedBox(height: 12),
            Text(
              'Công nghệ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('- Ball Detection (YOLO)'),
            Text('- Shot Tracking (Optical Flow)'),
            Text('- Table Calibration (OpenCV)'),
            SizedBox(height: 12),
            Text(
              'Bảo mật:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('- Dữ liệu được mã hóa end-to-end'),
            Text('- Chỉ bạn mới có quyền truy cập'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
