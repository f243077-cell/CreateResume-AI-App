import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';

/// Data model for PDF generation - combines Resume entity with user personal info
class ResumeData {
  final String fullName;
  final String? jobTitle;
  final String email;
  final String? phone;
  final String? location;
  final String? summary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Project> projects;

  const ResumeData({
    required this.fullName,
    this.jobTitle,
    required this.email,
    this.phone,
    this.location,
    this.summary,
    required this.workExperiences,
    required this.educations,
    required this.skills,
    required this.projects,
  });
}

abstract class ResumeTemplateBase {
  Future<pw.Document> generate(ResumeData resume);
}
