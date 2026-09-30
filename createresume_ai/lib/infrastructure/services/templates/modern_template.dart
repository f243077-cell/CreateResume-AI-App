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
import '../../../domain/entities/honor.dart';
import 'pdf_text.dart';
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

  @override
  Future<pw.Document> generate(ResumeData resume, {pw.ThemeData? theme}) async {
    final doc = pw.Document(theme: theme);

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
                    PdfTextSanitizer.clean(resume.fullName),
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _white),
                  ),
                  if (resume.jobTitle != null) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      PdfTextSanitizer.clean(resume.jobTitle!),
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
                  if (resume.linkedin != null) _sideLine('LinkedIn:', resume.linkedin!),
                  if (resume.github != null) _sideLine('GitHub:', resume.github!),
                  if (resume.leetcode != null) _sideLine('LeetCode:', resume.leetcode!),

                  pw.SizedBox(height: 16),
                  _sideDivider(),

                  // Profile
                  if (resume.summary != null) ...[
                    _sideHeader('PROFILE'),
                    pw.Text(
                      PdfTextSanitizer.clean(resume.summary!),
                      style: const pw.TextStyle(fontSize: 8.5, color: _sideText, lineSpacing: 1.5),
                    ),
                    pw.SizedBox(height: 16),
                    _sideDivider(),
                  ],

                  // Skills
                  if (resume.skills.isNotEmpty) ...[
                    _sideHeader('SKILLS'),
                    for (final entry in groupSkillsByCategory(resume.skills).entries) ...[
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Text(PdfTextSanitizer.clean(entry.key), style: const pw.TextStyle(fontSize: 7.5, color: _accent)),
                      ),
                      ...entry.value.map((s) => _sideSkillItem(s)),
                    ],
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

                    if (resume.honors.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      _mainSectionHeader('HONORS & AWARDS'),
                      ...resume.honors.map((h) => _honorBlock(h)),
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
          pw.Text(PdfTextSanitizer.clean(text), style: const pw.TextStyle(fontSize: 8.5, color: _sideText)),
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
              PdfTextSanitizer.clean(skill.name),
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
            PdfTextSanitizer.clean(exp.company),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
          ),
          pw.Text(
            '${PdfTextSanitizer.clean(exp.role)}  |  ${_dateRange(exp.startDate, exp.endDate, exp.isCurrent)}',
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
                        PdfTextSanitizer.bullet(line),
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
                pw.Text(PdfTextSanitizer.clean(proj.name), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
                if (proj.url != null && proj.url!.isNotEmpty)
                  pw.Text('GitHub', style: const pw.TextStyle(fontSize: 8.5, color: _accent)),
              ],
            ),
            if (proj.techStack.isNotEmpty)
              pw.Text(PdfTextSanitizer.clean(proj.techStack.join(', ')), style: pw.TextStyle(fontSize: 8.5, color: _midGrey, fontStyle: pw.FontStyle.italic)),
            if (proj.description.isNotEmpty) ...[
              pw.SizedBox(height: 3),
              pw.Text(PdfTextSanitizer.clean(proj.description), style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.4, color: _darkGrey)),
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
          pw.Text(PdfTextSanitizer.clean('${edu.degree}${edu.field.isNotEmpty ? ' - ${edu.field}' : ''}'), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black)),
          pw.Text(
            edu.endDate != null
                ? '${PdfTextSanitizer.clean(edu.institution)}  |  ${edu.startDate.year} - ${edu.endDate!.year}'
                : PdfTextSanitizer.clean(edu.institution),
            style: const pw.TextStyle(fontSize: 9, color: _midGrey),
          ),
        ],
      ),
    );
  }

  pw.Widget _honorBlock(Honor honor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 34, bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('-  ', style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: PdfTextSanitizer.clean(honor.title),
                    style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _black),
                  ),
                  if (honor.description != null && honor.description!.isNotEmpty)
                    pw.TextSpan(
                      text: ' - ${PdfTextSanitizer.clean(honor.description!)}',
                      style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey),
                    ),
                ],
              ),
            ),
          ),
          if (honor.certificateUrl != null && honor.certificateUrl!.isNotEmpty)
            pw.UrlLink(
              destination: honor.certificateUrl!,
              child: pw.Text('View Certificate', style: const pw.TextStyle(fontSize: 8.5, color: _accent)),
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