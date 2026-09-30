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

/// Groups skills by category, preserving first-seen category order.
/// Skills without a category are grouped under "Other".
Map<String, List<Skill>> groupSkillsByCategory(List<Skill> skills) {
  final Map<String, List<Skill>> grouped = {};
  for (final s in skills) {
    final key = (s.category == null || s.category!.trim().isEmpty)
        ? 'Other'
        : s.category!.trim();
    grouped.putIfAbsent(key, () => []).add(s);
  }
  return grouped;
}

abstract class ResumeTemplateBase {
  /// Builds the document. [theme] carries the embedded fonts; without it
  /// the pdf package's built-in Helvetica is used.
  Future<pw.Document> generate(ResumeData resume, {pw.ThemeData? theme});
}