// File: lib/infrastructure/services/templates/classic_template.dart
// Style: Dense ATS-friendly single-column layout — paragraph summary,
// categorized skills as running text, vector-drawn bullet points, tight spacing.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/honor.dart';
import 'pdf_text.dart';
import 'resume_template_base.dart';

class ClassicTemplate implements ResumeTemplateBase {
  static const PdfColor _black    = PdfColor.fromInt(0xFF111111);
  static const PdfColor _darkGrey = PdfColor.fromInt(0xFF222222);
  static const PdfColor _midGrey  = PdfColor.fromInt(0xFF555555);
  static const PdfColor _divider  = PdfColor.fromInt(0xFF222222);
  static const PdfColor _link     = PdfColor.fromInt(0xFF1155CC);

  @override
  Future<pw.Document> generate(ResumeData resume, {pw.ThemeData? theme}) async {
    final doc = pw.Document(theme: theme);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 34),
        build: (context) => [
          _header(resume),

          if (resume.summary != null && resume.summary!.trim().isNotEmpty) ...[
            _sectionHeader('SUMMARY'),
            pw.Text(
              PdfTextSanitizer.clean(resume.summary!.trim()),
              textAlign: pw.TextAlign.justify,
              style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.15, color: _darkGrey),
            ),
            pw.SizedBox(height: 8),
          ],

          if (resume.skills.isNotEmpty) ...[
            _sectionHeader('SKILLS'),
            _skillsRunningText(resume.skills),
            pw.SizedBox(height: 8),
          ],

          if (resume.workExperiences.isNotEmpty) ...[
            _sectionHeader('EXPERIENCE'),
            ...resume.workExperiences.map((e) => _experienceBlock(e)),
          ],

          if (resume.projects.isNotEmpty) ...[
            _sectionHeader('PROJECTS'),
            ...resume.projects.map((p) => _projectBlock(p)),
          ],

          if (resume.educations.isNotEmpty) ...[
            _sectionHeader('EDUCATION'),
            ...resume.educations.map((e) => _educationBlock(e)),
          ],

          if (resume.honors.isNotEmpty) ...[
            _sectionHeader('HONORS & AWARDS'),
            ...resume.honors.map((h) => _honorBlock(h)),
          ],
        ],
      ),
    );

    return doc;
  }

  // ── HEADER ───────────────────────────────────────────────────────────

  pw.Widget _header(ResumeData resume) {
    final contactParts = <String>[];
    if (resume.phone != null && resume.phone!.isNotEmpty) contactParts.add(resume.phone!);
    contactParts.add(resume.email);
    if (resume.linkedin != null && resume.linkedin!.isNotEmpty) contactParts.add('LinkedIn: ${resume.linkedin}');
    if (resume.github != null && resume.github!.isNotEmpty) contactParts.add('GitHub: ${resume.github}');
    if (resume.leetcode != null && resume.leetcode!.isNotEmpty) contactParts.add('LeetCode: ${resume.leetcode}');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          resume.fullName.toUpperCase(),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: _black,
            letterSpacing: 1.2,
          ),
        ),
        if (resume.jobTitle != null && resume.jobTitle!.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            PdfTextSanitizer.clean(resume.jobTitle!),
            style: pw.TextStyle(fontSize: 10.5, color: _darkGrey, fontStyle: pw.FontStyle.italic),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Text(
          PdfTextSanitizer.clean(contactParts.join('   |   ')),
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 8.5, color: _midGrey),
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _divider, thickness: 1),
      ],
    );
  }

  // ── SECTION HEADER ───────────────────────────────────────────────────

  pw.Widget _sectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6, bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _black,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Divider(color: _divider, thickness: 0.7),
          pw.SizedBox(height: 3),
        ],
      ),
    );
  }

  // ── VECTOR BULLET DOT ────────────────────────────────────────────────
  // Drawn as a shape, not a font glyph — avoids "tofu box" rendering
  // issues some PDF fonts have with the • (\u2022) character.

  pw.Widget _bulletDot({double size = 3, PdfColor color = _darkGrey, double topOffset = 3.5}) {
    return pw.Container(
      width: size,
      height: size,
      margin: pw.EdgeInsets.only(top: topOffset, right: 6),
      decoration: pw.BoxDecoration(
        color: color,
        shape: pw.BoxShape.circle,
      ),
    );
  }

  // ── SKILLS AS CATEGORIZED RUNNING TEXT ──────────────────────────────

  pw.Widget _skillsRunningText(List<Skill> skills) {
    final rows = <pw.Widget>[];
    groupSkillsByCategory(skills).forEach((category, items) {
      final names = items.map((s) => s.name).join(', ');
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2.5),
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$category: ',
                  style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _black),
                ),
                pw.TextSpan(
                  text: PdfTextSanitizer.clean(names),
                  style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows);
  }

  // ── EXPERIENCE ───────────────────────────────────────────────────────

  pw.Widget _experienceBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(exp.company),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black),
              ),
              pw.Text(
                _formatDateRange(exp.startDate, exp.endDate, exp.isCurrent),
                style: const pw.TextStyle(fontSize: 9, color: _midGrey),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean(exp.role),
            style: pw.TextStyle(fontSize: 9.5, color: _darkGrey, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 2),
          ...bullets.map((line) => _bulletLine(line)),
        ],
      ),
    );
  }

  // ── PROJECTS ─────────────────────────────────────────────────────────

  pw.Widget _projectBlock(Project proj) {
    final bullets = proj.description.isNotEmpty
        ? proj.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            PdfTextSanitizer.clean(proj.name),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black),
          ),
          if (proj.techStack.isNotEmpty)
            pw.Text(
              PdfTextSanitizer.clean(proj.techStack.join(', ')),
              style: pw.TextStyle(fontSize: 9, color: _darkGrey, fontStyle: pw.FontStyle.italic),
            ),
          pw.SizedBox(height: 2),
          ...bullets.map((line) => _bulletLine(line)),
        ],
      ),
    );
  }

  // ── EDUCATION ────────────────────────────────────────────────────────

  pw.Widget _educationBlock(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                PdfTextSanitizer.clean(edu.institution),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _black),
              ),
              pw.Text(
                edu.endDate != null ? '${edu.endDate!.year}' : '',
                style: const pw.TextStyle(fontSize: 9, color: _midGrey),
              ),
            ],
          ),
          pw.Text(
            PdfTextSanitizer.clean('${edu.degree} in ${edu.field}'),
            style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey),
          ),
          if (edu.gpa != null)
            pw.Text('CGPA: ${edu.gpa}', style: const pw.TextStyle(fontSize: 9, color: _midGrey)),
        ],
      ),
    );
  }

  // ── HONORS ───────────────────────────────────────────────────────────

  pw.Widget _honorBlock(Honor honor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _bulletDot(size: 3.2, topOffset: 3.2),
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
              child: pw.Text('View Certificate', style: const pw.TextStyle(fontSize: 8.5, color: _link)),
            ),
        ],
      ),
    );
  }

  // ── SHARED BULLET LINE ───────────────────────────────────────────────

  pw.Widget _bulletLine(String line) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8, bottom: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _bulletDot(),
          pw.Expanded(
            child: pw.Text(
              PdfTextSanitizer.bullet(line),
              style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.1, color: _darkGrey),
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