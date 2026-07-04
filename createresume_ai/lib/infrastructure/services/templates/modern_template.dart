// File: lib/infrastructure/services/templates/modern_template.dart
// Style: Inspired by Image 2 — Skills prominently at top, bold company names,
//        certificate-style links, structured sections, clean black/white

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/entities/work_experience.dart';
import '../../../domain/entities/education.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/project.dart';
import 'resume_template_base.dart';

class ModernTemplate implements ResumeTemplateBase {
  static const PdfColor _black    = PdfColor.fromInt(0xFF0A0A0A);
  static const PdfColor _darkGrey = PdfColor.fromInt(0xFF2C2C2C);
  static const PdfColor _midGrey  = PdfColor.fromInt(0xFF555555);
  static const PdfColor _accent   = PdfColor.fromInt(0xFF1A56A0); // blue links

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 36),
        build: (context) => [

          // ── HEADER ─────────────────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                resume.fullName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _black,
                  letterSpacing: 0.8,
                ),
              ),
              if (resume.jobTitle != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  resume.jobTitle!,
                  style: const pw.TextStyle(fontSize: 11, color: _midGrey),
                ),
              ],
              pw.SizedBox(height: 6),
              // Contact row with icons inline
              pw.Wrap(
                spacing: 16,
                children: [
                  _contactItem('📞', resume.phone ?? ''),
                  _contactItem('✉', resume.email),
                  if (resume.location != null)
                    _contactItem('📍', resume.location!),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: _black, thickness: 1.0),
            ],
          ),

          // ── SUMMARY ────────────────────────────────────────────────────
          if (resume.summary != null) ...[
            _sectionTitle('Summary'),
            pw.Text(
              resume.summary!,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.6, color: _darkGrey),
            ),
            pw.SizedBox(height: 8),
          ],

          // ── SKILLS (prominent, at top like Image 2) ────────────────────
          if (resume.skills.isNotEmpty) ...[
            _sectionTitle('Skills'),
            _skillsBlock(resume.skills),
            pw.SizedBox(height: 8),
          ],

          // ── EXPERIENCE ─────────────────────────────────────────────────
          if (resume.workExperiences.isNotEmpty) ...[
            _sectionTitle('Experience'),
            ...resume.workExperiences.map((e) => _expBlock(e)),
          ],

          // ── PROJECTS ───────────────────────────────────────────────────
          if (resume.projects.isNotEmpty) ...[
            _sectionTitle('Projects'),
            ...resume.projects.map((p) => _projectBlock(p)),
          ],

          // ── EDUCATION ──────────────────────────────────────────────────
          if (resume.educations.isNotEmpty) ...[
            _sectionTitle('Education'),
            ...resume.educations.map((e) => _eduBlock(e)),
          ],
        ],
      ),
    );

    return doc;
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _black,
            ),
          ),
          pw.Container(height: 0.8, color: _black),
          pw.SizedBox(height: 4),
        ],
      ),
    );
  }

  pw.Widget _contactItem(String icon, String text) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(icon, style: const pw.TextStyle(fontSize: 8.5)),
        pw.SizedBox(width: 3),
        pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: _darkGrey)),
      ],
    );
  }

  pw.Widget _skillsBlock(List<Skill> skills) {
    // Group by category/level like Image 2
    final expert = skills.where((s) => s.level == 'expert').toList();
    final intermediate = skills.where((s) => s.level == 'intermediate').toList();
    final beginner = skills.where((s) => s.level == 'beginner').toList();
    final all = [...expert, ...intermediate, ...beginner];

    // Display as labeled rows
    final rows = <pw.Widget>[];

    void addRow(String label, List<Skill> list) {
      if (list.isEmpty) return;
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9.5,
                    color: _black,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  list.map((s) => s.name).join(', '),
                  style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey, lineSpacing: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (expert.isNotEmpty || intermediate.isNotEmpty || beginner.isNotEmpty) {
      if (expert.isNotEmpty) addRow('Expert:', expert);
      if (intermediate.isNotEmpty) addRow('Intermediate:', intermediate);
      if (beginner.isNotEmpty) addRow('Familiar:', beginner);
    } else {
      // No levels — just show all as comma-separated
      rows.add(pw.Text(
        skills.map((s) => s.name).join(' • '),
        style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey, lineSpacing: 1.5),
      ));
    }

    return pw.Column(children: rows);
  }

  pw.Widget _expBlock(WorkExperience exp) {
    final bullets = exp.description.isNotEmpty
        ? exp.description.split('\n').where((l) => l.trim().isNotEmpty).toList()
        : <String>[];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Company + dates
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.company,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
              ),
              pw.Text(
                _dateRange(exp.startDate, exp.endDate, exp.isCurrent),
                style: const pw.TextStyle(fontSize: 9.5, color: _midGrey),
              ),
            ],
          ),
          // Role + location
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.role,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkGrey,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              if (exp.description != null && exp.description!.contains('View Certificate'))
                pw.Text(
                  'View Certificate',
                  style: const pw.TextStyle(fontSize: 8.5, color: _accent),
                ),
            ],
          ),
          pw.SizedBox(height: 4),
          // Tech tags if in description
          ...bullets.where((b) => b.trim().isNotEmpty).map(
            (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('•  ', style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey)),
                  pw.Expanded(
                    child: pw.Text(
                      line.replaceAll(RegExp(r'^[•\-\*]\s*'), ''),
                      style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.45, color: _darkGrey),
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

  pw.Widget _projectBlock(Project proj) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                proj.name,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
              ),
              if (proj.url != null && proj.url!.isNotEmpty)
                pw.Text('GitHub', style: const pw.TextStyle(fontSize: 9, color: _accent)),
            ],
          ),
          if (proj.techStack.isNotEmpty)
            pw.Text(
              proj.techStack.join(', '),
              style: pw.TextStyle(fontSize: 9.5, color: _midGrey, fontStyle: pw.FontStyle.italic),
            ),
          if (proj.description.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            ...proj.description
                .split('\n')
                .where((l) => l.trim().isNotEmpty)
                .map((line) => pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('•  ', style: const pw.TextStyle(fontSize: 9.5)),
                          pw.Expanded(
                            child: pw.Text(
                              line.replaceAll(RegExp(r'^[•\-\*]\s*'), ''),
                              style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 1.4, color: _darkGrey),
                            ),
                          ),
                        ],
                      ),
                    )),
          ],
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
              pw.Text(
                edu.institution,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: _black),
              ),
              pw.Text(
                '${edu.degree} in ${edu.field}',
                style: const pw.TextStyle(fontSize: 9.5, color: _darkGrey),
              ),
              if (edu.gpa != null)
                pw.Text('CGPA: ${edu.gpa}', style: const pw.TextStyle(fontSize: 9, color: _midGrey)),
            ],
          ),
          pw.Text(
            edu.endDate != null
                ? '${_monthName(edu.startDate.month)} ${edu.startDate.year} – ${_monthName(edu.endDate!.month)} ${edu.endDate!.year}'
                : '',
            style: const pw.TextStyle(fontSize: 9, color: _midGrey),
          ),
        ],
      ),
    );
  }

  String _dateRange(DateTime start, DateTime? end, bool isCurrent) {
    final startStr = '${_monthName(start.month)} ${start.year}';
    final endStr = isCurrent ? 'Present' : (end != null ? '${_monthName(end.month)} ${end.year}' : '');
    return '$startStr – $endStr';
  }

  String _monthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}
