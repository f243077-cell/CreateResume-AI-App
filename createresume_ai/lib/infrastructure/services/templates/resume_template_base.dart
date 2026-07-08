import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/honor.dart';

/// Data model for PDF generation - combines Resume entity with user personal info
class ResumeData {
  final String fullName;
  final String? jobTitle;
  final String email;
  final String? phone;
  final String? location;
  final String? summary;
  final String? linkedin;
  final String? github;
  final String? leetcode;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Honor> honors;

  const ResumeData({
    required this.fullName,
    this.jobTitle,
    required this.email,
    this.phone,
    this.location,
    this.summary,
    this.linkedin,
    this.github,
    this.leetcode,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.projects,
    this.honors = const [],
  });
}

abstract class ResumeTemplateBase {
  Future<pw.Document> generate(ResumeData resume);
}