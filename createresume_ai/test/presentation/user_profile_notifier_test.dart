import 'package:createresume_app/application/providers/auth_state_provider.dart';
import 'package:createresume_app/core/di/service_locator.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_user_profile_repository.dart';
import 'package:createresume_app/presentation/modules/user_profile_settings/providers/user_profile_notifier.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const User(id: '', email: '', fullName: '')));

  // The auth snapshot carries no contact fields; the profiles row does.
  const authUser = User(id: 'u1', email: 'a@b.test', fullName: 'Old Name');
  const storedProfile = User(
    id: 'u1',
    email: 'a@b.test',
    fullName: 'Old Name',
    creditBalance: 3,
    phone: '+1 555 0100',
    location: 'Lahore',
    jobTitle: 'Engineer',
    linkedin: 'linkedin.com/in/a',
    github: 'github.com/a',
    leetcode: 'leetcode.com/a',
  );

  late MockUserProfileRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = MockUserProfileRepository();
    when(() => repo.getProfile('u1')).thenAnswer((_) async => const Right(storedProfile));
    when(() => repo.updateProfile(any())).thenAnswer(
      (inv) async => Right(inv.positionalArguments.first as User),
    );
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(authUser)),
        userProfileRepositoryProvider.overrideWithValue(repo),
      ],
    );
    container.listen(authStateProvider, (_, _) {});
    await container.read(authStateProvider.future);
    container.listen(userProfileProvider, (_, _) {});
    // Let the profile load.
    await Future<void>.delayed(Duration.zero);
    expect(container.read(userProfileProvider).profile, storedProfile);
  });

  tearDown(() => container.dispose());

  User savedUser() =>
      verify(() => repo.updateProfile(captureAny())).captured.single as User;

  test('changing the name keeps contact details and credits', () async {
    await container.read(userProfileProvider.notifier).updateProfile(fullName: 'New Name');

    final saved = savedUser();
    expect(saved.fullName, 'New Name');
    expect(saved.phone, '+1 555 0100');
    expect(saved.location, 'Lahore');
    expect(saved.jobTitle, 'Engineer');
    expect(saved.linkedin, 'linkedin.com/in/a');
    expect(saved.github, 'github.com/a');
    expect(saved.leetcode, 'leetcode.com/a');
    expect(saved.creditBalance, 3);
  });

  test('updates contact details; empty string clears a field', () async {
    await container.read(userProfileProvider.notifier).updateProfile(
          phone: '+92 300 1234567',
          location: 'Karachi',
          jobTitle: 'Senior Engineer',
          linkedin: 'linkedin.com/in/b',
          github: '',
          leetcode: 'leetcode.com/b',
        );

    final saved = savedUser();
    expect(saved.fullName, 'Old Name');
    expect(saved.phone, '+92 300 1234567');
    expect(saved.location, 'Karachi');
    expect(saved.jobTitle, 'Senior Engineer');
    expect(saved.linkedin, 'linkedin.com/in/b');
    expect(saved.github, '');
    expect(saved.leetcode, 'leetcode.com/b');
    expect(container.read(userProfileProvider).profile?.location, 'Karachi');
  });
}
