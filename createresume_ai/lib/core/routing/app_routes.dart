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
  static const allResumes = '/all-resumes';
  static const resumeAnalyzer = '/resume-analyzer';
  static const applicationTracker = '/application-tracker';
  static const profile = '/profile';
  static const subscription = '/subscription';
  static const templateSelection = '/template-selection';

  static String resumeEditorPath(String resumeId) =>
      '$resumeEditor/$resumeId';

  static String resumeAnalyzerPath(String resumeId) =>
      '$resumeAnalyzer/$resumeId';

  static String templateSelectionPath(String resumeId) =>
      '$templateSelection/$resumeId';
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
  static const allResumes = 'allResumes';
  static const resumeAnalyzer = 'resumeAnalyzer';
  static const resumeAnalyzerDetail = 'resumeAnalyzerDetail';
  static const applicationTracker = 'applicationTracker';
  static const profile = 'profile';
  static const subscription = 'subscription';
  static const templateSelection = 'templateSelection';
}
