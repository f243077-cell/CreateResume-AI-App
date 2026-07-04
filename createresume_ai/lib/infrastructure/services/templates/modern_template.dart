import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_template_base.dart';

class ModernTemplate implements ResumeTemplateBase {
  static const PdfColor _navy = PdfColor.fromInt(0xFF1B2B44);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD4A92E);
  static const PdfColor _cream = PdfColor.fromInt(0xFFF9F3E3);
  static const PdfColor _textGrey = PdfColor.fromInt(0xFF555555);

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── LEFT SIDEBAR ──────────────────────────────────
            pw.Container(
              width: 190,
              color: _navy,
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Avatar circle with initials
                  pw.Container(
                    width: 72,
                    height: 72,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: _gold,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        _getInitials(resume.fullName),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Name
                  pw.Text(
                    resume.fullName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),

                  if (resume.jobTitle != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      resume.jobTitle!,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        color: _gold,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],

                  pw.SizedBox(height: 20),
                  _sidebarDivider(),

                  // Contact
                  _sidebarSectionTitle('CONTACT'),
                  _sidebarContactRow('✉', resume.email),
                  if (resume.phone != null)
                    _sidebarContactRow('✆', resume.phone!),
                  if (resume.location != null)
                    _sidebarContactRow('⌖', resume.location!),

                  pw.SizedBox(height: 16),
                  _sidebarDivider(),

                  // Skills
                  if (resume.skills.isNotEmpty) ...[
                    _sidebarSectionTitle('SKILLS'),
                    ...resume.skills.map((skill) => _skillBar(skill)),
                  ],

                  pw.SizedBox(height: 16),
                  _sidebarDivider(),

                  // Education in sidebar
                  if (resume.educations.isNotEmpty) ...[
                    _sidebarSectionTitle('EDUCATION'),
                    ...resume.educations
                        .map((edu) => _sidebarEducation(edu)),
                  ],
                ],
              ),
            ),

            // ── RIGHT MAIN CONTENT ────────────────────────────
            pw.Expanded(
              child: pw.Container(
                color: PdfColors.white,
                padding: const pw.EdgeInsets.all(28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // Summary
                    if (resume.summary != null) ...[
                      _mainSectionTitle('About Me'),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          color: _cream,
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border(
                            left: pw.BorderSide(color: _gold, width: 3),
                          ),
                        ),
                        child: pw.Text(
                          resume.summary!,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            lineSpacing: 1.5,
                            color: _textGrey,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 18),
                    ],

                    // Work Experience
                    if (resume.workExperiences.isNotEmpty) ...[
                      _mainSectionTitle('Work Experience'),
                      ...resume.workExperiences
                          .map((exp) => _experienceCard(exp)),
                      pw.SizedBox(height: 8),
                    ],

                    // Projects
                    if (resume.projects.isNotEmpty) ...[
                      _mainSectionTitle('Projects'),
                      ...resume.projects.map((proj) => _projectCard(proj)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return doc;
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  pw.Widget _sidebarDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Container(height: 0.5, color: _gold),
    );
  }

  pw.Widget _sidebarSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, top: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _gold,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  pw.Widget _sidebarContactRow(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(icon,
              style: const pw.TextStyle(fontSize: 9, color: _gold)),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                  fontSize: 8.5, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _skillBar(dynamic skill) {
    final level = skill.level;
    final double fillRatio = switch (level) {
      'expert' => 1.0,
      'intermediate' => 0.65,
      _ => 0.33,
    };

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            skill.name,
            style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.white),
          ),
          pw.SizedBox(height: 3),
          pw.Stack(
            children: [
              pw.Container(
                height: 4,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF2E4A6A),
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.Expanded(
                flex: (fillRatio * 100).toInt(),
                child: pw.Container(
                  height: 4,
                  decoration: pw.BoxDecoration(
                    color: _gold,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _sidebarEducation(dynamic edu) {
    final degree = edu.degree ?? '';
    final endDate = _formatDate(edu.endDate);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            degree,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            edu.institution,
            style: const pw.TextStyle(
                fontSize: 8.5, color: _gold),
          ),
          pw.Text(
            endDate,
            style: const pw.TextStyle(
                fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );
  }

  pw.Widget _mainSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _navy,
            ),
          ),
          pw.Container(height: 2, width: 36, color: _gold),
        ],
      ),
    );
  }

  pw.Widget _experienceCard(dynamic exp) {
    final startDate = _formatDate(exp.startDate);
    final endDate = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);
    final description = exp.description;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Gold dot timeline
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4, right: 10),
            child: pw.Container(
              width: 8,
              height: 8,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: _gold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      exp.role,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: _navy,
                      ),
                    ),
                    pw.Text(
                      '$startDate — $endDate',
                      style: const pw.TextStyle(
                          fontSize: 9, color: _textGrey),
                    ),
                  ],
                ),
                pw.Text(
                  exp.company,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _gold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    description,
                    style: const pw.TextStyle(
                      fontSize: 9.5,
                      lineSpacing: 1.4,
                      color: _textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _projectCard(dynamic proj) {
    final description = proj.description;
    final techStack = proj.techStack as List<dynamic>? ?? [];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8F8F8),
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(
              color: const PdfColor.fromInt(0xFFEEEEEE), width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              proj.name,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10.5,
                color: _navy,
              ),
            ),
            if (description != null && description.isNotEmpty)
              pw.Text(
                description,
                style: const pw.TextStyle(
                    fontSize: 9.5, color: _textGrey),
              ),
            if (techStack.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 4,
                children: techStack
                    .map((t) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: _navy,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(t,
                              style: const pw.TextStyle(
                                  fontSize: 7.5,
                                  color: PdfColors.white)),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('MMM yyyy').format(date);
    }
    return date.toString();
  }
}
