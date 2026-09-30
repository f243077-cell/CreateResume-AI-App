// File: lib/application/use_cases/resume/generate_resume_with_ai_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/resume_date_parser.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/honor.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../domain/repositories/i_resume_repository.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';
import '../../../infrastructure/services/ai_service.dart';

/// Returned when the AI produced a resume but saving it failed.
///
/// Carries the unsaved [resume] so the caller can retry the save with
/// [GenerateResumeWithAIUseCase.saveGenerated] instead of paying for a
/// second AI call.
class GeneratedResumeNotSavedFailure extends Failure {
  final Resume resume;

  const GeneratedResumeNotSavedFailure(this.resume, String message)
      : super(message);

  @override
  List<Object?> get props => [message, resume];
}

/// Generates a complete resume entity from a user description using AI.
///
/// Business rules:
/// 1. Fetch the user's profile; with fewer than [creditCost] credits return
///    [InsufficientCreditsFailure] without calling the AI (the server
///    enforces this too and answers 402).
/// 2. Call AiService.generateResumeFromDescription(). The dynamic-api
///    function charges [creditCost] before the model and refunds on failure.
/// 3. Map the JSON response to Resume domain entity with sub-entities.
/// 4. Save the Resume via [saveGenerated]; a failed save returns
///    [GeneratedResumeNotSavedFailure] with the unsaved resume, so the save
///    can be retried without paying for another AI call.
/// 5. Returns Either.Failure, Resume.
class GenerateResumeWithAIUseCase {
  static const creditCost = 2;

  final AiService _aiService;
  final IResumeRepository _resumeRepository;
  final IUserProfileRepository _userProfileRepository;
  final Uuid _uuid;

  const GenerateResumeWithAIUseCase({
    required this._aiService,
    required this._resumeRepository,
    required this._userProfileRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  Future<Either<Failure, Resume>> call({
    required String description,
    required String careerStage,
    required String jobTitle,
    required String templateId,
    required String userId,
    String? jobDescription,
    String? industry,
  }) async {
    final profileResult = await _userProfileRepository.getProfile(userId);

    return profileResult.fold((failure) => Left(failure), (user) async {
      if (user.creditBalance < creditCost) {
        return Left(
          InsufficientCreditsFailure(
            requested: creditCost,
            available: user.creditBalance,
          ),
        );
      }

      final aiResult = await _aiService.generateResumeFromDescription(
        description: description,
        careerStage: careerStage,
        jobTitle: jobTitle,
        userId: userId,
        jobDescription: jobDescription,
        industry: industry,
      );

      return aiResult.fold((failure) => Left(failure), (aiData) async {
        final resume = _mapAiDataToResume(
          aiData: aiData,
          userId: userId,
          templateId: templateId,
        );
        return saveGenerated(resume: resume, userId: userId);
      });
    });
  }

  /// Saves an AI-generated [resume]. The credits were already charged by
  /// the server when the AI answered.
  ///
  /// Used by [call], and directly to retry after a
  /// [GeneratedResumeNotSavedFailure] without another AI call.
  Future<Either<Failure, Resume>> saveGenerated({
    required Resume resume,
    required String userId,
  }) async {
    final saveResult = await _resumeRepository.createResume(resume);
    return saveResult.fold(
      (failure) => Left(GeneratedResumeNotSavedFailure(resume, failure.message)),
      Right.new,
    );
  }

  /// Maps AI-generated JSON data to Resume domain entity with sub-entities.
  Resume _mapAiDataToResume({
    required Map<String, dynamic> aiData,
    required String userId,
    required String templateId,
  }) {
    final now = DateTime.now();

    // orderIndex follows the AI's list order so the saved order is stable.
    final workExperiences =
        _asMaps(aiData['workExperiences']).asMap().entries.map<WorkExperience>((
          e,
        ) {
          final expData = e.value;
          // A current role has no end date; "Present" as endDate also means current.
          final isCurrent = expData['isCurrently'] == true ||
              ResumeDateParser.isPresent(expData['endDate']);
          return WorkExperience(
            id: _uuid.v4(),
            resumeId: '',
            company: expData['company'] as String? ?? '',
            role: expData['role'] as String? ?? '',
            startDate: ResumeDateParser.parse(expData['startDate']) ?? now,
            endDate: isCurrent ? null : ResumeDateParser.parse(expData['endDate']),
            isCurrent: isCurrent,
            description: expData['description'] as String? ?? '',
            orderIndex: e.key,
          );
        }).toList();

    final educations =
        _asMaps(aiData['educations']).asMap().entries.map<Education>((e) {
          final eduData = e.value;
          return Education(
            id: _uuid.v4(),
            resumeId: '',
            institution: eduData['institution'] as String? ?? '',
            degree: eduData['degree'] as String? ?? '',
            field: eduData['field'] as String? ?? '',
            startDate: ResumeDateParser.parse(eduData['startDate']) ?? now,
            endDate: ResumeDateParser.parse(eduData['endDate']),
            gpa: _parseGpa(eduData['gpa']),
            orderIndex: e.key,
          );
        }).toList();

    // Map skills — now reads `category` from the AI response so the PDF
    // template can group skills as "Languages: Go, Python, C++" instead
    // of a flat bulleted list. Falls back to null if the AI didn't
    // provide one (template groups these under "Other").
    final skills =
        _asMaps(aiData['skills']).asMap().entries.map<Skill>((e) {
          final skillData = e.value;
          return Skill(
            id: _uuid.v4(),
            resumeId: '',
            name: skillData['name'] as String? ?? '',
            level: skillData['level'] as String?,
            category: skillData['category'] as String?,
            orderIndex: e.key,
          );
        }).toList();

    final projects =
        _asMaps(aiData['projects']).asMap().entries.map<Project>((e) {
          final projData = e.value;
          return Project(
            id: _uuid.v4(),
            resumeId: '',
            name: projData['name'] as String? ?? '',
            description: projData['description'] as String? ?? '',
            techStack:
                (projData['techStack'] as List<dynamic>?)
                    ?.map((t) => t.toString())
                    .toList() ??
                [],
            url: projData['url'] as String?,
            orderIndex: e.key,
          );
        }).toList();

    // Map honors/awards, if the AI response includes any.
    final honors =
        _asMaps(aiData['honors']).asMap().entries.map<Honor>((e) {
          final honorData = e.value;
          return Honor(
            id: _uuid.v4(),
            resumeId: '',
            title: honorData['title'] as String? ?? '',
            description: honorData['description'] as String?,
            certificateUrl: honorData['certificateUrl'] as String?,
            orderIndex: e.key,
          );
        }).toList();

    return Resume(
      id: _uuid.v4(),
      userId: userId,
      title: aiData['jobTitle'] as String? ?? 'AI Generated Resume',
      templateId: templateId,
      // Paragraph-style professional summary from the AI response.
      summary: aiData['summary'] as String?,
      atsScore: null,
      isPublished: false,
      createdAt: now,
      updatedAt: now,
      workExperiences: workExperiences,
      educations: educations,
      skills: skills,
      projects: projects,
      honors: honors,
    );
  }

  /// Returns the map entries of an AI list field, skipping malformed items.
  List<Map<String, dynamic>> _asMaps(dynamic list) {
    if (list is! List) return const [];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  double? _parseGpa(dynamic gpa) {
    if (gpa == null) return null;
    if (gpa is double) return gpa;
    if (gpa is int) return gpa.toDouble();
    if (gpa is String) {
      return double.tryParse(gpa);
    }
    return null;
  }
}
