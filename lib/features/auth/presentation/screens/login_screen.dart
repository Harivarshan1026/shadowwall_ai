/// Login screen — authentication entry point.
///
/// Features email/password login, Google sign-in,
/// and navigation to register/forgot password.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Navigate on successful auth
    ref.listen(authNotifierProvider, (_, state) {
      if (state.status == AuthStatus.authenticated) {
        context.go(RoutePaths.dashboard);
      }
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // ── Logo & Title ──
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // ── Login Form ──
                    _buildLoginForm(authState),
                    const SizedBox(height: 24),

                    // ── Social Login ──
                    _buildSocialLogin(authState),
                    const SizedBox(height: 24),

                    // ── Register Link ──
                    _buildRegisterLink(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Official App Logo with Cyber Glow
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 44),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ShadowWall AI',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.darkOnSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Intelligent Cyber Safety Companion',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkOnSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState authState) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.darkOnSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue protecting your digital world',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Email
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),

            // Password
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.darkOnSurfaceVariant,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) =>
                  v != null && v.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 8),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push(RoutePaths.forgotPassword),
                child: Text(
                  'Forgot Password?',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryCyan,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Login Button
            GradientButton(
              label: 'Sign In',
              icon: Icons.login_rounded,
              isLoading: authState.status == AuthStatus.loading,
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin(AuthState authState) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkOnSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Google Sign-In Button
        SocialLoginButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          onPressed: authState.status == AuthStatus.loading
              ? null
              : () => ref
                  .read(authNotifierProvider.notifier)
                  .signInWithGoogle(),
        ),
        const SizedBox(height: 12),

        // Guest / Instant Access Button
        SocialLoginButton(
          label: 'Continue as Guest',
          icon: Icons.person_outline_rounded,
          onPressed: authState.status == AuthStatus.loading
              ? null
              : () => ref
                  .read(authNotifierProvider.notifier)
                  .signInAnonymously(),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.darkOnSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(RoutePaths.register),
          child: Text(
            'Sign Up',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
