import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_template_base.dart';

class ExecutiveTemplate implements ResumeTemplateBase {
  static const PdfColor _navy = PdfColor.fromInt(0xFF1B2B44);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD4A92E);
  static const PdfColor _lightGold = PdfColor.fromInt(0xFFFFF3CC);
  static const PdfColor _cardGrey = PdfColor.fromInt(0xFFF6F6F6);
  static const PdfColor _textGrey = PdfColor.fromInt(0xFF555555);
  static const PdfColor _darkGrey = PdfColor.fromInt(0xFF333333);

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── GOLD LEFT BORDER ─────────────────────────
              pw.Container(width: 5, color: _gold),

              // ── MAIN CONTENT ─────────────────────────────
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 32,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [

                      // ── HEADER ──────────────────────────
                      pw.Text(
                        resume.fullName,
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: _navy,
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
                      pw.SizedBox(height: 10),

                      // Contact row
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(
                          color: _cardGrey,
                          borderRadius: pw.BorderRadius.circular(4),
                          border: pw.Border(
                            left: pw.BorderSide(color: _gold, width: 3),
                          ),
                        ),
                        child: pw.Row(
                          children: [
                            _contactPill('✉', resume.email),
                            if (resume.phone != null)
                              _contactPill('✆', resume.phone!),
                            if (resume.location != null)
                              _contactPill('⌖', resume.location!),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 22),

                      // Summary
                      if (resume.summary != null) ...[
                        _sectionTitle('Professional Summary'),
                        pw.Text(
                          resume.summary!,
                          style: const pw.TextStyle(
                            fontSize: 10.5,
                            lineSpacing: 1.6,
                            color: _textGrey,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                      ],

                      // Work Experience
                      if (resume.workExperiences.isNotEmpty) ...[
                        _sectionTitle('Work Experience'),
                        ...resume.workExperiences
                            .map((exp) => _expCard(exp)),
                        pw.SizedBox(height: 6),
                      ],

                      // Education
                      if (resume.educations.isNotEmpty) ...[
                        _sectionTitle('Education'),
                        ...resume.educations
                            .map((edu) => _eduCard(edu)),
                        pw.SizedBox(height: 6),
                      ],

                      // Skills
                      if (resume.skills.isNotEmpty) ...[
                        _sectionTitle('Core Skills'),
                        pw.Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: resume.skills
                              .map((s) => _skillChip(s))
                              .toList(),
                        ),
                        pw.SizedBox(height: 20),
                      ],

                      // Projects
                      if (resume.projects.isNotEmpty) ...[
                        _sectionTitle('Notable Projects'),
                        ...resume.projects
                            .map((proj) => _projectCard(proj)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Gold square bullet
          pw.Container(
            width: 8,
            height: 8,
            color: _gold,
            margin: const pw.EdgeInsets.only(right: 8),
          ),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: _navy,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Container(height: 0.8, color: _gold),
          ),
        ],
      ),
    );
  }

  pw.Widget _expCard(dynamic exp) {
    final startDate = _formatDate(exp.startDate);
    final endDate = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);
    final description = exp.description;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _cardGrey,
          borderRadius: pw.BorderRadius.circular(5),
          border: pw.Border.all(
            color: const PdfColor.fromInt(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  exp.role,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11.5,
                    color: _darkGrey,
                  ),
                ),
                // Date pill badge
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _navy,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    '$startDate — $endDate',
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              exp.company,
              style: pw.TextStyle(
                fontSize: 10.5,
                color: _gold,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                description,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 1.5,
                  color: _textGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _eduCard(dynamic edu) {
    final degree = edu.degree ?? '';
    final field = edu.field;
    final gpa = edu.gpa;
    final endDate = _formatDate(edu.endDate);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _cardGrey,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  degree,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: _darkGrey,
                  ),
                ),
                if (field != null)
                  pw.Text(
                    field,
                    style: const pw.TextStyle(
                        fontSize: 10, color: _textGrey),
                  ),
                pw.Text(
                  edu.institution,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _gold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  endDate,
                  style: const pw.TextStyle(
                      fontSize: 9.5, color: _textGrey),
                ),
                if (gpa != null)
                  pw.Text(
                    'GPA: $gpa',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      color: _gold,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _skillChip(dynamic skill) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: pw.BoxDecoration(
        color: _gold,
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Text(
        skill.name,
        style: pw.TextStyle(
          fontSize: 9.5,
          color: _navy,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _projectCard(dynamic proj) {
    final description = proj.description;
    final techStack = proj.techStack as List<dynamic>? ?? [];
    final url = proj.url;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: _gold, width: 3),
          ),
          color: _lightGold,
          borderRadius: const pw.BorderRadius.only(
            topRight: pw.Radius.circular(5),
            bottomRight: pw.Radius.circular(5),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  proj.name,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: _navy,
                  ),
                ),
                if (url != null)
                  pw.Text(
                    url,
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: _textGrey,
                    ),
                  ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                description,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: _textGrey,
                  lineSpacing: 1.4,
                ),
              ),
            ],
            if (techStack.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 5,
                runSpacing: 4,
                children: techStack
                    .map((tech) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: _navy,
                            borderRadius:
                                pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(
                            tech,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.white,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _contactPill(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 16),
      child: pw.Row(
        children: [
          pw.Text(icon,
              style: const pw.TextStyle(fontSize: 9, color: _gold)),
          pw.SizedBox(width: 4),
          pw.Text(text,
              style: const pw.TextStyle(
                  fontSize: 9.5, color: _textGrey)),
        ],
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
