import 'package:equatable/equatable.dart';

import 'education.dart';
import 'honor.dart';
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
  final String? summary;
  final int? atsScore;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Honor> honors;

  const Resume({
    required this.id,
    required this.userId,
    required this.title,
    this.templateId,
    this.summary,
    this.atsScore,
    this.isPublished = false,
    required this.createdAt,
    required this.updatedAt,
    this.workExperiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.projects = const [],
    this.honors = const [],
  });

  Resume copyWith({
    String? id,
    String? userId,
    String? title,
    String? templateId,
    String? summary,
    int? atsScore,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Project>? projects,
    List<Honor>? honors,
  }) {
    return Resume(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      templateId: templateId ?? this.templateId,
      summary: summary ?? this.summary,
      atsScore: atsScore ?? this.atsScore,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      honors: honors ?? this.honors,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    templateId,
    summary,
    atsScore,
    isPublished,
    createdAt,
    updatedAt,
    workExperiences,
    educations,
    skills,
    projects,
    honors,
  ];
}
