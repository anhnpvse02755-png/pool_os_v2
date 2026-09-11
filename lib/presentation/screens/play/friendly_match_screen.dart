import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';

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
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.surface(brightness),
        elevation: 0,
        title: Text(
          'Đấu giao lưu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(brightness)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary(brightness),
                    AppColors.primary(brightness).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary(brightness).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary(brightness).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.groups, color: AppColors.onPrimary(brightness), size: 32),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chơi với bạn bè',
                          style: TextStyle(
                            color: AppColors.onPrimary(brightness),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tạo phòng và mời bạn tham gia',
                          style: TextStyle(
                            color: AppColors.onPrimary(brightness).withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            SizedBox(height: AppSpacing.xxl),

            // Opponent Info
            Text(
              'Thông tin đối thủ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(delay: 100.ms),
            SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: TextField(
                controller: _opponentNameController,
                style: TextStyle(color: AppColors.textPrimary(brightness)),
                decoration: InputDecoration(
                  labelText: 'Tên đối thủ',
                  labelStyle: TextStyle(color: AppColors.textSecondary(brightness)),
                  hintText: 'Nhập tên hoặc để trống',
                  hintStyle: TextStyle(color: AppColors.textTertiary(brightness)),
                  prefixIcon: Icon(Icons.person, color: AppColors.textSecondary(brightness)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            SizedBox(height: AppSpacing.xxl),

            // Game Settings
            Text(
              'Cài đặt trận đấu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: AppSpacing.md),

            // Game Type
            _SettingsTile(
              icon: Icons.sports_cricket,
              title: 'Loại game',
              value: _getGameTypeName(_selectedGameType),
              onTap: _showGameTypePicker,
            ).animate().fadeIn(delay: 250.ms),

            SizedBox(height: AppSpacing.sm),

            // Race
            _SettingsTile(
              icon: Icons.emoji_events,
              title: 'Đấu đến',
              value: _getRaceName(_selectedRaceTo),
              onTap: _showRacePicker,
            ).animate().fadeIn(delay: 300.ms),

            SizedBox(height: AppSpacing.xxl),

            // Options
            Text(
              'Tùy chọn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(brightness),
                  ),
            ).animate().fadeIn(delay: 350.ms),
            SizedBox(height: AppSpacing.md),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border(brightness)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Chế độ thân thiện',
                      style: TextStyle(color: AppColors.textPrimary(brightness)),
                    ),
                    subtitle: Text(
                      'Hiển thị gợi ý khi đánh',
                      style: TextStyle(color: AppColors.textSecondary(brightness)),
                    ),
                    value: _friendlyMode,
                    onChanged: (v) => setState(() => _friendlyMode = v),
                    activeTrackColor: AppColors.primary(brightness),
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border(brightness)),
                  SwitchListTile(
                    title: Text(
                      'Cho phép khán giả',
                      style: TextStyle(color: AppColors.textPrimary(brightness)),
                    ),
                    subtitle: Text(
                      'Người khác có thể xem trận đấu',
                      style: TextStyle(color: AppColors.textSecondary(brightness)),
                    ),
                    value: _includeSpectators,
                    onChanged: (v) => setState(() => _includeSpectators = v),
                    activeTrackColor: AppColors.primary(brightness),
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            SizedBox(height: AppSpacing.xxl),

            // Room Code Info
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã phòng sẽ được tạo tự động',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(brightness),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Chia sẻ mã với đối thủ để tham gia',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          boxShadow: AppShadows.soft(brightness),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: _OutlinedButton(
                  onPressed: _createRoom,
                  label: 'Tạo phòng',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PrimaryButton(
                  onPressed: _joinRoom,
                  label: 'Vào phòng',
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
    final brightness = Theme.of(context).brightness;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      backgroundColor: AppColors.surface(brightness),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ListTile(
            leading: Icon(Icons.sports_cricket, color: AppColors.primary(brightness)),
            title: Text('8-Ball', style: TextStyle(color: AppColors.textPrimary(brightness))),
            onTap: () {
              setState(() => _selectedGameType = '8-ball');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.circle_outlined, color: AppColors.primary(brightness)),
            title: Text('9-Ball', style: TextStyle(color: AppColors.textPrimary(brightness))),
            onTap: () {
              setState(() => _selectedGameType = '9-ball');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.linear_scale, color: AppColors.primary(brightness)),
            title: Text('Straight Pool', style: TextStyle(color: AppColors.textPrimary(brightness))),
            onTap: () {
              setState(() => _selectedGameType = 'straight');
              Navigator.pop(context);
            },
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _showRacePicker() {
    final brightness = Theme.of(context).brightness;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      backgroundColor: AppColors.surface(brightness),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(brightness),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ListTile(
            title: Text('FT 3', style: TextStyle(color: AppColors.textPrimary(brightness), fontWeight: FontWeight.w600)),
            subtitle: Text('First to 3', style: TextStyle(color: AppColors.textSecondary(brightness))),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-3');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('FT 5', style: TextStyle(color: AppColors.textPrimary(brightness), fontWeight: FontWeight.w600)),
            subtitle: Text('First to 5', style: TextStyle(color: AppColors.textSecondary(brightness))),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-5');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('FT 7', style: TextStyle(color: AppColors.textPrimary(brightness), fontWeight: FontWeight.w600)),
            subtitle: Text('First to 7', style: TextStyle(color: AppColors.textSecondary(brightness))),
            onTap: () {
              setState(() => _selectedRaceTo = 'first-to-7');
              Navigator.pop(context);
            },
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _createRoom() {
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Row(
          children: [
            Icon(Icons.construction, color: AppColors.warning),
            SizedBox(width: AppSpacing.sm),
            Text('Đang phát triển', style: TextStyle(color: AppColors.textPrimary(brightness))),
          ],
        ),
        content: Text(
          'Tính năng tạo phòng đang được phát triển.\n\n'
          'Hiện tại bạn có thể sử dụng "Ghi nhận trận đấu" để ghi lại kết quả thi đấu.',
          style: TextStyle(color: AppColors.textSecondary(brightness)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: TextStyle(color: AppColors.primary(brightness))),
          ),
        ],
      ),
    );
  }

  void _joinRoom() {
    final brightness = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        title: Text('Nhập mã phòng', style: TextStyle(color: AppColors.textPrimary(brightness))),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'VD: ABC123',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary(brightness))),
          ),
          _DialogButton(
            label: 'Vào',
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  title: Row(
                    children: [
                      Icon(Icons.construction, color: AppColors.warning),
                      SizedBox(width: AppSpacing.sm),
                      Text('Đang phát triển', style: TextStyle(color: AppColors.textPrimary(brightness))),
                    ],
                  ),
                  content: Text(
                    'Tính năng vào phòng đang được phát triển.\n\n'
                    'Hiện tại bạn có thể sử dụng "Ghi nhận trận đấu" để ghi lại kết quả thi đấu.',
                    style: TextStyle(color: AppColors.textSecondary(brightness)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Đóng', style: TextStyle(color: AppColors.primary(brightness))),
                    ),
                  ],
                ),
              );
            },
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
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(brightness),
          border: Border.all(color: AppColors.border(brightness)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary(brightness).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: AppColors.primary(brightness), size: 20),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(brightness),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textSecondary(brightness),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary(brightness)),
          ],
        ),
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
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.onPressed != null ? AppColors.primary(brightness) : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: widget.onPressed != null
                ? [BoxShadow(color: AppColors.primary(brightness).withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4))]
                : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onPrimary(brightness)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _OutlinedButton({required this.onPressed, required this.label});

  @override
  State<_OutlinedButton> createState() => _OutlinedButtonState();
}

class _OutlinedButtonState extends State<_OutlinedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.primary(brightness), width: 2),
          ),
          child: Text(
            widget.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary(brightness)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const _DialogButton({required this.onPressed, required this.label});

  @override
  State<_DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<_DialogButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            widget.label,
            style: TextStyle(color: AppColors.onPrimary(brightness), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
