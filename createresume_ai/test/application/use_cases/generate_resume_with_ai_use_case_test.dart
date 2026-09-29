import 'package:createresume_app/application/use_cases/resume/generate_resume_with_ai_use_case.dart';
import 'package:createresume_app/core/errors/exceptions.dart';
import 'package:createresume_app/core/errors/failures.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/repositories/i_resume_repository.dart';
import 'package:createresume_app/domain/repositories/i_user_profile_repository.dart';
import 'package:createresume_app/infrastructure/services/ai_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ──────────────────────────────────────────────────────────────────

class MockAIService extends Mock implements AiService {}

class MockResumeRepository extends Mock implements IResumeRepository {}

class MockUserProfileRepository extends Mock
    implements IUserProfileRepository {}

class FakeResume extends Fake implements Resume {}

void main() {
  late GenerateResumeWithAIUseCase useCase;
  late MockAIService mockAIService;
  late MockResumeRepository mockResumeRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() {
    registerFallbackValue(FakeResume());
  });

  setUp(() {
    mockAIService = MockAIService();
    mockResumeRepository = MockResumeRepository();
    mockUserProfileRepository = MockUserProfileRepository();

    useCase = GenerateResumeWithAIUseCase(
      aiService: mockAIService,
      resumeRepository: mockResumeRepository,
      userProfileRepository: mockUserProfileRepository,
    );
  });

  const testUserId = 'user-123';
  const testDescription = 'Software engineer with 5 years experience...';
  const testCareerStage = 'senior';
  const testJobTitle = 'Senior Flutter Developer';
  const testTemplateId = 'modern';

  User makeUser({int creditBalance = 0}) {
    return User(
      id: testUserId,
      email: 'test@example.com',
      fullName: 'Test User',
      creditBalance: creditBalance,
    );
  }

  Resume makeResume() {
    return Resume(
      id: 'resume-123',
      userId: testUserId,
      title: testJobTitle,
      templateId: testTemplateId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      workExperiences: [],
      educations: [],
      skills: [],
      projects: [],
    );
  }

  group('GenerateResumeWithAIUseCase', () {
    test(
      'throws InsufficientCreditsException when credit balance is less than 2',
      () async {
        // Arrange — user has 1 credit (needs 2)
        when(() => mockUserProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => Right(makeUser(creditBalance: 1)));

        // Act & Assert
        expect(
          () => useCase.call(
            userId: testUserId,
            description: testDescription,
            careerStage: testCareerStage,
            jobTitle: testJobTitle,
            templateId: testTemplateId,
          ),
          throwsA(isA<InsufficientCreditsException>()),
        );
      },
    );

    test(
      'deducts 2 credits and returns resume on success',
      () async {
        // Arrange — user has credits
        final user = makeUser(creditBalance: 5);
        final aiData = {
          'jobTitle': testJobTitle,
          'fullName': 'Test User',
          'email': 'test@example.com',
          'phone': '123-456-7890',
          'location': 'San Francisco',
          'summary': 'Experienced developer',
          'skills': [],
          'workExperiences': [],
          'educations': [],
          'projects': [],
        };
        final savedResume = makeResume();

        when(() => mockUserProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => Right(user));

        when(() => mockAIService.generateResumeFromDescription(
              description: testDescription,
              careerStage: testCareerStage,
              jobTitle: testJobTitle,
              userId: testUserId,
            )).thenAnswer((_) async => Right(aiData));

        when(() => mockResumeRepository.createResume(any()))
            .thenAnswer((_) async => Right(savedResume));

        when(() => mockUserProfileRepository.deductCredits(
              userId: testUserId,
              amount: 2,
            )).thenAnswer(
            (_) async => Right(user.copyWith(creditBalance: 3)));

        // Act
        final result = await useCase.call(
          userId: testUserId,
          description: testDescription,
          careerStage: testCareerStage,
          jobTitle: testJobTitle,
          templateId: testTemplateId,
        );

        // Assert
        expect(result, equals(Right(savedResume)));
        verify(() => mockUserProfileRepository.deductCredits(
              userId: testUserId,
              amount: 2,
            )).called(1);
      },
    );

    test(
      'returns failure when profile fetch fails',
      () async {
        // Arrange
        when(() => mockUserProfileRepository.getProfile(testUserId))
            .thenAnswer(
                (_) async => const Left(ServerFailure('Profile not found')));

        // Act
        final result = await useCase.call(
          userId: testUserId,
          description: testDescription,
          careerStage: testCareerStage,
          jobTitle: testJobTitle,
          templateId: testTemplateId,
        );

        // Assert
        expect(result, isA<Left>());
        verifyNever(() => mockAIService.generateResumeFromDescription(
              description: any(named: 'description'),
              careerStage: any(named: 'careerStage'),
              jobTitle: any(named: 'jobTitle'),
              userId: any(named: 'userId'),
            ));
      },
    );

    test(
      'returns failure when AI generation fails — does not deduct credits',
      () async {
        // Arrange
        when(() => mockUserProfileRepository.getProfile(testUserId))
            .thenAnswer(
                (_) async => Right(makeUser(creditBalance: 5)));

        when(() => mockAIService.generateResumeFromDescription(
              description: testDescription,
              careerStage: testCareerStage,
              jobTitle: testJobTitle,
              userId: testUserId,
            )).thenAnswer(
                (_) async => const Left(ServerFailure('AI service down')));

        // Act
        final result = await useCase.call(
          userId: testUserId,
          description: testDescription,
          careerStage: testCareerStage,
          jobTitle: testJobTitle,
          templateId: testTemplateId,
        );

        // Assert
        expect(result, isA<Left>());
        verifyNever(() => mockUserProfileRepository.deductCredits(
              userId: any(named: 'userId'),
              amount: any(named: 'amount'),
            ));
      },
    );
  });

  group('AI JSON mapping', () {
    /// Runs the use case with [aiData] and returns the Resume passed to save.
    Future<Resume> mapViaUseCase(Map<String, dynamic> aiData) async {
      final user = makeUser(creditBalance: 5);
      when(() => mockUserProfileRepository.getProfile(testUserId))
          .thenAnswer((_) async => Right(user));
      when(() => mockAIService.generateResumeFromDescription(
            description: testDescription,
            careerStage: testCareerStage,
            jobTitle: testJobTitle,
            userId: testUserId,
          )).thenAnswer((_) async => Right(aiData));
      when(() => mockResumeRepository.createResume(any()))
          .thenAnswer((inv) async => Right(inv.positionalArguments.first as Resume));
      when(() => mockUserProfileRepository.deductCredits(
            userId: testUserId,
            amount: 2,
          )).thenAnswer((_) async => Right(user));

      final result = await useCase.call(
        userId: testUserId,
        description: testDescription,
        careerStage: testCareerStage,
        jobTitle: testJobTitle,
        templateId: testTemplateId,
      );
      return result.getOrElse(() => throw StateError('expected Right'));
    }

    test('orderIndex follows list order for every section', () async {
      final resume = await mapViaUseCase({
        'workExperiences': [
          {'company': 'A', 'startDate': '2020-01'},
          {'company': 'B', 'startDate': '2018-01'},
        ],
        'educations': [
          {'institution': 'X'},
          {'institution': 'Y'},
        ],
        'skills': [
          {'name': 'Dart'},
          {'name': 'Go'},
          {'name': 'SQL'},
        ],
        'projects': [
          {'name': 'P1'},
          {'name': 'P2'},
        ],
        'honors': [
          {'title': 'H1'},
          {'title': 'H2'},
        ],
      });

      expect(resume.workExperiences.map((e) => e.orderIndex), [0, 1]);
      expect(resume.workExperiences.map((e) => e.company), ['A', 'B']);
      expect(resume.educations.map((e) => e.orderIndex), [0, 1]);
      expect(resume.skills.map((e) => e.orderIndex), [0, 1, 2]);
      expect(resume.projects.map((e) => e.orderIndex), [0, 1]);
      expect(resume.honors.map((e) => e.orderIndex), [0, 1]);
    });

    test('current job has null end date', () async {
      final resume = await mapViaUseCase({
        'workExperiences': [
          {
            'company': 'Now Inc',
            'startDate': '2021-03',
            'endDate': '2024-01',
            'isCurrently': true,
          },
          {'company': 'Present Co', 'startDate': 'Sept 2019', 'endDate': 'Present'},
          {'company': 'Past Ltd', 'startDate': '2015', 'endDate': 'May 2018'},
        ],
      });

      final [now, present, past] = resume.workExperiences;
      expect(now.isCurrent, isTrue);
      expect(now.endDate, isNull);
      expect(now.startDate, DateTime(2021, 3));
      expect(present.isCurrent, isTrue);
      expect(present.endDate, isNull);
      expect(present.startDate, DateTime(2019, 9));
      expect(past.isCurrent, isFalse);
      expect(past.startDate, DateTime(2015, 1));
      expect(past.endDate, DateTime(2018, 5));
    });

    test('unparseable dates and missing fields do not abort generation',
        () async {
      final resume = await mapViaUseCase({
        'workExperiences': [
          {'startDate': '2019-2021', 'endDate': 'garbage'},
        ],
        'educations': [
          {'startDate': null, 'endDate': ''},
        ],
        'skills': ['not a map', {'name': 'Dart'}],
      });

      expect(resume.workExperiences.single.company, '');
      expect(resume.workExperiences.single.endDate, isNull);
      expect(resume.educations.single.endDate, isNull);
      expect(resume.skills.map((s) => s.name), ['Dart']);
      expect(resume.title, 'AI Generated Resume');
    });

    test('maps skill category, honors and summary', () async {
      final resume = await mapViaUseCase({
        'jobTitle': 'Engineer',
        'summary': 'Seasoned engineer.',
        'skills': [
          {'name': 'Dart', 'level': 'expert', 'category': 'Languages'},
        ],
        'honors': [
          {
            'title': 'Dean’s List',
            'description': 'Top 5%',
            'certificateUrl': 'https://example.org/c',
          },
        ],
      });

      expect(resume.title, 'Engineer');
      expect(resume.summary, 'Seasoned engineer.');
      expect(resume.skills.single.category, 'Languages');
      expect(resume.honors.single.title, 'Dean’s List');
      expect(resume.honors.single.description, 'Top 5%');
      expect(resume.honors.single.certificateUrl, 'https://example.org/c');
    });
  });
}
