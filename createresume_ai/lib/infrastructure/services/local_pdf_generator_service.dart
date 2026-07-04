import '../../domain/entities/user.dart';
import '../../domain/entities/resume.dart';
import 'templates/resume_template_base.dart';
import 'templates/classic_template.dart';
import 'templates/modern_template.dart';
import 'templates/minimal_template.dart';
import 'templates/executive_template.dart';

class LocalPdfGeneratorService {
  /// Generate PDF bytes from a Resume entity using the selected template.
  /// Combines Resume entity with User entity for personal information.
  /// 
  /// templateId: 'classic' | 'modern' | 'minimal' | 'executive'
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
      'classic'   => ClassicTemplate(),
      'modern'    => ModernTemplate(),
      'minimal'   => MinimalTemplate(),
      'executive' => ExecutiveTemplate(),
      _           => ClassicTemplate(), // fallback default
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
  ];
}
