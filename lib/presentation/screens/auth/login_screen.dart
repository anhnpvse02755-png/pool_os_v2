import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/soft_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      context.go('/home');
    } else {
      setState(() {
        _errorMessage = 'Email hoặc mật khẩu không đúng';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background(brightness),
      body: SoftBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Logo
              const Center(
                child: IconTile(
                  icon: Icons.pool,
                  toneIndex: 0,
                  size: 80,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'PoolOS',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary(brightness),
                      letterSpacing: 2,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'AI Pool Training Platform',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(brightness),
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.xxl),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorSubtle(brightness),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      // Icon và chữ nằm TRÊN nền `errorSubtle` — nền dịu cùng
                      // tông. Tông gốc ở đó chỉ 3.44:1 bản sáng.
                      Icon(Icons.error_outline,
                          color: AppColors.errorOnTint(brightness), size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: AppColors.errorOnTint(brightness),
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    _StyledTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      labelText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: AppSpacing.md),

                    // Password
                    _StyledTextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
                      prefixIcon: Icons.lock_outlined,
                      labelText: 'Mật khẩu',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary(brightness),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: AppSpacing.sm),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tính năng đang phát triển'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Quên mật khẩu?',
                          style:
                              TextStyle(color: AppColors.primary(brightness)),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Sign in button
                    _PrimaryButton(
                      onPressed: _isLoading ? null : _signIn,
                      isLoading: _isLoading,
                      label: 'Đăng nhập',
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Divider
              Row(
                children: [
                  Expanded(
                      child: Divider(color: AppColors.border(brightness))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'hoặc',
                      style:
                          TextStyle(color: AppColors.textSecondary(brightness)),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: AppColors.border(brightness))),
                ],
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: AppSpacing.lg),


              const SizedBox(height: AppSpacing.xl),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style:
                        TextStyle(color: AppColors.textSecondary(brightness)),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/register'),
                    child: Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: AppColors.primary(brightness),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData prefixIcon;
  final String labelText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    required this.prefixIcon,
    required this.labelText,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: AppColors.textPrimary(brightness)),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.textSecondary(brightness)),
        prefixIcon: Icon(prefixIcon,
            color: AppColors.textSecondary(brightness), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface(brightness),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border(brightness)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border(brightness)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide:
              BorderSide(color: AppColors.primary(brightness), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const _PrimaryButton({
    required this.onPressed,
    this.isLoading = false,
    required this.label,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final enabled = widget.onPressed != null;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: widget.onPressed != null ? (_) => setState(() => _scale = 0.96) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _scale = 1.0) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary(brightness)
                : AppColors.textTertiary(brightness),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary(brightness)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary(brightness),
                    ),
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary(brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
