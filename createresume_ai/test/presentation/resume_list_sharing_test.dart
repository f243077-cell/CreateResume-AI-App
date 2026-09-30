import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/application/providers/connectivity_provider.dart';
import 'package:createresume_app/core/di/service_locator.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_resume_repository.dart';
import 'package:createresume_app/domain/repositories/i_user_profile_repository.dart';
import 'package:createresume_app/presentation/modules/all_resumes/providers/all_resumes_notifier.dart';
import 'package:createresume_app/presentation/modules/home_dashboard/providers/home_dashboard_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockResumeRepository extends Mock implements IResumeRepository {}

class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  const user = User(id: 'u1', email: 'a@b.test', fullName: 'A');
  final resumes = List.generate(
    7,
    (i) => Resume(
      id: 'r$i',
      userId: 'u1',
      title: 'Resume $i',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024, 1, 10 - i), // already newest first
    ),
  );

  late MockResumeRepository resumeRepo;
  late ProviderContainer container;

  setUp(() {
    resumeRepo = MockResumeRepository();
    final profileRepo = MockUserProfileRepository();
    final connectivity = MockConnectivity();
    when(() => connectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => connectivity.onConnectivityChanged).thenAnswer((_) => const Stream.empty());
    when(() => profileRepo.getProfile('u1')).thenAnswer((_) async => const Right(user));
    when(() => resumeRepo.getResumeSummaries('u1', limit: any(named: 'limit')))
        .thenAnswer((_) async => Right(resumes));

    container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(user)),
      resumeRepositoryProvider.overrideWithValue(resumeRepo),
      userProfileRepositoryProvider.overrideWithValue(profileRepo),
      connectivityServiceProvider.overrideWithValue(connectivity),
    ]);
    container.listen(homeDashboardProvider, (_, _) {});
    container.listen(allResumesProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test('dashboard and All Resumes share one summaries fetch', () async {
    final dashboard = await container.read(homeDashboardProvider.future);
    final all = await container.read(allResumesProvider.future);

    expect(dashboard.recentResumes.map((r) => r.id), ['r0', 'r1', 'r2', 'r3', 'r4']);
    expect(all.resumes, hasLength(7));
    verify(() => resumeRepo.getResumeSummaries('u1', limit: any(named: 'limit'))).called(1);
    verifyNever(() => resumeRepo.getResumeById(any()));
  });

  test('refresh (e.g. after a delete) refetches the shared list', () async {
    await container.read(allResumesProvider.future);
    await container.read(allResumesProvider.notifier).refresh();
    await container.read(homeDashboardProvider.future);

    verify(() => resumeRepo.getResumeSummaries('u1', limit: any(named: 'limit'))).called(2);
  });
}
