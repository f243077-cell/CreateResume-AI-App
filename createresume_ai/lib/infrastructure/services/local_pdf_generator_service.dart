import '../../core/constants/template_ids.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/resume.dart';
import 'templates/resume_template_base.dart';
import 'templates/classic_template.dart';
import 'templates/modern_template.dart';
import 'templates/minimal_template.dart';
import 'templates/executive_template.dart';
import 'templates/executive2_template.dart';

class LocalPdfGeneratorService {
  /// Generate PDF bytes from a Resume entity using the selected template.
  /// Combines Resume entity with User entity for personal information.
  ///
  /// templateId: any ID accepted by [TemplateIds.normalize]; unknown IDs
  /// render with the Classic template.
  Future<List<int>> generatePdf({
    required Resume resume,
    required User user,
    required String templateId,
  }) async {
    // Create ResumeData by combining Resume and User entities.
    // Blank strings become null so templates never render empty sections.
    final resumeData = ResumeData(
      fullName: user.fullName,
      jobTitle: _nonBlank(user.jobTitle) ?? _nonBlank(resume.title),
      email: user.email,
      phone: _nonBlank(user.phone),
      location: _nonBlank(user.location),
      summary: _nonBlank(resume.summary),
      linkedin: _nonBlank(user.linkedin),
      github: _nonBlank(user.github),
      leetcode: _nonBlank(user.leetcode),
      workExperiences: [...resume.workExperiences]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      educations: [...resume.educations]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      skills: [...resume.skills]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      projects: [...resume.projects]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
      honors: [...resume.honors]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
    );

    final ResumeTemplateBase template = switch (TemplateIds.normalize(templateId)) {
      TemplateIds.modern => ModernTemplate(),
      TemplateIds.minimal => MinimalTemplate(),
      TemplateIds.executive => ExecutiveTemplate(),
      TemplateIds.executive2 => Executive2Template(),
      _ => ClassicTemplate(),
    };

    final doc = await template.generate(resumeData);
    return doc.save();
  }

  static String? _nonBlank(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Returns all available template IDs with display names for UI picker
  static List<Map<String, String>> get availableTemplates => [
    {
      'id': TemplateIds.classic,
      'name': 'Classic',
      'description': 'Traditional corporate look — dark header, clean sections',
    },
    {
      'id': TemplateIds.modern,
      'name': 'Modern',
      'description': 'Two-column layout — navy sidebar with skill bars',
    },
    {
      'id': TemplateIds.minimal,
      'name': 'Minimal',
      'description': 'Ultra-clean — white space, typography-focused',
    },
    {
      'id': TemplateIds.executive,
      'name': 'Executive',
      'description': 'Premium feel — gold accents, card-based experience',
    },
    {
      'id': TemplateIds.executive2,
      'name': 'Executive 2',
      'description': 'Two-column layout — teal sidebar with skill bars',
    },
  ];
}
