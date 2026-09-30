import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/honor.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/work_experience.dart';
import '../../domain/repositories/i_resume_repository.dart';
import '../services/supabase_database_service.dart';

/// Supabase implementation of [IResumeRepository].
///
/// Performs CRUD on `resumes` table and assembles the full [Resume]
/// aggregate by joining child tables.
class SupabaseResumeRepository implements IResumeRepository {
  final SupabaseDatabaseService _db;

  const SupabaseResumeRepository(this._db);

  @override
  Future<Either<Failure, List<Resume>>> getResumeSummaries(
    String userId, {
    int? limit,
  }) async {
    try {
      // Only what list cards show; no child tables.
      final query = _db
          .from('resumes')
          .select(
            'id, user_id, title, template_id, ats_score, is_published, created_at, updated_at',
          )
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      final data = limit == null ? await query : await query.limit(limit);

      final resumes = (data as List<dynamic>)
          .map((e) => _assembleResume(e as Map<String, dynamic>))
          .toList();

      return Right(resumes);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch resumes: $e'));
    }
  }

  @override
  Future<Either<Failure, Resume>> getResumeById(String id) async {
    try {
      final data = await _db
          .from('resumes')
          .select('''
            *,
            work_experiences(*),
            educations(*),
            skills(*),
            projects(*),
            honors(*)
          ''')
          .eq('id', id)
          .single();

      return Right(_assembleResume(data));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch resume: $e'));
    }
  }

  @override
  Future<Either<Failure, Resume>> createResume(Resume resume) async {
    try {
      final id = await _saveResume(resume);
      // One read to return exactly what was stored (server timestamps).
      return getResumeById(id);
    } catch (e) {
      return Left(ServerFailure('Failed to create resume: $e'));
    }
  }

  @override
  Future<Either<Failure, Resume>> updateResume(Resume resume) async {
    try {
      await _saveResume(resume);
      return Right(resume.copyWith(updatedAt: DateTime.now()));
    } catch (e) {
      return Left(ServerFailure('Failed to update resume: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResume(String id) async {
    try {
      // Children cascade-delete via FK constraint.
      await _db.from('resumes').delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete resume: $e'));
    }
  }

  // ── Assembly ──────────────────────────────────────────────────────

  Resume _assembleResume(Map<String, dynamic> data) {
    return Resume(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String,
      templateId: data['template_id'] as String?,
      summary: data['summary'] as String?,
      atsScore: data['ats_score'] as int?,
      isPublished: data['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      workExperiences: _mapList(data['work_experiences'], _mapWorkExperience),
      educations: _mapList(data['educations'], _mapEducation),
      skills: _mapList(data['skills'], _mapSkill),
      projects: _mapList(data['projects'], _mapProject),
      honors: _mapList(data['honors'], _mapHonor),
    );
  }

  List<T> _mapList<T>(dynamic list, T Function(Map<String, dynamic>) mapper) {
    if (list == null) return [];
    return (list as List<dynamic>)
        .map((e) => mapper(e as Map<String, dynamic>))
        .toList();
  }

  WorkExperience _mapWorkExperience(Map<String, dynamic> m) => WorkExperience(
    id: m['id'] as String,
    resumeId: m['resume_id'] as String,
    company: m['company'] as String,
    role: m['role'] as String,
    startDate: DateTime.parse(m['start_date'] as String),
    endDate: m['end_date'] != null
        ? DateTime.parse(m['end_date'] as String)
        : null,
    isCurrent: m['is_current'] as bool? ?? false,
    description: m['description'] as String? ?? '',
    orderIndex: m['order_index'] as int? ?? 0,
  );

  Education _mapEducation(Map<String, dynamic> m) => Education(
    id: m['id'] as String,
    resumeId: m['resume_id'] as String,
    institution: m['institution'] as String,
    degree: m['degree'] as String,
    field: m['field'] as String,
    startDate: DateTime.parse(m['start_date'] as String),
    endDate: m['end_date'] != null
        ? DateTime.parse(m['end_date'] as String)
        : null,
    gpa: (m['gpa'] as num?)?.toDouble(),
    orderIndex: m['order_index'] as int? ?? 0,
  );

  Skill _mapSkill(Map<String, dynamic> m) => Skill(
    id: m['id'] as String,
    resumeId: m['resume_id'] as String,
    name: m['name'] as String,
    level: m['level'] as String?,
    category: m['category'] as String?,
    orderIndex: m['order_index'] as int? ?? 0,
  );

  Project _mapProject(Map<String, dynamic> m) => Project(
    id: m['id'] as String,
    resumeId: m['resume_id'] as String,
    name: m['name'] as String,
    description: m['description'] as String? ?? '',
    techStack: m['tech_stack'] != null
        ? List<String>.from(m['tech_stack'] as List)
        : [],
    url: m['url'] as String?,
    orderIndex: m['order_index'] as int? ?? 0,
  );

  Honor _mapHonor(Map<String, dynamic> m) => Honor(
    id: m['id'] as String,
    resumeId: m['resume_id'] as String,
    title: m['title'] as String,
    description: m['description'] as String?,
    certificateUrl: m['certificate_url'] as String?,
    orderIndex: m['order_index'] as int? ?? 0,
  );

  // ── Saving ────────────────────────────────────────────────────────

  /// Saves the resume and all child sections in one transaction via the
  /// save_resume database function (see supabase/migrations). Returns the id.
  Future<String> _saveResume(Resume resume) async {
    final id = await _db.rpc(
      'save_resume',
      params: {'p_resume': toSavePayload(resume)},
    );
    return id as String;
  }

  /// The save_resume payload: column names as keys, one list per section.
  static Map<String, dynamic> toSavePayload(Resume resume) => {
    'id': resume.id,
    'title': resume.title,
    'template_id': resume.templateId,
    'summary': resume.summary,
    'ats_score': resume.atsScore,
    'is_published': resume.isPublished,
    'work_experiences': [
      for (final w in resume.workExperiences)
        {
          'id': w.id,
          'company': w.company,
          'role': w.role,
          'start_date': w.startDate.toIso8601String(),
          'end_date': w.endDate?.toIso8601String(),
          'is_current': w.isCurrent,
          'description': w.description,
          'order_index': w.orderIndex,
        },
    ],
    'educations': [
      for (final e in resume.educations)
        {
          'id': e.id,
          'institution': e.institution,
          'degree': e.degree,
          'field': e.field,
          'start_date': e.startDate.toIso8601String(),
          'end_date': e.endDate?.toIso8601String(),
          'gpa': e.gpa,
          'order_index': e.orderIndex,
        },
    ],
    'skills': [
      for (final sk in resume.skills)
        {
          'id': sk.id,
          'name': sk.name,
          'level': sk.level,
          'category': sk.category,
          'order_index': sk.orderIndex,
        },
    ],
    'projects': [
      for (final p in resume.projects)
        {
          'id': p.id,
          'name': p.name,
          'description': p.description,
          'tech_stack': p.techStack,
          'url': p.url,
          'order_index': p.orderIndex,
        },
    ],
    'honors': [
      for (final h in resume.honors)
        {
          'id': h.id,
          'title': h.title,
          'description': h.description,
          'certificate_url': h.certificateUrl,
          'order_index': h.orderIndex,
        },
    ],
  };
}
