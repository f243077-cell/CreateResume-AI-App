import 'package:createresume_app/application/use_cases/user/run_ai_tool_use_case.dart';
import 'package:createresume_app/core/errors/failures.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_user_profile_repository.dart';
import 'package:createresume_app/domain/services/i_ai_content_generator.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileRepository extends Mock implements IUserProfileRepository {}

class MockAiContentGenerator extends Mock implements IAIContentGenerator {}

void main() {
  late MockUserProfileRepository repo;
  late MockAiContentGenerator ai;
  late RunAiToolUseCase useCase;

  const user = User(id: 'u1', email: 'a@b.test', fullName: 'A', creditBalance: 3);

  setUp(() {
    repo = MockUserProfileRepository();
    ai = MockAiContentGenerator();
    useCase = RunAiToolUseCase(repo, ai);
    when(() => repo.getProfile('u1')).thenAnswer((_) async => const Right(user));
  });

  test('bullet rewriter returns the model output and the server-charged balance', () async {
    when(() => ai.rewriteBullet('did stuff')).thenAnswer((_) async => const Right('Led X'));
    var fetches = 0;
    // First read: before the call (3). Second: after the server charged (2).
    when(() => repo.getProfile('u1')).thenAnswer(
      (_) async => Right(user.copyWith(creditBalance: fetches++ == 0 ? 3 : 2)),
    );

    final result = await useCase(userId: 'u1', request: const BulletRewriteRequest('did stuff'));

    final value = result.getOrElse(() => throw StateError('Left'));
    expect(value.resultText, 'Led X');
    expect(value.profile.creditBalance, 2);
  });

  test('skill gap and cover letter call the matching AI methods', () async {
    when(() => ai.analyzeSkillGap(skills: 'Dart', jobDescription: 'Kotlin role'))
        .thenAnswer((_) async => const Right('Missing: Kotlin'));
    when(() => ai.generateCoverLetter(
          resumeSummary: 'Mobile dev',
          companyName: 'Acme',
          jobTitle: 'Engineer',
        )).thenAnswer((_) async => const Right('Dear Acme'));

    final gap = await useCase(
      userId: 'u1',
      request: const SkillGapRequest(skills: 'Dart', jobDescription: 'Kotlin role'),
    );
    final letter = await useCase(
      userId: 'u1',
      request: const CoverLetterRequest(
        companyName: 'Acme',
        jobTitle: 'Engineer',
        background: 'Mobile dev',
      ),
    );

    expect(gap.getOrElse(() => throw StateError('Left')).resultText, 'Missing: Kotlin');
    expect(letter.getOrElse(() => throw StateError('Left')).resultText, 'Dear Acme');
  });

  test('no canned text: an AI failure is returned as a failure', () async {
    when(() => ai.rewriteBullet(any()))
        .thenAnswer((_) async => const Left(ServerFailure('function not found')));

    final result = await useCase(userId: 'u1', request: const BulletRewriteRequest('x'));

    expect(result, isA<Left>());
  });

  test('server 402 (out of credits) is passed through', () async {
    when(() => ai.rewriteBullet(any())).thenAnswer(
      (_) async => const Left(InsufficientCreditsFailure(requested: 1, available: 0)),
    );

    final result = await useCase(userId: 'u1', request: const BulletRewriteRequest('x'));

    expect(result.fold((f) => f, (_) => null), isA<InsufficientCreditsFailure>());
  });

  test('without credits the AI is not called', () async {
    when(() => repo.getProfile('u1'))
        .thenAnswer((_) async => Right(user.copyWith(creditBalance: 0)));

    final result = await useCase(userId: 'u1', request: const BulletRewriteRequest('x'));

    expect(
      result,
      const Left<Failure, ({User profile, String resultText})>(
        InsufficientCreditsFailure(requested: 1, available: 0),
      ),
    );
    verifyNever(() => ai.rewriteBullet(any()));
  });
}
