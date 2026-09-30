import 'dart:async';

import 'package:createresume_app/core/errors/exceptions.dart';
import 'package:createresume_app/infrastructure/services/edge_function_client.dart';
import 'package:createresume_app/infrastructure/services/supabase_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDb extends Mock implements SupabaseDatabaseService {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockFunctionsClient functions;
  late EdgeFunctionClient client;
  late List<Map<String, String>> headersSent;

  setUp(() {
    functions = MockFunctionsClient();
    final db = MockDb();
    when(() => db.functions).thenReturn(functions);
    client = EdgeFunctionClient(db, backoff: Duration.zero);
    headersSent = [];
  });

  /// Answers each attempt in turn with [outcomes] (a status code to throw,
  /// 'hang' to never answer, or a response body).
  void respond(List<Object> outcomes) {
    var call = 0;
    when(() => functions.invoke(any(), body: any(named: 'body'), headers: any(named: 'headers')))
        .thenAnswer((inv) {
      headersSent.add(inv.namedArguments[#headers] as Map<String, String>);
      final outcome = outcomes[call++];
      if (outcome == 'hang') return Completer<FunctionResponse>().future;
      if (outcome is int) throw FunctionException(status: outcome, details: {'error': 'e$outcome'});
      return Future.value(FunctionResponse(data: outcome, status: 200));
    });
  }

  test('a timeout is retried, then succeeds with the same key', () async {
    respond(['hang', {'ok': true}]);
    final data = await client.invoke('f', {}, timeout: const Duration(milliseconds: 50), maxRetries: 1);
    expect(data, {'ok': true});
    expect(headersSent, hasLength(2));
    expect(headersSent.map((h) => h['Idempotency-Key']).toSet(), hasLength(1));
  });

  test('409 (same key in flight) is retried', () async {
    respond([409, {'ok': true}]);
    expect(await client.invoke('f', {}), {'ok': true});
    expect(headersSent, hasLength(2));
  });

  test('400 and 402 are not retried', () async {
    respond([400]);
    await expectLater(
      client.invoke('f', {}),
      throwsA(isA<ServerException>().having((e) => e.statusCode, 'status', 400)),
    );
    expect(headersSent, hasLength(1));

    headersSent.clear();
    respond([402]);
    await expectLater(client.invoke('f', {}), throwsA(isA<InsufficientCreditsException>()));
    expect(headersSent, hasLength(1));
  });

  test('gives up after maxRetries + 1 attempts', () async {
    respond([500, 500, 500, 500]);
    await expectLater(
      client.invoke('f', {}, maxRetries: 2),
      throwsA(isA<ServerException>().having((e) => e.statusCode, 'status', 500)),
    );
    expect(headersSent, hasLength(3));
  });

  test('AI calls use a 45 s timeout and at most one retry', () {
    expect(EdgeFunctionClient.aiTimeout, const Duration(seconds: 45));
    expect(EdgeFunctionClient.aiMaxRetries, 1);
  });

  test('resume generation waits longer than the server model budget', () {
    // dynamic-api gives the models ~125 s in total.
    expect(EdgeFunctionClient.generationTimeout, greaterThan(const Duration(seconds: 125)));
  });
}
