import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;
import 'package:uuid/uuid.dart';

import '../../core/errors/exceptions.dart';
import 'supabase_database_service.dart';

/// The one place that calls Supabase Edge Functions (brief E6).
///
/// - One Idempotency-Key per call, reused on retries, so a retry after a
///   timeout is answered from the server's stored result, not charged twice.
/// - Retries only timeouts, network errors, 5xx and 409 (same key still in
///   flight), with a fixed back-off.
/// - 402 becomes [InsufficientCreditsException]; other 4xx are thrown as
///   [ServerException] with the status code, without retrying.
class EdgeFunctionClient {
  final SupabaseDatabaseService _db;
  final Duration backoff;

  const EdgeFunctionClient(this._db, {this.backoff = const Duration(seconds: 2)});

  /// AI calls: generation can take a while, but at most one retry.
  static const aiTimeout = Duration(seconds: 45);
  static const aiMaxRetries = 1;

  /// Returns the response body (decoded JSON or a string).
  Future<dynamic> invoke(
    String functionName,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    int maxRetries = 2,
  }) async {
    final idempotencyKey = const Uuid().v4();
    final attempts = maxRetries + 1;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      final isLastAttempt = attempt == attempts;
      try {
        final response = await _db.functions
            .invoke(
              functionName,
              body: body,
              headers: {'Idempotency-Key': idempotencyKey},
            )
            .timeout(timeout);
        return response.data;
      } on FunctionException catch (e) {
        final details = detailsMap(e.details);
        if (e.status == 402) {
          throw InsufficientCreditsException(
            requested: (details['required'] as num?)?.toInt() ?? 0,
            available: (details['available'] as num?)?.toInt() ?? 0,
          );
        }
        final message =
            'Edge Function "$functionName" failed: ${details['error'] ?? 'status ${e.status}'}';
        final retryable = e.status >= 500 || e.status == 409;
        if (!retryable || isLastAttempt) {
          throw ServerException(message, e.status);
        }
      } catch (e) {
        if (e is ServerException || e is InsufficientCreditsException) rethrow;
        // Timeout or network error.
        if (isLastAttempt) {
          throw ServerException(
            'Edge Function "$functionName" failed after $attempts attempts: $e',
          );
        }
      }
      await Future<void>.delayed(backoff);
    }

    throw const ServerException('Unexpected retry loop exit');
  }

  /// Error body of a failed function call as a map (empty if unreadable).
  static Map<String, dynamic> detailsMap(dynamic details) {
    try {
      if (details is Map<String, dynamic>) return details;
      if (details is String) return jsonDecode(details) as Map<String, dynamic>;
    } catch (_) {}
    return const {};
  }
}
