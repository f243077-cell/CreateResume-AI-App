import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/template_ids.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/resume.dart';
import 'templates/resume_template_base.dart';
import 'templates/classic_template.dart';
import 'templates/modern_template.dart';
import 'templates/minimal_template.dart';
import 'templates/executive_template.dart';
import 'templates/executive2_template.dart';

/// Font bytes for the PDF (Noto Sans), loaded once from assets.
class PdfFontBytes {
  final Uint8List regular;
  final Uint8List bold;
  final Uint8List italic;
  final Uint8List boldItalic;

  const PdfFontBytes({
    required this.regular,
    required this.bold,
    required this.italic,
    required this.boldItalic,
  });
}

/// Everything a background isolate needs to build one PDF (plain data only).
class _PdfJob {
  final Resume resume;
  final User user;
  final String templateId;
  final PdfFontBytes? fonts;

  const _PdfJob(this.resume, this.user, this.templateId, this.fonts);
}

class LocalPdfGeneratorService {
  static Future<PdfFontBytes?>? _fonts;

  /// Loads and caches the embedded Unicode font. Null (Helvetica fallback)
  /// if the assets are missing.
  static Future<PdfFontBytes?> _loadFonts() => _fonts ??= () async {
        try {
          Future<Uint8List> load(String style) async =>
              (await rootBundle.load('assets/fonts/NotoSans-$style.ttf'))
                  .buffer
                  .asUint8List();
          return PdfFontBytes(
            regular: await load('Regular'),
            bold: await load('Bold'),
            italic: await load('Italic'),
            boldItalic: await load('BoldItalic'),
          );
        } catch (e) {
          debugPrint('PDF fonts unavailable, using Helvetica: $e');
          return null;
        }
      }();

  /// Generate PDF bytes from a Resume entity using the selected template.
  /// Combines Resume entity with User entity for personal information.
  ///
  /// The document is built in a background isolate (compute) so a two-page
  /// resume does not drop UI frames.
  ///
  /// templateId: any ID accepted by [TemplateIds.normalize]; unknown IDs
  /// render with the Classic template.
  Future<List<int>> generatePdf({
    required Resume resume,
    required User user,
    required String templateId,
  }) async {
    final fonts = await _loadFonts();
    return compute(_buildPdf, _PdfJob(resume, user, templateId, fonts));
  }

  static Future<Uint8List> _buildPdf(_PdfJob job) async {
    final resume = job.resume;
    final user = job.user;
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

    final ResumeTemplateBase template = switch (TemplateIds.normalize(job.templateId)) {
      TemplateIds.modern => ModernTemplate(),
      TemplateIds.minimal => MinimalTemplate(),
      TemplateIds.executive => ExecutiveTemplate(),
      TemplateIds.executive2 => Executive2Template(),
      _ => ClassicTemplate(),
    };

    final fonts = job.fonts;
    final theme = fonts == null
        ? null
        : pw.ThemeData.withFont(
            base: pw.Font.ttf(ByteData.sublistView(fonts.regular)),
            bold: pw.Font.ttf(ByteData.sublistView(fonts.bold)),
            italic: pw.Font.ttf(ByteData.sublistView(fonts.italic)),
            boldItalic: pw.Font.ttf(ByteData.sublistView(fonts.boldItalic)),
          );

    final doc = await template.generate(resumeData, theme: theme);
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
