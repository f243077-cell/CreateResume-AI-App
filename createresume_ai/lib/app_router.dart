// File: lib/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/providers/auth_state_provider.dart';
import 'core/routing/app_routes.dart';
import 'presentation/modules/all_resumes/screens/all_resumes_screen.dart';
import 'presentation/modules/authentication/forgot_password_screen.dart';
import 'presentation/modules/authentication/login_screen.dart';
import 'presentation/modules/authentication/reset_password_screen.dart';
import 'presentation/modules/authentication/signup_screen.dart';
import 'presentation/modules/home_dashboard/screens/home_dashboard_screen.dart';
import 'presentation/modules/onboarding/onboarding_screen.dart';
import 'presentation/modules/resume_editor/screens/resume_editor_screen.dart';
import 'presentation/modules/resume_wizard/screens/resume_wizard_screen.dart';
import 'presentation/modules/subscription/screens/subscription_screen.dart';
import 'presentation/modules/template_selection/screens/template_selection_screen.dart';
import 'presentation/modules/user_profile_settings/screens/user_profile_screen.dart';
import 'presentation/widgets/scaffold_with_nav_bar.dart';

final seenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('seen_onboarding') ?? false;
});
final passwordRecoveryProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final seenOnboardingAsync = ref.watch(seenOnboardingProvider);
  final seenOnboarding = seenOnboardingAsync.value;
  final isRecovery = ref.watch(passwordRecoveryProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    redirect: (context, state) {
      final location = state.uri.path;
      final isResetPassword = location == AppRoutes.resetPassword;

      // Already on reset password screen — stay there.
      if (isResetPassword) return null;

      // Recovery mode active — force navigation to reset-password from
      // any other route (especially '/' after router recreation).
      if (isRecovery) return AppRoutes.resetPassword;

      if (authState.isLoading || seenOnboarding == null) return null;

      final isAuthenticated = authState.value != null;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;
      final isOnboarding = location == AppRoutes.onboarding;
      final isRoot = location == AppRoutes.root;

      if (isRoot) {
        if (!seenOnboarding) return AppRoutes.onboarding;
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) return AppRoutes.home;

      if (!isAuthenticated && !isAuthRoute && !isOnboarding) {
        return AppRoutes.login;
      }

      return null;
    },
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resumeWizard,
        name: AppRouteNames.resumeWizard,
        builder: (context, state) => const ResumeWizardScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.templateSelection}/:resumeId',
        name: AppRouteNames.templateSelection,
        builder: (context, state) {
          final resumeId = state.pathParameters['resumeId']!;
          return TemplateSelectionScreen(resumeId: resumeId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.resumeEditor}/:resumeId',
        name: AppRouteNames.resumeEditor,
        builder: (context, state) {
          final resumeId = state.pathParameters['resumeId']!;
          final templateId = state.uri.queryParameters['templateId'];
          return ResumeEditorScreen(
            resumeId: resumeId,
            initialTemplateId: templateId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: AppRouteNames.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.allResumes,
                name: AppRouteNames.allResumes,
                builder: (context, state) => const AllResumesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const UserProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
