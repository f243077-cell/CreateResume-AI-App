// File: lib/infrastructure/services/templates/executive2_template.dart
// Style: Executive v2 — Two-column layout, cream sidebar with teal/dark accents,
//        initials avatar, skill bars, premium senior professional look

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class Executive2Template implements ResumeTemplateBase {
  static const PdfColor _sidebar   = PdfColor.fromInt(0xFF1E2D40);
  static const PdfColor _accent    = PdfColor.fromInt(0xFF2E9E77);  // teal
  static const PdfColor _white     = PdfColors.white;
  static const PdfColor _offWhite  = PdfColor.fromInt(0xFFF2F2F2);
  static const PdfColor _black     = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey  = PdfColor.fromInt(0xFF333333);
  static const PdfColor _midGrey   = PdfColor.fromInt(0xFF777777);
  static const PdfColor _sideText  = PdfColor.fromInt(0xFFCCCCCC);

  /// Replaces Unicode punctuation/symbols that the default PDF font can't
  /// render (en/em dashes, smart quotes, ellipsis, icon glyphs) with safe
  /// ASCII equivalents. Without this, unsupported glyphs render as empty
  /// "tofu" boxes in the generated PDF.
  static String _sanitize(String text) {
    return text
        .replaceAll('\u2013', '-')  // – en dash
        .replaceAll('\u2014', '-')  // — em dash
        .replaceAll('\u2018', "'")  // ‘ left single quote
        .replaceAll('\u2019', "'")  // ’ right single quote
        .replaceAll('\u201C', '"')  // “ left double quote
        .replaceAll('\u201D', '"')  // ” right double quote
        .replaceAll('\u2026', '...') // … ellipsis
        .replaceAll('\u00A0', ' ')  // non-breaking space
        .replaceAll('\u2022', '-'); // • bullet
  }

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

            // ── LEFT SIDEBAR (35%) ──────────────────────────────────────
            pw.Container(
              width: 195,
              color: _sidebar,
              padding: const pw.EdgeInsets.all(22),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  // Avatar circle
                  pw.Center(
                    child: pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: _accent,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          _initials(resume.fullName),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: _white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Name
                  pw.Text(
                    _sanitize(resume.fullName),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: _white,
                    ),
                  ),
                  if (resume.jobTitle != null) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      _sanitize(resume.jobTitle!),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9, color: _accent, fontWeight: pw.FontWeight.bold),
                    ),
                  ],

                  pw.SizedBox(height: 14),
                  _sideDivider(),

                  // Contact
                  _sideSection('CONTACT'),
                  _sideContact('Email:', resume.email),
                  if (resume.phone != null) _sideContact('Phone:', resume.phone!),
                  if (resume.location != null) _sideContact('Location:', resume.location!),

                  pw.SizedBox(height: 14),
                  _sideDivider(),

                  // Skills with bars
                  if (resume.skills.isNotEmpty) ...[
                    _sideSection('SKILLS'),
                    ...resume.skills.take(10).map((s) => _skillBar(s)),
                  ],

                  pw.SizedBox(height: 14),
                  _sideDivider(),

                  // Education in sidebar
                  if (resume.educations.isNotEmpty) ...[
                    _sideSection('EDUCATION'),
                    ...resume.educations.map((e) => _sideEdu(e)),
                  ],
                ],
              ),
            ),

            // ── RIGHT MAIN (65%) ────────────────────────────────────────
            pw.Expanded(
              child: pw.Container(
                color: _white,
                padding: const pw.EdgeInsets.fromLTRB(26, 28, 28, 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    // Summary
                    if (resume.summary != null) ...[
                      _mainSection('About Me'),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: _offWhite,
                          borderRadius: pw.BorderRadius.circular(5),
                          border: pw.Border(
                            left: pw.BorderSide(color: _accent, width: 3),
                          ),
                        ),
                        child: pw.Text(
                          _sanitize(resume.summary!),
                          style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.6, color: _darkGrey),
                        ),
                      ),
                      pw.SizedBox(height: 16),
                    ],

                    // Experience
                    if (resume.workExperiences.isNotEmpty) ...[
                      _mainSection('Experience'),
                      ...resume.workExperiences.map((e) => _mainExpBlock(e)),
                      pw.SizedBox(height: 6),
                    ],

                    // Projects
                    if (resume.projects.isNotEmpty) ...[
                      _mainSection('Projects'),
                      ...resume.projects.map((p) => _mainProjectBlock(p)),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  pw.Widget _sideDivider() =>
      pw.Container(height: 0.5, color: const PdfColor.fromInt(0xFF3A5070), margin: const pw.EdgeInsets.only(bottom: 10));

  pw.Widget _sideSection(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: _accent,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  pw.Widget _sideContact(String label, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: _accent)),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(_sanitize(text), style: const pw.TextStyle(fontSize: 8, color: _sideText)),
          ),
        ],
      ),
    );
  }

  pw.Widget _skillBar(Skill skill) {
    final fill = switch (skill.level) {
      'expert' => 1.0,
      'intermediate' => 0.65,
      _ => 0.33,
    };

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_sanitize(skill.name), style: const pw.TextStyle(fontSize: 8.5, color: _white)),
          pw.SizedBox(height: 3),
          pw.Stack(
            children: [
              pw.Container(
                height: 4,
                color: const PdfColor.fromInt(0xFF2E4A6A),
                width: double.infinity,
              ),
              pw.SizedBox(
                width: 100 * fill,
                child: pw.Container(height: 4, color: _accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _sideEdu(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _sanitize(edu.degree),
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _white),
          ),
          pw.Text(_sanitize(edu.institution), style: const pw.TextStyle(fontSize: 8, color: _accent)),
          pw.Text(
            edu.endDate != null ? '${edu.startDate.year} - ${edu.endDate!.year}' : '',
            style: const pw.TextStyle(fontSize: 7.5, color: _sideText),
          ),
          if (edu.gpa != null)
            pw.Text('GPA: ${edu.gpa}', style: const pw.TextStyle(fontSize: 7.5, color: _sideText)),
        ],
      ),
    );
  }

  pw.Widget _mainSection(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _black),
          ),
          pw.Container(height: 2, width: 32, color: _accent),
        ],
      ),
    );
  }

  pw.Widget _mainExpBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Timeline dot
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3, right: 8),
            child: pw.Container(
              width: 8, height: 8,
              decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: _accent),
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_sanitize(exp.role), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black)),
                    pw.Text(
                      '${_formatDate(exp.startDate)} - ${exp.isCurrent ? 'Present' : _formatDate(exp.endDate)}',
                      style: const pw.TextStyle(fontSize: 8.5, color: _midGrey),
                    ),
                  ],
                ),
                pw.Text(_sanitize(exp.company), style: pw.TextStyle(fontSize: 9.5, color: _accent, fontWeight: pw.FontWeight.bold)),
                if (bullets.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  ...bullets.map(
                    (line) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 6, bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('- ', style: const pw.TextStyle(fontSize: 9, color: _darkGrey)),
                          pw.Expanded(
                            child: pw.Text(
                              _sanitize(line.replaceAll(RegExp(r'^[•\-\*]\s*'), '')),
                              style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.45, color: _darkGrey),
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
        ],
      ),
    );
  }

  pw.Widget _mainProjectBlock(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _offWhite,
          borderRadius: pw.BorderRadius.circular(5),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFDDDDDD), width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_sanitize(proj.name), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
                if (proj.url != null)
                  pw.Text(_sanitize(proj.url!), style: const pw.TextStyle(fontSize: 8, color: _midGrey)),
              ],
            ),
            if (proj.techStack.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 4,
                children: proj.techStack
                    .map((t) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: pw.BoxDecoration(color: _sidebar, borderRadius: pw.BorderRadius.circular(3)),
                          child: pw.Text(_sanitize(t), style: const pw.TextStyle(fontSize: 7.5, color: _white)),
                        ))
                    .toList(),
              ),
            ],
            if (proj.description.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                _sanitize(proj.description),
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: _darkGrey),
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