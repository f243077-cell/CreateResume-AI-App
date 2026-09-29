import 'package:createresume_app/infrastructure/services/ai_service.dart';
import 'package:createresume_app/infrastructure/services/supabase_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDb extends Mock implements SupabaseDatabaseService {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockFunctionsClient functions;
  late AiService service;

  setUp(() {
    functions = MockFunctionsClient();
    final db = MockDb();
    when(() => db.functions).thenReturn(functions);
    service = AiService(db);
  });

  /// Answers every Edge Function call with [data].
  void answerWith(Map<String, dynamic> data) {
    when(() => functions.invoke(any(), body: any(named: 'body')))
        .thenAnswer((_) async => FunctionResponse(data: data, status: 200));
  }

  Map<String, dynamic> lastCall() {
    final captured = verify(
      () => functions.invoke(captureAny(), body: captureAny(named: 'body')),
    ).captured;
    expect(captured[captured.length - 2], 'ai-tools',
        reason: 'only deployed functions may be called');
    return captured.last as Map<String, dynamic>;
  }

  test('improveSection uses ai-tools improve_text', () async {
    answerWith({'success': true, 'result': ' Better text '});
    final result = await service.improveSection('text');
    expect(result.getOrElse(() => ''), 'Better text');
    expect(lastCall(), {'action': 'improve_text', 'text': 'text'});
  });

  test('rewriteBullet uses ai-tools rewrite_bullet', () async {
    answerWith({'success': true, 'result': 'Led X'});
    await service.rewriteBullet('did x');
    expect(lastCall(), {'action': 'rewrite_bullet', 'text': 'did x'});
  });

  test('generateCoverLetter sends company, job title and background', () async {
    answerWith({'success': true, 'result': 'Dear Acme'});
    final result = await service.generateCoverLetter(
      resumeSummary: 'Mobile dev',
      companyName: 'Acme',
      jobTitle: 'Engineer',
    );
    expect(result.getOrElse(() => ''), 'Dear Acme');
    expect(lastCall(), {
      'action': 'cover_letter',
      'resumeSummary': 'Mobile dev',
      'companyName': 'Acme',
      'jobTitle': 'Engineer',
    });
  });

  test('analyzeSkillGap sends skills and the job description', () async {
    answerWith({'success': true, 'result': 'Missing: Kotlin'});
    await service.analyzeSkillGap(skills: 'Dart', jobDescription: 'Kotlin role');
    expect(lastCall(), {
      'action': 'skill_gap',
      'skills': 'Dart',
      'jobDescription': 'Kotlin role',
    });
  });

  test('an error body becomes a failure, never canned text', () async {
    answerWith({'success': false, 'error': 'text is required'});
    final result = await service.rewriteBullet('');
    expect(result.fold((f) => f.message, (_) => null), 'text is required');
  });
}
