import 'package:createresume_app/core/constants/template_ids.dart';
import 'package:createresume_app/domain/entities/education.dart';
import 'package:createresume_app/domain/entities/honor.dart';
import 'package:createresume_app/domain/entities/project.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/skill.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/entities/work_experience.dart';
import 'package:createresume_app/infrastructure/services/local_pdf_generator_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = User(
    id: 'u1',
    email: 'jose.munoz@mail.test',
    fullName: 'José Muñoz',
    jobTitle: 'Senior “Platform” Engineer',
    phone: '+1 555 0100',
    location: 'Zürich, CH',
    linkedin: 'linkedin.com/in/jose',
    github: 'github.com/jose',
    leetcode: 'leetcode.com/jose',
  );

  final now = DateTime(2024, 1, 1);

  // Enough content to run past one page so pagination is exercised.
  final resume = Resume(
    id: 'r1',
    userId: 'u1',
    title: 'Platform Engineer',
    summary: 'Engineer who ships — fast… with “quality” 🚀 and café-grade care. ' * 4,
    createdAt: now,
    updatedAt: now,
    workExperiences: List.generate(
      6,
      (i) => WorkExperience(
        id: 'w$i',
        resumeId: 'r1',
        company: 'Company $i – Ltd',
        role: 'Engineer $i',
        startDate: DateTime(2015 + i, 3),
        endDate: i == 5 ? null : DateTime(2016 + i, 6),
        isCurrent: i == 5,
        description: List.generate(
          5,
          (b) => '• Improved throughput by ${b + 10}% using Go, Kafka & “smart” caching ✅',
        ).join('\n'),
        orderIndex: 5 - i,
      ),
    ),
    educations: [
      Education(
        id: 'e1',
        resumeId: 'r1',
        institution: 'École Polytechnique',
        degree: 'BSc',
        field: 'Computer Science',
        startDate: DateTime(2011, 9),
        endDate: DateTime(2015, 6),
        gpa: 3.8,
      ),
    ],
    skills: const [
      Skill(id: 's1', resumeId: 'r1', name: 'Dart', category: 'Languages'),
      Skill(id: 's2', resumeId: 'r1', name: 'C++', category: 'Languages'),
      Skill(id: 's3', resumeId: 'r1', name: 'Flutter', category: 'Frameworks'),
      Skill(id: 's4', resumeId: 'r1', name: 'Leadership'),
      Skill(id: 's5', resumeId: 'r1', name: 'Docker', category: ''),
    ],
    projects: const [
      Project(
        id: 'p1',
        resumeId: 'r1',
        name: 'Résumé Builder',
        description: 'Cross-platform app — 10k users',
        techStack: ['Flutter', 'Supabase'],
        url: 'https://github.com/jose/resume',
      ),
    ],
    honors: const [
      Honor(
        id: 'h1',
        resumeId: 'r1',
        title: 'Dean’s List',
        description: 'Top 5% — 3 semesters',
        certificateUrl: 'https://example.org/cert',
      ),
      Honor(id: 'h2', resumeId: 'r1', title: 'Hackathon Winner'),
    ],
  );

  group('LocalPdfGeneratorService', () {
    for (final templateId in TemplateIds.all) {
      test('$templateId renders fully populated data', () async {
        final bytes = await LocalPdfGeneratorService().generatePdf(
          resume: resume,
          user: user,
          templateId: templateId,
        );
        expect(bytes, isNotEmpty);
      });
    }

    test('renders minimal data without optional fields', () async {
      final bytes = await LocalPdfGeneratorService().generatePdf(
        resume: Resume(
          id: 'r2',
          userId: 'u1',
          title: '',
          summary: '   ',
          createdAt: now,
          updatedAt: now,
        ),
        user: const User(id: 'u1', email: 'a@b.test', fullName: 'A', phone: ''),
        templateId: TemplateIds.modern,
      );
      expect(bytes, isNotEmpty);
    });

    test('unknown template ID falls back instead of throwing', () async {
      final bytes = await LocalPdfGeneratorService().generatePdf(
        resume: resume,
        user: user,
        templateId: 'does_not_exist',
      );
      expect(bytes, isNotEmpty);
    });
  });
}
