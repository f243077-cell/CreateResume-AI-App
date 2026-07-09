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
  /// templateId: 'classic_style1' | 'modern_style1' | 'minimal_style1' |
  ///             'executive_style1' | 'executive_style2'
  Future<List<int>> generatePdf({
    required Resume resume,
    required User user,
    required String templateId,
  }) async {
    // Create ResumeData by combining Resume and User entities
    final resumeData = ResumeData(
      fullName: user.fullName,
      jobTitle: null, // Job title would need to be stored separately
      email: user.email,
      phone: null, // Phone would need to be stored in User profile
      location: null, // Location would need to be stored in User profile
      summary: null, // Summary would need to be stored in Resume
      workExperiences: resume.workExperiences,
      educations: resume.educations,
      skills: resume.skills,
      projects: resume.projects,
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
      'id': 'classic_style1',
      'name': 'Classic',
      'description': 'Traditional corporate look — dark header, clean sections',
    },
    {
      'id': 'modern_style1',
      'name': 'Modern',
      'description': 'Two-column layout — navy sidebar with skill bars',
    },
    {
      'id': 'minimal_style1',
      'name': 'Minimal',
      'description': 'Ultra-clean — white space, typography-focused',
    },
    {
      'id': 'executive_style1',
      'name': 'Executive',
      'description': 'Premium feel — gold accents, card-based experience',
    },
    {
      'id': 'executive_style2',
      'name': 'Executive 2',
      'description': 'Two-column layout — teal sidebar with skill bars',
    },
  ];
}
