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

void main() {
  late GenerateResumeWithAIUseCase useCase;
  late MockAIService mockAIService;
  late MockResumeRepository mockResumeRepository;
  late MockUserProfileRepository mockUserProfileRepository;

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
}
