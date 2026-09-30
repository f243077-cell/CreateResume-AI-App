import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/application/providers/connectivity_provider.dart';
import 'package:createresume_app/application/providers/current_profile_provider.dart';
import 'package:createresume_app/core/di/service_locator.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_resume_repository.dart';
import 'package:createresume_app/domain/repositories/i_user_profile_repository.dart';
import 'package:createresume_app/presentation/modules/ai_tool_library/providers/ai_tool_notifier.dart';
import 'package:createresume_app/presentation/modules/home_dashboard/providers/home_dashboard_notifier.dart';
import 'package:createresume_app/presentation/modules/user_profile_settings/providers/user_profile_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

class MockResumeRepository extends Mock implements IResumeRepository {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  setUpAll(() => registerFallbackValue(const User(id: '', email: '', fullName: '')));

  const profile = User(id: 'u1', email: 'a@b.test', fullName: 'Ana', creditBalance: 3);

  late MockUserProfileRepository profileRepo;
  late ProviderContainer container;

  setUp(() async {
    profileRepo = MockUserProfileRepository();
    final resumeRepo = MockResumeRepository();
    final connectivity = MockConnectivity();
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
    when(() => profileRepo.getProfile('u1')).thenAnswer((_) async => const Right(profile));
    when(() => profileRepo.updateProfile(any()))
        .thenAnswer((inv) async => Right(inv.positionalArguments.first as User));
    when(() => resumeRepo.getResumeSummaries('u1', limit: any(named: 'limit')))
        .thenAnswer((_) async => const Right([]));

    container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(profile)),
      userProfileRepositoryProvider.overrideWithValue(profileRepo),
      resumeRepositoryProvider.overrideWithValue(resumeRepo),
      connectivityServiceProvider.overrideWithValue(connectivity),
    ]);
    // Dashboard, Settings and AI tools are all open.
    container.listen(homeDashboardProvider, (_, _) {});
    container.listen(userProfileProvider, (_, _) {});
    container.listen(aiToolProvider, (_, _) {});
    await container.read(homeDashboardProvider.future);
  });

  tearDown(() => container.dispose());

  test('the profile is fetched once for all screens', () {
    expect(container.read(homeDashboardProvider).value?.user, profile);
    expect(container.read(userProfileProvider).profile, profile);
    expect(container.read(aiToolProvider).profile, profile);
    verify(() => profileRepo.getProfile('u1')).called(1);
  });

  test('a name change in Settings reaches the dashboard without a refetch', () async {
    await container.read(userProfileProvider.notifier).updateProfile(fullName: 'Ana B');
    await container.read(homeDashboardProvider.future);

    expect(container.read(homeDashboardProvider).value?.user?.fullName, 'Ana B');
    expect(container.read(aiToolProvider).profile?.fullName, 'Ana B');
    verify(() => profileRepo.getProfile('u1')).called(1);
  });

  test('a new credit balance shows on every screen', () async {
    container.read(currentProfileProvider.notifier).setCreditBalance(1);
    await container.read(homeDashboardProvider.future);

    expect(container.read(homeDashboardProvider).value?.user?.creditBalance, 1);
    expect(container.read(userProfileProvider).profile?.creditBalance, 1);
    expect(container.read(aiToolProvider).profile?.creditBalance, 1);
  });
}
