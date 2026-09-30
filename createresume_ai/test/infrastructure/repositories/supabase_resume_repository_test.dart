import 'package:createresume_app/domain/entities/honor.dart';
import 'package:createresume_app/domain/entities/project.dart';
import 'package:createresume_app/domain/entities/resume.dart';
import 'package:createresume_app/domain/entities/skill.dart';
import 'package:createresume_app/domain/entities/work_experience.dart';
import 'package:createresume_app/infrastructure/repositories/supabase_resume_repository.dart';
import 'package:createresume_app/infrastructure/services/supabase_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDb extends Mock implements SupabaseDatabaseService {}

void main() {
  final resume = Resume(
    id: 'r1',
    userId: 'u1',
    title: 'Engineer',
    templateId: 'classic_style1',
    summary: 'S',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    workExperiences: [
      WorkExperience(
        id: 'w1',
        resumeId: '', // freshly generated children have no resume id yet
        company: 'Nexa',
        role: 'Dev',
        startDate: DateTime(2022, 3),
        isCurrent: true,
        description: 'Built X',
        orderIndex: 0,
      ),
    ],
    skills: const [Skill(id: 's1', resumeId: '', name: 'Dart', category: 'Languages')],
    projects: const [
      Project(id: 'p1', resumeId: '', name: 'App', description: 'd', techStack: ['Flutter']),
    ],
    honors: const [Honor(id: 'h1', resumeId: '', title: 'Award', certificateUrl: 'https://x.test')],
  );

  test('save payload uses column names and omits server-owned keys', () {
    final payload = SupabaseResumeRepository.toSavePayload(resume);

    expect(payload['id'], 'r1');
    expect(payload['template_id'], 'classic_style1');
    expect(payload.containsKey('user_id'), isFalse, reason: 'owner is auth.uid()');
    final exp = (payload['work_experiences'] as List).single as Map<String, dynamic>;
    expect(exp.containsKey('resume_id'), isFalse);
    expect(exp['start_date'], '2022-03-01T00:00:00.000');
    expect(exp['end_date'], isNull);
    expect(exp['is_current'], isTrue);
    expect((payload['skills'] as List).single, containsPair('category', 'Languages'));
    expect((payload['projects'] as List).single, containsPair('tech_stack', ['Flutter']));
    expect((payload['honors'] as List).single, containsPair('certificate_url', 'https://x.test'));
    expect(payload['educations'], isEmpty);
  });

  test('update is one save_resume call, no per-table requests', () async {
    final db = MockDb();
    when(() => db.rpc('save_resume', params: any(named: 'params'))).thenAnswer((_) async => 'r1');

    final result = await SupabaseResumeRepository(db).updateResume(resume);

    expect(result.isRight(), isTrue);
    final params = verify(() => db.rpc('save_resume', params: captureAny(named: 'params')))
        .captured
        .single as Map<String, dynamic>;
    expect(params['p_resume'], SupabaseResumeRepository.toSavePayload(resume));
    verifyNever(() => db.from(any()));
  });

  test('a failed save is reported, not swallowed', () async {
    final db = MockDb();
    when(() => db.rpc('save_resume', params: any(named: 'params')))
        .thenThrow(Exception('null value in column "company"'));

    final result = await SupabaseResumeRepository(db).updateResume(resume);

    expect(result.isLeft(), isTrue);
  });

  test('a resume round-trips through the save payload and the row mappers', () {
    // Build the rows the database would return for the saved payload: the
    // resume row gains user_id and timestamps, children gain resume_id, and
    // date columns come back as yyyy-mm-dd.
    final payload = SupabaseResumeRepository.toSavePayload(resume);
    String? day(Object? iso) => iso == null ? null : (iso as String).substring(0, 10);
    List<Map<String, dynamic>> children(String key, {bool dates = false}) => [
          for (final c in payload[key] as List)
            {
              ...c as Map<String, dynamic>,
              'resume_id': resume.id,
              if (dates) 'start_date': day(c['start_date']),
              if (dates) 'end_date': day(c['end_date']),
            },
        ];
    final row = <String, dynamic>{
      ...payload,
      'user_id': resume.userId,
      'created_at': resume.createdAt.toIso8601String(),
      'updated_at': resume.updatedAt.toIso8601String(),
      'work_experiences': children('work_experiences', dates: true),
      'educations': children('educations', dates: true),
      'skills': children('skills'),
      'projects': children('projects'),
      'honors': children('honors'),
    };

    final back = SupabaseResumeRepository.fromRow(row);

    // Children come back with the real resume id.
    final expected = resume.copyWith(
      workExperiences: [for (final w in resume.workExperiences) w.copyWith(resumeId: 'r1')],
      skills: [for (final x in resume.skills) x.copyWith(resumeId: 'r1')],
      projects: [for (final x in resume.projects) x.copyWith(resumeId: 'r1')],
      honors: [for (final x in resume.honors) x.copyWith(resumeId: 'r1')],
    );
    expect(back, expected);
    expect(back.skills.single.category, 'Languages');
    expect(back.honors.single.certificateUrl, 'https://x.test');
    expect(back.workExperiences.single.endDate, isNull);
  });
}
