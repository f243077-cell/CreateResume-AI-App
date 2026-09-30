import 'dart:async';

import 'package:createresume_app/app_router.dart';
import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/core/routing/app_routes.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appRedirect', () {
    String? go(String location, {bool auth = false, bool? seen = true, bool loading = false, bool recovery = false}) =>
        appRedirect(
          location: location,
          authLoading: loading,
          isAuthenticated: auth,
          seenOnboarding: seen,
          isRecovery: recovery,
        );

    test('root goes to onboarding, home or login', () {
      expect(go(AppRoutes.root, seen: false), AppRoutes.onboarding);
      expect(go(AppRoutes.root, auth: true), AppRoutes.home);
      expect(go(AppRoutes.root), AppRoutes.login);
    });

    test('signed-out users are sent to login, except auth pages and onboarding', () {
      expect(go(AppRoutes.home), AppRoutes.login);
      expect(go(AppRoutes.login), isNull);
      expect(go(AppRoutes.signup), isNull);
      expect(go(AppRoutes.onboarding), isNull);
    });

    test('signed-in users skip auth pages', () {
      expect(go(AppRoutes.login, auth: true), AppRoutes.home);
      expect(go(AppRoutes.allResumes, auth: true), isNull);
    });

    test('password recovery wins, and the reset page is kept', () {
      expect(go(AppRoutes.home, auth: true, recovery: true), AppRoutes.resetPassword);
      expect(go(AppRoutes.resetPassword, recovery: true), isNull);
    });

    test('waits while auth or onboarding state is loading', () {
      expect(go(AppRoutes.home, loading: true), isNull);
      expect(go(AppRoutes.home, seen: null), isNull);
    });
  });

  test('the router is built once; auth and recovery changes do not replace it', () async {
    final auth = StreamController<User?>();
    final container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => auth.stream),
      seenOnboardingProvider.overrideWith((ref) async => true),
    ]);
    addTearDown(() async {
      container.dispose();
      await auth.close();
    });

    final router = container.read(routerProvider);
    container.listen(routerProvider, (_, _) {});

    auth.add(const User(id: 'u1', email: 'a@b.test', fullName: 'A'));
    await Future<void>.delayed(Duration.zero);
    container.read(passwordRecoveryProvider.notifier).set(true);
    auth.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(identical(container.read(routerProvider), router), isTrue);
  });
}
