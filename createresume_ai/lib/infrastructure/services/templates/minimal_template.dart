// File: lib/infrastructure/services/templates/minimal_template.dart
// Style: Clean ATS-friendly single column — centered header, light-grey
//        full-width section bars, right-aligned dates, bulleted experience,
//        3-column skills grid at the bottom.

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_template_base.dart';

class MinimalTemplate implements ResumeTemplateBase {
  static const PdfColor _black     = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey  = PdfColor.fromInt(0xFF333333);
  static const PdfColor _midGrey   = PdfColor.fromInt(0xFF666666);
  static const PdfColor _sectionBg = PdfColor.fromInt(0xFFEFEFEF);
  static const PdfColor _divider   = PdfColor.fromInt(0xFFCCCCCC);

  /// Replaces Unicode punctuation/symbols that the default PDF font can't
  /// render with safe ASCII equivalents, then strips any remaining
  /// character outside the safe printable range as a catch-all — this
  /// guarantees no "tofu" boxes regardless of what symbols the AI outputs.
  static String _sanitize(String text) {
    var result = text
        .replaceAll('\u2013', '-')
        .replaceAll('\u2014', '-')
        .replaceAll('\u2011', '-')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'")
        .replaceAll('\u201C', '"')
        .replaceAll('\u201D', '"')
        .replaceAll('\u2026', '...')
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[\u2022\u2023\u25E6\u2043\u2219\u25AA\u25CF\u25A0\u2192\u2794\u27A4]'), '-');

    result = result.replaceAllMapped(RegExp(r'[^\x20-\x7E\xA0-\xFF]'), (m) => ' ');
    return result;
  }

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => [

          // ── HEADER ──────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                _sanitize(resume.fullName).toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _black, letterSpacing: 1.2),
              ),
              if (resume.jobTitle != null) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  _sanitize(resume.jobTitle!),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: _darkGrey),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Text(
                _sanitize(_buildContactLine(resume)),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: _midGrey),
              ),
              pw.SizedBox(height: 14),
            ],
          ),

          // ── SUMMARY ───────────────────────────────────────
          if (resume.summary != null) ...[
            _sectionBar('SUMMARY'),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8, bottom: 14),
              child: pw.Text(
                _sanitize(resume.summary!),
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.5, color: _darkGrey),
              ),
            ),
          ],

          // ── WORK EXPERIENCE ───────────────────────────────
          if (resume.workExperiences.isNotEmpty) ...[
            _sectionBar('WORK EXPERIENCE'),
            pw.SizedBox(height: 8),
            ...resume.workExperiences.map((exp) => _expItem(exp)),
          ],

          // ── EDUCATION ─────────────────────────────────────
          if (resume.educations.isNotEmpty) ...[
            _sectionBar('EDUCATION'),
            pw.SizedBox(height: 8),
            ...resume.educations.map((edu) => _eduItem(edu)),
          ],

          // ── PROJECTS ──────────────────────────────────────
          if (resume.projects.isNotEmpty) ...[
            _sectionBar('PROJECTS'),
            pw.SizedBox(height: 8),
            ...resume.projects.map((proj) => _projItem(proj)),
          ],

          // ── SKILLS (3-column grid) ────────────────────────
          if (resume.skills.isNotEmpty) ...[
            _sectionBar('KEY SKILLS'),
            pw.SizedBox(height: 8),
            _skillsGrid(resume.skills),
          ],
        ],
      ),
    );

    return doc;
  }

  String _buildContactLine(ResumeData resume) {
    final parts = <String>[resume.email];
    if (resume.phone != null) parts.add(resume.phone!);
    if (resume.location != null) parts.add(resume.location!);
    return parts.join('  |  ');
  }

  pw.Widget _sectionBar(String title) {
    return pw.Container(
      width: double.infinity,
      color: _sectionBg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _black, letterSpacing: 0.8),
      ),
    );
  }

  pw.Widget _expItem(dynamic exp) {
    final startDate = _formatDate(exp.startDate);
    final endDate = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);
    final bullets = (exp.description as String).isNotEmpty
        ? (exp.description as String).split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(_sanitize('${exp.role}, ${exp.company}'), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
              pw.Text('$startDate - $endDate', style: const pw.TextStyle(fontSize: 9, color: _midGrey)),
            ],
          ),
          if (bullets.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            ...bullets.map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('-  ', style: const pw.TextStyle(fontSize: 9, color: _darkGrey)),
                    pw.Expanded(
                      child: pw.Text(
                        _sanitize(line.replaceAll(RegExp(r'^[\-\*]\s*'), '')),
                        style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: _darkGrey),
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

  pw.Widget _eduItem(dynamic edu) {
    final degree = edu.degree ?? '';
    final field = edu.field;
    final gpa = edu.gpa;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _sanitize(field != null && field.isNotEmpty ? '$degree' : degree),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black),
              ),
              pw.Text(
                '${_formatDate(edu.startDate)} - ${_formatDate(edu.endDate)}',
                style: const pw.TextStyle(fontSize: 9, color: _midGrey),
              ),
            ],
          ),
          pw.Text(_sanitize(edu.institution), style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
          if (field != null && field.isNotEmpty)
            pw.Text(_sanitize('Major in $field'), style: const pw.TextStyle(fontSize: 8.5, color: _midGrey)),
          if (gpa != null)
            pw.Text('Final CGPA: $gpa', style: const pw.TextStyle(fontSize: 8.5, color: _midGrey)),
        ],
      ),
    );
  }

  pw.Widget _projItem(dynamic proj) {
    final description = proj.description as String?;
    final techStack = proj.techStack as List<dynamic>? ?? [];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_sanitize(proj.name), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
          if (description != null && description.isNotEmpty)
            pw.Text(_sanitize(description), style: const pw.TextStyle(fontSize: 9, color: _darkGrey, lineSpacing: 1.4)),
          if (techStack.isNotEmpty)
            pw.Text(_sanitize(techStack.join(', ')), style: const pw.TextStyle(fontSize: 8.5, color: _midGrey)),
        ],
      ),
    );
  }

  pw.Widget _skillsGrid(List<dynamic> skills) {
    final rows = <pw.Widget>[];
    for (int i = 0; i < skills.length; i += 3) {
      final rowSkills = skills.sublist(i, i + 3 > skills.length ? skills.length : i + 3);
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: rowSkills.map((s) => pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('-  ', style: const pw.TextStyle(fontSize: 9, color: _darkGrey)),
                  pw.Expanded(
                    child: pw.Text(_sanitize(s.name), style: const pw.TextStyle(fontSize: 9, color: _darkGrey)),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      );
    }
    return pw.Column(children: rows);
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('MMM yyyy').format(date);
    }
    return date.toString();
  }
}