import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'providers/auth_form_provider.dart';
import 'widgets/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(signUpControllerProvider.notifier).signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(signUpControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join CreateResume AI',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start building your professional resume today.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Full Name Input
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Alex Johnson',
                    prefixIcon: Icons.person_rounded,
                    keyboardType: TextInputType.name,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 24),

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
                  ),
                  const SizedBox(height: 24),

                  // Confirm Password Input
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (val) => Validators.confirmPassword(
                        val, _passwordController.text),
                    onFieldSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Button
                  Semantics(
                    button: true,
                    label: 'Create account',
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleSignUp,
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Sign Up'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Semantics(
                        button: true,
                        label: 'Sign in to existing account',
                        child: TextButton(
                          onPressed: () => context.pop(), // Go back to login
                          child: const Text('Sign In'),
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
