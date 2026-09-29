import 'package:createresume_app/domain/entities/education.dart';
import 'package:createresume_app/domain/entities/honor.dart';
import 'package:createresume_app/domain/entities/project.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/skill.dart';
import 'package:createresume_app/domain/entities/user.dart';
import 'package:createresume_app/domain/entities/work_experience.dart';
import 'package:createresume_app/infrastructure/services/local_ats_scoring_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scorer = LocalAtsScoringService();
  const profile = User(id: 'u', email: 'a@b.test', fullName: 'A', phone: '+1 555 0100');

  // Hand-computed fixture:
  // completeness 5/5 -> 20; bullets: one perfect, one weak -> 0.5 -> 10;
  // format: 50-word summary (5) + short resume (0) + no long paragraph (2) -> 7;
  // consistency: current job, ordered, no placeholders -> 10.
  Resume fixture({String summary = '', String? description}) => Resume(
        id: 'r',
        userId: 'u',
        title: 'Mobile Engineer',
        summary: summary.isEmpty ? List.filled(50, 'builds').join(' ') : summary,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        workExperiences: [
          WorkExperience(
            id: 'w',
            resumeId: 'r',
            company: 'Nexa',
            role: 'Engineer',
            startDate: DateTime(2022, 3),
            isCurrent: true,
            description: description ??
                '• Led a team of 5 engineers to ship a Flutter app used by thousands of customers\n'
                    'responsible for bugs',
          ),
        ],
        educations: [
          Education(
            id: 'e',
            resumeId: 'r',
            institution: 'FAST',
            degree: 'BS',
            field: 'CS',
            startDate: DateTime(2017),
            endDate: DateTime(2021),
          ),
        ],
        skills: [
          for (final n in ['Dart', 'Flutter', 'Firebase', 'Git', 'REST', 'Figma'])
            Skill(id: n, resumeId: 'r', name: n),
        ],
      );

  const jd = 'Flutter developer with Kotlin. Flutter, Kotlin and Riverpod required. Riverpod, Flutter.';

  group('score', () {
    test('without a job description the keyword weight is redistributed', () {
      // (20 + 10 + 7 + 10) * 100 / 60 = 78.3
      expect(scorer.score(fixture(), profile: profile), 78);
    });

    test('with a job description keywords count for 40 points', () {
      // 20 + 25% of 40 + 10 + 7 + 10 = 57
      expect(scorer.score(fixture(), jobDescription: jd, profile: profile), 57);
    });

    test('is repeatable for the same input', () {
      final scores = List.generate(
        3,
        (_) => scorer.score(fixture(), jobDescription: jd, profile: profile),
      );
      expect(scores.toSet(), hasLength(1));
    });

    test('placeholder text lowers the score', () {
      final clean = scorer.score(fixture(), profile: profile);
      final withPlaceholder = scorer.score(
        fixture(summary: '${List.filled(49, 'builds').join(' ')} example.com'),
        profile: profile,
      );
      expect(withPlaceholder, lessThan(clean));
    });

    test('an empty resume scores low and never throws', () {
      final empty = Resume(
        id: 'r',
        userId: 'u',
        title: '',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final value = scorer.score(empty, jobDescription: jd);
      expect(value, inInclusiveRange(0, 30));
    });
  });

  group('keywordMatch', () {
    test('lists matched and missing top terms by frequency', () {
      final match = scorer.keywordMatch(
        resumeText: fixture().toPlainText(),
        jobDescription: jd,
      );
      expect(match.matchedKeywords, ['flutter']);
      expect(match.missingKeywords, ['kotlin', 'riverpod', 'developer']);
      expect(match.matchPercentage, 25);
    });

    test('keeps tech tokens like c++, c#, node.js and ci/cd', () {
      expect(
        LocalAtsScoringService.tokenize('We use C++, C#, Node.js and CI/CD.'),
        containsAll(['c++', 'c#', 'node.js', 'ci/cd']),
      );
      final match = scorer.keywordMatch(
        resumeText: 'Built services in C++ and Node.js',
        jobDescription: 'C++ C++ Node.js Node.js Go',
      );
      expect(match.matchedKeywords, containsAll(['c++', 'node.js']));
      expect(match.missingKeywords, ['go']);
    });

    test('repeated two-word phrases become keywords', () {
      final match = scorer.keywordMatch(
        resumeText: 'Experience with machine learning pipelines',
        jobDescription: 'machine learning engineer. machine learning at scale.',
      );
      expect(match.matchedKeywords, contains('machine learning'));
    });

    test('empty job description gives an empty match', () {
      final match = scorer.keywordMatch(resumeText: 'anything', jobDescription: '  ');
      expect(match.totalKeywords, 0);
      expect(match.matchPercentage, 0);
    });

    test('takes at most 30 terms', () {
      final longJd = List.generate(60, (i) => 'term$i').join(' ');
      final match = scorer.keywordMatch(resumeText: '', jobDescription: longJd);
      expect(match.totalKeywords, LocalAtsScoringService.maxKeywords);
    });
  });

  test('Resume.toPlainText includes every section', () {
    final resume = fixture().copyWith(
      projects: const [
        Project(id: 'p', resumeId: 'r', name: 'Tracker', description: 'Offline app', techStack: ['Hive']),
      ],
      honors: const [Honor(id: 'h', resumeId: 'r', title: 'Hackathon', description: '2nd place')],
    );
    final text = resume.toPlainText();
    for (final part in ['Mobile Engineer', 'builds', 'Nexa', 'Engineer', 'FAST', 'Figma', 'Tracker', 'Hive', 'Hackathon', '2nd place']) {
      expect(text, contains(part));
    }
  });
}
