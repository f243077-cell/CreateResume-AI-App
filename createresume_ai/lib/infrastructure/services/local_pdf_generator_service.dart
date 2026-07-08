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
  /// templateId: 'classic' | 'modern' | 'minimal' | 'executive' | 'executive2'
  Future<List<int>> generatePdf({
    required Resume resume,
    required User user,
    required String templateId,
  }) async {
    final resumeData = ResumeData(
      fullName: user.fullName,
      jobTitle: user.jobTitle,
      email: user.email,
      phone: user.phone,
      location: user.location,
      summary: resume.summary,
      linkedin: user.linkedin,
      github: user.github,
      leetcode: user.leetcode,
      workExperiences: resume.workExperiences,
      educations: resume.educations,
      skills: resume.skills,
      projects: resume.projects,
      honors: resume.honors,
    );

    final ResumeTemplateBase template = switch (templateId) {
      'classic_style1' => ClassicTemplate(),
      'modern_style1' => ModernTemplate(),
      'minimal_style1' => MinimalTemplate(),
      'executive_style1' => ExecutiveTemplate(),
      'executive_style2' => Executive2Template(),
      _ => ClassicTemplate(), // fallback default
    };

    final doc = await template.generate(resumeData);
    return doc.save();
  }

  /// Returns all available template IDs with display names for UI picker
  static List<Map<String, String>> get availableTemplates => [
    {
      'id': 'classic',
      'name': 'Classic',
      'description': 'Traditional corporate look — dark header, clean sections',
    },
    {
      'id': 'modern',
      'name': 'Modern',
      'description': 'Two-column layout — navy sidebar with skill bars',
    },
    {
      'id': 'minimal',
      'name': 'Minimal',
      'description': 'Ultra-clean — white space, typography-focused',
    },
    {
      'id': 'executive',
      'name': 'Executive',
      'description': 'Premium feel — gold accents, card-based experience',
    },
    {
      'id': 'executive2',
      'name': 'Executive 2',
      'description': 'Two-column layout — teal sidebar with skill bars',
    },
  ];
}
