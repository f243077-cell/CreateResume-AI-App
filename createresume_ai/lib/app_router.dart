import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'application/providers/auth_state_provider.dart';
import 'core/routing/app_routes.dart';
import 'presentation/modules/all_resumes/screens/all_resumes_screen.dart';
import 'presentation/modules/application_tracker/screens/application_tracker_screen.dart';
import 'presentation/modules/authentication/forgot_password_screen.dart';
import 'presentation/modules/authentication/login_screen.dart';
import 'presentation/modules/authentication/signup_screen.dart';
import 'presentation/modules/home_dashboard/screens/home_dashboard_screen.dart';
import 'presentation/modules/onboarding/onboarding_screen.dart';
import 'presentation/modules/resume_analyzer/screens/resume_analyzer_screen.dart';
import 'presentation/modules/resume_analyzer/screens/resume_picker_screen.dart';
import 'presentation/modules/resume_editor/screens/resume_editor_screen.dart';
import 'presentation/modules/resume_wizard/screens/resume_wizard_screen.dart';
import 'presentation/modules/subscription/screens/subscription_screen.dart';
import 'presentation/modules/template_selection/screens/template_selection_screen.dart';
import 'presentation/modules/user_profile_settings/screens/user_profile_screen.dart';
import 'presentation/widgets/scaffold_with_nav_bar.dart';

/// The global router provider for the app.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = authState.value != null;
      final location = state.uri.path;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;
      final isOnboarding = location == AppRoutes.onboarding;
      final isRoot = location == AppRoutes.root;

      if (isRoot) {
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }

      if (isAuthenticated) {
        if (isAuthRoute || isOnboarding) {
          return AppRoutes.home;
        }
      } else {
        if (!isAuthRoute && !isOnboarding) {
          return AppRoutes.login;
        }
      }

      return null;
    },
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
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
        path: AppRoutes.resumeWizard,
        name: AppRouteNames.resumeWizard,
        builder: (context, state) => const ResumeWizardScreen(),
      ),
      GoRoute(
        path: AppRoutes.allResumes,
        name: AppRouteNames.allResumes,
        builder: (context, state) => const AllResumesScreen(),
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
          return ResumeEditorScreen(resumeId: resumeId);
        },
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: AppRouteNames.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
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
                path: AppRoutes.resumeAnalyzer,
                name: AppRouteNames.resumeAnalyzer,
                builder: (context, state) => const ResumePickerScreen(),
                routes: [
                  GoRoute(
                    path: ':resumeId',
                    name: AppRouteNames.resumeAnalyzerDetail,
                    builder: (context, state) {
                      final resumeId = state.pathParameters['resumeId']!;
                      return ResumeAnalyzerScreen(resumeId: resumeId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.applicationTracker,
                name: AppRouteNames.applicationTracker,
                builder: (context, state) => const ApplicationTrackerScreen(),
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
