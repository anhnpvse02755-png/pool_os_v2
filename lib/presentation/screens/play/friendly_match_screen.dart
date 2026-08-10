import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class FriendlyMatchScreen extends StatefulWidget {
  const FriendlyMatchScreen({super.key});

  @override
  State<FriendlyMatchScreen> createState() => _FriendlyMatchScreenState();
}

class _FriendlyMatchScreenState extends State<FriendlyMatchScreen> {
  final _opponentNameController = TextEditingController();
  String _selectedGameType = '8-ball';
  String _selectedRaceTo = 'first-to-5';
  bool _includeSpectators = false;
  bool _friendlyMode = true;

  @override
  void dispose() {
    _opponentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu giao lưu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chơi với bạn bè',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tạo phòng và mời bạn tham gia',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Opponent Info
            Text(
              'Thông tin đối thủ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            TextField(
              controller: _opponentNameController,
              decoration: InputDecoration(
                labelText: 'Tên đối thủ',
                hintText: 'Nhập tên hoặc để trống',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 24),

            // Game Settings
            Text(
              'Cài đặt trận đấu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),

            // Game Type
            _SettingsTile(
              icon: Icons.sports_cricket,
              title: 'Loại game',
              value: _getGameTypeName(_selectedGameType),
              onTap: _showGameTypePicker,
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 8),

            // Race
            _SettingsTile(
              icon: Icons.emoji_events,
              title: 'Đấu đến',
              value: _getRaceName(_selectedRaceTo),
              onTap: _showRacePicker,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Options
            Text(
              'Tùy chọn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Chế độ thân thiện'),
              subtitle: const Text('Hiển thị gợi ý khi đánh'),
              value: _friendlyMode,
              onChanged: (v) => setState(() => _friendlyMode = v),
              activeColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ).animate().fadeIn(delay: 400.ms),

            SwitchListTile(
              title: const Text('Cho phép khán giả'),
              subtitle: const Text('Người khác có thể xem trận đấu'),
              value: _includeSpectators,
              onChanged: (v) => setState(() => _includeSpectators = v),
              activeColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 32),

            // Room Code Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã phòng sẽ được tạo tự động',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chia sẻ mã với đối thủ để tham gia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _createRoom,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tạo phòng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _joinRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Vào phòng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGameTypeName(String type) {
    switch (type) {
      case '8-ball':
        return '8-Ball';
      case '9-ball':
        return '9-Ball';
      case 'straight':
        return 'Straight Pool';
      default:
        return type;
    }
  }

  String _getRaceName(String race) {
    return race.replaceAll('first-to-', 'FT ');
  }

  void _showGameTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sports_cricket),
            title: const Text('8-Ball'),
            onTap: () {
              setState(() => _selectedGameType = '8-ball');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.circle_outlined),
            title: const Text('9-Ball'),
            onTap: () {
              setState(() => _selectedGameType = '9-ball');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Straight Pool'),
            onTap: () {
              setState(() => _selectedGameType = 'straight');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showRacePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('FT 3'),
            subtitle: const Text('First to 3'),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-3');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('FT 5'),
            subtitle: const Text('First to 5'),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-5');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('FT 7'),
            subtitle: const Text('First to 7'),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-7');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _createRoom() {
    // Show "Đang phát triển" dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.construction, color: Colors.blue),
            SizedBox(width: 8),
            Text('Đang phát triển'),
          ],
        ),
        content: const Text(
          'Tính năng tạo phòng đang được phát triển.\n\n'
          'Hiện tại bạn có thể sử dụng "Ghi nhận trận đấu" để ghi lại kết quả thi đấu.',
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

  void _joinRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập mã phòng'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'VD: ABC123',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.construction, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Đang phát triển'),
                    ],
                  ),
                  content: const Text(
                    'Tính năng vào phòng đang được phát triển.\n\n'
                    'Hiện tại bạn có thể sử dụng "Ghi nhận trận đấu" để ghi lại kết quả thi đấu.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Vào'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
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
