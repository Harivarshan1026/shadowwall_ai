/// Forgot password screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authNotifierProvider.notifier)
          .forgotPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    color: AppColors.darkOnSurface,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _emailSent
                        ? Icons.mark_email_read_rounded
                        : Icons.lock_reset_rounded,
                    color: AppColors.primaryCyan,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  _emailSent ? 'Email Sent!' : 'Reset Password',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.darkOnSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _emailSent
                      ? 'Check your inbox for the password reset link'
                      : 'Enter your email to receive a password reset link',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkOnSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (!_emailSent)
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your registered email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 24),
                          GradientButton(
                            label: 'Send Reset Link',
                            icon: Icons.send_rounded,
                            isLoading: authState.status == AuthStatus.loading,
                            onPressed: _handleReset,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GlassCard(
                    glowColor: AppColors.neonGreen,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.neonGreen,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A password reset link has been sent to:',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.darkOnSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _emailController.text,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primaryCyan,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          label: 'Back to Login',
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
