// File: lib/infrastructure/services/templates/classic_template.dart
// Style: Inspired by Image 1 — ATS-friendly, serif header, bold section titles, bullet points

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class ClassicTemplate implements ResumeTemplateBase {
  static const PdfColor _black      = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey   = PdfColor.fromInt(0xFF333333);
  static const PdfColor _midGrey    = PdfColor.fromInt(0xFF666666);
  static const PdfColor _divider    = PdfColor.fromInt(0xFF222222);

  /// Replaces Unicode punctuation that the default PDF font can't render
  /// (en/em dashes, smart quotes, bullets, ellipsis, non-breaking spaces)
  /// with safe ASCII equivalents. Without this, unsupported glyphs render
  /// as empty "tofu" boxes in the generated PDF.
  static String _sanitize(String text) {
    return text
        .replaceAll('\u2013', '-')  // – en dash
        .replaceAll('\u2014', '-')  // — em dash
        .replaceAll('\u2018', "'")  // ' left single quote
        .replaceAll('\u2019', "'")  // ' right single quote
        .replaceAll('\u201C', '"')  // " left double quote
        .replaceAll('\u201D', '"')  // " right double quote
        .replaceAll('\u2026', '...') // … ellipsis
        .replaceAll('\u00A0', ' ')  // non-breaking space
        .replaceAll('\u2022', '-'); // • bullet (we render our own bullets separately)
  }

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (context) => [

          // ── HEADER ─────────────────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                _toSmallCaps(_sanitize(resume.fullName)),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _black,
                  letterSpacing: 1.0,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _sanitize(_buildContactLine(resume)),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: _midGrey),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: _divider, thickness: 1.2),
            ],
          ),

          // ── SUMMARY ────────────────────────────────────────────────────
          if (resume.summary != null) ...[
            pw.SizedBox(height: 10),
            _sectionHeader('PROFESSIONAL SUMMARY'),
            pw.Text(
              _sanitize(resume.summary!),
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: _darkGrey),
            ),
            pw.SizedBox(height: 10),
          ],

          // ── EXPERIENCE ─────────────────────────────────────────────────
          if (resume.workExperiences.isNotEmpty) ...[
            _sectionHeader('PROFESSIONAL EXPERIENCE'),
            ...resume.workExperiences.map((e) => _experienceBlock(e)),
          ],

          // ── EDUCATION ──────────────────────────────────────────────────
          if (resume.educations.isNotEmpty) ...[
            _sectionHeader('EDUCATION'),
            ...resume.educations.map((e) => _educationBlock(e)),
          ],

          // ── SKILLS ─────────────────────────────────────────────────────
          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('SKILLS'),
            _skillsGrid(resume.skills),
            pw.SizedBox(height: 8),
          ],

          // ── PROJECTS ───────────────────────────────────────────────────
          if (resume.projects.isNotEmpty) ...[
            _sectionHeader('PROJECTS'),
            ...resume.projects.map((p) => _projectBlock(p)),
          ],
        ],
      ),
    );

    return doc;
  }

  String _toSmallCaps(String text) => text.toUpperCase();

  String _buildContactLine(ResumeData resume) {
    final parts = <String>[];
    if (resume.location != null) parts.add(resume.location!);
    parts.add(resume.email);
    if (resume.phone != null) parts.add(resume.phone!);
    return parts.join('  -  ');
  }

  pw.Widget _sectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: _black,
              letterSpacing: 0.5,
            ),
          ),
          pw.Divider(color: _divider, thickness: 0.8),
          pw.SizedBox(height: 4),
        ],
      ),
    );
  }

  pw.Widget _experienceBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company + date row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _sanitize(exp.company),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10.5,
                  color: _black,
                ),
              ),
              pw.Text(
                _formatDateRange(exp.startDate, exp.endDate, exp.isCurrent),
                style: const pw.TextStyle(fontSize: 9.5, color: _midGrey),
              ),
            ],
          ),
          // Role
          pw.Text(
            _sanitize(exp.role),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _darkGrey,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          // Bullet points
          ...bullets.map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('- ', style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
                  pw.Expanded(
                    child: pw.Text(
                      _sanitize(line.replaceAll(RegExp(r'^[•\-\*]\s*'), '')),
                      style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4, color: _darkGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _educationBlock(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _sanitize(edu.institution),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10.5,
                  color: _black,
                ),
              ),
              pw.Text(
                edu.endDate != null
                    ? 'May ${edu.endDate!.year}'
                    : '',
                style: const pw.TextStyle(fontSize: 9.5, color: _midGrey),
              ),
            ],
          ),
          pw.Text(
            _sanitize('${edu.degree} in ${edu.field}'),
            style: const pw.TextStyle(fontSize: 10, color: _darkGrey),
          ),
          if (edu.gpa != null)
            pw.Text(
              'GPA: ${edu.gpa}',
              style: const pw.TextStyle(fontSize: 9.5, color: _midGrey),
            ),
        ],
      ),
    );
  }

  pw.Widget _skillsGrid(List<Skill> skills) {
    // 4 columns grid like Image 1
    final rows = <pw.Widget>[];
    for (int i = 0; i < skills.length; i += 4) {
      final rowSkills = skills.sublist(i, i + 4 > skills.length ? skills.length : i + 4);
      rows.add(
        pw.Row(
          children: rowSkills.map((s) =>
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('- ', style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
                    pw.Expanded(
                      child: pw.Text(_sanitize(s.name), style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
                    ),
                  ],
                ),
              ),
            ),
          ).toList(),
        ),
      );
    }
    return pw.Column(children: rows);
  }

  pw.Widget _projectBlock(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _sanitize(proj.name),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
              ),
            ],
          ),
          if (proj.techStack.isNotEmpty)
            pw.Text(
              _sanitize(proj.techStack.join(', ')),
              style: pw.TextStyle(fontSize: 9.5, color: _darkGrey, fontStyle: pw.FontStyle.italic),
            ),
          if (proj.description.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, top: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('- ', style: const pw.TextStyle(fontSize: 9.5)),
                  pw.Expanded(
                    child: pw.Text(_sanitize(proj.description), style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4, color: _darkGrey)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end, bool isCurrent) {
    final endStr = isCurrent ? 'Present' : (end != null ? '${end.year}' : '');
    return '${start.year} - $endStr';
  }
}