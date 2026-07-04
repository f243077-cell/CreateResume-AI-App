import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'providers/auth_form_provider.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(signInControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
    // Note: On success, the authStateProvider will emit a user,
    // and go_router's redirect logic will automatically push to /home.
  }

  Future<void> _handleGoogleSignIn() async {
    final error =
        await ref.read(signInControllerProvider.notifier).signInWithGoogle();

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(signInControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // App Logo / Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: theme.colorScheme.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your professional journey',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),

                  // Email Input
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'alex@example.com',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 24),

                  // Password Input
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _handleSignIn(),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      button: true,
                      label: 'Reset password',
                      child: TextButton(
                        onPressed: () => context.pushNamed(AppRouteNames.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  Semantics(
                    button: true,
                    label: 'Sign in to account',
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleSignIn,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Auth Buttons
                  Semantics(
                    button: true,
                    label: 'Continue with Google',
                    child: OutlinedButton.icon(
                      onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata, size: 32),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      Semantics(
                        button: true,
                        label: 'Create new account',
                        child: TextButton(
                          onPressed: () => context.pushNamed(AppRouteNames.signup),
                          child: const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
