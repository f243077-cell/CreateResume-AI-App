import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/resume.dart';
import '../../domain/services/i_pdf_generator_service.dart';
import 'supabase_database_service.dart';

/// Calls the `export-pdf` Supabase Edge Function to generate a PDF
/// and returns the resulting URL string.
///
/// Uses the same 10 s timeout + exponential backoff retry pattern as [AiService].
class PdfGeneratorService implements IPDFGeneratorService {
  final SupabaseDatabaseService _db;

  const PdfGeneratorService(this._db);

  @override
  Future<Either<Failure, String>> generatePdf(Resume resume) async {
    try {
      final response = await _invokeWithRetry(body: {'resume_id': resume.id});

      final data = jsonDecode(response) as Map<String, dynamic>;
      final url = data['url'] as String;
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ── Retry helper (same pattern as AiService) ─────────────────────

  Future<String> _invokeWithRetry({required Map<String, dynamic> body}) async {
    const functionName = 'export-pdf';
    const maxAttempts = 3;
    const backoffDelays = [Duration(seconds: 1), Duration(seconds: 2)];

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await _db.functions
            .invoke(functionName, body: body)
            .timeout(const Duration(seconds: 10));

        if (response.status != 200) {
          throw ServerException(
            'Edge Function "$functionName" returned ${response.status}',
            response.status,
          );
        }

        return response.data as String;
      } catch (e) {
        final isLastAttempt = attempt == maxAttempts - 1;
        if (isLastAttempt) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Edge Function "$functionName" failed after $maxAttempts attempts: $e',
          );
        }
        await Future<void>.delayed(backoffDelays[attempt]);
      }
    }

    throw const ServerException('Unexpected retry loop exit');
  }
}
