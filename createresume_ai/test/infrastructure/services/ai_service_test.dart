import 'package:createresume_app/core/errors/failures.dart';
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
    when(() => functions.invoke(any(), body: any(named: 'body'), headers: any(named: 'headers')))
        .thenAnswer((_) async => FunctionResponse(data: data, status: 200));
  }

  Map<String, dynamic> lastCall() {
    final captured = verify(
      () => functions.invoke(captureAny(), body: captureAny(named: 'body'), headers: any(named: 'headers')),
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

  group('server-side credits', () {
    void failWith(int status, Map<String, dynamic> body) {
      when(() => functions.invoke(any(), body: any(named: 'body'), headers: any(named: 'headers')))
          .thenThrow(FunctionException(status: status, details: body));
    }

    List<Map<String, String>> sentHeaders() => verify(
          () => functions.invoke(any(), body: any(named: 'body'), headers: captureAny(named: 'headers')),
        ).captured.cast<Map<String, String>>();

    test('402 becomes InsufficientCreditsFailure and is not retried', () async {
      failWith(402, {'error': 'insufficient_credits', 'required': 2, 'available': 1});
      final result = await service.generateResumeFromDescription(
        description: 'd', careerStage: 's', jobTitle: 't', userId: 'u1');
      expect(
        result.fold((f) => f, (_) => null),
        const InsufficientCreditsFailure(requested: 2, available: 1),
      );
      expect(sentHeaders(), hasLength(1));
    });

    test('401 becomes an auth failure and is not retried', () async {
      failWith(401, {'error': 'unauthorized'});
      final result = await service.rewriteBullet('x');
      expect(result.fold((f) => f, (_) => null), isA<AuthFailure>());
      expect(sentHeaders(), hasLength(1));
    });

    test('5xx is retried once (AI calls) with the same Idempotency-Key', () async {
      failWith(502, {'error': 'all models down'});
      final result = await service.rewriteBullet('x');
      expect(result.isLeft(), isTrue);
      final headers = sentHeaders();
      expect(headers, hasLength(2));
      final keys = headers.map((h) => h['Idempotency-Key']).toSet();
      expect(keys, hasLength(1));
      expect(keys.single, matches(RegExp(r'^[0-9a-f-]{36}$')));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('each user action gets a new key; userId is not sent', () async {
      answerWith({'success': true, 'resume': {'summary': 's'}});
      await service.generateResumeFromDescription(
        description: 'd', careerStage: 's', jobTitle: 't', userId: 'u1');
      await service.rewriteBullet('x');
      final captured = verify(
        () => functions.invoke(any(), body: captureAny(named: 'body'), headers: captureAny(named: 'headers')),
      ).captured;
      final bodies = [captured[0], captured[2]].cast<Map<String, dynamic>>();
      final keys = [captured[1], captured[3]].cast<Map<String, String>>().map((h) => h['Idempotency-Key']);
      expect(bodies.first.containsKey('userId'), isFalse);
      expect(keys.toSet(), hasLength(2));
    });
  });
}
