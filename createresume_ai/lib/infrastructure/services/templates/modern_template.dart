// File: lib/infrastructure/services/templates/modern_template.dart
// Style: Two-column layout — dark navy sidebar (name, contact, profile,
//        skills) + white main area (work experience, education) with
//        icon-style section header bars, inspired by classic two-column
//        professional resume layouts.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class ModernTemplate implements ResumeTemplateBase {
  static const PdfColor _sidebar   = PdfColor.fromInt(0xFF1E2B3C);
  static const PdfColor _sideText  = PdfColor.fromInt(0xFFD8DEE6);
  static const PdfColor _accent    = PdfColor.fromInt(0xFF3D5A80);
  static const PdfColor _white     = PdfColors.white;
  static const PdfColor _black     = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey  = PdfColor.fromInt(0xFF333333);
  static const PdfColor _midGrey   = PdfColor.fromInt(0xFF777777);
  static const PdfColor _offWhite  = PdfColor.fromInt(0xFFF4F4F4);

  /// Replaces Unicode punctuation/symbols that the default PDF font can't
  /// render with safe ASCII equivalents, then strips any remaining
  /// character outside the safe printable range as a catch-all — this
  /// guarantees no "tofu" boxes regardless of what symbols the AI outputs.
  static String _sanitize(String text) {
    var result = text
        .replaceAll('\u2013', '-')   // – en dash
        .replaceAll('\u2014', '-')   // — em dash
        .replaceAll('\u2011', '-')   // ‑ non-breaking hyphen
        .replaceAll('\u2018', "'")   // ' left single quote
        .replaceAll('\u2019', "'")   // ' right single quote
        .replaceAll('\u201C', '"')   // " left double quote
        .replaceAll('\u201D', '"')   // " right double quote
        .replaceAll('\u2026', '...') // … ellipsis
        .replaceAll('\u00A0', ' ')   // non-breaking space
        .replaceAll(RegExp(r'[\u2022\u2023\u25E6\u2043\u2219\u25AA\u25CF\u25A0\u2192\u2794\u27A4]'), '-');

    result = result.replaceAllMapped(RegExp(r'[^\x20-\x7E\xA0-\xFF]'), (m) => ' ');
    return result;
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

            // ── LEFT SIDEBAR ───────────────────────────────────────────
            pw.Container(
              width: 190,
              color: _sidebar,
              padding: const pw.EdgeInsets.all(22),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Avatar circle with initials
                  pw.Center(
                    child: pw.Container(
                      width: 72,
                      height: 72,
                      decoration: const pw.BoxDecoration(
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
                  pw.SizedBox(height: 14),

                  pw.Text(
                    _sanitize(resume.fullName),
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _white),
                  ),
                  if (resume.jobTitle != null) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      _sanitize(resume.jobTitle!),
                      style: const pw.TextStyle(fontSize: 9.5, color: _sideText),
                    ),
                  ],

                  pw.SizedBox(height: 16),
                  _sideDivider(),

                  // Contact
                  _sideHeader('CONTACT'),
                  _sideLine('Email:', resume.email),
                  if (resume.phone != null) _sideLine('Phone:', resume.phone!),
                  if (resume.location != null) _sideLine('Location:', resume.location!),

                  pw.SizedBox(height: 16),
                  _sideDivider(),

                  // Profile
                  if (resume.summary != null) ...[
                    _sideHeader('PROFILE'),
                    pw.Text(
                      _sanitize(resume.summary!),
                      style: const pw.TextStyle(fontSize: 8.5, color: _sideText, lineSpacing: 1.5),
                    ),
                    pw.SizedBox(height: 16),
                    _sideDivider(),
                  ],

                  // Skills
                  if (resume.skills.isNotEmpty) ...[
                    _sideHeader('SKILLS'),
                    ...resume.skills.map((s) => _sideSkillItem(s)),
                  ],
                ],
              ),
            ),

            // ── RIGHT MAIN AREA ────────────────────────────────────────
            pw.Expanded(
              child: pw.Container(
                color: _white,
                padding: const pw.EdgeInsets.fromLTRB(26, 28, 28, 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    if (resume.workExperiences.isNotEmpty) ...[
                      _mainSectionHeader('WORK EXPERIENCE'),
                      ...resume.workExperiences.map((e) => _expBlock(e)),
                      pw.SizedBox(height: 10),
                    ],

                    if (resume.projects.isNotEmpty) ...[
                      _mainSectionHeader('PROJECTS'),
                      ...resume.projects.map((p) => _projectBlock(p)),
                      pw.SizedBox(height: 10),
                    ],

                    if (resume.educations.isNotEmpty) ...[
                      _mainSectionHeader('EDUCATION'),
                      ...resume.educations.map((e) => _eduBlock(e)),
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
    if (name.isNotEmpty) return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return '';
  }

  pw.Widget _sideDivider() => pw.Container(
        height: 0.6,
        color: const PdfColor.fromInt(0xFF3A4E63),
        margin: const pw.EdgeInsets.only(bottom: 12),
      );

  pw.Widget _sideHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(width: 10, height: 10, color: _accent),
          pw.SizedBox(width: 6),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: _white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sideLine(String label, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: _accent)),
          pw.Text(_sanitize(text), style: const pw.TextStyle(fontSize: 8.5, color: _sideText)),
        ],
      ),
    );
  }

  pw.Widget _sideSkillItem(Skill skill) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4, height: 4,
            margin: const pw.EdgeInsets.only(top: 3, right: 6),
            color: _accent,
          ),
          pw.Expanded(
            child: pw.Text(
              _sanitize(skill.name),
              style: const pw.TextStyle(fontSize: 8.5, color: _sideText, lineSpacing: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _mainSectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.Container(
            width: 22, height: 22,
            decoration: pw.BoxDecoration(color: _sidebar, borderRadius: pw.BorderRadius.circular(4)),
            margin: const pw.EdgeInsets.only(right: 8),
          ),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _black, letterSpacing: 0.6),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFDDDDDD))),
        ],
      ),
    );
  }

  pw.Widget _expBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14, left: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _sanitize(exp.company),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
          ),
          pw.Text(
            '${_sanitize(exp.role)}  |  ${_dateRange(exp.startDate, exp.endDate, exp.isCurrent)}',
            style: const pw.TextStyle(fontSize: 9, color: _midGrey),
          ),
          if (bullets.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            ...bullets.map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('-  ', style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
                    pw.Expanded(
                      child: pw.Text(
                        _sanitize(line.replaceAll(RegExp(r'^[\-\*]\s*'), '')),
                        style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.45, color: _darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _projectBlock(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12, left: 30),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(color: _offWhite, borderRadius: pw.BorderRadius.circular(4)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_sanitize(proj.name), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
                if (proj.url != null && proj.url!.isNotEmpty)
                  pw.Text('GitHub', style: const pw.TextStyle(fontSize: 8.5, color: _accent)),
              ],
            ),
            if (proj.techStack.isNotEmpty)
              pw.Text(_sanitize(proj.techStack.join(', ')), style: pw.TextStyle(fontSize: 8.5, color: _midGrey, fontStyle: pw.FontStyle.italic)),
            if (proj.description.isNotEmpty) ...[
              pw.SizedBox(height: 3),
              pw.Text(_sanitize(proj.description), style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: _darkGrey)),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _eduBlock(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10, left: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_sanitize('${edu.degree}${edu.field.isNotEmpty ? ' - ${edu.field}' : ''}'), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
          pw.Text(
            edu.endDate != null
                ? '${_sanitize(edu.institution)}  |  ${edu.startDate.year} - ${edu.endDate!.year}'
                : _sanitize(edu.institution),
            style: const pw.TextStyle(fontSize: 9, color: _midGrey),
          ),
        ],
      ),
    );
  }

  String _dateRange(DateTime start, DateTime? end, bool isCurrent) {
    final endStr = isCurrent ? 'present' : (end != null ? '${end.year}' : '');
    return '${start.year} - $endStr';
  }
}