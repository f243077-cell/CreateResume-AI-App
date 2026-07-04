import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_template_base.dart';

class ClassicTemplate implements ResumeTemplateBase {
  static const PdfColor _navy = PdfColor.fromInt(0xFF1B2B44);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD4A92E);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor _textGrey = PdfColor.fromInt(0xFF666666);

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // ── HEADER ────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            color: _navy,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 28,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.fullName,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                if (resume.jobTitle != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    resume.jobTitle!,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: _gold,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    _contactItem('✉', resume.email),
                    if (resume.phone != null) ...[
                      _contactDot(),
                      _contactItem('✆', resume.phone!),
                    ],
                    if (resume.location != null) ...[
                      _contactDot(),
                      _contactItem('⌖', resume.location!),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── BODY ──────────────────────────────────────────────
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 24,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // Summary
                if (resume.summary != null) ...[
                  _sectionTitle('PROFESSIONAL SUMMARY'),
                  pw.Text(
                    resume.summary!,
                    style: const pw.TextStyle(
                      fontSize: 10.5,
                      lineSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 18),
                ],

                // Work Experience
                if (resume.workExperiences.isNotEmpty) ...[
                  _sectionTitle('WORK EXPERIENCE'),
                  ...resume.workExperiences
                      .map((exp) => _experienceItem(exp)),
                  pw.SizedBox(height: 6),
                ],

                // Education
                if (resume.educations.isNotEmpty) ...[
                  _sectionTitle('EDUCATION'),
                  ...resume.educations.map((edu) => _educationItem(edu)),
                  pw.SizedBox(height: 6),
                ],

                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _sectionTitle('SKILLS'),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: resume.skills
                        .map((skill) => _skillChip(skill))
                        .toList(),
                  ),
                  pw.SizedBox(height: 18),
                ],

                // Projects
                if (resume.projects.isNotEmpty) ...[
                  _sectionTitle('PROJECTS'),
                  ...resume.projects.map((proj) => _projectItem(proj)),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: _navy,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 1.5, color: _gold),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _experienceItem(dynamic exp) {
    final startDate = _formatDate(exp.startDate);
    final endDate = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);
    final description = exp.description;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
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
                  fontSize: 11.5,
                  color: _navy,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: _lightGrey,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  '$startDate — $endDate',
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    color: _textGrey,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            exp.company,
            style: pw.TextStyle(
              fontSize: 10.5,
              color: _gold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              description,
              style: const pw.TextStyle(
                fontSize: 10,
                lineSpacing: 1.4,
                color: _textGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _educationItem(dynamic edu) {
    final degree = edu.degree ?? '';
    final gpa = edu.gpa;
    final endDate = _formatDate(edu.endDate);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                degree,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                  color: _navy,
                ),
              ),
              pw.Text(
                edu.institution,
                style: const pw.TextStyle(
                  fontSize: 10.5,
                  color: _textGrey,
                ),
              ),
              if (gpa != null)
                pw.Text(
                  'GPA: $gpa',
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    color: _textGrey,
                  ),
                ),
            ],
          ),
          pw.Text(
            endDate,
            style: const pw.TextStyle(fontSize: 9.5, color: _textGrey),
          ),
        ],
      ),
    );
  }

  pw.Widget _skillChip(dynamic skill) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _navy, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        skill.name,
        style: const pw.TextStyle(fontSize: 9.5, color: _navy),
      ),
    );
  }

  pw.Widget _projectItem(dynamic proj) {
    final description = proj.description;
    final techStack = proj.techStack as List<dynamic>? ?? [];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            proj.name,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: _navy,
            ),
          ),
          if (description != null && description.isNotEmpty)
            pw.Text(
              description,
              style: const pw.TextStyle(fontSize: 10, color: _textGrey),
            ),
          if (techStack.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Tech: ${techStack.join(', ')}',
              style: pw.TextStyle(
                fontSize: 9.5,
                color: _gold,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _contactItem(String icon, String text) {
    return pw.Row(
      children: [
        pw.Text(icon,
            style: const pw.TextStyle(fontSize: 9, color: _gold)),
        pw.SizedBox(width: 4),
        pw.Text(text,
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.white)),
      ],
    );
  }

  pw.Widget _contactDot() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
      child: pw.Text('•',
          style: const pw.TextStyle(fontSize: 9, color: _textGrey)),
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
