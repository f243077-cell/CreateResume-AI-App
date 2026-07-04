import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/education.dart';
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
  Future<Either<Failure, List<Resume>>> getResumes(String userId) async {
    try {
      final data = await _db
          .from('resumes')
          .select('''
            *,
            work_experiences(*),
            educations(*),
            skills(*),
            projects(*)
          ''')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

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
            projects(*)
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
      final data = await _db
          .from('resumes')
          .insert({
            'id': resume.id,
            'user_id': resume.userId,
            'title': resume.title,
            'template_id': resume.templateId,
            'ats_score': resume.atsScore,
            'is_published': resume.isPublished,
          })
          .select()
          .single();

      final savedResumeId = data['id'] as String;

      // Stamp the real, DB-assigned resume ID onto every child entity
      // before inserting them — the incoming `resume` may have children
      // with a placeholder/empty resumeId (e.g. freshly AI-generated).
      final resumeWithRealId = Resume(
        id: savedResumeId,
        userId: resume.userId,
        title: resume.title,
        templateId: resume.templateId,
        atsScore: resume.atsScore,
        isPublished: resume.isPublished,
        createdAt: resume.createdAt,
        updatedAt: resume.updatedAt,
        workExperiences: resume.workExperiences
            .map(
              (w) => WorkExperience(
                id: w.id,
                resumeId: savedResumeId,
                company: w.company,
                role: w.role,
                startDate: w.startDate,
                endDate: w.endDate,
                isCurrent: w.isCurrent,
                description: w.description,
                orderIndex: w.orderIndex,
              ),
            )
            .toList(),
        educations: resume.educations
            .map(
              (e) => Education(
                id: e.id,
                resumeId: savedResumeId,
                institution: e.institution,
                degree: e.degree,
                field: e.field,
                startDate: e.startDate,
                endDate: e.endDate,
                gpa: e.gpa,
                orderIndex: e.orderIndex,
              ),
            )
            .toList(),
        skills: resume.skills
            .map(
              (s) => Skill(
                id: s.id,
                resumeId: savedResumeId,
                name: s.name,
                level: s.level,
                orderIndex: s.orderIndex,
              ),
            )
            .toList(),
        projects: resume.projects
            .map(
              (p) => Project(
                id: p.id,
                resumeId: savedResumeId,
                name: p.name,
                description: p.description,
                techStack: p.techStack,
                url: p.url,
                orderIndex: p.orderIndex,
              ),
            )
            .toList(),
      );

      // Insert child records now that they carry the correct resumeId.
      await _upsertChildren(resumeWithRealId);

      // Re-fetch to get complete aggregate
      return getResumeById(savedResumeId);
    } catch (e) {
      return Left(ServerFailure('Failed to create resume: $e'));
    }
  }

  @override
  Future<Either<Failure, Resume>> updateResume(Resume resume) async {
    try {
      await _db
          .from('resumes')
          .update({
            'title': resume.title,
            'template_id': resume.templateId,
            'ats_score': resume.atsScore,
            'is_published': resume.isPublished,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', resume.id);

      // Replace children: delete then re-insert
      await _deleteChildren(resume.id);
      await _upsertChildren(resume);

      return getResumeById(resume.id);
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

  @override
  Future<Either<Failure, List<String>>> getTemplates() async {
    try {
      final data = await _db.from('templates').select('id');
      final ids = (data as List<dynamic>)
          .map((e) => (e as Map<String, dynamic>)['id'] as String)
          .toList();
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch templates: $e'));
    }
  }

  // ── Assembly ──────────────────────────────────────────────────────

  Resume _assembleResume(Map<String, dynamic> data) {
    return Resume(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String,
      templateId: data['template_id'] as String?,
      atsScore: data['ats_score'] as int?,
      isPublished: data['is_published'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      workExperiences: _mapList(data['work_experiences'], _mapWorkExperience),
      educations: _mapList(data['educations'], _mapEducation),
      skills: _mapList(data['skills'], _mapSkill),
      projects: _mapList(data['projects'], _mapProject),
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

  // ── Child table operations ────────────────────────────────────────

  Future<void> _upsertChildren(Resume resume) async {
    if (resume.workExperiences.isNotEmpty) {
      await _db
          .from('work_experiences')
          .insert(
            resume.workExperiences
                .map(
                  (w) => {
                    'id': w.id,
                    'resume_id': w.resumeId,
                    'company': w.company,
                    'role': w.role,
                    'start_date': w.startDate.toIso8601String(),
                    'end_date': w.endDate?.toIso8601String(),
                    'is_current': w.isCurrent,
                    'description': w.description,
                    'order_index': w.orderIndex,
                  },
                )
                .toList(),
          );
    }

    if (resume.educations.isNotEmpty) {
      await _db
          .from('educations')
          .insert(
            resume.educations
                .map(
                  (e) => {
                    'id': e.id,
                    'resume_id': e.resumeId,
                    'institution': e.institution,
                    'degree': e.degree,
                    'field': e.field,
                    'start_date': e.startDate.toIso8601String(),
                    'end_date': e.endDate?.toIso8601String(),
                    'gpa': e.gpa,
                    'order_index': e.orderIndex,
                  },
                )
                .toList(),
          );
    }

    if (resume.skills.isNotEmpty) {
      await _db
          .from('skills')
          .insert(
            resume.skills
                .map(
                  (s) => {
                    'id': s.id,
                    'resume_id': s.resumeId,
                    'name': s.name,
                    'level': s.level,
                    'order_index': s.orderIndex,
                  },
                )
                .toList(),
          );
    }

    if (resume.projects.isNotEmpty) {
      await _db
          .from('projects')
          .insert(
            resume.projects
                .map(
                  (p) => {
                    'id': p.id,
                    'resume_id': p.resumeId,
                    'name': p.name,
                    'description': p.description,
                    'tech_stack': p.techStack,
                    'url': p.url,
                    'order_index': p.orderIndex,
                  },
                )
                .toList(),
          );
    }
  }

  Future<void> _deleteChildren(String resumeId) async {
    await Future.wait([
      _db.from('work_experiences').delete().eq('resume_id', resumeId),
      _db.from('educations').delete().eq('resume_id', resumeId),
      _db.from('skills').delete().eq('resume_id', resumeId),
      _db.from('projects').delete().eq('resume_id', resumeId),
    ]);
  }
}
