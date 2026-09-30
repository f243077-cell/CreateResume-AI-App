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
}
