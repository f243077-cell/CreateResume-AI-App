/// Central route paths and names for [GoRouter] navigation.
abstract final class AppRoutes {
  static const root = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const resumeWizard = '/resume-wizard';
  static const resumeEditor = '/resume-editor';
  static const resumeAnalyzer = '/resume-analyzer';
  static const applicationTracker = '/application-tracker';
  static const aiTools = '/ai-tools';
  static const profile = '/profile';
  static const subscription = '/subscription';

  static String resumeEditorPath(String resumeId) =>
      '$resumeEditor/$resumeId';

  static String resumeAnalyzerPath(String resumeId) =>
      '$resumeAnalyzer/$resumeId';
}

abstract final class AppRouteNames {
  static const root = 'root';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const signup = 'signup';
  static const forgotPassword = 'forgotPassword';
  static const home = 'home';
  static const resumeWizard = 'resumeWizard';
  static const resumeEditor = 'resumeEditor';
  static const resumeAnalyzer = 'resumeAnalyzer';
  static const resumeAnalyzerDetail = 'resumeAnalyzerDetail';
  static const applicationTracker = 'applicationTracker';
  static const aiTools = 'aiTools';
  static const profile = 'profile';
  static const subscription = 'subscription';
}
