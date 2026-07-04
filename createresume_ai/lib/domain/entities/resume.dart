import 'package:equatable/equatable.dart';

import 'education.dart';
import 'project.dart';
import 'skill.dart';
import 'work_experience.dart';

/// A complete resume document owned by a user.
///
/// Contains all resume sections as sub-entity lists.
class Resume extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? templateId;
  final int? atsScore;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    this.templateId,
    this.atsScore,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
    this.workExperiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.projects = const [],
  });

  Resume copyWith({
    String? id,
    String? userId,
    String? title,
    String? templateId,
    int? atsScore,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
  }) {
    return Resume(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      atsScore: atsScore ?? this.atsScore,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        templateId,
        atsScore,
        isPublished,
        createdAt,
        updatedAt,
        workExperiences,
        educations,
        skills,
        projects,
      ];
}
