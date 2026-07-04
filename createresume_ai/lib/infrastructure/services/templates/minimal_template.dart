import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_template_base.dart';

class MinimalTemplate implements ResumeTemplateBase {
  static const PdfColor _black = PdfColor.fromInt(0xFF111111);
  static const PdfColor _gold = PdfColor.fromInt(0xFFD4A92E);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFF999999);

  @override
  Future<pw.Document> generate(ResumeData resume) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(
          horizontal: 52,
          vertical: 44,
        ),
        build: (context) => [
          // ── HEADER ──────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                resume.fullName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: _black,
                  letterSpacing: 3,
                ),
              ),
              if (resume.jobTitle != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  resume.jobTitle!,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: _lightGrey,
                  ),
                ),
              ],
              pw.SizedBox(height: 10),

              // Contact row — centered with dots
              pw.Text(
                _buildContactLine(resume),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 9.5,
                  color: _lightGrey,
                ),
              ),

              pw.SizedBox(height: 14),
              // Gold thin separator line
              pw.Container(height: 1.5, color: _gold),
              pw.SizedBox(height: 20),
            ],
          ),

          // ── SUMMARY ───────────────────────────────────────
          if (resume.summary != null) ...[
            _sectionTitle('Summary'),
            pw.Text(
              resume.summary!,
              style: const pw.TextStyle(
                fontSize: 10.5,
                lineSpacing: 1.6,
                color: _black,
              ),
            ),
            pw.SizedBox(height: 20),
            _thinDivider(),
          ],

          // ── WORK EXPERIENCE ───────────────────────────────
          if (resume.workExperiences.isNotEmpty) ...[
            _sectionTitle('Experience'),
            ...resume.workExperiences.map((exp) => _expItem(exp)),
            _thinDivider(),
          ],

          // ── EDUCATION ─────────────────────────────────────
          if (resume.educations.isNotEmpty) ...[
            _sectionTitle('Education'),
            ...resume.educations.map((edu) => _eduItem(edu)),
            _thinDivider(),
          ],

          // ── SKILLS ────────────────────────────────────────
          if (resume.skills.isNotEmpty) ...[
            _sectionTitle('Skills'),
            pw.Text(
              resume.skills.map((s) => s.name).join('   ·   '),
              style: const pw.TextStyle(
                fontSize: 10,
                color: _black,
                lineSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 20),
            _thinDivider(),
          ],

          // ── PROJECTS ──────────────────────────────────────
          if (resume.projects.isNotEmpty) ...[
            _sectionTitle('Projects'),
            ...resume.projects.map((proj) => _projItem(proj)),
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
    return parts.join('   ·   ');
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _lightGrey,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  pw.Widget _thinDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 14),
      child: pw.Container(height: 0.5, color: _lightGrey),
    );
  }

  pw.Widget _expItem(dynamic exp) {
    final startDate = _formatDate(exp.startDate);
    final endDate = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);
    final description = exp.description;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.role,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                  color: _black,
                ),
              ),
              pw.Text(
                '$startDate – $endDate',
                style: const pw.TextStyle(
                    fontSize: 9.5, color: _lightGrey),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            exp.company,
            style: const pw.TextStyle(
              fontSize: 10,
              color: _lightGrey,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              description,
              style: const pw.TextStyle(
                fontSize: 10,
                lineSpacing: 1.5,
                color: _black,
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
    final endDate = _formatDate(edu.endDate);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                field != null ? '$degree · $field' : degree,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10.5,
                  color: _black,
                ),
              ),
              pw.Text(
                edu.institution,
                style: const pw.TextStyle(
                    fontSize: 10, color: _lightGrey),
              ),
            ],
          ),
          pw.Text(
            endDate,
            style: const pw.TextStyle(
                fontSize: 9.5, color: _lightGrey),
          ),
        ],
      ),
    );
  }

  pw.Widget _projItem(dynamic proj) {
    final description = proj.description;
    final techStack = proj.techStack as List<dynamic>? ?? [];
    final url = proj.url;

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
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10.5,
                  color: _black,
                ),
              ),
              if (url != null)
                pw.Text(
                  url,
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: _gold,
                  ),
                ),
            ],
          ),
          if (description != null && description.isNotEmpty)
            pw.Text(
              description,
              style: const pw.TextStyle(
                  fontSize: 10, color: _black, lineSpacing: 1.4),
            ),
          if (techStack.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              techStack.join(' · '),
              style: const pw.TextStyle(
                  fontSize: 9, color: _lightGrey),
            ),
          ],
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
