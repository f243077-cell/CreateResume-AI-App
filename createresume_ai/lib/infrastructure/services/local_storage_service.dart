import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/skill.dart';
import '../../domain/entities/work_experience.dart';

/// Hive-backed local cache for the active resume.
///
/// Stores serialized Resume JSON in a Hive box keyed by resume ID.
class LocalStorageService {
  static const _boxName = 'resume_cache';

  /// Opens (or returns the already-open) Hive box.
  Future<Box<String>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  /// Saves a [Resume] to local cache.
  Future<void> save(Resume resume) async {
    final box = await _openBox();
    final json = jsonEncode(_resumeToMap(resume));
    await box.put(resume.id, json);
  }

  /// Loads a [Resume] from local cache by [resumeId].
  ///
  /// Returns `null` if not found.
  Future<Resume?> load(String resumeId) async {
    final box = await _openBox();
    final json = box.get(resumeId);
    if (json == null) return null;

    final map = jsonDecode(json) as Map<String, dynamic>;
    return _resumeFromMap(map);
  }

  /// Removes a resume from local cache.
  Future<void> clear(String resumeId) async {
    final box = await _openBox();
    await box.delete(resumeId);
  }

  // ── Serialization helpers ─────────────────────────────────────────

  Map<String, dynamic> _resumeToMap(Resume r) => {
        'id': r.id,
        'user_id': r.userId,
        'title': r.title,
        'template_id': r.templateId,
        'ats_score': r.atsScore,
        'is_published': r.isPublished,
        'created_at': r.createdAt.toIso8601String(),
        'updated_at': r.updatedAt.toIso8601String(),
        'work_experiences':
            r.workExperiences.map(_workExperienceToMap).toList(),
        'educations': r.educations.map(_educationToMap).toList(),
        'skills': r.skills.map(_skillToMap).toList(),
        'projects': r.projects.map(_projectToMap).toList(),
      };

  Resume _resumeFromMap(Map<String, dynamic> m) => Resume(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        templateId: m['template_id'] as String?,
        atsScore: m['ats_score'] as int?,
        isPublished: m['is_published'] as bool? ?? false,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
        workExperiences: (m['work_experiences'] as List<dynamic>?)
                ?.map((e) =>
                    _workExperienceFromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        educations: (m['educations'] as List<dynamic>?)
                ?.map((e) => _educationFromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        skills: (m['skills'] as List<dynamic>?)
                ?.map((e) => _skillFromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        projects: (m['projects'] as List<dynamic>?)
                ?.map((e) => _projectFromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> _workExperienceToMap(WorkExperience w) => {
        'id': w.id,
        'resume_id': w.resumeId,
        'company': w.company,
        'role': w.role,
        'start_date': w.startDate.toIso8601String(),
        'end_date': w.endDate?.toIso8601String(),
        'is_current': w.isCurrent,
        'description': w.description,
        'order_index': w.orderIndex,
      };

  WorkExperience _workExperienceFromMap(Map<String, dynamic> m) =>
      WorkExperience(
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

  Map<String, dynamic> _educationToMap(Education e) => {
        'id': e.id,
        'resume_id': e.resumeId,
        'institution': e.institution,
        'degree': e.degree,
        'field': e.field,
        'start_date': e.startDate.toIso8601String(),
        'end_date': e.endDate?.toIso8601String(),
        'gpa': e.gpa,
        'order_index': e.orderIndex,
      };

  Education _educationFromMap(Map<String, dynamic> m) => Education(
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

  Map<String, dynamic> _skillToMap(Skill s) => {
        'id': s.id,
        'resume_id': s.resumeId,
        'name': s.name,
        'level': s.level,
        'order_index': s.orderIndex,
      };

  Skill _skillFromMap(Map<String, dynamic> m) => Skill(
        id: m['id'] as String,
        resumeId: m['resume_id'] as String,
        name: m['name'] as String,
        level: m['level'] as String?,
        orderIndex: m['order_index'] as int? ?? 0,
      );

  Map<String, dynamic> _projectToMap(Project p) => {
        'id': p.id,
        'resume_id': p.resumeId,
        'name': p.name,
        'description': p.description,
        'tech_stack': p.techStack,
        'url': p.url,
        'order_index': p.orderIndex,
      };

  Project _projectFromMap(Map<String, dynamic> m) => Project(
        id: m['id'] as String,
        resumeId: m['resume_id'] as String,
        name: m['name'] as String,
        description: m['description'] as String? ?? '',
        techStack: (m['tech_stack'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        url: m['url'] as String?,
        orderIndex: m['order_index'] as int? ?? 0,
      );
}
