// File: lib/application/use_cases/resume/generate_resume_with_ai_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/honor.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/resume.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/work_experience.dart';
import '../../../domain/repositories/i_resume_repository.dart';
import '../../../domain/repositories/i_user_profile_repository.dart';
import '../../../infrastructure/services/ai_service.dart';

/// Generates a complete resume entity from a user description using AI.
///
/// Business rules:
/// 1. Fetch the user's profile to check credit balance.
/// 2. If credits are less than 2, throw [InsufficientCreditsException].
/// 3. Call AiService.generateResumeFromDescription() to get AI-generated resume data.
/// 4. Map the JSON response to Resume domain entity with sub-entities.
/// 5. Save the Resume to Supabase via IResumeRepository.createResume().
/// 6. Deduct 2 credits from user profile on success.
/// 7. Returns Either.Failure, Resume.
class GenerateResumeWithAIUseCase {
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
  }) async {
    final profileResult = await _userProfileRepository.getProfile(userId);

    return profileResult.fold((failure) => Left(failure), (user) async {
      if (user.creditBalance < 2) {
        throw InsufficientCreditsException(
          requested: 2,
          available: user.creditBalance,
        );
      }

      final aiResult = await _aiService.generateResumeFromDescription(
        description: description,
        careerStage: careerStage,
        jobTitle: jobTitle,
        userId: userId,
      );

      return aiResult.fold((failure) => Left(failure), (aiData) async {
        final resume = _mapAiDataToResume(
          aiData: aiData,
          userId: userId,
          templateId: templateId,
        );

        final saveResult = await _resumeRepository.createResume(resume);

        return saveResult.fold((failure) => Left(failure), (savedResume) async {
          await _userProfileRepository.deductCredits(userId: userId, amount: 2);
          return Right(savedResume);
        });
      });
    });
  }

  /// Maps AI-generated JSON data to Resume domain entity with sub-entities.
  Resume _mapAiDataToResume({
    required Map<String, dynamic> aiData,
    required String userId,
    required String templateId,
  }) {
    final now = DateTime.now();

    final workExperiences =
        (aiData['workExperiences'] as List<dynamic>?)?.map<WorkExperience>((
          exp,
        ) {
          final expData = exp as Map<String, dynamic>;
          return WorkExperience(
            id: _uuid.v4(),
            resumeId: '',
            company: expData['company'] as String? ?? '',
            role: expData['role'] as String? ?? '',
            startDate: _parseDate(expData['startDate']),
            endDate: _parseDate(expData['endDate']),
            isCurrent: expData['isCurrently'] as bool? ?? false,
            description: expData['description'] as String? ?? '',
            orderIndex: 0,
          );
        }).toList() ??
        [];

    final educations =
        (aiData['educations'] as List<dynamic>?)?.map<Education>((edu) {
          final eduData = edu as Map<String, dynamic>;
          return Education(
            id: _uuid.v4(),
            resumeId: '',
            institution: eduData['institution'] as String? ?? '',
            degree: eduData['degree'] as String? ?? '',
            field: eduData['field'] as String? ?? '',
            startDate: _parseDate(eduData['startDate']),
            endDate: _parseDate(eduData['endDate']),
            gpa: _parseGpa(eduData['gpa']),
            orderIndex: 0,
          );
        }).toList() ??
        [];

    // Map skills — now reads `category` from the AI response so the PDF
    // template can group skills as "Languages: Go, Python, C++" instead
    // of a flat bulleted list. Falls back to null if the AI didn't
    // provide one (template groups these under "Other").
    final skills =
        (aiData['skills'] as List<dynamic>?)?.map<Skill>((skill) {
          final skillData = skill as Map<String, dynamic>;
          return Skill(
            id: _uuid.v4(),
            resumeId: '',
            name: skillData['name'] as String? ?? '',
            level: skillData['level'] as String?,
            category: skillData['category'] as String?,
            orderIndex: 0,
          );
        }).toList() ??
        [];

    final projects =
        (aiData['projects'] as List<dynamic>?)?.map<Project>((proj) {
          final projData = proj as Map<String, dynamic>;
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
            orderIndex: 0,
          );
        }).toList() ??
        [];

    // Map honors/awards, if the AI response includes any.
    final honors =
        (aiData['honors'] as List<dynamic>?)?.map<Honor>((honor) {
          final honorData = honor as Map<String, dynamic>;
          return Honor(
            id: _uuid.v4(),
            resumeId: '',
            title: honorData['title'] as String? ?? '',
            description: honorData['description'] as String?,
            certificateUrl: honorData['certificateUrl'] as String?,
            orderIndex: 0,
          );
        }).toList() ??
        [];

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

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      final parts = date.split(' ');
      if (parts.length == 2) {
        return DateTime(int.parse(parts[1]), _monthToNumber(parts[0]));
      }
      if (parts.length == 1 && parts[0].length == 4) {
        return DateTime(int.parse(parts[0]));
      }
    }
    return DateTime.now();
  }

  int _monthToNumber(String month) {
    final months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final key = month.substring(0, 3).toLowerCase();
    return months[key] ?? 1;
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
