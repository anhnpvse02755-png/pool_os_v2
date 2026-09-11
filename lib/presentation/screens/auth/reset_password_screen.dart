// ============================================================================
// RESET PASSWORD SCREEN
// ============================================================================
//
// Đích của link trong email đặt lại mật khẩu:
//   https://poolos.kjdybl.easypanel.host/reset-password?token=...
//
// App dùng hash routing nên GoRouter không tự đọc được đường dẫn dạng path.
// Token lấy từ `Uri.base.queryParameters` (xem `initialLocationFromUrl` trong
// app_router.dart), rồi truyền vào đây.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../widgets/soft_background.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.token});

  /// Token từ query string. Null nghĩa là người dùng vào thẳng màn này.
  final String? token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _error =
          'Thiếu mã đặt lại. Hãy mở lại liên kết trong email, hoặc yêu cầu gửi lại.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await ref
        .read(authProvider.notifier)
        .resetPassword(token, _passwordController.text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _done = ok;
      _error = ok ? null : ref.read(authProvider).error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary(brightness),
        title: const Text('Đặt lại mật khẩu'),
      ),
      body: SoftBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _done ? _buildDone(brightness) : _buildForm(brightness),
          ),
        ),
      ),
    );
  }

  Widget _buildDone(Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.check_circle_outline,
            size: 64, color: AppColors.success),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Đã đổi mật khẩu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Bạn có thể đăng nhập bằng mật khẩu mới.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary(brightness)),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => context.go('/auth/login'),
          child: const Text('Đăng nhập'),
        ),
      ],
    );
  }

  Widget _buildForm(Brightness brightness) {
    final missingToken = widget.token == null || widget.token!.isEmpty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nhập mật khẩu mới cho tài khoản của bạn.',
            style: TextStyle(color: AppColors.textSecondary(brightness)),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (missingToken)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warningSubtle(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                'Không tìm thấy mã đặt lại trong liên kết. Hãy mở lại email, '
                'hoặc yêu cầu gửi lại từ màn đăng nhập.',
                style: TextStyle(color: AppColors.textPrimary(brightness)),
              ),
            ),

          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Nhập mật khẩu mới';
              if (v.length < 8) return 'Mật khẩu cần ít nhất 8 ký tự';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nhập lại mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) =>
                v == _passwordController.text ? null : 'Hai mật khẩu chưa khớp',
          ),

          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorSubtle(brightness),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.errorOnTint(brightness), size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(
                            color: AppColors.errorOnTint(brightness),
                            fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Đổi mật khẩu'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}
