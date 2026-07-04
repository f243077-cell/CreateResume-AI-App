// File: lib/infrastructure/services/templates/executive_template.dart
// Style: Executive v1 — Dark navy full-width header, gold accents,
//        card-based experience blocks, premium feel

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class ExecutiveTemplate implements ResumeTemplateBase {
  static const PdfColor _navy      = PdfColor.fromInt(0xFF1B2B44);
  static const PdfColor _gold      = PdfColor.fromInt(0xFFD4A92E);
  static const PdfColor _lightGold = PdfColor.fromInt(0xFFFFF8E1);
  static const PdfColor _cardGrey  = PdfColor.fromInt(0xFFF7F7F7);
  static const PdfColor _textGrey  = PdfColor.fromInt(0xFF444444);
  static const PdfColor _midGrey   = PdfColor.fromInt(0xFF777777);
  static const PdfColor _white     = PdfColors.white;

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [

          // ── DARK HEADER ────────────────────────────────────────────────
          pw.Container(
            width: double.infinity,
            color: _navy,
            padding: const pw.EdgeInsets.fromLTRB(40, 30, 40, 26),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  resume.fullName,
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: _white,
                    letterSpacing: 0.5,
                  ),
                ),
                if (resume.jobTitle != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    resume.jobTitle!,
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: _gold,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
                pw.SizedBox(height: 12),
                // Contact row in header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFF243550),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Wrap(
                    spacing: 20,
                    children: [
                      _headerContact('✉', resume.email),
                      if (resume.phone != null) _headerContact('✆', resume.phone!),
                      if (resume.location != null) _headerContact('⌖', resume.location!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ───────────────────────────────────────────────────────
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(40, 24, 40, 32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // Summary
                if (resume.summary != null) ...[
                  _sectionTitle('Professional Summary'),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _lightGold,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border(left: pw.BorderSide(color: _gold, width: 3)),
                    ),
                    child: pw.Text(
                      resume.summary!,
                      style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.6, color: _textGrey),
                    ),
                  ),
                  pw.SizedBox(height: 18),
                ],

                // Experience
                if (resume.workExperiences.isNotEmpty) ...[
                  _sectionTitle('Work Experience'),
                  ...resume.workExperiences.map((e) => _expCard(e)),
                  pw.SizedBox(height: 6),
                ],

                // Education
                if (resume.educations.isNotEmpty) ...[
                  _sectionTitle('Education'),
                  ...resume.educations.map((e) => _eduCard(e)),
                  pw.SizedBox(height: 6),
                ],

                // Skills
                if (resume.skills.isNotEmpty) ...[
                  _sectionTitle('Core Skills'),
                  pw.Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: resume.skills.map((s) => _goldChip(s.name)).toList(),
                  ),
                  pw.SizedBox(height: 18),
                ],

                // Projects
                if (resume.projects.isNotEmpty) ...[
                  _sectionTitle('Notable Projects'),
                  ...resume.projects.map((p) => _projectCard(p)),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _headerContact(String icon, String text) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(icon, style: const pw.TextStyle(fontSize: 9, color: _gold)),
        pw.SizedBox(width: 4),
        pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: _white)),
      ],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.Container(width: 4, height: 16, color: _gold, margin: const pw.EdgeInsets.only(right: 8)),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _navy),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Container(height: 0.8, color: _gold)),
        ],
      ),
    );
  }

  pw.Widget _expCard(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _cardGrey,
          borderRadius: pw.BorderRadius.circular(5),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE8E8E8), width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  exp.role,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: _navy),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: _navy,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    '${_formatDate(exp.startDate)} – ${exp.isCurrent ? 'Present' : _formatDate(exp.endDate)}',
                    style: const pw.TextStyle(fontSize: 8, color: _white),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              exp.company,
              style: pw.TextStyle(fontSize: 10, color: _gold, fontWeight: pw.FontWeight.bold),
            ),
            if (bullets.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              ...bullets.map(
                (line) => pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('▸  ', style: pw.TextStyle(fontSize: 8.5, color: _gold)),
                      pw.Expanded(
                        child: pw.Text(
                          line.replaceAll(RegExp(r'^[•\-\*▸]\s*'), ''),
                          style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.45, color: _textGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _eduCard(Education edu) {
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
                  edu.degree ?? '',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: _navy),
                ),
                if (edu.field != null)
                  pw.Text(edu.field!, style: const pw.TextStyle(fontSize: 10, color: _textGrey)),
                pw.Text(
                  edu.institution,
                  style: pw.TextStyle(fontSize: 10, color: _gold, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (edu.endDate != null)
                  pw.Text(
                    '${edu.startDate?.year ?? ''} – ${edu.endDate!.year}',
                    style: const pw.TextStyle(fontSize: 9.5, color: _midGrey),
                  ),
                if (edu.gpa != null)
                  pw.Text(
                    'GPA: ${edu.gpa}',
                    style: pw.TextStyle(fontSize: 9.5, color: _gold, fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _goldChip(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: _gold,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9.5, color: _navy, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _projectCard(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _lightGold,
          borderRadius: const pw.BorderRadius.only(
            topRight: pw.Radius.circular(5),
            bottomRight: pw.Radius.circular(5),
          ),
          border: pw.Border(left: pw.BorderSide(color: _gold, width: 3)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(proj.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _navy)),
                if (proj.url != null && proj.url!.isNotEmpty)
                  pw.Text(proj.url!, style: const pw.TextStyle(fontSize: 8.5, color: _midGrey)),
              ],
            ),
            if (proj.techStack.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 4,
                children: proj.techStack.map((t) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: pw.BoxDecoration(color: _navy, borderRadius: pw.BorderRadius.circular(3)),
                  child: pw.Text(t, style: const pw.TextStyle(fontSize: 7.5, color: _white)),
                )).toList(),
              ),
            ],
            if (proj.description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                proj.description,
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4, color: _textGrey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}';
  }
}
