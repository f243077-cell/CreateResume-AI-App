// File: lib/infrastructure/services/templates/executive2_template.dart
// Style: Executive v2 — "Resume Worded" classic ATS layout: full-page
//        border frame, small-caps serif name, company/dates row + role
//        below, tight bulleted achievements, 4-column skills grid.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class Executive2Template implements ResumeTemplateBase {
  static const PdfColor _black    = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey = PdfColor.fromInt(0xFF2A2A2A);
  static const PdfColor _midGrey  = PdfColor.fromInt(0xFF555555);
  static const PdfColor _border   = PdfColor.fromInt(0xFF000000);

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
        margin: const pw.EdgeInsets.all(14),
        build: (context) => [
          pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _border, width: 1.2)),
            padding: const pw.EdgeInsets.symmetric(horizontal: 34, vertical: 26),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // ── HEADER ──────────────────────────────────
                pw.Center(
                  child: pw.Text(
                    _sanitize(resume.fullName).toUpperCase(),
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _black, letterSpacing: 1.5),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    _sanitize(_buildContactLine(resume)),
                    style: const pw.TextStyle(fontSize: 8.5, color: _midGrey),
                  ),
                ),
                pw.SizedBox(height: 16),

                // ── SUMMARY (optional) ─────────────────────
                if (resume.summary != null) ...[
                  pw.Text(
                    _sanitize(resume.summary!),
                    style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5, color: _darkGrey),
                  ),
                  pw.SizedBox(height: 14),
                ],

                // ── PROFESSIONAL EXPERIENCE ────────────────
                if (resume.workExperiences.isNotEmpty) ...[
                  _sectionHeader('PROFESSIONAL EXPERIENCE'),
                  ...resume.workExperiences.map((e) => _expBlock(e)),
                  pw.SizedBox(height: 6),
                ],

                // ── PROJECTS ────────────────────────────────
                if (resume.projects.isNotEmpty) ...[
                  _sectionHeader('PROJECTS'),
                  ...resume.projects.map((p) => _projectBlock(p)),
                  pw.SizedBox(height: 6),
                ],

                // ── EDUCATION ───────────────────────────────
                if (resume.educations.isNotEmpty) ...[
                  _sectionHeader('EDUCATION'),
                  ...resume.educations.map((e) => _eduBlock(e)),
                  pw.SizedBox(height: 6),
                ],

                // ── SKILLS (4-column grid) ──────────────────
                if (resume.skills.isNotEmpty) ...[
                  _sectionHeader('SKILLS'),
                  _skillsGrid(resume.skills),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  String _buildContactLine(ResumeData resume) {
    final parts = <String>[];
    if (resume.location != null) parts.add(resume.location!);
    parts.add(resume.phone ?? '');
    parts.add(resume.email);
    return parts.where((p) => p.isNotEmpty).join('  .  ');
  }

  pw.Widget _sectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _black, letterSpacing: 0.5),
          ),
          pw.SizedBox(height: 3),
          pw.Container(height: 1, color: _black),
          pw.SizedBox(height: 8),
        ],
      ),
    );
  }

  pw.Widget _expBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(_sanitize(exp.company), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black)),
              pw.Text(_dateRange(exp.startDate, exp.endDate, exp.isCurrent), style: const pw.TextStyle(fontSize: 9, color: _midGrey)),
            ],
          ),
          pw.Text(
            _sanitize(exp.role),
            style: pw.TextStyle(fontSize: 9.5, fontStyle: pw.FontStyle.italic, color: _darkGrey),
          ),
          if (bullets.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            ...bullets.map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
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

  pw.Widget _projectBlock(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_sanitize(proj.name), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black)),
          if (proj.techStack.isNotEmpty)
            pw.Text(_sanitize(proj.techStack.join(', ')), style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: _midGrey)),
          if (proj.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, top: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('-  ', style: const pw.TextStyle(fontSize: 9)),
                  pw.Expanded(
                    child: pw.Text(_sanitize(proj.description), style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: _darkGrey)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _eduBlock(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(_sanitize(edu.institution), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black)),
              pw.Text(
                _sanitize('${edu.degree}${edu.field.isNotEmpty ? '; Major in ${edu.field}' : ''}'),
                style: const pw.TextStyle(fontSize: 9, color: _darkGrey),
              ),
              if (edu.gpa != null)
                pw.Text('GPA: ${edu.gpa}', style: const pw.TextStyle(fontSize: 8.5, color: _midGrey)),
            ],
          ),
          pw.Text(
            edu.endDate != null ? '${_monthName(edu.endDate!.month)} ${edu.endDate!.year}' : '',
            style: const pw.TextStyle(fontSize: 9, color: _midGrey),
          ),
        ],
      ),
    );
  }

  pw.Widget _skillsGrid(List<Skill> skills) {
    final rows = <pw.Widget>[];
    for (int i = 0; i < skills.length; i += 4) {
      final rowSkills = skills.sublist(i, i + 4 > skills.length ? skills.length : i + 4);
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
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

  String _dateRange(DateTime start, DateTime? end, bool isCurrent) {
    final startStr = '${_monthName(start.month)} ${start.year}';
    final endStr = isCurrent ? 'Present' : (end != null ? '${_monthName(end.month)} ${end.year}' : '');
    return '$startStr - $endStr';
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}